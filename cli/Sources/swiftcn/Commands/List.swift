import ArgumentParser

struct List: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "List every item in the registry."
    )

    @OptionGroup var registryOptions: RegistryOptions

    private static let descriptionWidth = 60
    private static let kindRank = ["theme": 0, "component": 1, "effect": 2, "block": 3]

    func run() async throws {
        let client = try await registryOptions.loadClient()
        let items = client.registry.items

        let nameWidth = max(items.map { $0.name.count }.max() ?? 0, "NAME".count)
        let typeWidth = max(items.map { $0.kind.count }.max() ?? 0, "TYPE".count)

        func row(_ name: String, _ type: String, _ description: String) -> String {
            "\(name.padded(to: nameWidth))  \(type.padded(to: typeWidth))  \(description)"
        }

        print(row("NAME", "TYPE", "DESCRIPTION"))

        let groups = Dictionary(grouping: items, by: \.kind).sorted {
            (Self.kindRank[$0.key] ?? .max, $0.key) < (Self.kindRank[$1.key] ?? .max, $1.key)
        }
        for (index, group) in groups.enumerated() {
            if index > 0 { print("") }
            for item in group.value.sorted(by: { $0.name < $1.name }) {
                let description = (item.description ?? "")
                    .replacingOccurrences(of: "\n", with: " ")
                    .truncated(to: Self.descriptionWidth)
                print(row(item.name, item.kind, description))
            }
        }
    }
}

extension String {
    func padded(to width: Int) -> String {
        self + String(repeating: " ", count: Swift.max(0, width - count))
    }

    func truncated(to width: Int) -> String {
        count <= width ? self : String(prefix(Swift.max(0, width - 3))) + "..."
    }
}
