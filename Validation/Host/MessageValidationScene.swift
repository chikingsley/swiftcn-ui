import SwiftUI
import Swiftcn

/// Start- and end-aligned SCMessage rows composed from SCMessageAvatar,
/// SCMessageContent, SCMessageHeader, and SCMessageFooter; an SCMessageGroup
/// pairing a reserved empty avatar with a populated one; and a real Button
/// nested inside a footer (including a disabled row), so UI tests can prove
/// composition renders and that nested controls route their activation
/// through the row's `.accessibilityElement(children: .contain)` container
/// instead of being flattened.
struct MessageValidationScene: View {
    @State private var activationCount = 0
    @State private var lastActivated = "none"

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Activations: \(activationCount)")
                .accessibilityIdentifier("message-activation-count")
            Text("Last: \(lastActivated)")
                .accessibilityIdentifier("message-last-activated")

            SCMessage {
                SCMessageAvatar { SCAvatar(url: nil, fallback: "R", size: .sm) }
                SCMessageContent {
                    SCMessageHeader {
                        Text("Olivia").accessibilityIdentifier("message-header-text")
                    }
                    SCBubble(variant: .muted) { SCBubbleContent("I already checked the logs.") }
                    SCMessageFooter {
                        Text("Read Yesterday").accessibilityIdentifier("message-footer-text")
                    }
                }
            }
            .accessibilityIdentifier("message-row-start")

            SCMessage(align: .end) {
                SCMessageAvatar { SCAvatar(url: nil, fallback: "ME", size: .sm) }
                SCMessageContent {
                    SCBubble { SCBubbleContent("Send the report to the team.") }
                    SCMessageFooter {
                        Button("Undo send") {
                            activationCount += 1
                            lastActivated = "footer-action"
                        }
                        .buttonStyle(.sc(.ghost, size: .xs))
                        .accessibilityIdentifier("message-nested-action")
                    }
                }
            }
            .accessibilityIdentifier("message-row-end")

            SCMessageGroup {
                SCMessage {
                    SCMessageAvatar()
                        .accessibilityIdentifier("message-avatar-reserved")
                    SCMessageContent {
                        SCBubble(variant: .muted) { SCBubbleContent("It's always a one-line change 😭.") }
                    }
                }
                SCMessage {
                    SCMessageAvatar { SCAvatar(url: nil, fallback: "R", size: .sm) }
                        .accessibilityIdentifier("message-avatar-populated")
                    SCMessageContent {
                        SCBubble(variant: .muted) { SCBubbleContent("Alright, let me take a look.") }
                    }
                }
            }
            .accessibilityIdentifier("message-group")

            // SCMessage has no isDisabled/invalid concept of its own; this
            // proves environment disabling still reaches a real nested
            // Button without the row's `.contain` semantics blocking it.
            SCMessage(align: .end) {
                SCMessageContent {
                    SCBubble { SCBubbleContent("Disabled action row") }
                    SCMessageFooter {
                        Button("Disabled action") {
                            activationCount += 1
                            lastActivated = "disabled-footer-action"
                        }
                        .buttonStyle(.sc(.ghost, size: .xs))
                        .accessibilityIdentifier("message-disabled-action")
                    }
                }
            }
            .disabled(true)
            .accessibilityIdentifier("message-disabled")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
