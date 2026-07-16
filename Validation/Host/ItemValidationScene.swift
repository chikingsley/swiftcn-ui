import SwiftUI
import Swiftcn

/// Every Item variant, size, and media treatment; all named content regions;
/// compact composition; and real Button and Link roots wired to visible state,
/// including disabled and long-description behavior for UI validation.
struct ItemValidationScene: View {
    @State private var activationCount = 0
    @State private var lastActivated = "none"

    private let longDescription =
        "This deliberately long description must remain clamped to two lines even when the available width is narrow "
        + "and the caller supplies substantially more content than the item can display."

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 16) {
                Text("Activations: \(activationCount)")
                    .accessibilityIdentifier("item-activation-count")
                Text("Last: \(lastActivated)")
                    .accessibilityIdentifier("item-last-activated")
            }

            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 10) {
                    SCItem(variant: .default, size: .default) {
                        SCItemMedia(variant: .default, isDecorative: false) {
                            Image(systemName: "doc")
                                .accessibilityLabel("Document")
                                .accessibilityIdentifier("item-media-default")
                        }
                        SCItemContent {
                            SCItemTitle("Default item")
                                .accessibilityIdentifier("item-default-title")
                            SCItemDescription("Default variant and size.")
                        }
                    }
                    .accessibilityIdentifier("item-variant-default")

                    SCItem(variant: .outline, size: .sm) {
                        SCItemHeader {
                            Text("Header")
                                .accessibilityIdentifier("item-header")
                            Text("Metadata")
                        }
                        SCItemMedia(variant: .icon, isDecorative: true) {
                            Image(systemName: "shippingbox")
                                .accessibilityIdentifier("item-media-icon-decorative")
                        }
                        SCItemContent {
                            SCItemTitle("Outline item")
                                .accessibilityIdentifier("item-outline-title")
                            SCItemDescription("Composed with every named region.")
                        }
                        SCItemActions {
                            Button("Action") {
                                activationCount += 1
                                lastActivated = "nested-action"
                            }
                            .buttonStyle(.sc(.outline, size: .xs))
                            .accessibilityIdentifier("item-nested-action")
                        }
                        SCItemFooter {
                            Text("Footer")
                                .accessibilityIdentifier("item-footer")
                        }
                    }
                    .accessibilityIdentifier("item-variant-outline")

                    SCItem(variant: .muted, size: .xs) {
                        SCItemMedia(variant: .image, isDecorative: false) {
                            Image(systemName: "photo.fill")
                                .resizable()
                                .scaledToFill()
                                .accessibilityLabel("Photo thumbnail")
                                .accessibilityIdentifier("item-media-image")
                        }
                        SCItemContent {
                            SCItemTitle("Muted compact item")
                                .accessibilityIdentifier("item-muted-title")
                            SCItemDescription(longDescription)
                                .accessibilityIdentifier("item-long-description")
                        }
                    }
                    .accessibilityIdentifier("item-variant-muted")
                }
                .frame(width: 350)

                VStack(alignment: .leading, spacing: 10) {
                    SCItem(
                        "Compact convenience",
                        description: "String title and description.",
                        variant: .outline,
                        size: .sm
                    ) {
                        Image(systemName: "bolt")
                    } trailing: {
                        Text("Trailing")
                    }
                    .accessibilityIdentifier("item-compact")

                    SCItemButton(
                        variant: .outline,
                        action: {
                            activationCount += 1
                            lastActivated = "button-root"
                        },
                        content: {
                            SCItemContent {
                                SCItemTitle("Action item root")
                                SCItemDescription("A real native action.")
                            }
                        }
                    )
                    .accessibilityIdentifier("item-button-root")

                    SCItemLink(destination: URL(fileURLWithPath: "/item-validation"), size: .sm) {
                        SCItemContent {
                            SCItemTitle("Navigation item root")
                            SCItemDescription("A real native destination.")
                        }
                        SCItemActions {
                            Image(systemName: "arrow.up.right")
                                .accessibilityLabel("Open")
                        }
                    }
                    .accessibilityIdentifier("item-link-root")

                    SCItemButton(
                        action: {},
                        content: {
                            SCItemContent {
                                SCItemTitle("Disabled item")
                            }
                        }
                    )
                    .disabled(true)
                    .accessibilityIdentifier("item-disabled")
                }
                .frame(width: 350)
            }
        }
        .environment(
            \.openURL,
            OpenURLAction { _ in
                activationCount += 1
                lastActivated = "link-root"
                return .handled
            }
        )
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
