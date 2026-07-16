import SwiftUI
import Swiftcn

/// Arbitrary and compact empty-state composition, both media treatments and
/// decorative semantics, title and description regions, plus real enabled
/// and disabled actions wired to caller-owned state for accessibility proof.
struct EmptyValidationScene: View {
    @State private var activationCount = 0
    @State private var lastActivated = "none"

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 16) {
                Text("Activations: \(activationCount)")
                    .accessibilityIdentifier("empty-activation-count")
                Text("Last: \(lastActivated)")
                    .accessibilityIdentifier("empty-last-activated")
            }

            HStack(alignment: .top, spacing: 20) {
                SCEmpty(horizontalPadding: 20, verticalPadding: 24, minimumHeight: 300) {
                    Text("Arbitrary root content")
                        .accessibilityIdentifier("empty-arbitrary-content")
                    SCEmptyHeader {
                        SCEmptyMedia(variant: .default, isDecorative: false) {
                            Image(systemName: "tray")
                                .accessibilityLabel("Empty tray artwork")
                                .accessibilityIdentifier("empty-media-default")
                        }
                        SCEmptyMedia(variant: .icon, isDecorative: true) {
                            Image(systemName: "sparkles")
                                .accessibilityIdentifier("empty-media-decorative")
                        }
                        SCEmptyTitle("No projects")
                            .accessibilityIdentifier("empty-title")
                        SCEmptyDescription("Create or import a project to continue.")
                            .accessibilityIdentifier("empty-description")
                    }
                    SCEmptyContent {
                        HStack(spacing: 8) {
                            Button("Create") {
                                activationCount += 1
                                lastActivated = "create"
                            }
                            .buttonStyle(.sc(size: .sm))
                            .accessibilityIdentifier("empty-create-button")
                            Button("Import") {
                                activationCount += 1
                                lastActivated = "import"
                            }
                            .buttonStyle(.sc(.outline, size: .sm))
                            .accessibilityIdentifier("empty-import-button")
                        }
                        Button("Unavailable") {}
                            .buttonStyle(.sc(.outline, size: .sm))
                            .disabled(true)
                            .accessibilityIdentifier("empty-disabled")
                    }
                }
                .accessibilityIdentifier("empty-composed")
                .frame(width: 340)

                SCEmpty(
                    "No results",
                    systemImage: "magnifyingglass",
                    description: "Try adjusting your filters.",
                    horizontalPadding: 20,
                    verticalPadding: 24,
                    minimumHeight: 300
                ) {
                    Button("Clear filters") {
                        activationCount += 1
                        lastActivated = "clear"
                    }
                    .buttonStyle(.sc(.outline, size: .sm))
                    .accessibilityIdentifier("empty-clear-button")
                }
                .accessibilityIdentifier("empty-compact")
                .frame(width: 340)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
