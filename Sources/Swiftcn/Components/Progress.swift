// ============================================================
// Progress.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Style

/// swiftcn's linear progress bar for native `ProgressView`s — behavior and
/// accessibility stay native; this supplies the style layer only.
///
/// A determinate value animates the fill; without a value the bar shows an
/// indeterminate sweep.
///
///     ProgressView(value: 0.6).progressViewStyle(.scLinear)
///     ProgressView("Uploading…", value: 0.3).progressViewStyle(.scLinear)
///     ProgressView().progressViewStyle(.scLinear)   // indeterminate
public struct SCProgressStyle: ProgressViewStyle {
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    private let trackHeight: CGFloat = 8

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            configuration.label
                .font(.subheadline.weight(.medium))
                .foregroundStyle(theme.foreground)
            track(fraction: configuration.fractionCompleted)
        }
        .opacity(isEnabled ? 1 : 0.5)
    }

    private func track(fraction: Double?) -> some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(theme.secondary)
                if let fraction {
                    Capsule()
                        .fill(theme.primary)
                        .frame(width: geo.size.width * min(max(fraction, 0), 1))
                } else {
                    sweep(width: geo.size.width)
                }
            }
        }
        .frame(height: trackHeight)
        .clipShape(Capsule())
        .animation(.easeInOut(duration: 0.35), value: fraction)
    }

    /// Indeterminate state: a 30%-wide bar sweeping left to right.
    private func sweep(width: CGFloat) -> some View {
        TimelineView(.animation) { context in
            let period: TimeInterval = 1.4
            let phase = context.date.timeIntervalSinceReferenceDate
                .truncatingRemainder(dividingBy: period) / period
            let barWidth = width * 0.3
            Capsule()
                .fill(theme.primary)
                .frame(width: barWidth, height: trackHeight)
                .offset(x: (width + barWidth) * phase - barWidth)
        }
    }
}

public extension ProgressViewStyle where Self == SCProgressStyle {
    /// `ProgressView(value: progress).progressViewStyle(.scLinear)`
    static var scLinear: SCProgressStyle { SCProgressStyle() }
}

// MARK: - Previews

#Preview("Progress") {
    @Previewable @State var progress = 0.4
    SCPreview {
        VStack(spacing: 20) {
            ProgressView(value: progress)
                .progressViewStyle(.scLinear)
            Button("Advance") { progress = progress >= 1 ? 0 : min(progress + 0.25, 1) }
                .buttonStyle(.sc(.outline, size: .sm))
        }
        .frame(maxWidth: 280)
    }
}

#Preview("Progress · labeled") {
    SCPreview {
        ProgressView("Uploading…", value: 0.66)
            .progressViewStyle(.scLinear)
            .frame(maxWidth: 280)
    }
}

#Preview("Progress · indeterminate") {
    SCPreview {
        ProgressView()
            .progressViewStyle(.scLinear)
            .frame(maxWidth: 280)
    }
}
