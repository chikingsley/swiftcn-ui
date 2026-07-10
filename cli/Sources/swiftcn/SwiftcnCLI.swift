import ArgumentParser

@main
struct SwiftcnCLI: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "swiftcn",
        abstract: "Copy swiftcn-ui components, blocks, and the theme into your project.",
        version: "0.1.0",
        subcommands: [List.self, View.self, Add.self, Init.self]
    )
}

/// Shared --registry option, available on every subcommand.
struct RegistryOptions: ParsableArguments {
    @Option(
        name: .customLong("registry"),
        help: ArgumentHelp(
            "Path or URL to a registry.json, or a directory/URL containing one.",
            discussion: "Defaults to the nearest registry.json above the current directory, else the swiftcn-ui GitHub registry."
        )
    )
    var registry: String?

    func loadClient() async throws -> RegistryClient {
        try await RegistryClient.load(from: RegistryLocation.resolve(option: registry))
    }
}
