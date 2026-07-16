// ============================================================
// Shimmer.swift — swiftcn-ui (Effects)
// Depends on: Theme/, Components/Button.swift (SCShimmerButton only)
//
// `scShimmer` is the port of shadcn/ui's `shimmer` utility (June
// 2026 chat release) — a text shimmer for live status, also used
// by Attachment while uploading/processing. `SCShimmerButton` is
// a swiftcn-native effect, not an upstream component.
// ============================================================
import SwiftUI

// MARK: - Modifier

extension View {
    /// Sweeps a highlight across this view, masked to its shape — the
    /// swiftcn port of shadcn/ui's `shimmer` utility (June 2026 chat
    /// release), used upstream as a text shimmer for live status. The
    /// highlight derives from the theme — fading toward the background in
    /// light appearance and brightening in dark, like upstream's
    /// `currentColor`-derived band. The sweep follows the layout
    /// direction, and it disables itself under Reduce Motion.
    ///
    ///     SCMarkerContent("Thinking…").scShimmer()
    ///
    ///     Text("Introducing swiftcn 2.0")
    ///         .font(.title2.weight(.semibold))
    ///         .scShimmer(duration: 3)
    ///
    /// - Parameters:
    ///   - active: Whether the sweep is running; `false` renders the view
    ///     untouched (upstream's `shimmer-none`).
    ///   - duration: Seconds per sweep (upstream's `shimmer-duration`).
    ///   - spread: Width of the highlight band in points (upstream's
    ///     `shimmer-spread`).
    ///   - angle: Tilt of the band (upstream's `shimmer-angle`).
    ///   - color: Overrides the derived highlight (upstream's
    ///     `shimmer-color`).
    ///   - repeats: `false` runs a single sweep (upstream's
    ///     `shimmer-once`).
    ///   - reverse: Sweeps against the reading direction (upstream's
    ///     `shimmer-reverse`).
    public func scShimmer(
        active: Bool = true,
        duration: Double = 2,
        spread: CGFloat = 72,
        angle: Angle = .degrees(20),
        color: Color? = nil,
        repeats: Bool = true,
        reverse: Bool = false
    ) -> some View {
        modifier(
            SCShimmerModifier(
                active: active,
                duration: duration,
                spread: spread,
                angle: angle,
                color: color,
                repeats: repeats,
                reverse: reverse
            )
        )
    }
}

private struct SCShimmerModifier: ViewModifier {
    @Environment(\.theme) private var theme
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var active: Bool
    var duration: Double
    var spread: CGFloat
    var angle: Angle
    var color: Color?
    var repeats: Bool
    var reverse: Bool

