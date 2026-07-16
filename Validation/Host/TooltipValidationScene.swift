import Swiftcn
import SwiftUI

/// Provider-backed tooltip triggers cover every edge, real caller actions,
/// keyboard-focus presentation requests, and disabled trigger semantics while
/// leaving the intentionally accessibility-hidden bubble as visual evidence.
struct TooltipValidationScene: View {
    @State private var actionCount = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Actions: \(actionCount)")
                .accessibilityIdentifier("tooltip-action-count")

            SCTooltip("Top tooltip", side: .top) {
                tooltipButton(title: "Top", identifier: "tooltip-trigger-top")
            }

            tooltipButton(title: "Bottom", identifier: "tooltip-trigger-bottom")
                .scTooltip("Bottom tooltip", edge: .bottom)

            tooltipButton(title: "Leading", identifier: "tooltip-trigger-leading")
                .scTooltip("Leading tooltip", edge: .leading)

            tooltipButton(title: "Trailing", identifier: "tooltip-trigger-trailing")
                .scTooltip("Trailing tooltip", edge: .trailing)

            SCTooltip("Unavailable tooltip") {
                Button("Disabled tooltip") {}
                    .buttonStyle(.sc(.outline))
                    .disabled(true)
                    .accessibilityIdentifier("tooltip-disabled")
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .scTooltipProvider()
    }

    private func tooltipButton(title: String, identifier: String) -> some View {
        Button(title) { actionCount += 1 }
            .buttonStyle(.sc(.outline))
            .accessibilityIdentifier(identifier)
    }
}
