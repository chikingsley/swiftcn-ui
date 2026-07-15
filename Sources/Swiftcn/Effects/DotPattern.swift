// ============================================================
// DotPattern.swift — swiftcn-ui (Effects)
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Effect

/// A dotted background pattern, drawn in a single `Canvas` pass — the
/// magicui `DotPattern` port. Place it behind content with a `ZStack`;
/// it fills whatever frame it's given (extending under the safe area is
/// the caller's choice via `.ignoresSafeArea()`).
///
///     ZStack {
///         SCDotPattern()
///         heroContent
///     }
///
///     SCDotPattern(fade: true)   // radial fade toward the edges
public struct SCDotPattern: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.theme) private var theme

    private let dotSize: CGFloat
    private let spacing: CGFloat
    private let horizontalSpacing: CGFloat?
    private let verticalSpacing: CGFloat?
    private let offset: CGSize
    private let dotOffset: CGPoint
    private let color: Color?
    private let fade: Bool
    private let glow: Bool

    /// - Parameters:
    ///   - dotSize: Diameter of each dot in points.
    ///   - spacing: Distance between dot centers (the grid pitch).
    ///   - color: Dot color; `nil` uses `theme.mutedForeground` at 40%.
    ///   - fade: Masks the pattern radially — fully visible at the center,
    ///     transparent toward the edges.
    ///   - glow: Pulses each dot at a deterministic phase and duration.
    ///   - horizontalSpacing: Optional horizontal grid pitch; `nil` uses
    ///     `spacing`.
    ///   - verticalSpacing: Optional vertical grid pitch; `nil` uses
    ///     `spacing`.
    ///   - offset: Offset of the entire pattern.
    ///   - dotOffset: Position of each dot within its grid cell, matching the
    ///     upstream `cx` and `cy` inputs.
    public init(
        dotSize: CGFloat = 2,
        spacing: CGFloat = 16,
        color: Color? = nil,
        fade: Bool = false,
        glow: Bool = false,
        horizontalSpacing: CGFloat? = nil,
        verticalSpacing: CGFloat? = nil,
        offset: CGSize = .zero,
        dotOffset: CGPoint = CGPoint(x: 1, y: 1)
    ) {
        self.dotSize = dotSize
        self.spacing = spacing
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.offset = offset
        self.dotOffset = dotOffset
        self.color = color
        self.fade = fade
        self.glow = glow
    }

    @ViewBuilder
    public var body: some View {
        if fade {
            animatedPattern.mask { fadeMask }
        } else {
            animatedPattern
        }
    }

    @ViewBuilder
    private var animatedPattern: some View {
        if glow && !reduceMotion {
            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
                pattern(at: context.date.timeIntervalSinceReferenceDate)
            }
        } else {
            pattern(at: nil)
        }
    }

    private func pattern(at time: TimeInterval?) -> some View {
        let dotColor = color ?? theme.mutedForeground.opacity(0.4)
        let radius = resolvedRadius
        let horizontalPitch = resolvedHorizontalSpacing
        let verticalPitch = resolvedVerticalSpacing
        return Canvas { context, size in
            guard radius > 0, horizontalPitch >= 1, verticalPitch >= 1 else { return }
            let horizontalIndices = gridIndices(
                origin: offset.width + dotOffset.x,
                pitch: horizontalPitch,
                extent: size.width,
                radius: radius
            )
            let verticalIndices = gridIndices(
                origin: offset.height + dotOffset.y,
                pitch: verticalPitch,
                extent: size.height,
                radius: radius
            )

            if let time {
                for row in verticalIndices {
                    for column in horizontalIndices {
                        let center = CGPoint(
                            x: offset.width + dotOffset.x + CGFloat(column) * horizontalPitch,
                            y: offset.height + dotOffset.y + CGFloat(row) * verticalPitch
                        )
                        let pulse = pulse(at: time, column: column, row: row)
                        let animatedRadius = radius * (1 + pulse * 0.5)
                        let opacity = 0.4 + pulse * 0.6
                        let rect = CGRect(
                            x: center.x - animatedRadius,
                            y: center.y - animatedRadius,
                            width: animatedRadius * 2,
                            height: animatedRadius * 2
                        )
                        context.fill(Path(ellipseIn: rect), with: .color(dotColor.opacity(opacity)))
                    }
                }
            } else {
                var dots = Path()
                for row in verticalIndices {
                    for column in horizontalIndices {
                        let center = CGPoint(
                            x: offset.width + dotOffset.x + CGFloat(column) * horizontalPitch,
                            y: offset.height + dotOffset.y + CGFloat(row) * verticalPitch
                        )
                        dots.addEllipse(
                            in: CGRect(
                                x: center.x - radius,
                                y: center.y - radius,
                                width: radius * 2,
                                height: radius * 2
                            )
                        )
                    }
                }
                context.fill(dots, with: .color(dotColor))
            }
        }
        .accessibilityHidden(true)
    }

    private var resolvedRadius: CGFloat {
        guard dotSize.isFinite else { return 0 }
        return max(dotSize / 2, 0)
    }

    private var resolvedHorizontalSpacing: CGFloat {
        let value = horizontalSpacing ?? spacing
        return value.isFinite ? value : 0
    }

    private var resolvedVerticalSpacing: CGFloat {
        let value = verticalSpacing ?? spacing
        return value.isFinite ? value : 0
    }

    private func gridIndices(
        origin: CGFloat,
        pitch: CGFloat,
        extent: CGFloat,
        radius: CGFloat
    ) -> ClosedRange<Int> {
        let lower = Int(floor((-radius - origin) / pitch))
        let upper = Int(ceil((extent + radius - origin) / pitch))
        return lower...max(lower, upper)
    }

    private func pulse(at time: TimeInterval, column: Int, row: Int) -> CGFloat {
        let x = Double(column)
        let y = Double(row)
        let delay = abs(sin(x * 12.9898 + y * 78.233)) * 5
        let duration = 2 + abs(sin(x * 39.3467 + y * 11.1351)) * 3
        let phase = (time + delay).truncatingRemainder(dividingBy: duration) / duration
        return CGFloat((1 - cos(phase * 2 * .pi)) / 2)
    }

    /// Only the mask's alpha matters; the theme color just supplies an
    /// opaque channel.
    private var fadeMask: some View {
        EllipticalGradient(
            gradient: Gradient(stops: [
                .init(color: .black, location: 0.3),
                .init(color: .clear, location: 1),
            ]),
            center: .center,
            startRadiusFraction: 0,
            endRadiusFraction: 0.55
        )
    }
}

// MARK: - Previews

#Preview("DotPattern") {
    SCPreview {
        ZStack {
            SCDotPattern()
            SCBadge("Hero section")
        }
        .frame(height: 220)
    }
}

#Preview("DotPattern · fade") {
    SCPreview {
        ZStack {
            SCDotPattern(dotSize: 3, spacing: 20, fade: true)
            SCBadge("Faded edges", variant: .outline)
        }
        .frame(height: 220)
    }
}
