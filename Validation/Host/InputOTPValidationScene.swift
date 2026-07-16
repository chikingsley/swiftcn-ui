import Swiftcn
import SwiftUI

/// SCInputOTP's digit, alphanumeric, and custom filters, convenience and
/// composed group layouts, separator, invalid and disabled states, and full
/// completion callback, with code and completion mirrored into visible text.
struct InputOTPValidationScene: View {
    @State private var digitCode = ""
    @State private var alphanumericCode = "A1"
    @State private var customCode = "AB"
    @State private var completedCode = "none"

    private let customPattern = SCInputOTPPattern(inputMode: .text) { character in
        character == "A" || character == "B"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Code: \(digitCode)")
                .accessibilityIdentifier("inputotp-code-echo")
            Text("Completed: \(completedCode)")
                .accessibilityIdentifier("inputotp-completion-echo")

            SCInputOTP(
                code: $digitCode,
                length: 6,
                groupSize: 3,
                pattern: .digits,
                accessibilityLabel: "Digit code",
                onComplete: { completedCode = $0 }
            )
            .accessibilityIdentifier("inputotp-digits")

            SCInputOTP(
                code: $alphanumericCode,
                length: 4,
                groupSize: 2,
                pattern: .alphanumeric,
                accessibilityLabel: "Alphanumeric code"
            )
            .accessibilityIdentifier("inputotp-alphanumeric")

            SCInputOTP(
                code: $customCode,
                length: 4,
                pattern: customPattern,
                accessibilityLabel: "Custom code"
            ) {
                SCInputOTPGroup {
                    SCInputOTPSlot(index: 0)
                    SCInputOTPSlot(index: 1)
                }
                SCInputOTPSeparator()
                SCInputOTPGroup {
                    SCInputOTPSlot(index: 2)
                    SCInputOTPSlot(index: 3)
                }
            }
            .accessibilityIdentifier("inputotp-custom")

            SCInputOTP(
                code: .constant("12"),
                length: 4,
                groupSize: nil,
                isInvalid: true,
                accessibilityLabel: "Invalid code"
            )
            .accessibilityIdentifier("inputotp-invalid")

            SCInputOTP(
                code: .constant("987"),
                length: 4,
                groupSize: nil,
                accessibilityLabel: "Disabled code"
            )
            .disabled(true)
            .accessibilityIdentifier("inputotp-disabled")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
