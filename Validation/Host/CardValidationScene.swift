import Swiftcn
import SwiftUI

/// A fully composed SCCard (header with a real SCCardAction button, content,
/// footer buttons), the small size with the string conveniences, and the
/// compatibility header action slot — all actions wired to a visible counter
/// so UI tests can prove region rendering, top-trailing action placement, and
/// activation routing through the accessibility tree.
struct CardValidationScene: View {
    @State private var activationCount = 0
    @State private var lastActivated = "none"

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Activations: \(activationCount)")
                    .accessibilityIdentifier("card-activation-count")
                Text("Last: \(lastActivated)")
                    .accessibilityIdentifier("card-last-activated")
            }

            SCCard {
                SCCardHeader {
                    SCCardTitle { Text("Create project") }
                        .accessibilityIdentifier("card-title")
                    SCCardDescription { Text("Deploy your new project in one click.") }
                        .accessibilityIdentifier("card-description")
                    SCCardAction {
                        Button {
                            activationCount += 1
                            lastActivated = "header-action"
                        } label: {
                            Image(systemName: "ellipsis")
                                .accessibilityLabel("More options")
                        }
                        .buttonStyle(.sc(.ghost, size: .iconSM))
                        .accessibilityIdentifier("card-action-button")
                    }
                }
                SCCardContent {
                    Text("Any arbitrary content can go here.")
                        .accessibilityIdentifier("card-content-text")
                }
                SCCardFooter {
                    Button("Cancel") {
                        activationCount += 1
                        lastActivated = "cancel"
                    }
                    .buttonStyle(.sc(.outline, size: .sm))
                    .accessibilityIdentifier("card-footer-cancel")
                    Button("Deploy") {
                        activationCount += 1
                        lastActivated = "deploy"
                    }
                    .buttonStyle(.sc(size: .sm))
                    .accessibilityIdentifier("card-footer-deploy")
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("card-composed")

            SCCard(size: .sm) {
                SCCardHeader {
                    SCCardTitle("Notifications")
                        .accessibilityIdentifier("card-small-title")
                    SCCardDescription("You have 3 unread messages.")
                        .accessibilityIdentifier("card-small-description")
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("card-small")

            SCCard(size: .sm) {
                SCCardHeader {
                    SCCardTitle("Compatibility slot")
                        .accessibilityIdentifier("card-compat-title")
                } action: {
                    Button("Act") {
                        activationCount += 1
                        lastActivated = "compat-action"
                    }
                    .buttonStyle(.sc(.outline, size: .xs))
                    .accessibilityIdentifier("card-compat-action-button")
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("card-compat")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
