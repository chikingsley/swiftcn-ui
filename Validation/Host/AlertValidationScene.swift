import Swiftcn
import SwiftUI

/// Both SCAlert variants — the icon/title/description convenience and the
/// fully composed destructive form with a real SCAlertAction button wired to
/// a visible counter — so UI tests can prove slot rendering per variant and
/// that actions inside an alert still route.
struct AlertValidationScene: View {
    @State private var activationCount = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Activations: \(activationCount)")
                .accessibilityIdentifier("alert-activation-count")

            SCAlert(
                icon: "terminal",
                title: "Heads up!",
                description: "You can add components to your app using the CLI."
            )
            .accessibilityIdentifier("alert-default")

            SCAlert(variant: .destructive) {
                SCAlertTitle { Text("Payment failed") }
                    .accessibilityIdentifier("alert-destructive-title")
                SCAlertDescription {
                    Text("Choose another payment method and try again.")
                }
                .accessibilityIdentifier("alert-destructive-description")
                SCAlertAction {
                    Button("Try again") {
                        activationCount += 1
                    }
                    .buttonStyle(.sc(.outline, size: .sm))
                    .accessibilityIdentifier("alert-action-button")
                }
            } leading: {
                Image(systemName: "exclamationmark.triangle")
                    .accessibilityHidden(true)
            }
            .accessibilityIdentifier("alert-destructive")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
