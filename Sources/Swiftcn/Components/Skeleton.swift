// ============================================================
// Skeleton.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Component

/// A placeholder block shown while content is loading, with a subtle
/// shimmer sweep — shadcn's `Skeleton`.
///
///     SCSkeleton(width: 200, height: 20)
///     SCSkeleton(height: 14)                 // flexible width
///     SCSkeleton(width: 48, height: 48)
///         .clipShape(Circle())               // avatar-shaped placeholder
public struct SCSkeleton: View {
    @Environment(\.theme) private var theme

    var width: CGFloat?
    var height: CGFloat

    /// - Parameters:
    ///   - width: Fixed width, or `nil` to fill the available width.
    ///   - height: Fixed height (16 by default — one line of text).
    public init(width: CGFloat? = nil, height: CGFloat = 16) {
        self.width = width
        self.height = height
    }

    private var cornerRadius: CGFloat {
        max(theme.radius / 2, 6)
    }

    public var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(theme.muted)
            .overlay { SCSkeletonShimmer(highlight: theme.background.opacity(0.4)) }
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .frame(width: width, height: height)
            .accessibilityHidden(true)
    }
}

// MARK: - Modifier

public extension View {
    /// Swaps this view for a skeleton placeholder while `condition` is true:
    /// text and images are redacted to placeholder shapes, a shimmer sweeps
    /// across them, and hit testing is disabled. The layout keeps the
    /// content's size, so nothing jumps when loading finishes.
    ///
    ///     VStack(alignment: .leading) {
    ///         Text(article.title).font(.headline)
    ///         Text(article.summary)
    ///     }
    ///     .scSkeleton(when: isLoading)
    func scSkeleton(when condition: Bool) -> some View {
        modifier(SCSkeletonModifier(isActive: condition))
    }
}

private struct SCSkeletonModifier: ViewModifier {
    @Environment(\.theme) private var theme

    var isActive: Bool

    func body(content: Content) -> some View {
        content
            .redacted(reason: isActive ? .placeholder : [])
            .overlay {
                if isActive {
                    SCSkeletonShimmer(highlight: theme.background.opacity(0.4))
                        .mask(content.redacted(reason: .placeholder))
                }
            }
            .allowsHitTesting(!isActive)
    }
}

// MARK: - Shimmer band

/// A soft highlight band that sweeps left → right forever. Internal to
/// this file; both `SCSkeleton` and `.scSkeleton(when:)` use it.
private struct SCSkeletonShimmer: View {
    var highlight: Color

    var body: some View {
        GeometryReader { geometry in
            LinearGradient(
                colors: [highlight.opacity(0), highlight, highlight.opacity(0)],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: geometry.size.width * 0.6, height: geometry.size.height)
            // Phase -1 parks the band fully off the leading edge; 2 is fully
            // past the trailing edge, so the repeat loops seamlessly.
            .keyframeAnimator(initialValue: CGFloat(-1), repeating: true) { content, phase in
                content.offset(x: phase * geometry.size.width)
            } keyframes: { _ in
                LinearKeyframe(CGFloat(2), duration: 1.6)
            }
        }
        .allowsHitTesting(false)
    }
}

// MARK: - Previews

#Preview("Skeleton · card row") {
    SCPreview {
        HStack(spacing: 12) {
            SCSkeleton(width: 48, height: 48)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 8) {
                SCSkeleton(width: 200, height: 14)
                SCSkeleton(width: 140, height: 14)
            }
        }
    }
}

#Preview("Skeleton · scSkeleton(when:)") {
    @Previewable @State var isLoading = true
    SCPreview {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Sync complete")
                    .font(.headline)
                Text("All 128 files are up to date.")
                    .font(.subheadline)
            }
            .scSkeleton(when: isLoading)

            Button(isLoading ? "Show content" : "Show skeleton") {
                isLoading.toggle()
            }
            .buttonStyle(.sc(.outline, size: .sm))
        }
    }
}
