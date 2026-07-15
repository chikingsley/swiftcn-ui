// ============================================================
// ScrollFade.swift — swiftcn-ui (Effects)
// Depends on: nothing (pure SwiftUI)
//
// SwiftUI port of shadcn/ui's `scroll-fade` utility (June 2026
// chat release): scroll-aware edge fades for scroll containers.
// Upstream is a CSS mask driven by scroll-timeline animations;
// where scroll geometry is observable (macOS 15 / iOS 18) the
// fades ease in and out with scroll position, exactly like
// upstream. On the macOS 14 / iOS 17 floor it falls back to a
// static fade on the selected edges — the same fallback
// upstream ships for browsers without scroll-driven animations.
//
//     ScrollView { rows }
//         .scScrollFade()             // vertical, both edges
//     ScrollView(.horizontal) { chips }
//         .scScrollFade(.horizontal)
// ============================================================
import SwiftUI

// MARK: - Edges

/// Which container edges fade — the Swift analog of upstream's
/// `scroll-fade`, `scroll-fade-x`, and per-edge `-t/-b/-s/-e` classes.
/// Leading/trailing are logical, so they mirror automatically in
/// right-to-left layouts.
public struct SCScrollFadeEdges: OptionSet, Sendable {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let top = SCScrollFadeEdges(rawValue: 1 << 0)
    public static let bottom = SCScrollFadeEdges(rawValue: 1 << 1)
    public static let leading = SCScrollFadeEdges(rawValue: 1 << 2)
    public static let trailing = SCScrollFadeEdges(rawValue: 1 << 3)
    public static let left = SCScrollFadeEdges(rawValue: 1 << 4)
    public static let right = SCScrollFadeEdges(rawValue: 1 << 5)

    /// Both vertical edges — upstream's bare `scroll-fade`.
    public static let vertical: SCScrollFadeEdges = [.top, .bottom]
    /// Both horizontal edges — upstream's `scroll-fade-x`.
    public static let horizontal: SCScrollFadeEdges = [.leading, .trailing]
    /// Both physical horizontal edges, matching the upstream `-l`/`-r`
    /// utilities without mirroring under RTL.
    public static let physicalHorizontal: SCScrollFadeEdges = [.left, .right]
    /// All four edges.
    public static let all: SCScrollFadeEdges = [.top, .bottom, .leading, .trailing]
}

/// Optional per-edge fade depths. Logical leading/trailing values mirror under
/// RTL; physical left/right values do not.
public struct SCScrollFadeEdgeSizes: Sendable {
    public var top: CGFloat?
    public var bottom: CGFloat?
    public var leading: CGFloat?
    public var trailing: CGFloat?
    public var left: CGFloat?
    public var right: CGFloat?

    public init(
        top: CGFloat? = nil,
        bottom: CGFloat? = nil,
        leading: CGFloat? = nil,
        trailing: CGFloat? = nil,
        left: CGFloat? = nil,
        right: CGFloat? = nil
    ) {
        self.top = top
        self.bottom = bottom
        self.leading = leading
        self.trailing = trailing
        self.left = left
        self.right = right
    }
}

// MARK: - Modifier

extension View {
    /// Fades the edges of a scroll container so clipped content reads as
    /// scrollable — the swiftcn port of shadcn/ui's `scroll-fade` utility.
    /// Apply it directly to a `ScrollView` (or a view wrapping one).
    ///
    ///     ScrollView { transcript }
    ///         .scScrollFade(.bottom)
    ///
    /// - Parameters:
    ///   - edges: Which edges fade. Defaults to `.vertical`.
    ///   - size: Fade depth in points. `nil` uses upstream's default of
    ///     12% of the container, capped at 40pt.
    ///   - edgeSizes: Optional per-edge depth overrides.
    ///   - reveal: The scroll distance over which a fade eases in near an
    ///     edge (upstream's `--scroll-fade-reveal`, default 96pt). Only
    ///     used where scroll geometry is observable.
    public func scScrollFade(
        _ edges: SCScrollFadeEdges = .vertical,
        size: CGFloat? = nil,
        edgeSizes: SCScrollFadeEdgeSizes = SCScrollFadeEdgeSizes(),
        reveal: CGFloat = 96
    ) -> some View {
        modifier(
            SCScrollFadeModifier(
                edges: edges,
                size: size,
                edgeSizes: edgeSizes,
                reveal: reveal
            )
        )
    }
}

