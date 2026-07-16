import SwiftUI
import Swiftcn

/// SCLabel's text and arbitrary-content forms, required and disabled states,
/// activation routing, and every SCLabelledControl orientation and placement,
/// including a native labelled-pair relationship that forwards focus.
struct LabelValidationScene: View {
    @State private var accountName = ""
    @State private var activationCount = 0
    @FocusState private var accountNameIsFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Account: \(accountName)")
                .accessibilityIdentifier("label-account-echo")
            Text("Activations: \(activationCount)")
                .accessibilityIdentifier("label-activation-count")

            SCLabel(
                required: true,
                onActivate: { activationCount += 1 },
                content: {
                    Image(systemName: "envelope")
                    Text("Arbitrary content")
                }
            )
            .accessibilityIdentifier("label-arbitrary-required")

            SCLabelledControl(orientation: .vertical, labelPlacement: .leading) {
                SCLabel("Account name", required: true, focus: $accountNameIsFocused)
                    .accessibilityIdentifier("label-paired-label")
            } control: {
                TextField("Type account name", text: $accountName)
                    .focused($accountNameIsFocused)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityIdentifier("label-paired-control")
            }
            .frame(width: 280)

            HStack(spacing: 32) {
                SCLabelledControl(orientation: .vertical, labelPlacement: .trailing) {
                    SCLabel("Below control")
                        .accessibilityIdentifier("label-vertical-trailing-label")
                } control: {
                    Button("Vertical trailing") { activationCount += 1 }
                        .accessibilityIdentifier("label-vertical-trailing-control")
                }

                SCLabelledControl(orientation: .horizontal, labelPlacement: .leading) {
                    SCLabel("Before control")
                        .accessibilityIdentifier("label-horizontal-leading-label")
                } control: {
                    Button("Horizontal leading") { activationCount += 1 }
                        .accessibilityIdentifier("label-horizontal-leading-control")
                }
            }

            SCLabelledControl(orientation: .horizontal, labelPlacement: .trailing) {
                SCLabel("After control")
                    .accessibilityIdentifier("label-horizontal-trailing-label")
            } control: {
                Button("Horizontal trailing") { activationCount += 1 }
                    .accessibilityIdentifier("label-horizontal-trailing-control")
            }

            SCLabel("Disabled", onActivate: { activationCount += 100 })
                .disabled(true)
                .accessibilityIdentifier("label-disabled")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
