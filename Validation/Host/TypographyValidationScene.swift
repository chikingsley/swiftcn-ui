import SwiftUI
import Swiftcn

/// Every shadcn typography treatment, native h1-h4 heading levels, both list
/// composition paths, and typography inside real enabled and disabled
/// controls, so UI tests can validate semantics, rendering, and action flow.
struct TypographyValidationScene: View {
    @State private var activationCount = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Activations: \(activationCount)")
                .accessibilityIdentifier("typography-activation-count")

            HStack(alignment: .top, spacing: 32) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("Level one").scH1(centered: false)
                        .accessibilityIdentifier("typography-h1")
                    Text("Level two").scH2()
                        .accessibilityIdentifier("typography-h2")
                    Text("Level three").scH3()
                        .accessibilityIdentifier("typography-h3")
                    Text("Level four").scH4()
                        .accessibilityIdentifier("typography-h4")
                    Text("A relaxed paragraph for readable prose.").scP()
                        .accessibilityIdentifier("typography-paragraph")
                    Text("A quoted observation.").scBlockquote()
                        .accessibilityIdentifier("typography-blockquote")
                }
                .frame(width: 330, alignment: .leading)

                VStack(alignment: .leading, spacing: 10) {
                    SCBulletList(["First list item", "Second list item"])
                        .accessibilityElement(children: .contain)
                        .accessibilityIdentifier("typography-string-list")
                    SCBulletList(["Alpha", "Beta"], id: \.self) { item in
                        Text(item).scSmall()
                            .accessibilityIdentifier("typography-typed-list-\(item.lowercased())")
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("typography-typed-list")
                    Text("swift build").scInlineCode()
                        .accessibilityIdentifier("typography-inline-code")
                    Text("A lead introduction").scLead()
                        .accessibilityIdentifier("typography-lead")
                    Text("Large emphasis").scLarge()
                        .accessibilityIdentifier("typography-large")
                    Text("Small supporting text").scSmall()
                        .accessibilityIdentifier("typography-small")
                    Text("Muted metadata").scMuted()
                        .accessibilityIdentifier("typography-muted")
                }
                .frame(width: 330, alignment: .leading)
            }

            HStack(spacing: 12) {
                Button {
                    activationCount += 1
                } label: {
                    Text("Styled action").scSmall()
                }
                .buttonStyle(.sc(.outline, size: .sm))
                .accessibilityIdentifier("typography-action-button")

                Button {
                } label: {
                    Text("Disabled typography").scSmall()
                }
                .buttonStyle(.sc(.outline, size: .sm))
                .disabled(true)
                .accessibilityIdentifier("typography-disabled")
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