private struct SCScrollFadeModifier: ViewModifier {
    var edges: SCScrollFadeEdges
    var size: CGFloat?
    var edgeSizes: SCScrollFadeEdgeSizes
    var reveal: CGFloat

    func body(content: Content) -> some View {
        if #available(iOS 18.0, macOS 15.0, *) {
            content.modifier(
                SCScrollFadeDynamicModifier(
                    edges: edges,
                    size: size,
                    edgeSizes: edgeSizes,
                    reveal: reveal
                )
            )
        } else {
            // Static fallback: full-strength fades on the selected edges,
            // matching upstream's non-scroll-driven fallback.
            content.mask {
                SCScrollFadeMask(
                    edges: edges,
                    size: size,
                    edgeSizes: edgeSizes,
                    progress: SCScrollFadeProgress(
                        top: 1,
                        bottom: 1,
                        leading: 1,
                        trailing: 1,
                        left: 1,
                        right: 1
                    )
                )
            }
        }
    }
}

// MARK: - Dynamic fades (macOS 15 / iOS 18)

/// How far each edge's fade has eased in, 0…1 — the analog of upstream's
/// scroll-timeline-driven custom properties.
private struct SCScrollFadeProgress: Equatable {
    var top: CGFloat = 0
    var bottom: CGFloat = 0
    var leading: CGFloat = 0
    var trailing: CGFloat = 0
    var left: CGFloat = 0
    var right: CGFloat = 0
}

@available(iOS 18.0, macOS 15.0, *)
private struct SCScrollFadeDynamicModifier: ViewModifier {
    @Environment(\.layoutDirection) private var layoutDirection
    @State private var progress = SCScrollFadeProgress()

    var edges: SCScrollFadeEdges
    var size: CGFloat?
    var edgeSizes: SCScrollFadeEdgeSizes
    var reveal: CGFloat

    func body(content: Content) -> some View {
        let rightToLeft = layoutDirection == .rightToLeft
        let revealDistance = reveal.isFinite ? max(reveal, 1) : 96
        content
            .onScrollGeometryChange(for: SCScrollFadeProgress.self) { geometry in
                let visible = geometry.visibleRect
                let startX = rightToLeft ? geometry.contentSize.width - visible.maxX : visible.minX
                let endX = rightToLeft ? visible.minX : geometry.contentSize.width - visible.maxX
                return SCScrollFadeProgress(
                    top: min(max(visible.minY / revealDistance, 0), 1),
                    bottom: min(max((geometry.contentSize.height - visible.maxY) / revealDistance, 0), 1),
                    leading: min(max(startX / revealDistance, 0), 1),
                    trailing: min(max(endX / revealDistance, 0), 1),
                    left: min(max(visible.minX / revealDistance, 0), 1),
                    right: min(max((geometry.contentSize.width - visible.maxX) / revealDistance, 0), 1)
                )
            } action: { _, newValue in
                progress = newValue
            }
            .mask {
                SCScrollFadeMask(
                    edges: edges,
                    size: size,
                    edgeSizes: edgeSizes,
                    progress: progress
                )
            }
    }
}

// MARK: - Mask

/// The alpha mask: opaque in the middle, transparent toward faded edges.
/// Vertical and horizontal gradients are intersected, mirroring upstream's
/// `mask-composite: intersect`.
private struct SCScrollFadeMask: View {
    @Environment(\.layoutDirection) private var layoutDirection

    var edges: SCScrollFadeEdges
    var size: CGFloat?
    var edgeSizes: SCScrollFadeEdgeSizes
    var progress: SCScrollFadeProgress

    var body: some View {
        GeometryReader { proxy in
            let hasVertical = !edges.isDisjoint(with: .vertical)
            let hasHorizontal = !edges.isDisjoint(with: [.leading, .trailing, .left, .right])
            if hasVertical && hasHorizontal {
                vertical(height: proxy.size.height)
                    .mask { horizontal(width: proxy.size.width) }
            } else if hasVertical {
                vertical(height: proxy.size.height)
            } else if hasHorizontal {
                horizontal(width: proxy.size.width)
            } else {
                Color.black
            }
        }
    }

