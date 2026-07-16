import Swiftcn
import SwiftUI

/// Every hover-card side uses deterministic controlled presentation, while a
/// focus-only trigger exercises the native keyboard-open path and AppKit panel
/// actions and dismissal update caller-owned state without pretending hover.
struct HoverCardValidationScene: View {
    @State private var actionCount = 0
    @State private var lastChange = "none"
    @State private var presentedSide: SCHoverCardSide?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Actions: \(actionCount)")
                .accessibilityIdentifier("hovercard-scene-action-count")
            Text("Last change: \(lastChange)")
                .accessibilityIdentifier("hovercard-last-change")

            HStack(spacing: 8) {
                ForEach(sides, id: \.self) { side in
                    HoverCardSideExample(
                        side: side,
                        presentedSide: $presentedSide,
                        actionCount: $actionCount,
                        lastChange: $lastChange
                    )
                }
            }

            SCHoverCard(
                openDelay: .zero,
                closeDelay: .zero,
                isHoverEnabled: false,
                isFocusEnabled: true
            ) {
                SCHoverCardTrigger {
                    Button("Focus-open hover card") {}
                        .buttonStyle(.sc(.outline))
                        .accessibilityIdentifier("hovercard-focus-trigger")
                }
            } content: {
                HoverCardPanelContent(
                    identifier: "focus",
                    actionCount: $actionCount
                )
            }

            SCHoverCard(
                isHoverEnabled: false,
                isFocusEnabled: true
            ) {
                SCHoverCardTrigger {
                    Button("Disabled hover card") {}
                        .buttonStyle(.sc(.outline))
                        .accessibilityIdentifier("hovercard-disabled")
                }
            } content: {
                HoverCardPanelContent(
                    identifier: "disabled",
                    actionCount: $actionCount
                )
            }
            .disabled(true)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var sides: [SCHoverCardSide] {
        [.top, .bottom, .leading, .trailing, .left, .right]
    }
}

private struct HoverCardSideExample: View {
    let side: SCHoverCardSide
    @Binding var presentedSide: SCHoverCardSide?
    @Binding var actionCount: Int
    @Binding var lastChange: String

    private var name: String {
        String(describing: side)
    }

    private var isPresented: Binding<Bool> {
        Binding {
            presentedSide == side
        } set: { presented in
            presentedSide = presented ? side : nil
        }
    }

    var body: some View {
        SCHoverCard(
            isPresented: isPresented,
            openDelay: .zero,
            closeDelay: .zero,
            side: side,
            isHoverEnabled: false,
            isFocusEnabled: false,
            onOpenChange: { isOpen, reason in
                lastChange = "\(isOpen ? "open" : "closed")-\(String(describing: reason))"
            }
        ) {
            SCHoverCardTrigger {
                Button(name.capitalized) { presentedSide = side }
                    .buttonStyle(.sc(.outline, size: .sm))
                    .accessibilityIdentifier("hovercard-present-\(name)")
            }
        } content: {
            HoverCardPanelContent(
                identifier: name,
                actionCount: $actionCount
            )
        }
    }
}

private struct HoverCardPanelContent: View {
    @Environment(\.scDismissHoverCard) private var dismiss

    let identifier: String
    @Binding var actionCount: Int

    var body: some View {
        SCHoverCardContent {
            VStack(alignment: .leading, spacing: 12) {
                Text("Hover card details")
                    .font(.headline)
                    .accessibilityIdentifier("hovercard-title")
                Text("An AppKit overlay panel anchored outside the host layout.")
                    .accessibilityIdentifier("hovercard-description")
                Text("Actions: \(actionCount)")
                    .accessibilityIdentifier("hovercard-action-count")
                Button("Run hover-card action") { actionCount += 1 }
                    .buttonStyle(.sc())
                    .accessibilityIdentifier("hovercard-run-action")
                Button("Dismiss hover card") { dismiss() }
                    .buttonStyle(.sc(.outline))
                    .accessibilityIdentifier("hovercard-dismiss")
            }
        }
        .accessibilityIdentifier("hovercard-\(identifier)-content")
    }
}
