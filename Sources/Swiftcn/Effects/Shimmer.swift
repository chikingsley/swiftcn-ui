// ============================================================
// Shimmer.swift — swiftcn-ui (Effects)
// Depends on: Theme/, Components/Button.swift (SCShimmerButton only)
// ============================================================
import SwiftUI

// MARK: - Modifier

public extension View {
    /// Sweeps a soft highlight across this view, masked to its shape —
    /// works on text, buttons, icons, anything.
    ///
    ///     Text("Introducing swiftcn 2.0")
    ///         .font(.title2.weight(.semibold))
    ///         .scShimmer()
    ///
    ///     Button("Upgrade") { … }
    ///         .buttonStyle(.sc())
    ///         .scShimmer(active: isOnSale, duration: 3)
    ///
    /// - Parameters:
    ///   - active: Whether the sweep is running; `false` renders the view untouched.
    ///   - duration: Seconds per sweep.
    func scShimmer(active: Bool = true, duration: Double = 2) -> some View {
        modifier(SCShimmerModifier(active: active, duration: duration))
    }
}

private struct SCShimmerModifier: ViewModifier {
    @Environment(\.theme) private var theme

    var active: Bool
    var duration: Double

    /// -1 parks the band fully off the leading edge; 2 is fully past the
    /// trailing edge, so the repeat loops seamlessly.
    @State private var phase: CGFloat = -1

    func body(content: Content) -> some View {
        content.overlay {
            if active {
                GeometryReader { geometry in
                    LinearGradient(
                        colors: [
                            theme.background.opacity(0),
                            theme.background.opacity(0.8),
                            theme.background.opacity(0),
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .frame(width: geometry.size.width * 0.4, height: geometry.size.height)
                    .offset(x: phase * geometry.size.width)
                }
                .mask(content)
                .allowsHitTesting(false)
                .onAppear {
                    phase = -1
                    withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                        phase = 2
                    }
                }
                .onDisappear {
                    var transaction = Transaction()
                    transaction.disablesAnimations = true
                    withTransaction(transaction) { phase = -1 }
                }
            }
        }
    }
}

// MARK: - Component

/// A call-to-action button with a highlight that endlessly travels its
/// border — the v1 `ShimmerButton`, rebuilt on `SCButtonStyle` and theme
/// tokens.
///
///     SCShimmerButton(text: "Get Started") { start() }
public struct SCShimmerButton: View {
    @Environment(\.theme) private var theme

    var text: String
    var duration: Double
    var action: () -> Void

    @State private var progress: CGFloat = 0

    /// - Parameters:
    ///   - text: The button label.
    ///   - duration: Seconds for one full lap of the border highlight.
    ///   - action: Performed on tap.
    public init(text: String, duration: Double = 3, action: @escaping () -> Void) {
        self.text = text
        self.duration = duration
        self.action = action
    }

    public var body: some View {
        Button(text, action: action)
            .buttonStyle(.sc())
            .overlay {
                SCBorderBeam(progress: progress, cornerRadius: theme.radius)
                    .stroke(
                        theme.primaryForeground.opacity(0.9),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                    .allowsHitTesting(false)
            }
            .onAppear {
                progress = 0
                withAnimation(.linear(duration: duration).repeatForever(autoreverses: false)) {
                    progress = 1
                }
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
    SCPreview {
        VStack(spacing: 16) {
            Button("Upgrade to Pro") {}
                .buttonStyle(.sc())
                .scShimmer(active: active, duration: 2.5)
            Button(active ? "Pause shimmer" : "Resume shimmer") {
                active.toggle()
            }
            .buttonStyle(.sc(.outline, size: .sm))
        }
    }
}

#Preview("ShimmerButton") {
    SCPreview {
        SCShimmerButton(text: "Get Started") {}
    }
}