    private func vertical(height: CGFloat) -> LinearGradient {
        gradient(
            length: height,
            startDepth: edges.contains(.top) ? fadeSize(for: height, override: edgeSizes.top) * progress.top : 0,
            endDepth: edges.contains(.bottom)
                ? fadeSize(for: height, override: edgeSizes.bottom) * progress.bottom : 0
        )
    }

    private func horizontal(width: CGFloat) -> LinearGradient {
        gradient(
            length: width,
            startDepth: horizontalStartDepth(width: width),
            endDepth: horizontalEndDepth(width: width),
            axis: .horizontal
        )
    }

    private func horizontalStartDepth(width: CGFloat) -> CGFloat {
        var depths: [CGFloat] = []
        if edges.contains(.leading) {
            depths.append(fadeSize(for: width, override: edgeSizes.leading) * progress.leading)
        }
        if edges.contains(.left), layoutDirection == .leftToRight {
            depths.append(fadeSize(for: width, override: edgeSizes.left) * progress.left)
        }
        if edges.contains(.right), layoutDirection == .rightToLeft {
            depths.append(fadeSize(for: width, override: edgeSizes.right) * progress.right)
        }
        return depths.max() ?? 0
    }

    private func horizontalEndDepth(width: CGFloat) -> CGFloat {
        var depths: [CGFloat] = []
        if edges.contains(.trailing) {
            depths.append(fadeSize(for: width, override: edgeSizes.trailing) * progress.trailing)
        }
        if edges.contains(.right), layoutDirection == .leftToRight {
            depths.append(fadeSize(for: width, override: edgeSizes.right) * progress.right)
        }
        if edges.contains(.left), layoutDirection == .rightToLeft {
            depths.append(fadeSize(for: width, override: edgeSizes.left) * progress.left)
        }
        return depths.max() ?? 0
    }

    private func gradient(
        length: CGFloat,
        startDepth: CGFloat,
        endDepth: CGFloat,
        axis: Axis = .vertical
    ) -> LinearGradient {
        let safeLength = max(length, 1)
        let start = min(max(startDepth / safeLength, 0), 1)
        let end = min(max(endDepth / safeLength, 0), 1)
        return LinearGradient(
            stops: [
                .init(color: .black.opacity(startDepth > 0 ? 0 : 1), location: 0),
                .init(color: .black, location: start),
                .init(color: .black, location: max(1 - end, start)),
                .init(color: .black.opacity(endDepth > 0 ? 0 : 1), location: 1),
            ],
            startPoint: axis == .vertical ? .top : .leading,
            endPoint: axis == .vertical ? .bottom : .trailing
        )
    }

    /// Upstream default: 12% of the container, capped at 40pt.
    private func fadeSize(for length: CGFloat, override: CGFloat?) -> CGFloat {
        let value = override ?? size ?? min(length * 0.12, 40)
        return value.isFinite ? max(value, 0) : 0
    }
}

// MARK: - Previews

#Preview("ScrollFade · vertical") {
    SCPreview {
        ScrollView {
            VStack(spacing: 6) {
                ForEach(1...12, id: \.self) { index in
                    Text("Item \(index)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 10)
                        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
            }
            .padding(6)
        }
        .scScrollFade()
        .frame(width: 260, height: 280)
    }
}

#Preview("ScrollFade · horizontal & single edge") {
    SCPreview {
        VStack(spacing: 24) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(["SwiftUI", "SwiftData", "Metal", "Combine", "WidgetKit"], id: \.self) { name in
                        Text(name)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(.quaternary, in: Capsule())
                    }
                }
                .padding(.horizontal, 6)
            }
            .scScrollFade(.horizontal)
            .frame(width: 260)

            ScrollView {
                VStack(spacing: 6) {
                    ForEach(1...8, id: \.self) { index in
                        Text("Row \(index)").frame(maxWidth: .infinity)
                    }
                }
            }
            .scScrollFade(.bottom, size: 32)
            .frame(width: 260, height: 120)
        }
    }
}