    func body(content: Content) -> some View {
        content.overlay {
            // Reduce Motion renders the view untouched, exactly like
            // upstream's prefers-reduced-motion fallback.
            if active && !reduceMotion {
                GeometryReader { geometry in
                    let containerWidth = geometry.size.width
                    let containerHeight = geometry.size.height

                    LinearGradient(
                        colors: [
                            highlight.opacity(0),
                            highlight,
                            highlight.opacity(0),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: resolvedSpread, height: containerHeight * 3)
                    .rotationEffect(resolvedAngle, anchor: .center)
                    .offset(y: -containerHeight)
                    // Phase -1 parks the band fully off the starting edge; 2
                    // is fully past the far edge, so the repeat loops
                    // seamlessly. The sweep follows the reading direction.
                    .keyframeAnimator(initialValue: startPhase, repeating: repeats) { band, phase in
                        band.offset(x: phase * containerWidth)
                    } keyframes: { _ in
                        LinearKeyframe(endPhase, duration: resolvedDuration)
                    }
                }
                .mask(content)
                .allowsHitTesting(false)
            }
        }
    }

    /// Upstream derives the band from `currentColor`: a faded highlight in
    /// light appearance, a brightened one in dark.
    private var highlight: Color {
        if let color { return color }
        return colorScheme == .dark ? theme.foreground.opacity(0.9) : theme.background.opacity(0.85)
    }

    private var sweepsBackward: Bool {
        // XOR: an explicit reverse flips whatever the reading direction is.
        (layoutDirection == .rightToLeft) != reverse
    }

    private var startPhase: CGFloat { sweepsBackward ? 2 : -1 }

    private var endPhase: CGFloat { sweepsBackward ? -1 : 2 }

    private var resolvedDuration: Double {
        duration.isFinite ? max(duration, 0.01) : 2
    }

    private var resolvedSpread: CGFloat {
        spread.isFinite ? max(spread, 0) : 72
    }

    private var resolvedAngle: Angle {
        angle.radians.isFinite ? angle : .degrees(20)
    }
}

// MARK: - Component

/// A call-to-action button with a highlight that endlessly travels its
/// border — the v1 `ShimmerButton`, rebuilt on `SCButtonStyle` and theme
/// tokens.
///
///     SCShimmerButton(text: "Get Started") { start() }
public struct SCShimmerButton: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.theme) private var theme

    private let variant: SCButtonVariant
    private let size: SCButtonSize
    private let duration: Double
    private let beamColor: Color?
    private let lineWidth: CGFloat
    private let beamLength: CGFloat
    private let action: () -> Void
    private let label: AnyView

    /// - Parameters:
    ///   - text: The button label.
    ///   - variant: Shared `SCButtonStyle` variant.
    ///   - size: Shared `SCButtonStyle` size.
    ///   - duration: Seconds for one full lap of the border highlight.
    ///   - beamColor: Optional border highlight override.
    ///   - lineWidth: Highlight stroke width.
    ///   - beamLength: Fraction of the rounded border occupied by the beam.
    ///   - action: Performed on tap.
    public init(
        text: String,
        variant: SCButtonVariant = .default,
        size: SCButtonSize = .default,
        duration: Double = 3,
        beamColor: Color? = nil,
        lineWidth: CGFloat = 2,
        beamLength: CGFloat = 0.15,
        action: @escaping () -> Void
    ) {
        self.variant = variant
        self.size = size
        self.duration = duration
        self.beamColor = beamColor
        self.lineWidth = lineWidth
        self.beamLength = beamLength
        self.action = action
        label = AnyView(Text(text))
    }

    /// Creates a shimmer button with arbitrary icon, text, or rich SwiftUI
    /// label content while retaining the accepted Button engine.
    public init<Label: View>(
        variant: SCButtonVariant = .default,
        size: SCButtonSize = .default,
        duration: Double = 3,
        beamColor: Color? = nil,
        lineWidth: CGFloat = 2,
        beamLength: CGFloat = 0.15,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.variant = variant
        self.size = size
        self.duration = duration
        self.beamColor = beamColor
        self.lineWidth = lineWidth
        self.beamLength = beamLength
        self.action = action
        self.label = AnyView(label())
    }

    @ViewBuilder
    public var body: some View {
        // Resolve environment and actor-isolated values before entering the
        // keyframe animator's nonisolated render closure.
        let lineWidth = resolvedLineWidth
        let beamLength = resolvedBeamLength
        let beamColor = resolvedBeamColor
        let cornerRadius = theme.radius
        let duration = resolvedDuration

        if reduceMotion || lineWidth == 0 || beamLength == 0 {
            button
        } else {
            button
                .keyframeAnimator(initialValue: CGFloat(0), repeating: true) { content, progress in
                    content.overlay {
                        SCBorderBeam(
                            progress: progress,
                            length: beamLength,
                            cornerRadius: cornerRadius
                        )
                        .stroke(
                            beamColor,
                            style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                        )
                        .allowsHitTesting(false)
                        .accessibilityHidden(true)
                    }
                } keyframes: { _ in
                    LinearKeyframe(CGFloat(1), duration: duration)
                }
        }
    }

    private var button: some View {
        Button(action: action) {
            label
        }
        .buttonStyle(.sc(variant, size: size))
    }

    private var resolvedBeamColor: Color {
        if let beamColor { return beamColor }
        switch variant {
        case .default:
            return theme.primaryForeground.opacity(0.9)
        case .destructive:
            return theme.destructiveForeground.opacity(0.9)
        case .secondary:
            return theme.secondaryForeground.opacity(0.9)
        case .outline, .ghost, .link:
            return theme.primary.opacity(0.9)
        }
    }

    private var resolvedDuration: Double {
        duration.isFinite ? max(duration, 0.01) : 3
    }

    private var resolvedLineWidth: CGFloat {
        lineWidth.isFinite ? max(lineWidth, 0) : 2
    }

    private var resolvedBeamLength: CGFloat {
        if beamLength.isFinite {
            return min(max(beamLength, 0), 1)
        } else {
            return 0.15
        }
    }
}

// MARK: - Border beam shape

/// A short segment of a rounded rectangle's outline, positioned by
/// `progress` (0…1 around the perimeter). Animating `progress` moves the
/// segment along the border, wrapping seamlessly at the start point.
private struct SCBorderBeam: Shape {
    var progress: CGFloat
    var length: CGFloat = 0.15
    var cornerRadius: CGFloat

    var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let base = Path(
            roundedRect: rect.insetBy(dx: 1, dy: 1),
            cornerRadius: cornerRadius,
            style: .continuous
        )
        let start = progress.truncatingRemainder(dividingBy: 1)
        let end = start + length
        if end <= 1 {
            return base.trimmedPath(from: start, to: end)
        }
        var beam = base.trimmedPath(from: start, to: 1)
        beam.addPath(base.trimmedPath(from: 0, to: end - 1))
        return beam
    }
}

// MARK: - Previews

#Preview("Shimmer · text") {
    SCPreview {
        Text("Introducing swiftcn 2.0")
            .font(.title2.weight(.semibold))
            .scShimmer()
    }
}

#Preview("Shimmer · toggle") {
    @Previewable @State var active = true
    @Previewable @State var lastAction = ""
    SCPreview {
        VStack(spacing: 16) {
            Button("Upgrade to Pro") { lastAction = "Upgrade requested" }
                .buttonStyle(.sc())
                .scShimmer(active: active, duration: 2.5)
            Button(active ? "Pause shimmer" : "Resume shimmer") {
                active.toggle()
            }
            .buttonStyle(.sc(.outline, size: .sm))
            if !lastAction.isEmpty { Text(lastAction).scMuted() }
        }
    }
}

#Preview("ShimmerButton") {
    @Previewable @State var started = false

    SCPreview {
        VStack(spacing: 8) {
            SCShimmerButton(text: "Get Started") { started = true }
            if started { Text("Started").scMuted() }
        }
    }
}
