import Swiftcn
import SwiftUI

@main
struct ValidationHostApp: App {
    var body: some Scene {
        WindowGroup {
            ValidationRootView()
        }
        .windowResizability(.contentSize)
    }
}

/// Routes `--sc-scene <key>` to one deterministic component scene and applies
/// `--sc-appearance light|dark` so UI tests control both axes per launch.
struct ValidationRootView: View {
    private let scene: String
    private let appearance: ColorScheme?

    init() {
        let arguments = ProcessInfo.processInfo.arguments
        scene = Self.value(named: "--sc-scene", in: arguments) ?? "button"
        switch Self.value(named: "--sc-appearance", in: arguments) {
        case "dark": appearance = .dark
        case "light": appearance = .light
        default: appearance = nil
        }
    }

    var body: some View {
        Group {
            switch scene {
            case "button": ButtonValidationScene()
            case "badge": BadgeValidationScene()
            default:
                Text("Unknown scene: \(scene)")
                    .accessibilityIdentifier("sc-unknown-scene")
            }
        }
        .frame(width: 780, height: 560, alignment: .topLeading)
        .background(Theme.default.background)
        .theme(.default)
        .preferredColorScheme(appearance)
    }

    private static func value(named name: String, in arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: name),
            arguments.indices.contains(index + 1)
        else { return nil }
        return arguments[index + 1]
    }
}
