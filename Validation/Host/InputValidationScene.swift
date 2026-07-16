import SwiftUI
import Swiftcn

/// Every SCInput value type, text intent, size, validation state, and accessory
/// wired to caller-owned values, so UI tests can prove real editing, secure
/// reveal, accessory actions, and disabled semantics through accessibility.
struct InputValidationScene: View {
    @State private var text = ""
    @State private var email = "reader@example.com"
    @State private var password = "secret"
    @State private var telephone = "5550100"
    @State private var url = "https://example.com"
    @State private var search = "swiftcn"
    @State private var numberText = "42"
    @State private var integer = 7
    @State private var decimal = 1.5
    @State private var accessoryActivations = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Text: \(text)")
                .accessibilityIdentifier("input-text-echo")
            Text("Integer: \(integer); Double: \(decimal.formatted(.number))")
                .accessibilityIdentifier("input-typed-echo")
            Text("Accessory activations: \(accessoryActivations)")
                .accessibilityIdentifier("input-accessory-count")

            HStack(spacing: 12) {
                SCInput("Text", text: $text, kind: .text)
                    .accessibilityIdentifier("input-text")
                SCInput("Email", text: $email, kind: .email, size: .sm)
                    .accessibilityIdentifier("input-email")
                SCInput("Password", text: $password, secure: true)
                    .accessibilityIdentifier("input-password")
            }

            HStack(spacing: 12) {
                SCInput("Telephone", text: $telephone, kind: .telephone)
                    .accessibilityIdentifier("input-telephone")
                SCInput("URL", text: $url, kind: .url)
                    .accessibilityIdentifier("input-url")
                SCInput("Number text", text: $numberText, kind: .number)
                    .accessibilityIdentifier("input-number")
            }

            HStack(spacing: 12) {
                SCInput("Search", text: $search, icon: "magnifyingglass", kind: .search) {
                    Button {
                        search = ""
                        accessoryActivations += 1
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Clear search")
                    .accessibilityIdentifier("input-trailing-accessory")
                }
                .accessibilityIdentifier("input-search")

                SCInput("Integer", value: $integer)
                    .accessibilityIdentifier("input-integer")
                SCInput("Double", value: $decimal)
                    .accessibilityIdentifier("input-double")
            }

            HStack(spacing: 12) {
                SCInput("Invalid", text: .constant("invalid"), isInvalid: .invalid)
                    .accessibilityIdentifier("input-invalid")
                SCInput("Disabled", text: .constant("disabled"))
                    .disabled(true)
                    .accessibilityIdentifier("input-disabled")
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
