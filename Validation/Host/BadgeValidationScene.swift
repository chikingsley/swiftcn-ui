import Swiftcn
import SwiftUI

/// Every SCBadge variant plus the invalid state and a real Button carrying
/// SCBadgeButtonStyle, so UI tests can prove static rendering and that the
/// badge-styled native control still owns activation.
struct BadgeValidationScene: View {
    @State private var activationCount = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Activations: \(activationCount)")
                .accessibilityIdentifier("badge-activation-count")

            HStack(spacing: 8) {
                ForEach(SCBadgeVariant.allCases, id: \.self) { variant in
                    let name = String(describing: variant)
                    SCBadge(name, variant: variant)
                        .accessibilityIdentifier("badge-variant-\(name)")
                }
            }

            SCBadge("Invalid", isInvalid: true)
                .accessibilityIdentifier("badge-invalid")

            Button("Notifications") {
                activationCount += 1
            }
            .buttonStyle(SCBadgeButtonStyle(variant: .secondary))
            .accessibilityIdentifier("badge-button")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
