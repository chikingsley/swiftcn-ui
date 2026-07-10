// ============================================================
// ShowcaseApp.swift — Swiftcn Showcase
// The component gallery, itself built from swiftcn components.
// ============================================================
import SwiftUI
import Swiftcn

@main
struct ShowcaseApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .theme(.default)
        }
    }
}
