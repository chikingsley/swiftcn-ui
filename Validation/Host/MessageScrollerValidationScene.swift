import SwiftUI
import Swiftcn

/// A conversation of 20 SCMessageScrollerItems (five of them turn anchors)
/// hosted in SCMessageScroller/Viewport/Content, driven by an externally
/// owned SCMessageScrollerState so its derived, caller-observable state
/// (current anchor, visible count, at-end, and both scrollable-edge flags)
/// can be echoed and asserted after real scrollToStart/scrollToEnd/
/// scrollToMessage commands — plus the floating SCMessageScrollerButtons
/// that gate their own hit-testing and accessibility on that same state.
struct MessageScrollerValidationScene: View {
    @State private var scroller = SCMessageScrollerState(defaultScrollPosition: .end)

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Anchor: \(scroller.currentAnchorId ?? "none")")
                .accessibilityIdentifier("messagescroller-anchor-echo")
            Text("Visible: \(scroller.visibleMessageIds.count)")
                .accessibilityIdentifier("messagescroller-visible-echo")
            Text("AtEnd: \(scroller.isAtEnd ? "true" : "false")")
                .accessibilityIdentifier("messagescroller-atend-echo")
            Text("CanStart: \(scroller.canScrollToStart ? "true" : "false")")
                .accessibilityIdentifier("messagescroller-canstart-echo")
            Text("CanEnd: \(scroller.canScrollToEnd ? "true" : "false")")
                .accessibilityIdentifier("messagescroller-canend-echo")

            SCMessageScroller(state: scroller) {
                SCMessageScrollerViewport {
                    SCMessageScrollerContent {
                        ForEach(1...20, id: \.self) { index in
                            SCMessageScrollerItem(
                                messageId: "m\(index)",
                                scrollAnchor: index.isMultiple(of: 5)
                            ) {
                                SCMessage {
                                    SCMessageContent {
                                        SCBubble(variant: .muted) {
                                            SCBubbleContent("Message #\(index)")
                                        }
                                    }
                                }
                                .accessibilityIdentifier("messagescroller-item-m\(index)")
                            }
                        }
                    }
                    .padding(16)
                }
                SCMessageScrollerButton()
                    .accessibilityIdentifier("messagescroller-scroll-end-button")
                SCMessageScrollerButton(direction: .start)
                    .accessibilityIdentifier("messagescroller-scroll-start-button")
            }
            .frame(width: 400, height: 260)
            .accessibilityIdentifier("messagescroller-root")

            HStack(spacing: 8) {
                Button("Jump to m5") { scroller.scrollToMessage("m5") }
                    .buttonStyle(.sc(.outline, size: .sm))
                    .accessibilityIdentifier("messagescroller-jump-m5")
                Button("Scroll to start") { scroller.scrollToStart() }
                    .buttonStyle(.sc(.outline, size: .sm))
                    .accessibilityIdentifier("messagescroller-command-start")
                Button("Scroll to end") { scroller.scrollToEnd() }
                    .buttonStyle(.sc(.outline, size: .sm))
                    .accessibilityIdentifier("messagescroller-command-end")
                // SCMessageScrollerButton has no isDisabled parameter; this
                // plain command button demonstrates the standard SwiftUI
                // disabled contract on the same scroller commands.
                Button("Disabled command") { scroller.scrollToStart() }
                    .buttonStyle(.sc(.outline, size: .sm))
                    .disabled(true)
                    .accessibilityIdentifier("messagescroller-disabled-command")
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
