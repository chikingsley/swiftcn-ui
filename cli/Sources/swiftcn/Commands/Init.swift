import ArgumentParser

struct Init: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Set up swiftcn in your project (copies the Theme/ folder; sugar for 'add theme')."
    )

    @OptionGroup var registryOptions: RegistryOptions

    @Option(help: "Directory to copy files into.")
    var target: String = "."

    func run() async throws {
        let client = try await registryOptions.loadClient()
        try await copyItems(
            named: ["theme"], from: client,
            into: target, dryRun: false, overwrite: false
        )
    }
}
