import SwiftUI
import Swiftcn

/// SCFieldSet/Legend/Group composition, vertical/horizontal/responsive
/// SCField orientations, a live isInvalid recomputed from caller-owned
/// state, deduplicated versus multiple SCFieldError messages, a required
/// label, and a disabled field set, so UI tests can prove real invalid
/// propagation, error rendering, and disabled semantics through the
/// accessibility tree.
struct FieldValidationScene: View {
    @State private var email = "not-an-email"
    @State private var notifications = true
    @State private var buttonActivationCount = 0
    @State private var disabledActivationCount = 0

    private var isEmailInvalid: Bool {
        !email.contains("@")
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Button activations: \(buttonActivationCount)")
                .accessibilityIdentifier("field-button-activation-count")
            Text("Disabled activations: \(disabledActivationCount)")
                .accessibilityIdentifier("field-disabled-activation-count")

            SCFieldSet {
                SCFieldLegend("Account settings")
                    .accessibilityIdentifier("field-legend")

                SCFieldGroup {
                    SCField(isInvalid: isEmailInvalid) {
                        SCFieldLabel("Email", isRequired: true)
                            .accessibilityElement(children: .contain)
                            .accessibilityIdentifier("field-email-label")
                        SCInput("you@example.com", text: $email, icon: "envelope")
                            .accessibilityLabel("Email")
                            .accessibilityIdentifier("field-email-input")
                        SCFieldDescription("We'll never share your email.")
                            .accessibilityIdentifier("field-email-description")
                        if isEmailInvalid {
                            SCFieldError(errors: ["Enter a valid email address.", "Enter a valid email address."])
                                .accessibilityElement(children: .combine)
                                .accessibilityIdentifier("field-email-error")
                        }
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("field-email")

                    SCField {
                        SCFieldLabel("Username")
                            .accessibilityElement(children: .contain)
                            .accessibilityIdentifier("field-username-label")
                        SCInput("Username", text: .constant(""))
                            .accessibilityLabel("Username")
                            .accessibilityIdentifier("field-username-input")
                        SCFieldError(errors: ["Too short.", "Already taken."])
                            .accessibilityElement(children: .combine)
                            .accessibilityIdentifier("field-username-error")
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("field-username")

                    SCField(orientation: .horizontal) {
                        SCFieldContent {
                            SCFieldLabel("Notifications")
                            SCFieldDescription("Receive account updates.")
                        }
                        .accessibilityElement(children: .contain)
                        .accessibilityIdentifier("field-notifications-content")
                        Toggle("", isOn: $notifications)
                            .labelsHidden()
                            .accessibilityLabel("Notifications")
                            .accessibilityIdentifier("field-notifications-toggle")
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("field-horizontal")

                    SCFieldSeparator {
                        Text("or")
                    }

                    SCField(orientation: .responsive) {
                        SCFieldContent {
                            SCFieldTitle("Responsive field")
                            SCFieldDescription("Stacks in narrow containers.")
                        }
                        Button("Configure") {
                            buttonActivationCount += 1
                        }
                        .buttonStyle(.sc(.outline))
                        .accessibilityIdentifier("field-responsive-button")
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("field-responsive")
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("field-set")

            SCFieldSet(isDisabled: true) {
                SCFieldLegend("Disabled section", variant: .label)
                    .accessibilityIdentifier("field-disabled-legend")
                SCField {
                    SCFieldLabel("Locked setting")
                    Button("Locked action") {
                        disabledActivationCount += 1
                    }
                    .buttonStyle(.sc(.outline))
                    .accessibilityIdentifier("field-disabled-button")
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("field-disabled-set")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
