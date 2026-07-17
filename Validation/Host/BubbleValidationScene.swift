import SwiftUI
import Swiftcn

/// Every SCBubble variant (including `.destructive`, the closest analog to
/// an "invalid" bubble upstream exposes), both alignments, a grouped pair,
/// overlapped reactions, custom colors, and real Button/Link content styled
/// with `.scBubbleContent()` — including a disabled instance — so UI tests
/// can prove rendering and that native controls route their activation
/// rather than the surface being purely decorative chrome.
struct BubbleValidationScene: View {
    @State private var activationCount = 0
    @State private var lastActivated = "none"

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Activations: \(activationCount)")
                .accessibilityIdentifier("bubble-activation-count")
            Text("Last: \(lastActivated)")
                .accessibilityIdentifier("bubble-last-activated")

            VStack(alignment: .leading, spacing: 8) {
                ForEach(
                    [
                        SCBubbleVariant.default, .secondary, .muted, .tinted, .outline, .ghost,
                        .destructive,
                    ],
                    id: \.self
                ) { variant in
                    let name = String(describing: variant)
                    SCBubble(variant: variant) { SCBubbleContent("Variant: \(name)") }
                        .accessibilityElement(children: .contain)
                        .accessibilityIdentifier("bubble-variant-\(name)")
                }
            }
            .frame(width: 320, alignment: .leading)

            SCBubble(align: .start) { SCBubbleContent("Start aligned") }
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("bubble-align-start")
                .frame(width: 320, alignment: .leading)
            SCBubble(align: .end) { SCBubbleContent("End aligned") }
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("bubble-align-end")
                .frame(width: 320, alignment: .leading)

            SCBubbleGroup {
                SCBubble(variant: .muted) { SCBubbleContent("It's 4:55 PM.") }
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("bubble-group-item-1")
                SCBubble(variant: .muted) { SCBubbleContent("On a Friday.") }
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("bubble-group-item-2")
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("bubble-group")
            .frame(width: 320, alignment: .leading)

            SCBubble(variant: .muted) { SCBubbleContent("Alright, let me take a look.") }
                .scBubbleReactions(accessibilityLabel: "Reactions: thumbs up") { Text("👍") }
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("bubble-with-reactions")
                .frame(width: 320, alignment: .leading)

            SCBubble {
                SCBubbleContent(backgroundColor: .black, foregroundColor: .white) {
                    Text("Custom colors")
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("bubble-custom-colors")
            .frame(width: 320, alignment: .leading)

            HStack(spacing: 12) {
                SCBubble(variant: .secondary) {
                    Button("Retry upload") {
                        activationCount += 1
                        lastActivated = "button-content"
                    }
                    .buttonStyle(.scBubbleContent())
                    .accessibilityIdentifier("bubble-button-content")
                }

                SCBubble(align: .end) {
                    Link(destination: URL(fileURLWithPath: "/bubble-validation")) {
                        Label("Open attachment", systemImage: "arrow.up.right")
                    }
                    .buttonStyle(.scBubbleContent())
                    .accessibilityIdentifier("bubble-link-content")
                }

                Button("Disabled bubble action") {
                    activationCount += 1
                    lastActivated = "disabled-button-content"
                }
                .buttonStyle(.scBubbleContent())
                .disabled(true)
                .accessibilityIdentifier("bubble-disabled")
            }
        }
        .environment(
            \.openURL,
            OpenURLAction { _ in
                activationCount += 1
                lastActivated = "link-content"
                return .handled
            }
        )
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
