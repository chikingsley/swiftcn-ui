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

    private func commonPrefixLength(_ lhs: String, _ rhs: String) -> Int {
        zip(lhs, rhs).prefix { $0 == $1 }.count
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
    let meta: RegistryItemMeta?

    func dependencies(includePreviews: Bool) -> [String] {
        var dependencies = meta?.swiftcnDependencies ?? registryDependencies ?? []
        if includePreviews {
            dependencies.append(contentsOf: meta?.swiftcnPreviewDependencies ?? [])
        }
        return Array(Set(dependencies)).sorted()
    }

    /// "registry:component" -> "component".
    var kind: String {
        guard let colon = type.firstIndex(of: ":") else { return type }
        return String(type[type.index(after: colon)...])
    }
}

struct RegistryItemMeta: Decodable {
    let swiftcnDependencies: [String]?
    let swiftcnPreviewDependencies: [String]?
}

/// One source file of a registry item.
struct RegistryFile: Decodable {
    /// Path relative to the registry.json's directory (where the file is fetched from).
    let path: String
    /// Path relative to the consumer's target directory (where the file is written to).
    let target: String
    let type: String?
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
    case registryRequired
    case unknownItem(name: String, suggestions: [String])
    case unsafePath(path: String, root: String)
    case dependencyCycle([String])

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
        case .registryRequired:
            return "No local registry.json was found. Pass --registry with a local path or URL."
        case .unknownItem(let name, let suggestions):
            if suggestions.isEmpty {
                return "Unknown item '\(name)'. Run 'swiftcn list' to see available items."
            }
            return "Unknown item '\(name)'. Closest matches: \(suggestions.joined(separator: ", "))"
        case .unsafePath(let path, let root):
            return "Registry path '\(path)' escapes or is unsafe for '\(root)'."
        case .dependencyCycle(let cycle):
            return "Registry dependency cycle: \(cycle.joined(separator: " -> "))."
        }
    }
}

// MARK: - Path containment

enum RegistryPath {
    static func validateRelative(_ path: String, rootDescription: String) throws {
        let components = path.split(separator: "/", omittingEmptySubsequences: false)
        guard
            !path.isEmpty,
            !(path as NSString).isAbsolutePath,
            !path.hasPrefix("~"),
            !path.contains("\0"),
            components.allSatisfy({ !$0.isEmpty && $0 != "." && $0 != ".." })
        else {
            throw SwiftcnError.unsafePath(path: path, root: rootDescription)
        }
    }

    static func localURL(for path: String, under root: URL) throws -> URL {
        try validateRelative(path, rootDescription: root.path)

        let fileManager = FileManager.default
        let resolvedRoot = root.standardizedFileURL.resolvingSymlinksInPath()
        let rootPath = resolvedRoot.path.hasSuffix("/") ? resolvedRoot.path : resolvedRoot.path + "/"
        let components = path.split(separator: "/").map(String.init)
        var candidate = resolvedRoot

        for component in components {
            candidate.appendPathComponent(component)
            guard fileManager.fileExists(atPath: candidate.path) else { continue }

            let resolvedCandidate = candidate.resolvingSymlinksInPath()
            guard resolvedCandidate.path == resolvedRoot.path || resolvedCandidate.path.hasPrefix(rootPath) else {
                throw SwiftcnError.unsafePath(path: path, root: resolvedRoot.path)
            }
        }

        let standardized = candidate.standardizedFileURL
        guard standardized.path.hasPrefix(rootPath) else {
            throw SwiftcnError.unsafePath(path: path, root: resolvedRoot.path)
        }
        return standardized
    }
}

// MARK: - Location

/// Where a registry.json lives; item file paths resolve against its directory.
enum RegistryLocation {
    case local(URL)  // file URL of a registry.json
    case remote(URL)  // http(s) URL of a registry.json

    /// Resolve the --registry option (path or URL, to a registry.json or its
    /// containing directory). With no option, walk up from cwd looking for a
    /// repo-local registry.json. A remote default will be added only after a
    /// canonical registry is actually published.
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
        throw SwiftcnError.registryRequired
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
    func resolveWithDependencies(
        _ names: [String], includePreviews: Bool = true
    ) throws -> [RegistryItem] {
        var ordered: [RegistryItem] = []
        var visited: Set<String> = []
        var inProgress: Set<String> = []
        var stack: [String] = []

        func visit(_ name: String) throws {
            if visited.contains(name) { return }
            if inProgress.contains(name) {
                let cycleStart = stack.firstIndex(of: name) ?? stack.startIndex
                throw SwiftcnError.dependencyCycle(Array(stack[cycleStart...]) + [name])
            }
            let item = try requireItem(named: name)
            inProgress.insert(name)
            stack.append(name)
            for dependency in item.dependencies(includePreviews: includePreviews) {
                try visit(dependency)
            }
            stack.removeLast()
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
            let root = registryURL.deletingLastPathComponent()
            let url = try RegistryPath.localURL(for: file.path, under: root)
            do {
                return try Data(contentsOf: url)
            } catch {
                throw SwiftcnError.fileReadFailed(path: url.path, detail: error.localizedDescription)
            }
        case .remote(let registryURL):
            try RegistryPath.validateRelative(file.path, rootDescription: registryURL.absoluteString)
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
