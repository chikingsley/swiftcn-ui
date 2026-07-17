// ============================================================
// ShowcaseApp.swift — Swiftcn macOS Showcase
// The component gallery, itself built from swiftcn components.
// ============================================================
import SwiftUI
import Swiftcn

@main
struct ShowcaseApp: App {
    private let captureComponentID: String?
    private let captureAppearance: ColorScheme?

    init() {
        let arguments = ProcessInfo.processInfo.arguments
        captureComponentID = Self.value(named: "--capture-component", in: arguments)
        switch Self.value(named: "--capture-appearance", in: arguments) {
        case "dark": captureAppearance = .dark
        case "light": captureAppearance = .light
        default: captureAppearance = nil
        }
    }

    var body: some Scene {
        WindowGroup {
            if let captureComponentID {
                CaptureRootView(
                    componentID: captureComponentID,
                    appearance: captureAppearance
                )
            } else {
                RootView()
                    .theme(.default)
            }
        }
        .defaultSize(
            width: captureComponentID == nil ? 1_200 : 900,
            height: 800
        )
    }

    private static func value(named name: String, in arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: name), arguments.indices.contains(index + 1) else {
            return nil
        }
        return arguments[index + 1]
    }
}
