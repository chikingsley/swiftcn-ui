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
    @Environment(\.theme) private var theme

    var dotSize: CGFloat
    var spacing: CGFloat
    var color: Color?
    var fade: Bool

    /// - Parameters:
    ///   - dotSize: Diameter of each dot in points.
    ///   - spacing: Distance between dot centers (the grid pitch).
    ///   - color: Dot color; `nil` uses `theme.mutedForeground` at 40%.
    ///   - fade: Masks the pattern radially — fully visible at the center,
    ///     transparent toward the edges.
    public init(
        dotSize: CGFloat = 2,
        spacing: CGFloat = 16,
        color: Color? = nil,
        fade: Bool = false
    ) {
        self.dotSize = dotSize
        self.spacing = spacing
        self.color = color
        self.fade = fade
    }

    public var body: some View {
        if fade {
            pattern.mask { fadeMask }
        } else {
            pattern
        }
    }

    private var pattern: some View {
        let dotColor = color ?? theme.mutedForeground.opacity(0.4)
        let dotSize = dotSize
        let spacing = spacing
        return Canvas { context, size in
            guard dotSize > 0, spacing > 0 else { return }
            var dots = Path()
            var y = spacing / 2
            while y < size.height + dotSize {
                var x = spacing / 2
                while x < size.width + dotSize {
                    dots.addEllipse(in: CGRect(
                        x: x - dotSize / 2,
                        y: y - dotSize / 2,
                        width: dotSize,
                        height: dotSize
                    ))
                    x += spacing
                }
                y += spacing
            }
            context.fill(dots, with: .color(dotColor))
        }
        .accessibilityHidden(true)
    }

    /// Only the mask's alpha matters; the theme color just supplies an
    /// opaque channel.
    private var fadeMask: some View {
        EllipticalGradient(
            gradient: Gradient(stops: [
                .init(color: theme.foreground, location: 0.3),
                .init(color: theme.foreground.opacity(0), location: 1),
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
