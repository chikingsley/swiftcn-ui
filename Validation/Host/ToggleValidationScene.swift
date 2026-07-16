import Swiftcn
import SwiftUI

/// Every toggle variant and size renders with native pressed semantics, while
/// a caller-owned binding and disabled control prove real state routing.
struct ToggleValidationScene: View {
    @State private var primaryPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Pressed: \(primaryPressed ? "true" : "false")")
                .accessibilityIdentifier("toggle-pressed-echo")

            HStack(spacing: 8) {
                Toggle("Default small", isOn: .constant(false))
                    .toggleStyle(.scToggle(size: .sm))
                    .accessibilityIdentifier("toggle-default-sm")
                Toggle("Default regular", isOn: $primaryPressed)
                    .toggleStyle(.scToggle())
                    .accessibilityIdentifier("toggle-default-default")
                Toggle("Default large", isOn: .constant(true))
                    .toggleStyle(.scToggle(size: .lg))
                    .accessibilityIdentifier("toggle-default-lg")
            }

            HStack(spacing: 8) {
                Toggle("Outline small", isOn: .constant(false))
                    .toggleStyle(.scToggle(variant: .outline, size: .sm))
                    .accessibilityIdentifier("toggle-outline-sm")
                Toggle("Outline regular", isOn: .constant(true))
                    .toggleStyle(.scToggle(variant: .outline))
                    .accessibilityIdentifier("toggle-outline-default")
                Toggle("Outline large", isOn: .constant(false))
                    .toggleStyle(.scToggle(variant: .outline, size: .lg))
                    .accessibilityIdentifier("toggle-outline-lg")
            }

            Toggle("Disabled toggle", isOn: .constant(true))
                .toggleStyle(.scToggle(variant: .outline))
                .disabled(true)
                .accessibilityIdentifier("toggle-disabled")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
