import ArgumentParser
import Foundation

struct Add: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Materialize registry items and their dependencies into a Swift project."
    )

    @OptionGroup var registryOptions: RegistryOptions

    @Argument(help: "Registry item names to add (e.g. 'button card').")
    var names: [String]

    @Option(help: "Override the configured destination directory.")
    var target: String?

    @Flag(help: "Show changes without writing files or the lock file.")
    var dryRun = false

    @Flag(help: "Show unified diffs. Implies --dry-run.")
    var diff = false

    @Flag(help: "Overwrite locally changed files with registry source.")
    var overwrite = false

    func validate() throws {
        guard !names.isEmpty else {
            throw ValidationError("Provide at least one item name. Run 'swiftcn list' to see what's available.")
        }
    }

    func run() async throws {
        let project = try registryOptions.loadProject()
        let client = try await registryOptions.loadClient(project: project)
        let targetRoot =
            target.map {
                resolve($0, relativeTo: URL(fileURLWithPath: FileManager.default.currentDirectoryPath))
            } ?? project?.targetURL ?? URL(fileURLWithPath: FileManager.default.currentDirectoryPath)

        let request = CopyRequest(
            named: names,
            dryRun: dryRun || diff,
            showDiff: diff,
            overwrite: overwrite,
            lockURL: project?.lockURL,
            registryIdentifier: project?.config.registry ?? client.location.displayName
        )
        let materialization = MaterializationOptions(
            targetRoot: targetRoot,
            includePreviews: project?.config.includePreviews ?? true,
            fileLayout: project?.config.fileLayout ?? .registry,
            formatSwift: project?.config.formatSwift ?? false,
            projectRoot: project?.root
                ?? URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        )
        try await copyItems(request, from: client, materialization: materialization)
    }
}

struct CopyRequest {
    let named: [String]
    let dryRun: Bool
    let showDiff: Bool
    let overwrite: Bool
    let lockURL: URL?
    let registryIdentifier: String
}

func copyItems(
    _ request: CopyRequest,
    from client: RegistryClient,
    materialization: MaterializationOptions
) async throws {
    let items = try client.resolveWithDependencies(
        request.named,
        includePreviews: materialization.includePreviews
    )
    let files = try await preparedFiles(
        for: items,
        from: client,
        options: materialization
    )
    let fileManager = FileManager.default
    var lock = try request.lockURL.map {
        try SwiftcnLock.load(from: $0, registry: request.registryIdentifier)
    }
    lock?.registry = request.registryIdentifier

    var created = 0
    var updated = 0
    var unchanged = 0
    var skipped = 0

    for item in items {
        print("\(item.name) (\(item.kind)):")
        for file in files.filter({ $0.itemName == item.name }) {
            let exists = fileManager.fileExists(atPath: file.destination.path)
            let localData = exists ? try Data(contentsOf: file.destination) : nil

            if localData == file.data {
                print("  unchanged    \(file.targetPath)")
                unchanged += 1
                updateLock(&lock, item: item.name, file: file)
                continue
            }

            if let localData, request.showDiff {
                let rendered = try unifiedDiff(local: localData, registry: file.data, path: file.targetPath)
                if !rendered.isEmpty { print(rendered, terminator: rendered.hasSuffix("\n") ? "" : "\n") }
            }

            if request.dryRun {
                if exists, !request.overwrite {
                    print("  would skip  \(file.targetPath) (local changes; pass --overwrite to replace)")
                    skipped += 1
                } else {
                    print("  would \(exists ? "update" : "create")  \(file.targetPath)")
                    if exists { updated += 1 } else { created += 1 }
                }
                continue
            }

            if exists, !request.overwrite {
                print("  skipped      \(file.targetPath) (local changes; inspect with --diff)")
                skipped += 1
                continue
            }

            do {
                try fileManager.createDirectory(
                    at: file.destination.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
                try file.data.write(to: file.destination, options: .atomic)
            } catch {
                throw SwiftcnError.fileWriteFailed(
                    path: file.destination.path, detail: error.localizedDescription
                )
            }
            print("  \(exists ? "updated" : "created")      \(file.targetPath)")
            if exists { updated += 1 } else { created += 1 }
            updateLock(&lock, item: item.name, file: file)
        }
    }

    if !request.dryRun, let lockURL = request.lockURL, let lock {
        try lock.write(to: lockURL)
    }

    let prefix = request.dryRun ? "Dry run" : "Done"
    let summary =
        "\(prefix): \(created) created, \(updated) updated, "
        + "\(unchanged) unchanged, \(skipped) skipped; \(items.count) items."
    print(summary)
}

private func updateLock(
    _ lock: inout SwiftcnLock?, item: String, file: PreparedRegistryFile
) {
    guard var currentLock = lock else { return }
    var files = currentLock.items[item]?.files ?? []
    let entry = SwiftcnLock.LockedFile(
        source: file.sourcePath,
        target: file.targetPath,
        sourceHash: file.sourceHash,
        installedHash: file.sourceHash
    )
    if let index = files.firstIndex(where: { $0.target == file.targetPath }) {
        files[index] = entry
    } else {
        files.append(entry)
    }
    files.sort { $0.target < $1.target }
    currentLock.items[item] = SwiftcnLock.LockedItem(files: files)
    lock = currentLock
}
