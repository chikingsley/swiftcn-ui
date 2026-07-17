import SwiftUI
import Swiftcn

/// Horizontal and vertical SCResizablePanelGroup instances plus a disabled
/// handle, each mirroring its real layout fractions into visible percentage
/// echoes, so UI tests can prove that dragging, arrow-key adjustment, and
/// double-click reset genuinely resize panels — and that a disabled handle
/// blocks all three — through the accessibility tree.
struct ResizableValidationScene: View {
    @State private var horizontalLayout = SCResizableLayout(["left": 0.5, "right": 0.5])
    @State private var verticalLayout = SCResizableLayout(["top": 0.5, "bottom": 0.5])
    @State private var disabledLeftPercent = 50

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Left: \(leftPercent)%")
                .accessibilityIdentifier("resizable-left-percent")
            Text("Right: \(100 - leftPercent)%")
                .accessibilityIdentifier("resizable-right-percent")
            Text("Top: \(topPercent)%")
                .accessibilityIdentifier("resizable-top-percent")
            Text("Bottom: \(100 - topPercent)%")
                .accessibilityIdentifier("resizable-bottom-percent")
            Text("Disabled left: \(disabledLeftPercent)%")
                .accessibilityIdentifier("resizable-disabled-left-percent")

            SCResizablePanelGroup(.horizontal, layout: $horizontalLayout) {
                SCResizablePanel(id: "left", minimumSize: 0.15, maximumSize: 0.85) {
                    pane("Left", identifier: "resizable-left-pane")
                }
                SCResizableHandle(
                    withHandle: true,
                    keyboardStep: 0.05,
                    accessibilityLabel: "Resize left and right panels"
                )
                SCResizablePanel(id: "right", minimumSize: 0.15, maximumSize: 0.85) {
                    pane("Right", identifier: "resizable-right-pane")
                }
            }
            .frame(height: 100)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("resizable-horizontal-group")

            SCResizablePanelGroup(.vertical, layout: $verticalLayout) {
                SCResizablePanel(id: "top", minimumSize: 0.15, maximumSize: 0.85) {
                    pane("Top", identifier: "resizable-top-pane")
                }
                SCResizableHandle(
                    withHandle: true,
                    keyboardStep: 0.05,
                    accessibilityLabel: "Resize top and bottom panels"
                )
                SCResizablePanel(id: "bottom", minimumSize: 0.15, maximumSize: 0.85) {
                    pane("Bottom", identifier: "resizable-bottom-pane")
                }
            }
            .frame(width: 280, height: 140)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("resizable-vertical-group")

            SCResizablePanelGroup(
                .horizontal,
                defaultLayout: SCResizableLayout(["disabled-left": 0.5, "disabled-right": 0.5]),
                onLayoutChange: { layout in
                    disabledLeftPercent = Int(((layout["disabled-left"] ?? 0) * 100).rounded())
                }
            ) {
                SCResizablePanel(id: "disabled-left") {
                    pane("Locked left", identifier: "resizable-disabled-left-pane")
                }
                SCResizableHandle(
                    withHandle: true,
                    isDisabled: true,
                    accessibilityLabel: "Disabled resize handle"
                )
                SCResizablePanel(id: "disabled-right") {
                    pane("Locked right", identifier: "resizable-disabled-right-pane")
                }
            }
            .frame(height: 100)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("resizable-disabled-group")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var leftPercent: Int {
        Int(((horizontalLayout["left"] ?? 0) * 100).rounded())
    }

    private var topPercent: Int {
        Int(((verticalLayout["top"] ?? 0) * 100).rounded())
    }

    private func pane(_ label: String, identifier: String) -> some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(Theme.default.muted)
            .overlay { Text(label).font(.footnote.weight(.medium)) }
            .padding(4)
            .accessibilityIdentifier(identifier)
    }
}
