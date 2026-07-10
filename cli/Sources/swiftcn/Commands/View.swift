import ArgumentParser
import Foundation

struct View: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Print an item's source files to stdout."
    )

    @OptionGroup var registryOptions: RegistryOptions

    @Argument(help: "The registry item to view (e.g. 'button').")
    var name: String

    func run() async throws {
        let client = try await registryOptions.loadClient()
        let item = try client.requireItem(named: name)

        for (index, file) in item.files.enumerated() {
            if index > 0 { print("") }
            print("// ==== \(file.path) -> \(file.target) ====")
            let data = try await client.contents(of: file)
            guard let text = String(data: data, encoding: .utf8) else {
                throw SwiftcnError.notUTF8(path: file.path)
            }
            print(text.hasSuffix("\n") ? String(text.dropLast()) : text)
        }
    }
}
