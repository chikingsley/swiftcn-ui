import ArgumentParser
import Foundation

struct Add: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Copy items and all their registry dependencies into your project."
    )

    @OptionGroup var registryOptions: RegistryOptions

    @Argument(help: "Registry item names to add (e.g. 'button card').")
    var names: [String]

    @Option(help: "Directory to copy files into.")
    var target: String = "."

    @Flag(help: "Show what would be copied without writing anything.")
    var dryRun = false

    @Flag(help: "Overwrite files that already exist.")
    var overwrite = false

    func validate() throws {
        guard !names.isEmpty else {
            throw ValidationError("Provide at least one item name. Run 'swiftcn list' to see what's available.")
        }
    }

    func run() async throws {
        let client = try await registryOptions.loadClient()
        try await copyItems(
            named: names, from: client,
            into: target, dryRun: dryRun, overwrite: overwrite
        )
    }
}

/// Shared engine for `add` and `init`: resolve names (with transitive
/// dependencies, dependency-first), copy each item file into the target
/// directory, and print a per-file and summary report.
func copyItems(
    named names: [String],
    from client: RegistryClient,
    into target: String,
    dryRun: Bool,
    overwrite: Bool
) async throws {
    let items = try client.resolveWithDependencies(names)
    let targetRoot = URL(fileURLWithPath: (target as NSString).expandingTildeInPath)
    let fm = FileManager.default

    var written = 0
    var skipped = 0

    for item in items {
        print("\(item.name) (\(item.kind)):")
        for file in item.files {
            let destination = targetRoot.appendingPathComponent(file.target)
            let exists = fm.fileExists(atPath: destination.path)

            if exists && !overwrite {
                print("  skipped      \(file.target) (exists, use --overwrite)")
                skipped += 1
                continue
            }
            if dryRun {
                print("  would write  \(file.target)\(exists ? " (overwrite)" : "")")
                written += 1
                continue
            }
            let data = try await client.contents(of: file)
            do {
                try fm.createDirectory(
                    at: destination.deletingLastPathComponent(),
                    withIntermediateDirectories: true
                )
                try data.write(to: destination)
            } catch {
                throw SwiftcnError.fileWriteFailed(
                    path: destination.path, detail: error.localizedDescription
                )
            }
            print("  written      \(file.target)")
            written += 1
        }
    }

    let files = "\(written) file\(written == 1 ? "" : "s")"
    let itemCount = "\(items.count) item\(items.count == 1 ? "" : "s")"
    var summary = dryRun
        ? "Dry run: \(files) would be written, \(itemCount)."
        : "Done: \(files) written, \(itemCount)."
    if skipped > 0 {
        summary += " Skipped \(skipped) existing file\(skipped == 1 ? "" : "s")."
    }
    print(summary)
}
