import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

// MARK: - Models

/// The top-level registry.json document.
struct Registry: Decodable {
    let name: String
    let homepage: String?
    let items: [RegistryItem]

    func item(named name: String) -> RegistryItem? {
        items.first { $0.name == name }
    }

    /// Closest-match candidates for an unknown item name: prefix/contains
    /// matches first, else names sharing a common prefix of 3+ characters
    /// (catches trailing typos like 'buttn').
    func suggestions(for name: String) -> [String] {
        let query = name.lowercased()
        guard !query.isEmpty else { return [] }
        let names = items.map(\.name)
        let matches = names.filter {
            $0.hasPrefix(query) || $0.contains(query) || query.contains($0)
        }
        if !matches.isEmpty { return matches.sorted() }
        return names.filter { commonPrefixLength($0, query) >= 3 }.sorted()
    }

    private func commonPrefixLength(_ a: String, _ b: String) -> Int {
        zip(a, b).prefix { $0 == $1 }.count
    }
}

/// A single registry item (component, block, theme, effect).
struct RegistryItem: Decodable {
    let name: String
    let type: String
    let title: String?
    let description: String?
    let files: [RegistryFile]
    let registryDependencies: [String]?
    let platforms: [String: String]?

    var dependencies: [String] { registryDependencies ?? [] }

    /// "registry:component" -> "component".
    var kind: String {
        guard let colon = type.firstIndex(of: ":") else { return type }
        return String(type[type.index(after: colon)...])
    }
}

/// One source file of a registry item.
struct RegistryFile: Decodable {
    /// Path relative to the registry.json's directory (where the file is fetched from).
    let path: String
    /// Path relative to the consumer's target directory (where the file is written to).
    let target: String
}

// MARK: - Errors

enum SwiftcnError: Error, LocalizedError {
    case invalidRegistry(String)
    case registryNotFound(String)
    case registryDecodeFailed(location: String, detail: String)
    case network(url: String, detail: String)
    case fileReadFailed(path: String, detail: String)
    case fileWriteFailed(path: String, detail: String)
    case notUTF8(path: String)
    case unknownItem(name: String, suggestions: [String])

    var errorDescription: String? {
        switch self {
        case .invalidRegistry(let value):
            return "'\(value)' is not a valid registry path or URL."
        case .registryNotFound(let path):
            return "No registry.json found at '\(path)'."
        case .registryDecodeFailed(let location, let detail):
            return "Could not parse registry at '\(location)': \(detail)"
        case .network(let url, let detail):
            return "Failed to fetch '\(url)': \(detail). Check your network connection and the registry URL."
        case .fileReadFailed(let path, let detail):
            return "Could not read '\(path)': \(detail)"
        case .fileWriteFailed(let path, let detail):
            return "Could not write '\(path)': \(detail)"
        case .notUTF8(let path):
            return "'\(path)' is not valid UTF-8 text."
        case .unknownItem(let name, let suggestions):
            if suggestions.isEmpty {
                return "Unknown item '\(name)'. Run 'swiftcn list' to see available items."
            }
            return "Unknown item '\(name)'. Closest matches: \(suggestions.joined(separator: ", "))"
        }
    }
}

// MARK: - Location

/// Where a registry.json lives; item file paths resolve against its directory.
enum RegistryLocation {
    case local(URL)  // file URL of a registry.json
    case remote(URL) // http(s) URL of a registry.json

    static let defaultRemote = URL(
        string: "https://raw.githubusercontent.com/Mobilecn-UI/swiftcn-ui/v2/registry.json"
    )!

