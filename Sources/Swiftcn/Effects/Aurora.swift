// ============================================================
// Aurora.swift — swiftcn-ui (Effects)
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Effect

/// A soft, slowly drifting color wash — large blurred circles moving on
/// sinusoidal paths over a caller-selected background.
/// Motion is derived from `TimelineView(.animation)` time (no accumulated
/// animation state), rendered through `.drawingGroup()` and clipped to its
/// frame. Place it behind content in a `ZStack`; extending under the safe
/// area is the caller's choice via `.ignoresSafeArea()`.
///
///     ZStack {
///         SCAuroraBackground()
///         heroContent
///     }
///
///     SCAuroraBackground(colors: [.purple.opacity(0.3), .cyan.opacity(0.3)], speed: 2)
public struct SCAuroraBackground: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.theme) private var theme

    private let colors: [Color]?
    private let speed: Double
    private let blur: CGFloat
    private let backgroundColor: Color?

    /// - Parameters:
    ///   - colors: Blob colors, one blob per color (cycled up to a minimum
    ///     of three); `nil` uses `theme.chart1/2/5` at 35% opacity.
    ///   - speed: Drift-rate multiplier — `1` is a slow ambient drift,
    ///     `0` freezes the aurora.
    ///   - blur: Blur radius applied to the blobs, in points.
    ///   - backgroundColor: Base color under the blobs; `nil` uses the theme
    ///     background.
    public init(
        colors: [Color]? = nil,
        speed: Double = 1,
        blur: CGFloat = 60,
        backgroundColor: Color? = nil
    ) {
        self.colors = colors
        self.speed = speed
        self.blur = blur
        self.backgroundColor = backgroundColor
    }

    public var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            TimelineView(
                .animation(
                    minimumInterval: 1.0 / 30.0,
                    paused: reduceMotion || resolvedSpeed == 0
                )
            ) { context in
                let time = reduceMotion ? 0 : context.date.timeIntervalSinceReferenceDate * resolvedSpeed
                let blobs = resolvedBlobs
                ZStack {
                    backgroundColor ?? theme.background
                    ZStack {
                        ForEach(blobs.indices, id: \.self) { index in
                            blobView(blobs[index], size: size, time: time)
                        }
                    }
                    .blur(radius: resolvedBlur)
                }
                .drawingGroup()
            }
        }
        .clipped()
        .accessibilityHidden(true)
    }

    // MARK: Blobs

    private struct Blob {
        var color: Color
        /// Diameter as a fraction of the container's larger side.
        var scale: CGFloat
        /// Horizontal/vertical travel as fractions of the container size.
        var xAmplitude: CGFloat
        var yAmplitude: CGFloat
        /// Angular frequencies in radians per second (kept incommensurate
        /// so the composite path doesn't visibly repeat).
        var xFrequency: Double
        var yFrequency: Double
        var phase: Double
    }

    private struct Motion {
        var scale: CGFloat
        var xAmplitude: CGFloat
        var yAmplitude: CGFloat
        var xFrequency: Double
        var yFrequency: Double
        var phase: Double
    }

    /// Distinct radius/amplitude/frequency/phase per blob slot.
    private static let motions: [Motion] = [
        Motion(scale: 0.90, xAmplitude: 0.28, yAmplitude: 0.22, xFrequency: 0.23, yFrequency: 0.31, phase: 0.0),
        Motion(scale: 0.75, xAmplitude: 0.32, yAmplitude: 0.26, xFrequency: 0.17, yFrequency: 0.26, phase: 2.1),
        Motion(scale: 0.80, xAmplitude: 0.24, yAmplitude: 0.30, xFrequency: 0.29, yFrequency: 0.19, phase: 4.2),
        Motion(scale: 0.65, xAmplitude: 0.30, yAmplitude: 0.24, xFrequency: 0.13, yFrequency: 0.22, phase: 1.3),
    ]

    private var resolvedBlobs: [Blob] {
        let palette =
            colors ?? [
                theme.chart1.opacity(0.35),
                theme.chart2.opacity(0.35),
                theme.chart5.opacity(0.35),
            ]
        guard !palette.isEmpty else { return [] }
        let count = max(palette.count, 3)
        return (0..<count).map { index in
            let motion = Self.motions[index % Self.motions.count]
            return Blob(
                color: palette[index % palette.count],
                scale: motion.scale,
                xAmplitude: motion.xAmplitude,
                yAmplitude: motion.yAmplitude,
                xFrequency: motion.xFrequency,
                yFrequency: motion.yFrequency,
                phase: motion.phase
            )
        }
    }

    private var resolvedSpeed: Double {
        speed.isFinite ? speed : 0
    }

    private var resolvedBlur: CGFloat {
        blur.isFinite ? max(blur, 0) : 0
    }

    private func blobView(_ blob: Blob, size: CGSize, time: Double) -> some View {
        let diameter = max(size.width, size.height) * blob.scale
        return Circle()
            .fill(blob.color)
            .frame(width: diameter, height: diameter)
            .offset(
                x: CGFloat(sin(time * blob.xFrequency + blob.phase)) * size.width * blob.xAmplitude,
                y: CGFloat(cos(time * blob.yFrequency + blob.phase * 1.6)) * size.height * blob.yAmplitude
            )
            .position(x: size.width / 2, y: size.height / 2)
    }
}

// MARK: - Previews

#Preview("Aurora") {
    SCPreview {
        ZStack {
            SCAuroraBackground()
            SCCard {
                Text("Ship faster").scH3()
                Text("Soft ambient color, drifting behind your content.")
                    .scMuted()
            }
            .padding(32)
        }
        .frame(height: 320)
    }
}

#Preview("Aurora · custom colors") {
    SCPreview {
        ZStack {
            SCAuroraBackground(
                colors: [.purple.opacity(0.3), .cyan.opacity(0.3), .pink.opacity(0.25)],
                speed: 2,
                blur: 48
            )
            Text("Aurora").scH2()
        }
        .frame(height: 260)
    }
}
