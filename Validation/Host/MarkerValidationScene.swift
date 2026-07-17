import SwiftUI
import Swiftcn

/// Every SCMarker variant, an axis/alignment combination, the `.status` role
/// live announcement (with its content driven by caller-owned state), real
/// SCMarkerButton/SCMarkerLink roots (one disabled), and a native Button
/// nested inside SCMarkerContent — proving the marker's
/// `.accessibilityElement(children: .contain)` keeps nested controls
/// independently reachable instead of flattening them into the marker's own
/// label.
struct MarkerValidationScene: View {
    @State private var activationCount = 0
    @State private var lastActivated = "none"
    @State private var statusAnnouncement = "Compacting conversation"

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Activations: \(activationCount)")
                .accessibilityIdentifier("marker-activation-count")
            Text("Last: \(lastActivated)")
                .accessibilityIdentifier("marker-last-activated")

            SCMarker {
                SCMarkerIcon { Image(systemName: "checkmark") }
                SCMarkerContent("Explored 4 files")
            }
            .accessibilityIdentifier("marker-variant-default")

            SCMarker(variant: .border) {
                SCMarkerContent("Yesterday")
            }
            .accessibilityIdentifier("marker-variant-border")

            SCMarker(variant: .separator) {
                SCMarkerContent("Today")
            }
            .accessibilityIdentifier("marker-variant-separator")

            SCMarker(axis: .vertical, alignment: .center) {
                SCMarkerIcon { Image(systemName: "doc.text") }
                SCMarkerContent("Vertical, centered")
            }
            .accessibilityIdentifier("marker-axis-vertical")

            SCMarker(alignment: .trailing) {
                SCMarkerContent("Trailing alignment")
            }
            .accessibilityIdentifier("marker-alignment-trailing")

            SCMarker(
                role: .status,
                statusAnnouncement: statusAnnouncement
            ) {
                SCMarkerIcon { Image(systemName: "arrow.triangle.2.circlepath") }
                SCMarkerContent(statusAnnouncement)
                    .accessibilityIdentifier("marker-status-text")
            }
            .accessibilityIdentifier("marker-status")

            Button("Advance status") {
                statusAnnouncement = "Running tests"
            }
            .buttonStyle(.sc(.outline, size: .sm))
            .accessibilityIdentifier("marker-status-advance")

            SCMarkerButton(
                action: {
                    activationCount += 1
                    lastActivated = "button-root"
                },
                content: {
                    SCMarkerIcon { Image(systemName: "clock") }
                    SCMarkerContent("Marker as a native action")
                }
            )
            .accessibilityIdentifier("marker-button-root")

            SCMarkerLink(destination: URL(fileURLWithPath: "/marker-validation")) {
                SCMarkerContent("Marker as a navigable destination")
            }
            .accessibilityIdentifier("marker-link-root")

            // Marker has no isDisabled/invalid concept of its own; this
            // proves the native Button underneath SCMarkerButton still
            // honors the standard SwiftUI environment disabling.
            SCMarkerButton(
                action: {
                    activationCount += 1
                    lastActivated = "disabled-button"
                },
                content: {
                    SCMarkerContent("Disabled marker button")
                }
            )
            .disabled(true)
            .accessibilityIdentifier("marker-disabled")

            SCMarker(variant: .separator) {
                SCMarkerContent {
                    Button("Nested action") {
                        activationCount += 1
                        lastActivated = "nested-action"
                    }
                    .buttonStyle(.sc(.outline, size: .sm))
                    .accessibilityIdentifier("marker-nested-action")
                }
            }
            .accessibilityIdentifier("marker-nested-container")
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
