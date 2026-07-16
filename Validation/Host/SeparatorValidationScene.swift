import Swiftcn
import SwiftUI

/// Horizontal, vertical, labeled, custom-labeled, and decorative separators,
/// plus a button that swaps the labeled separator's text, so UI tests can
/// prove semantic separators are exposed with their orientation, decorative
/// ones are hidden, and the label slot re-renders from state.
struct SeparatorValidationScene: View {
    @State private var labelIsFlipped = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("swiftcn-ui")
                .font(.subheadline.weight(.medium))
                .accessibilityIdentifier("separator-heading")

            SCSeparator()
                .accessibilityIdentifier("separator-horizontal")

            HStack(spacing: 12) {
                Text("Docs").font(.subheadline)
                SCSeparator(.vertical)
                    .accessibilityIdentifier("separator-vertical")
                Text("Source").font(.subheadline)
            }
            .frame(height: 20)

            SCSeparator(label: labelIsFlipped ? "or start a trial" : "or continue with")
                .accessibilityIdentifier("separator-labeled")

            SCSeparator(accessibilityLabel: "Alternative sign-in methods") {
                Label("or use passkey", systemImage: "person.badge.key")
            }
            .accessibilityIdentifier("separator-custom-label")

            SCSeparator {
                Text("view labeled")
            }
            .accessibilityIdentifier("separator-view-labeled")

            SCSeparator(isDecorative: true)
                .accessibilityIdentifier("separator-decorative")

            Button("Flip label") {
                labelIsFlipped.toggle()
            }
            .buttonStyle(.sc(.outline, size: .sm))
            .accessibilityIdentifier("separator-flip-label")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