    /// Resolve the --registry option (path or URL, to a registry.json or its
    /// containing directory). With no option: walk up from cwd looking for a
    /// repo-local registry.json, else fall back to the default remote registry.
    static func resolve(option: String?) throws -> RegistryLocation {
        let fm = FileManager.default

        if let option {
            if option.hasPrefix("http://") || option.hasPrefix("https://") {
                guard var url = URL(string: option) else {
                    throw SwiftcnError.invalidRegistry(option)
                }
                if url.pathExtension != "json" {
                    url.appendPathComponent("registry.json")
                }
                return .remote(url)
            }
            var url = URL(fileURLWithPath: (option as NSString).expandingTildeInPath)
            var isDirectory: ObjCBool = false
            guard fm.fileExists(atPath: url.path, isDirectory: &isDirectory) else {
                throw SwiftcnError.registryNotFound(option)
            }
            if isDirectory.boolValue {
                url.appendPathComponent("registry.json")
                guard fm.fileExists(atPath: url.path) else {
                    throw SwiftcnError.registryNotFound(url.path)
                }
            }
            return .local(url.standardizedFileURL)
        }

        var directory = URL(fileURLWithPath: fm.currentDirectoryPath)
        while true {
            let candidate = directory.appendingPathComponent("registry.json")
            if fm.fileExists(atPath: candidate.path) {
                return .local(candidate.standardizedFileURL)
            }
            let parent = directory.deletingLastPathComponent()
            if parent.path == directory.path { break }
            directory = parent
        }
        return .remote(defaultRemote)
    }

    var displayName: String {
        switch self {
        case .local(let url): return url.path
        case .remote(let url): return url.absoluteString
        }
    }
}

// MARK: - Client

/// A loaded registry plus the machinery to fetch its item files.
struct RegistryClient {
    let location: RegistryLocation
    let registry: Registry

    static func load(from location: RegistryLocation) async throws -> RegistryClient {
        let data: Data
        switch location {
        case .local(let url):
            do {
                data = try Data(contentsOf: url)
            } catch {
                throw SwiftcnError.fileReadFailed(path: url.path, detail: error.localizedDescription)
            }
        case .remote(let url):
            data = try await fetchRemote(url)
        }
        do {
            let registry = try JSONDecoder().decode(Registry.self, from: data)
            return RegistryClient(location: location, registry: registry)
        } catch {
            throw SwiftcnError.registryDecodeFailed(
                location: location.displayName, detail: error.localizedDescription
            )
        }
    }

    func requireItem(named name: String) throws -> RegistryItem {
        guard let item = registry.item(named: name) else {
            throw SwiftcnError.unknownItem(name: name, suggestions: registry.suggestions(for: name))
        }
        return item
    }

    /// The requested items plus all transitive registryDependencies, in
    /// dependency-first topological order (depth-first, deduplicated, cycle-safe).
    func resolveWithDependencies(_ names: [String]) throws -> [RegistryItem] {
        var ordered: [RegistryItem] = []
        var visited: Set<String> = []
        var inProgress: Set<String> = []

        func visit(_ name: String) throws {
            if visited.contains(name) || inProgress.contains(name) { return }
            let item = try requireItem(named: name)
            inProgress.insert(name)
            for dependency in item.dependencies {
                try visit(dependency)
            }
            inProgress.remove(name)
            visited.insert(name)
            ordered.append(item)
        }

        for name in names {
            try visit(name)
        }
        return ordered
    }

    /// Fetch an item file's contents, resolving its path against the
    /// registry.json's directory (local folder or remote URL).
    func contents(of file: RegistryFile) async throws -> Data {
        switch location {
        case .local(let registryURL):
            let url = registryURL.deletingLastPathComponent().appendingPathComponent(file.path)
            do {
                return try Data(contentsOf: url)
            } catch {
                throw SwiftcnError.fileReadFailed(path: url.path, detail: error.localizedDescription)
            }
        case .remote(let registryURL):
            let url = registryURL.deletingLastPathComponent().appendingPathComponent(file.path)
            return try await Self.fetchRemote(url)
        }
    }

    private static func fetchRemote(_ url: URL) async throws -> Data {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(from: url)
        } catch {
            throw SwiftcnError.network(url: url.absoluteString, detail: error.localizedDescription)
        }
        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw SwiftcnError.network(url: url.absoluteString, detail: "HTTP \(http.statusCode)")
        }
        return data
    }
}
