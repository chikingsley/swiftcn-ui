// ============================================================
// Slider.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Component

/// A themed range input — the swiftcn take on shadcn's Slider. The native
/// SwiftUI `Slider` can't theme its track, so this draws its own track and
/// thumb while exposing the native adjustable to VoiceOver via
/// `accessibilityRepresentation`.
///
///     SCSlider(value: $volume)
///     SCSlider(value: $brightness, in: 0...100)
///     SCSlider(value: $rating, in: 0...5, step: 1)
public struct SCSlider: View {
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    @Binding private var value: Double
    private let range: ClosedRange<Double>
    private let step: Double?

    private let trackHeight: CGFloat = 6
    private let thumbSize: CGFloat = 20

    /// - Parameters:
    ///   - value: The selected value, kept within `range`.
    ///   - range: The bounds of the slider. Defaults to `0...1`.
    ///   - step: Optional increment to snap to while dragging.
    public init(value: Binding<Double>, in range: ClosedRange<Double> = 0...1, step: Double? = nil) {
        self._value = value
        self.range = range
        self.step = step
    }

    public var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let thumbOffset = fraction(of: value) * max(width - thumbSize, 0)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(theme.secondary)
                    .frame(height: trackHeight)
                Capsule()
                    .fill(theme.primary)
                    .frame(width: thumbOffset + thumbSize / 2, height: trackHeight)
                Circle()
                    .fill(theme.background)
                    .overlay(Circle().strokeBorder(theme.primary, lineWidth: 1.5))
                    .shadow(color: theme.foreground.opacity(0.12), radius: 2, x: 0, y: 1)
                    .frame(width: thumbSize, height: thumbSize)
                    .offset(x: thumbOffset)
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { drag in
                        setValue(atX: drag.location.x, width: width)
                    }
            )
        }
        .frame(height: thumbSize)
        .opacity(isEnabled ? 1 : 0.5)
        .accessibilityRepresentation {
            if let step {
                Slider(value: $value, in: range, step: step)
            } else {
                Slider(value: $value, in: range)
            }
        }
    }

    // MARK: Geometry ↔ value

    private func fraction(of value: Double) -> Double {
        let span = range.upperBound - range.lowerBound
        guard span > 0 else { return 0 }
        return min(max((value - range.lowerBound) / span, 0), 1)
    }

    private func setValue(atX x: CGFloat, width: CGFloat) {
        guard isEnabled else { return }
        let usable = max(width - thumbSize, 1)
        let fraction = min(max((x - thumbSize / 2) / usable, 0), 1)
        var newValue = range.lowerBound + fraction * (range.upperBound - range.lowerBound)
        if let step, step > 0 {
            newValue = range.lowerBound + (((newValue - range.lowerBound) / step).rounded() * step)
        }
        value = min(max(newValue, range.lowerBound), range.upperBound)
    }
}

// MARK: - Previews

#Preview("Slider") {
    @Previewable @State var value = 0.5
    SCPreview {
        VStack(spacing: 16) {
            SCSlider(value: $value)
            Text(value, format: .percent.precision(.fractionLength(0)))
                .font(.caption)
                .foregroundStyle(Theme.default.mutedForeground)
        }
        .frame(maxWidth: 280)
    }
}

#Preview("Slider · stepped") {
    @Previewable @State var value = 40.0
    SCPreview {
        VStack(spacing: 16) {
            SCSlider(value: $value, in: 0...100, step: 10)
            Text(value, format: .number.precision(.fractionLength(0)))
                .font(.caption)
                .foregroundStyle(Theme.default.mutedForeground)
        }
        .frame(maxWidth: 280)
    }
}

#Preview("Slider · disabled") {
    @Previewable @State var value = 0.3
    SCPreview {
        SCSlider(value: $value)
            .disabled(true)
            .frame(maxWidth: 280)
    }
}
