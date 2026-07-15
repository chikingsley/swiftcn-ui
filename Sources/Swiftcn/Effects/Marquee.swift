// ============================================================
// Marquee.swift — swiftcn-ui (Effects)
// Depends on: SwiftUI
// ============================================================
import SwiftUI

// MARK: - Direction

public enum SCMarqueeDirection: Sendable {
    /// Content travels toward the leading edge (right to left in LTR).
    case leading
    /// Content travels toward the trailing edge (left to right in LTR).
    case trailing
}

// MARK: - Effect

/// Scrolls its content in an endless horizontal or vertical loop — the Magic UI
/// `Marquee` port. The content is measured once, tiled with `spacing`
/// between repetitions, and the scroll position is derived from
/// `TimelineView(.animation)` time, so the loop is restart-safe, stops
/// ticking off-screen, and never accumulates animation state. Both edges
/// fade out over 24pt. With `pauseOnHover`, a pointer over the marquee
/// (macOS, iPad trackpad) freezes it in place and it resumes seamlessly.
///
///     SCMarquee {
///         HStack(spacing: 32) {
///             ForEach(stack, id: \.self) { SCBadge($0, variant: .secondary) }
///         }
///     }
///
///     SCMarquee(speed: 80, direction: .trailing) { logos }
public struct SCMarquee<Content: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.layoutDirection) private var layoutDirection

    private let spacing: CGFloat
    private let speed: CGFloat
    private let direction: SCMarqueeDirection
    private let pauseOnHover: Bool
    private let axis: Axis
    private let repeatCount: Int
    private let fadeLength: CGFloat
    private let content: Content

    @State private var contentSize: CGSize = .zero
    @State private var epoch = Date()
    @State private var isHovering = false
    @State private var hoverStart: Date?
    @State private var pausedTime: TimeInterval = 0

    /// - Parameters:
    ///   - spacing: Gap between the end of the content and its next repetition.
    ///   - speed: Scroll speed in points per second.
    ///   - direction: Which edge the content travels toward.
    ///   - pauseOnHover: Freezes the loop while a pointer hovers over it.
    ///   - axis: Horizontal or vertical travel.
    ///   - repeatCount: Minimum number of copies. Additional copies are added
    ///     when needed to fill the container without a gap.
    ///   - fadeLength: Length of the optional edge fades. Set to zero to
    ///     disable them.
    ///   - content: The content to loop; it keeps its ideal unwrapped size.
    public init(
        spacing: CGFloat = 16,
        speed: CGFloat = 40,
        direction: SCMarqueeDirection = .leading,
        pauseOnHover: Bool = false,
        axis: Axis = .horizontal,
        repeatCount: Int = 4,
        fadeLength: CGFloat = 24,
        @ViewBuilder content: () -> Content
    ) {
        self.spacing = spacing
        self.speed = speed
        self.direction = direction
        self.pauseOnHover = pauseOnHover
        self.axis = axis
        self.repeatCount = repeatCount
        self.fadeLength = fadeLength
        self.content = content()
    }

    public var body: some View {
        // The hidden copy gives the marquee its intrinsic height and reports
        // the content's ideal size; the moving track renders in an overlay.
        content
            .fixedSize()
            .hidden()
            .background {
                GeometryReader { geometry in
                    Color.clear
                        .onAppear { contentSize = geometry.size }
                        .onChange(of: geometry.size) { _, size in
                            contentSize = size
                        }
                }
            }
            .frame(
                maxWidth: axis == .horizontal ? .infinity : nil,
                maxHeight: axis == .vertical ? .infinity : nil
            )
            .overlay {
                GeometryReader { geometry in
                    TimelineView(.animation(minimumInterval: nil, paused: isPaused)) { context in
                        track(in: geometry.size, at: elapsed(until: context.date))
                    }
                }
                .clipped()
                .mask {
                    if resolvedFadeLength > 0 {
                        fadeMask
                    } else {
                        Color.black
                    }
                }
            }
            .onHover { hovering in
                guard pauseOnHover else { return }
                if hovering {
                    if hoverStart == nil {
                        hoverStart = Date()
                    }
                } else if let start = hoverStart {
                    pausedTime += Date().timeIntervalSince(start)
                    hoverStart = nil
                }
                isHovering = hovering
            }
    }

    // MARK: Track

    @ViewBuilder
    private func track(in size: CGSize, at time: TimeInterval) -> some View {
        let loopLength = contentLength + resolvedSpacing
        let copyCount = copies(in: size, loopLength: loopLength)
        let offset = motionOffset(at: time, loopLength: loopLength)

        if axis == .horizontal {
            HStack(spacing: resolvedSpacing) {
                repeatedContent(count: copyCount)
            }
            .offset(x: copyCount > 1 ? offset : 0)
            .frame(width: size.width, height: size.height, alignment: .leading)
        } else {
            VStack(spacing: resolvedSpacing) {
                repeatedContent(count: copyCount)
            }
            .offset(y: copyCount > 1 ? offset : 0)
            .frame(width: size.width, height: size.height, alignment: .top)
        }
    }

    @ViewBuilder
    private func repeatedContent(count: Int) -> some View {
        ForEach(0..<count, id: \.self) { index in
            content
                .fixedSize()
                .accessibilityHidden(index > 0)
        }
    }

    private var contentLength: CGFloat {
        axis == .horizontal ? contentSize.width : contentSize.height
    }

    private func copies(in size: CGSize, loopLength: CGFloat) -> Int {
        guard loopLength > 0 else { return 1 }
        let containerLength = axis == .horizontal ? size.width : size.height
        let automatic = Int((containerLength / loopLength).rounded(.up)) + 1
        return max(2, max(repeatCount, automatic))
    }

    private func motionOffset(at time: TimeInterval, loopLength: CGFloat) -> CGFloat {
        guard !reduceMotion, resolvedSpeed > 0, loopLength > 0 else { return 0 }
        let phase = CGFloat(time * Double(resolvedSpeed)).truncatingRemainder(dividingBy: loopLength)
        return usesNegativeOffset ? -phase : phase - loopLength
    }

    private var usesNegativeOffset: Bool {
        if axis == .vertical {
            return direction == .leading
        }
        switch (direction, layoutDirection) {
        case (.leading, .leftToRight), (.trailing, .rightToLeft):
            return true
        default:
            return false
        }
    }

    private var resolvedSpacing: CGFloat {
        spacing.isFinite ? max(spacing, 0) : 0
    }

    private var resolvedSpeed: CGFloat {
        speed.isFinite ? max(speed, 0) : 0
    }

    private var resolvedFadeLength: CGFloat {
        fadeLength.isFinite ? max(fadeLength, 0) : 0
    }

    // MARK: Timing

    private var isPaused: Bool {
        reduceMotion || resolvedSpeed == 0 || (pauseOnHover && isHovering)
    }

    /// Seconds of scroll time, excluding everything spent paused. While
    /// hovering the clock pins to the hover start, so pausing and resuming
    /// never jumps the track.
    private func elapsed(until date: Date) -> TimeInterval {
        let end = (pauseOnHover ? hoverStart : nil) ?? date
        return max(0, end.timeIntervalSince(epoch) - pausedTime)
    }

    // MARK: Fade mask

    /// Only alpha matters: opaque center, 24pt linear fades on each edge.
    @ViewBuilder
    private var fadeMask: some View {
        if axis == .horizontal {
            HStack(spacing: 0) {
                edgeFade(startPoint: .leading, endPoint: .trailing)
                    .frame(width: resolvedFadeLength)
                Rectangle().fill(.black)
                edgeFade(startPoint: .trailing, endPoint: .leading)
                    .frame(width: resolvedFadeLength)
            }
        } else {
            VStack(spacing: 0) {
                edgeFade(startPoint: .top, endPoint: .bottom)
                    .frame(height: resolvedFadeLength)
                Rectangle().fill(.black)
                edgeFade(startPoint: .bottom, endPoint: .top)
                    .frame(height: resolvedFadeLength)
            }
        }
    }

    private func edgeFade(startPoint: UnitPoint, endPoint: UnitPoint) -> LinearGradient {
        LinearGradient(
            colors: [.black.opacity(0), .black],
            startPoint: startPoint,
            endPoint: endPoint
        )
    }
}

// MARK: - Previews

#Preview("Marquee") {
    SCPreview {
        SCMarquee {
            HStack(spacing: 32) {
                ForEach(
                    ["SwiftUI", "SwiftData", "Metal", "Combine", "WidgetKit", "TestFlight"],
                    id: \.self
                ) { name in
                    SCBadge(name, variant: .secondary)
                }
            }
        }
    }
}

#Preview("Marquee · trailing, fast") {
    SCPreview {
        VStack(spacing: 16) {
            SCMarquee(speed: 80) {
                HStack(spacing: 32) {
                    ForEach(["Xcode", "Instruments", "Playgrounds", "Simulator"], id: \.self) {
                        SCBadge($0, variant: .outline)
                    }
                }
            }
            SCMarquee(speed: 80, direction: .trailing) {
                HStack(spacing: 32) {
                    ForEach(["iOS", "iPadOS", "macOS", "watchOS", "visionOS"], id: \.self) {
                        SCBadge($0)
                    }
                }
            }
        }
    }
}
