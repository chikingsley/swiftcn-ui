import ArgumentParser
import Foundation

struct Check: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Compare installed source with its lock and the current registry."
    )

    @OptionGroup var registryOptions: RegistryOptions

    @Argument(help: "Optional installed item names to check.")
    var names: [String] = []

    func run() async throws {
        guard let project = try registryOptions.loadProject() else {
            throw ConsumerConfigError.required
        }
        guard FileManager.default.fileExists(atPath: project.lockURL.path) else {
            throw MaterializationError.missingLock(project.lockURL.path)
        }
        let client = try await registryOptions.loadClient(project: project)
        let lock = try SwiftcnLock.load(from: project.lockURL, registry: project.config.registry)
        let selectedNames = names.isEmpty ? lock.items.keys.sorted() : names
        var problems = 0

        for name in selectedNames {
            guard let lockedItem = lock.items[name] else {
                print("not installed  \(name)")
                problems += 1
                continue
            }
            let item = try client.requireItem(named: name)
            for lockedFile in lockedItem.files {
                guard let registryFile = item.files.first(where: { $0.path == lockedFile.source }) else {
                    throw MaterializationError.missingRegistryFile(
                        item: name, source: lockedFile.source
                    )
                }
                let rawSource = try await client.contents(of: registryFile)
                let source =
                    project.config.includePreviews ? rawSource : stripPreviewSource(from: rawSource)
                let materializedSource =
                    project.config.formatSwift && destinationPathExtension(lockedFile.target) == "swift"
                    ? try formatSwiftSource(source, projectRoot: project.root)
                    : source
                let sourceHash = sha256(materializedSource)
                let destination = try RegistryPath.localURL(
                    for: lockedFile.target, under: project.targetURL
                )
                guard FileManager.default.fileExists(atPath: destination.path) else {
                    print("missing        \(name): \(lockedFile.target)")
                    problems += 1
                    continue
                }
                let localHash = sha256(try Data(contentsOf: destination))
                let status = fileStatus(
                    localHash: localHash,
                    sourceHash: sourceHash,
                    lockedFile: lockedFile
                )
                print("\(status.padded(to: 16))  \(name): \(lockedFile.target)")
                if status != "current", status != "matches registry" { problems += 1 }
            }
        }

        if problems > 0 {
            print("Check failed: \(problems) file state problem\(problems == 1 ? "" : "s").")
            throw ExitCode.failure
        }
        print("Check passed: installed source matches its recorded registry state.")
    }
}

private func fileStatus(
    localHash: String,
    sourceHash: String,
    lockedFile: SwiftcnLock.LockedFile
) -> String {
    let localChanged = localHash != lockedFile.installedHash
    let sourceChanged = sourceHash != lockedFile.sourceHash
    switch (localChanged, sourceChanged) {
    case (false, false): return "current"
    case (true, false): return "locally modified"
    case (false, true): return "update available"
    case (true, true): return localHash == sourceHash ? "matches registry" : "diverged"
    }
}

private func destinationPathExtension(_ path: String) -> String {
    URL(fileURLWithPath: path).pathExtension
}
