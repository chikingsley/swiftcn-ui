// ============================================================
// Marquee.swift — swiftcn-ui (Effects)
// Depends on: Theme/
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

/// Scrolls its content in an endless horizontal loop — the magicui
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
    var spacing: CGFloat
    var speed: CGFloat
    var direction: SCMarqueeDirection
    var pauseOnHover: Bool
    var content: Content

    @State private var contentWidth: CGFloat = 0
    @State private var epoch = Date()
    @State private var isHovering = false
    @State private var hoverStart: Date?
    @State private var pausedTime: TimeInterval = 0

    private let fadeWidth: CGFloat = 24

    /// - Parameters:
    ///   - spacing: Gap between the end of the content and its next repetition.
    ///   - speed: Scroll speed in points per second.
    ///   - direction: Which edge the content travels toward.
    ///   - pauseOnHover: Freezes the loop while a pointer hovers over it.
    ///   - content: The content to loop; it keeps its ideal (unwrapped) width.
    public init(
        spacing: CGFloat = 32,
        speed: CGFloat = 40,
        direction: SCMarqueeDirection = .leading,
        pauseOnHover: Bool = true,
        @ViewBuilder content: () -> Content
    ) {
        self.spacing = spacing
        self.speed = speed
        self.direction = direction
        self.pauseOnHover = pauseOnHover
        self.content = content()
    }

    public var body: some View {
        // The hidden copy gives the marquee its intrinsic height and reports
        // the content's ideal width; the moving track renders in an overlay.
        content
            .fixedSize()
            .hidden()
            .background {
                GeometryReader { geometry in
                    Color.clear
                        .onAppear { contentWidth = geometry.size.width }
                        .onChange(of: geometry.size.width) { _, width in
                            contentWidth = width
                        }
                }
            }
            .frame(maxWidth: .infinity)
            .overlay {
                GeometryReader { geometry in
                    TimelineView(.animation(minimumInterval: nil, paused: isPaused)) { context in
                        track(in: geometry.size, at: elapsed(until: context.date))
                    }
                }
                .clipped()
                .mask { fadeMask }
            }
            .onHover { hovering in
                guard pauseOnHover else { return }
                if hovering {
                    hoverStart = Date()
                } else if let start = hoverStart {
                    pausedTime += Date().timeIntervalSince(start)
                    hoverStart = nil
                }
                isHovering = hovering
            }
    }

    // MARK: Track

    private func track(in size: CGSize, at time: TimeInterval) -> some View {
        let loopWidth = contentWidth + spacing
        let copies = contentWidth > 0
            ? max(2, Int((size.width / loopWidth).rounded(.up)) + 1)
            : 1
        let phase = loopWidth > 0
            ? CGFloat(time * Double(max(speed, 0))).truncatingRemainder(dividingBy: loopWidth)
            : 0
        let offset: CGFloat = switch direction {
        case .leading:  -phase
        case .trailing: phase - loopWidth
        }

        return HStack(spacing: spacing) {
            ForEach(0..<copies, id: \.self) { index in
                content
                    .fixedSize()
                    .accessibilityHidden(index > 0)
            }
        }
        .offset(x: copies > 1 ? offset : 0)
        .frame(width: size.width, height: size.height, alignment: .leading)
    }

    // MARK: Timing

    private var isPaused: Bool {
        pauseOnHover && isHovering
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
    private var fadeMask: some View {
        HStack(spacing: 0) {
            LinearGradient(
                colors: [.black.opacity(0), .black],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: fadeWidth)
            Rectangle().fill(.black)
            LinearGradient(
                colors: [.black, .black.opacity(0)],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: fadeWidth)
        }
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
