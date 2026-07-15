import CryptoKit
import Foundation

struct SwiftcnLock: Codable {
    var schemaVersion = 1
    var registry: String
    var items: [String: LockedItem] = [:]

    struct LockedItem: Codable {
        var files: [LockedFile]
    }

    struct LockedFile: Codable {
        var source: String
        var target: String
        var sourceHash: String
        var installedHash: String
    }

    static func load(from url: URL, registry: String) throws -> SwiftcnLock {
        guard FileManager.default.fileExists(atPath: url.path) else {
            return SwiftcnLock(registry: registry)
        }
        do {
            return try JSONDecoder().decode(SwiftcnLock.self, from: Data(contentsOf: url))
        } catch {
            throw ConsumerConfigError.decodeFailed(url.path, error.localizedDescription)
        }
    }

    func write(to url: URL) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        do {
            var data = try encoder.encode(self)
            data.append(0x0A)
            try data.write(to: url, options: .atomic)
        } catch {
            throw ConsumerConfigError.writeFailed(url.path, error.localizedDescription)
        }
    }
}

struct PreparedRegistryFile {
    let itemName: String
    let sourcePath: String
    let targetPath: String
    let destination: URL
    let data: Data

    var sourceHash: String { sha256(data) }
}

struct MaterializationOptions {
    let targetRoot: URL
    let includePreviews: Bool
    let fileLayout: ConsumerConfig.FileLayout
    let formatSwift: Bool
    let projectRoot: URL
}

func preparedFiles(
    for items: [RegistryItem],
    from client: RegistryClient,
    options: MaterializationOptions
) async throws -> [PreparedRegistryFile] {
    var prepared: [PreparedRegistryFile] = []
    var destinations: Set<String> = []

    for item in items {
        for file in item.files {
            let isPreviewHelper =
                URL(fileURLWithPath: file.path).lastPathComponent == "SCPreview.swift"
            if !options.includePreviews, isPreviewHelper {
                continue
            }
            let targetPath =
                options.fileLayout == .flat
                ? URL(fileURLWithPath: file.target).lastPathComponent
                : file.target
            let destination = try RegistryPath.localURL(for: targetPath, under: options.targetRoot)
            guard destinations.insert(destination.path).inserted else {
                throw MaterializationError.destinationCollision(destination.path)
            }
            let source = try await client.contents(of: file)
            let materialized =
                options.includePreviews ? source : stripPreviewSource(from: source)
            let data =
                options.formatSwift && destination.pathExtension == "swift"
                ? try formatSwiftSource(materialized, projectRoot: options.projectRoot)
                : materialized
            prepared.append(
                PreparedRegistryFile(
                    itemName: item.name,
                    sourcePath: file.path,
                    targetPath: targetPath,
                    destination: destination,
                    data: data
                )
            )
        }
    }
    return prepared
}

func formatSwiftSource(_ data: Data, projectRoot: URL) throws -> Data {
    let fileManager = FileManager.default
    let directory = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let sourceURL = directory.appendingPathComponent("Source.swift")
    try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
    defer { try? fileManager.removeItem(at: directory) }
    try data.write(to: sourceURL)

    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
    var arguments = ["swift", "format", "format", "--in-place"]
    let configuration = projectRoot.appendingPathComponent(".swift-format")
    if fileManager.fileExists(atPath: configuration.path) {
        arguments.append(contentsOf: ["--configuration", configuration.path])
    }
    arguments.append(sourceURL.path)
    process.arguments = arguments
    process.currentDirectoryURL = projectRoot
    let output = Pipe()
    process.standardOutput = output
    process.standardError = output
    try process.run()
    process.waitUntilExit()
    guard process.terminationStatus == 0 else {
        let outputData = output.fileHandleForReading.readDataToEndOfFile()
        let detail = String(bytes: outputData, encoding: .utf8) ?? "Unknown formatter error"
        throw MaterializationError.formatFailed(detail.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    return try Data(contentsOf: sourceURL)
}

func stripPreviewSource(from data: Data) -> Data {
    guard var source = String(data: data, encoding: .utf8) else { return data }
    let markers = ["// MARK: - Previews", "// MARK: Previews"]
    let ranges = markers.compactMap { source.range(of: $0) }
    if let first = ranges.min(by: { $0.lowerBound < $1.lowerBound }) {
        source = String(source[..<first.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
        source.append("\n")
    }
    return Data(source.utf8)
}

func sha256(_ data: Data) -> String {
    SHA256.hash(data: data).map { String(format: "%02x", $0) }.joined()
}

func unifiedDiff(local: Data, registry: Data, path: String) throws -> String {
    let fileManager = FileManager.default
    let directory = fileManager.temporaryDirectory.appendingPathComponent(UUID().uuidString)
    let localURL = directory.appendingPathComponent("local")
    let registryURL = directory.appendingPathComponent("registry")
    try fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
    defer { try? fileManager.removeItem(at: directory) }
    try local.write(to: localURL)
    try registry.write(to: registryURL)

    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/diff")
    process.arguments = [
        "-u", "--label", "\(path) (local)", "--label", "\(path) (registry)",
        localURL.path, registryURL.path,
    ]
    let output = Pipe()
    process.standardOutput = output
    process.standardError = output
    try process.run()
    process.waitUntilExit()
    let data = output.fileHandleForReading.readDataToEndOfFile()
    guard process.terminationStatus == 0 || process.terminationStatus == 1 else {
        throw MaterializationError.diffFailed(path)
    }
    return String(bytes: data, encoding: .utf8) ?? ""
}

enum MaterializationError: Error, LocalizedError {
    case destinationCollision(String)
    case diffFailed(String)
    case missingLock(String)
    case missingRegistryFile(item: String, source: String)
    case formatFailed(String)

    var errorDescription: String? {
        switch self {
        case .destinationCollision(let path):
            return "More than one registry file resolves to '\(path)'. Choose registry layout or fix the registry."
        case .diffFailed(let path):
            return "Could not produce a diff for '\(path)'."
        case .missingLock(let path):
            return "No lock file exists at '\(path)'. Add a component first."
        case .missingRegistryFile(let item, let source):
            return "Registry item '\(item)' no longer contains '\(source)'."
        case .formatFailed(let detail):
            return "Apple swift format failed while materializing source: \(detail)"
        }
    }
}
