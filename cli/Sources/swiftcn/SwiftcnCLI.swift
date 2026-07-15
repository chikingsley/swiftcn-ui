import ArgumentParser

@main
struct SwiftcnCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "swiftcn",
        abstract: "Materialize and track swiftcn-ui source in a Swift project.",
        version: "0.2.0",
        subcommands: [List.self, View.self, Add.self, Init.self, Check.self]
    )
}

/// Shared --registry option, available on every subcommand.
struct RegistryOptions: ParsableArguments {
    @Option(
        name: .customLong("registry"),
        help: ArgumentHelp(
            "Path or URL to a registry.json, or a directory/URL containing one.",
            discussion: """
                Defaults to the nearest registry.json above the current directory. Outside a registry \
                checkout, pass this option explicitly.
                """
        )
    )
    var registry: String?

    @Option(
        name: .customLong("config"),
        help: "Path to swiftcn.json. Defaults to the nearest config above the current directory."
    )
    var config: String?

    func loadProject() throws -> ConsumerProject? {
        try ConsumerProject.discover(explicitPath: config)
    }

    func resolveRegistryLocation(
        project: ConsumerProject?, discoverProject: Bool = true
    ) throws -> RegistryLocation {
        if let registry {
            return try RegistryLocation.resolve(option: registry)
        }
        let resolvedProject: ConsumerProject?
        if let project {
            resolvedProject = project
        } else if discoverProject {
            resolvedProject = try loadProject()
        } else {
            resolvedProject = nil
        }
        if let resolvedProject {
            return try RegistryLocation.resolve(option: resolvedProject.registryOption)
        }
        return try RegistryLocation.resolve(option: nil)
    }

    func loadClient(project: ConsumerProject? = nil) async throws -> RegistryClient {
        try await RegistryClient.load(from: resolveRegistryLocation(project: project))
    }
}
