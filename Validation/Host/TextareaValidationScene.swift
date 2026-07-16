import Swiftcn
import SwiftUI

/// SCTextarea's multiline binding, placeholder, default and custom minimum
/// heights, invalid state, and disabled state, with edited text mirrored into
/// a visible echo so UI tests can prove real caller-owned value flow.
struct TextareaValidationScene: View {
    @State private var message = ""
    @State private var biography = "A deterministic multiline value."

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Message: \(message)")
                .accessibilityIdentifier("textarea-value-echo")

            HStack(alignment: .top, spacing: 16) {
                SCTextarea("Type your message here.", text: $message)
                    .accessibilityIdentifier("textarea-default")
                    .frame(maxWidth: 280)
                SCTextarea("Biography", text: $biography, minHeight: 120)
                    .accessibilityIdentifier("textarea-tall")
                    .frame(maxWidth: 280)
            }

            HStack(alignment: .top, spacing: 16) {
                SCTextarea("Compact", text: .constant("Compact"), minHeight: 32)
                    .accessibilityIdentifier("textarea-compact")
                    .frame(maxWidth: 280)
                SCTextarea("Invalid", text: .constant("Needs review"), isInvalid: .invalid)
                    .accessibilityIdentifier("textarea-invalid")
                    .frame(maxWidth: 280)
            }

            SCTextarea("Disabled", text: .constant("Cannot edit"), minHeight: 64)
                .disabled(true)
                .accessibilityIdentifier("textarea-disabled")
                .frame(maxWidth: 280)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
