import ArgumentParser
import Foundation

struct ConsumerConfig: Codable, Equatable {
    static let fileName = "swiftcn.json"
    static let lockFileName = ".swiftcn.lock.json"
    static let currentSchemaVersion = 1

    var schema: String?
    var schemaVersion = Self.currentSchemaVersion
    var registry: String
    var target: String
    var platform: Platform
    var includePreviews: Bool
    var fileLayout: FileLayout
    var formatSwift: Bool

    enum Platform: String, Codable, CaseIterable, ExpressibleByArgument {
        case macOS
        case iOS
        case iPadOS
    }

    enum FileLayout: String, Codable, CaseIterable, ExpressibleByArgument {
        case flat
        case registry
    }

    enum CodingKeys: String, CodingKey {
        case schema = "$schema"
        case schemaVersion
        case registry
        case target
        case platform
        case includePreviews
        case fileLayout
        case formatSwift
    }
}

struct ConsumerProject {
    let root: URL
    let configURL: URL
    let config: ConsumerConfig

    var lockURL: URL { root.appendingPathComponent(ConsumerConfig.lockFileName) }

    var targetURL: URL {
        resolve(config.target, relativeTo: root)
    }

    var registryOption: String {
        if config.registry.hasPrefix("http://") || config.registry.hasPrefix("https://") {
            return config.registry
        }
        return resolve(config.registry, relativeTo: root).path
    }

    static func discover(explicitPath: String? = nil) throws -> ConsumerProject? {
        let fileManager = FileManager.default
        if let explicitPath {
            let expanded = (explicitPath as NSString).expandingTildeInPath
            let url = URL(fileURLWithPath: expanded).standardizedFileURL
            guard fileManager.fileExists(atPath: url.path) else {
                throw ConsumerConfigError.notFound(url.path)
            }
            return try load(from: url)
        }

        var directory = URL(fileURLWithPath: fileManager.currentDirectoryPath).standardizedFileURL
        while true {
            let candidate = directory.appendingPathComponent(ConsumerConfig.fileName)
            if fileManager.fileExists(atPath: candidate.path) {
                return try load(from: candidate)
            }
            let parent = directory.deletingLastPathComponent()
            if parent.path == directory.path { return nil }
            directory = parent
        }
    }

    static func write(_ config: ConsumerConfig, at root: URL, overwrite: Bool) throws -> ConsumerProject {
        let fileManager = FileManager.default
        let configURL = root.appendingPathComponent(ConsumerConfig.fileName)
        if fileManager.fileExists(atPath: configURL.path), !overwrite {
            throw ConsumerConfigError.alreadyExists(configURL.path)
        }
        do {
            try fileManager.createDirectory(at: root, withIntermediateDirectories: true)
            try encoded(config).write(to: configURL, options: .atomic)
        } catch let error as ConsumerConfigError {
            throw error
        } catch {
            throw ConsumerConfigError.writeFailed(configURL.path, error.localizedDescription)
        }
        return ConsumerProject(root: root, configURL: configURL, config: config)
    }

    private static func load(from url: URL) throws -> ConsumerProject {
        do {
            let data = try Data(contentsOf: url)
            let config = try JSONDecoder().decode(ConsumerConfig.self, from: data)
            guard config.schemaVersion == ConsumerConfig.currentSchemaVersion else {
                throw ConsumerConfigError.unsupportedVersion(config.schemaVersion)
            }
            return ConsumerProject(root: url.deletingLastPathComponent(), configURL: url, config: config)
        } catch let error as ConsumerConfigError {
            throw error
        } catch {
            throw ConsumerConfigError.decodeFailed(url.path, error.localizedDescription)
        }
    }

    private static func encoded<T: Encodable>(_ value: T) throws -> Data {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        var data = try encoder.encode(value)
        data.append(0x0A)
        return data
    }
}

func resolve(_ path: String, relativeTo root: URL) -> URL {
    let expanded = (path as NSString).expandingTildeInPath
    if (expanded as NSString).isAbsolutePath {
        return URL(fileURLWithPath: expanded).standardizedFileURL
    }
    return root.appendingPathComponent(expanded).standardizedFileURL
}

enum ConsumerConfigError: Error, LocalizedError {
    case notFound(String)
    case alreadyExists(String)
    case decodeFailed(String, String)
    case writeFailed(String, String)
    case unsupportedVersion(Int)
    case required

    var errorDescription: String? {
        switch self {
        case .notFound(let path):
            return "No swiftcn consumer config exists at '\(path)'."
        case .alreadyExists(let path):
            return "'\(path)' already exists. Use --force to replace it."
        case .decodeFailed(let path, let detail):
            return "Could not parse '\(path)': \(detail)"
        case .writeFailed(let path, let detail):
            return "Could not write '\(path)': \(detail)"
        case .unsupportedVersion(let version):
            return "swiftcn.json schemaVersion \(version) is not supported."
        case .required:
            return "No swiftcn.json found. Run 'swiftcn init' first or pass --config."
        }
    }
}
