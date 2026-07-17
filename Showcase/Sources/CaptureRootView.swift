import AppKit
import SwiftUI
import Swiftcn

/// Shared launch-state signal for demos that can deterministically expose an
/// open overlay without UI scripting.
enum ShowcaseCaptureMode {
    static let isEnabled = ProcessInfo.processInfo.arguments.contains("--capture-component")
}

/// A deterministic, single-component surface for visual comparison captures.
///
/// The regular Showcase shell remains the human-browsable catalog. This view
/// removes its sidebar, usage sample, and navigation chrome so each captured
/// image concentrates on the same component demo in a fixed 900x800 window.
struct CaptureRootView: View {
    @Environment(\.theme) private var theme

    let componentID: String
    let appearance: ColorScheme?

    private var entry: ComponentEntry? {
        Catalog.all.first { $0.id == componentID }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if let entry {
                    Text(entry.name)
                        .scH2()
                    Text(entry.description)
                        .scMuted()
                    DemoBox {
                        entry.demoView()
                    }
                } else {
                    Text("Unknown component: \(componentID)")
                        .foregroundStyle(theme.destructive)
                }
            }
            .padding(32)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(width: 900, height: 800)
        .background(theme.background)
        .background(CaptureWindowConfigurator())
        .theme(.default)
        .preferredColorScheme(appearance)
    }
}

/// Turns only the automated capture window into a fixed, chrome-free canvas.
/// The regular Showcase window keeps its normal macOS title bar and controls.
private struct CaptureWindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> CaptureConfigurationView {
        CaptureConfigurationView()
    }

    func updateNSView(_ view: CaptureConfigurationView, context: Context) {
        view.configureWindow()
    }
}

private final class CaptureConfigurationView: NSView {
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        configureWindow()
    }

    func configureWindow() {
        guard let window else { return }
        window.styleMask = [.borderless]
        window.setContentSize(NSSize(width: 900, height: 800))
        window.isMovable = false
    }
}
