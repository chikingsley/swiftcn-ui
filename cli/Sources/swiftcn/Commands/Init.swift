import ArgumentParser
import Foundation

struct Init: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Create swiftcn.json and install the production theme source."
    )

    @OptionGroup var registryOptions: RegistryOptions

    @Option(help: "Consumer project directory.")
    var cwd: String = "."

    @Option(help: "Destination directory, relative to the consumer project.")
    var target: String = "Sources/Components/UI"

    @Option(help: "Apple platform this consumer targets.")
    var platform: ConsumerConfig.Platform = .macOS

    @Option(help: "How registry file paths map into the destination.")
    var fileLayout: ConsumerConfig.FileLayout = .flat

    @Flag(help: "Keep #Preview declarations and preview-only dependencies.")
    var includePreviews = false

    @Flag(help: "Replace an existing swiftcn.json.")
    var force = false

    func run() async throws {
        let root = resolve(cwd, relativeTo: URL(fileURLWithPath: FileManager.default.currentDirectoryPath))
        let location = try registryOptions.resolveRegistryLocation(project: nil, discoverProject: false)
        let client = try await RegistryClient.load(from: location)
        let registryValue = registryOptions.registry ?? location.displayName
        let config = ConsumerConfig(
            registry: registryValue,
            target: target,
            platform: platform,
            includePreviews: includePreviews,
            fileLayout: fileLayout,
            formatSwift: true
        )
        let project = try ConsumerProject.write(config, at: root, overwrite: force)
        print("created      \(project.configURL.path)")

        let request = CopyRequest(
            named: ["theme"],
            dryRun: false,
            showDiff: false,
            overwrite: false,
            lockURL: project.lockURL,
            registryIdentifier: registryValue
        )
        let materialization = MaterializationOptions(
            targetRoot: project.targetURL,
            includePreviews: includePreviews,
            fileLayout: fileLayout,
            formatSwift: true,
            projectRoot: project.root
        )
        try await copyItems(request, from: client, materialization: materialization)
    }
}
