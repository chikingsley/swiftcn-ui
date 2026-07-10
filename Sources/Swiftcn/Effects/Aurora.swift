// ============================================================
// Aurora.swift — swiftcn-ui (Effects)
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Effect

/// A soft, slowly drifting color wash — large blurred circles moving on
/// sinusoidal paths over `theme.background`, the magicui aurora look.
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
    @Environment(\.theme) private var theme

    var colors: [Color]?
    var speed: Double
    var blur: CGFloat

    /// - Parameters:
    ///   - colors: Blob colors, one blob per color (cycled up to a minimum
    ///     of three); `nil` uses `theme.chart1/2/5` at 35% opacity.
    ///   - speed: Drift-rate multiplier — `1` is a slow ambient drift,
    ///     `0` freezes the aurora.
    ///   - blur: Blur radius applied to the blobs, in points.
    public init(colors: [Color]? = nil, speed: Double = 1, blur: CGFloat = 60) {
        self.colors = colors
        self.speed = speed
        self.blur = blur
    }

    public var body: some View {
        GeometryReader { geometry in
            let size = geometry.size
            TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { context in
                let time = context.date.timeIntervalSinceReferenceDate * speed
                let blobs = resolvedBlobs
                ZStack {
                    theme.background
                    ZStack {
                        ForEach(blobs.indices, id: \.self) { index in
                            blobView(blobs[index], size: size, time: time)
                        }
                    }
                    .blur(radius: blur)
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

    /// Distinct radius/amplitude/frequency/phase per blob slot.
    private static let motions: [(scale: CGFloat, xAmp: CGFloat, yAmp: CGFloat, xFreq: Double, yFreq: Double, phase: Double)] = [
        (0.90, 0.28, 0.22, 0.23, 0.31, 0.0),
        (0.75, 0.32, 0.26, 0.17, 0.26, 2.1),
        (0.80, 0.24, 0.30, 0.29, 0.19, 4.2),
        (0.65, 0.30, 0.24, 0.13, 0.22, 1.3),
    ]

    private var resolvedBlobs: [Blob] {
        let palette = colors ?? [
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
                xAmplitude: motion.xAmp,
                yAmplitude: motion.yAmp,
                xFrequency: motion.xFreq,
                yFrequency: motion.yFreq,
                phase: motion.phase
            )
        }
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
