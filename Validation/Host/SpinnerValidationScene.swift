import SwiftUI
import Swiftcn

/// Default, compact, large, custom-stroke, accented, and disabled spinners
/// with explicit status labels, plus caller-owned appearance state, so tests
/// can validate stable geometry and semantics without sampling animation.
struct SpinnerValidationScene: View {
    @State private var usesAccentAppearance = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Appearance: \(usesAccentAppearance ? "accent" : "secondary")")
                .accessibilityIdentifier("spinner-appearance-echo")

            HStack(spacing: 28) {
                SCSpinner(size: 14, lineWidth: 1.5, accessibilityLabel: Text("Loading compact"))
                    .accessibilityIdentifier("spinner-compact")
                SCSpinner(accessibilityLabel: Text("Loading default"))
                    .accessibilityIdentifier("spinner-default")
                SCSpinner(size: 32, lineWidth: 3, accessibilityLabel: Text("Loading large"))
                    .accessibilityIdentifier("spinner-large")
                SCSpinner(size: 24, lineWidth: 4, accessibilityLabel: Text("Loading custom stroke"))
                    .accessibilityIdentifier("spinner-custom-stroke")
                SCSpinner(size: 24, accessibilityLabel: Text("Loading accented"))
                    .foregroundStyle(usesAccentAppearance ? Color.accentColor : Color.secondary)
                    .accessibilityIdentifier("spinner-appearance")
                SCSpinner(size: 24, accessibilityLabel: Text("Loading disabled"))
                    .disabled(true)
                    .accessibilityIdentifier("spinner-disabled")
            }

            Button("Toggle appearance") {
                usesAccentAppearance.toggle()
            }
            .buttonStyle(.sc(.outline, size: .sm))
            .accessibilityIdentifier("spinner-appearance-toggle")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
