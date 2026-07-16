import Swiftcn
import SwiftUI

/// Every SCSkeleton animation mode, the custom-shape form, and the
/// scSkeleton(when:) modifier over real content behind a loading toggle, so
/// UI tests can prove skeletons render without entering the accessibility
/// tree and that content is restored (and re-exposed) when loading ends.
struct SkeletonValidationScene: View {
    @State private var isLoading = true

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Loading: \(isLoading ? "true" : "false")")
                .accessibilityIdentifier("skeleton-loading-state")

            SCSkeleton(width: 220, height: 16)
                .accessibilityIdentifier("skeleton-pulse")
            SCSkeleton(width: 220, height: 16, animation: .shimmer)
                .accessibilityIdentifier("skeleton-shimmer")
            SCSkeleton(width: 220, height: 16, animation: .none)
                .accessibilityIdentifier("skeleton-static")
            SCSkeleton(width: 48, height: 48, shape: Circle(), animation: .none)
                .accessibilityIdentifier("skeleton-circle")

            VStack(alignment: .leading, spacing: 6) {
                Text("Sync complete")
                    .font(.headline)
                    .accessibilityIdentifier("skeleton-content-title")
                Text("All 128 files are up to date.")
                    .font(.subheadline)
                    .accessibilityIdentifier("skeleton-content-description")
            }
            .scSkeleton(when: isLoading)

            Button(isLoading ? "Show content" : "Show skeleton") {
                isLoading.toggle()
            }
            .buttonStyle(.sc(.outline, size: .sm))
            .accessibilityIdentifier("skeleton-toggle")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
