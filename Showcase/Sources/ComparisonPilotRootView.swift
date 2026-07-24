import AppKit
import SwiftUI
import Swiftcn

/// The exact Swift side of the cross-runtime Accordion/Alert pilot contract.
/// The state is encoded in the filename and launch arguments, so the image
/// contains only the component and a 16-point neutral capture stage.
struct ComparisonPilotRootView: View {
    @Environment(\.theme) private var theme

    let componentID: String
    let state: String
    let appearance: ColorScheme?

    var body: some View {
        fixture
            .frame(width: componentWidth)
            .padding(16)
            .background(theme.background)
            .fixedSize(horizontal: true, vertical: true)
            .background(PilotCaptureWindowConfigurator())
            .theme(.default)
            .preferredColorScheme(appearance)
    }

    @ViewBuilder
    private var fixture: some View {
        switch (componentID, state) {
        case ("accordion", "expanded"):
            accordion(expanded: true)
        case ("accordion", "collapsed"):
            accordion(expanded: false)
        case ("alert", "default"):
            alert(destructive: false)
        case ("alert", "destructive"):
            alert(destructive: true)
        default:
            Text("Unknown pilot fixture: \(componentID)-\(state)")
                .foregroundStyle(theme.destructive)
        }
    }

    private var componentWidth: CGFloat {
        componentID == "alert" ? 672 : 448
    }

    private func accordion(expanded: Bool) -> some View {
        SCAccordion(defaultExpanded: expanded ? ["item-1"] : []) {
            SCAccordionItem(id: "item-1") {
                SCAccordionTrigger("Is it accessible?")
                SCAccordionContent {
                    Text("Yes. It adheres to the WAI-ARIA design pattern.")
                }
            }
            SCAccordionItem(id: "item-2") {
                SCAccordionTrigger("Is it styled?")
                SCAccordionContent {
                    Text("Yes. It comes with default styles that match the other components' aesthetic.")
                }
            }
            SCAccordionItem(id: "item-3", showsSeparator: false) {
                SCAccordionTrigger("Is it animated?")
                SCAccordionContent {
                    Text("Yes. It is animated by default, but you can disable it if you prefer.")
                }
            }
        }
    }

    private func alert(destructive: Bool) -> some View {
        SCAlert(variant: destructive ? .destructive : .default) {
            SCAlertTitle(destructive ? "Something went wrong" : "Heads up!")
            SCAlertDescription(
                destructive
                    ? "Your session has expired. Please log in again."
                    : "You can add components to your app using the CLI."
            )
        } leading: {
            Image(systemName: destructive ? "exclamationmark.triangle" : "info.circle")
                .font(.system(size: 16))
                .accessibilityHidden(true)
        }
    }
}

/// Shrinks the borderless capture window to the root view's intrinsic size.
/// This is deliberately pilot-only; overlay components still need the regular
/// fixed viewport capture path.
private struct PilotCaptureWindowConfigurator: NSViewRepresentable {
    func makeNSView(context: Context) -> PilotCaptureConfigurationView {
        PilotCaptureConfigurationView()
    }

    func updateNSView(_ view: PilotCaptureConfigurationView, context: Context) {
        view.configureWindow()
    }
}

private final class PilotCaptureConfigurationView: NSView {
    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        configureWindow()
    }

    func configureWindow() {
        guard let window else { return }
        window.styleMask = [.borderless]
        window.isMovable = false

        DispatchQueue.main.async { [weak window] in
            guard let window, let contentView = window.contentView else { return }
            window.layoutIfNeeded()
            let fittingSize = contentView.fittingSize
            guard fittingSize.width > 0, fittingSize.height > 0 else { return }
            window.setContentSize(fittingSize)
        }
    }
}
