// ============================================================
// NumberTicker.swift — swiftcn-ui (Effects)
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Effect

/// Animates numeric changes by rolling each digit into place — the magicui
/// `NumberTicker` port, built on `contentTransition(.numericText)`. Digits
/// are monospaced so the layout stays stable while values change. Font and
/// color are inherited from the context, so style it like any `Text`.
///
///     SCNumberTicker(value: downloads)
///         .scH2()
///
///     SCNumberTicker(value: revenue, format: .number.precision(.fractionLength(2)))
///         .font(.system(.largeTitle, design: .rounded))
public struct SCNumberTicker: View {
    var value: Double
    var format: FloatingPointFormatStyle<Double>

    /// - Parameters:
    ///   - value: The number to display; changes animate digit-by-digit.
    ///   - format: How the number is rendered (defaults to `.number`).
    public init(value: Double, format: FloatingPointFormatStyle<Double> = .number) {
        self.value = value
        self.format = format
    }

    /// Displays an integer with no fraction digits.
    ///
    /// - Parameter value: The number to display; changes animate digit-by-digit.
    public init(value: Int) {
        self.init(
            value: Double(value),
            format: .number.precision(.fractionLength(0))
        )
    }

    public var body: some View {
        Text(value, format: format)
            .monospacedDigit()
            .contentTransition(.numericText(value: value))
            .animation(.snappy(duration: 0.4), value: value)
    }
}

// MARK: - Previews

#Preview("NumberTicker") {
    @Previewable @State var value = 1024
    SCPreview {
        VStack(spacing: 20) {
            SCNumberTicker(value: value)
                .scH2()
            HStack(spacing: 8) {
                Button {
                    value -= 125
                } label: {
                    Image(systemName: "minus")
                }
                .buttonStyle(.sc(.outline, size: .icon))
                .accessibilityLabel("Decrease")

                Button {
                    value += 125
                } label: {
                    Image(systemName: "plus")
                }
                .buttonStyle(.sc(.outline, size: .icon))
                .accessibilityLabel("Increase")
            }
        }
    }
}

#Preview("NumberTicker · fractions") {
    @Previewable @State var price = 128.75
    SCPreview {
        VStack(spacing: 20) {
            SCNumberTicker(value: price, format: .number.precision(.fractionLength(2)))
                .scH3()
            Button("Randomize") {
                price = Double.random(in: 0...500)
            }
            .buttonStyle(.sc(.outline, size: .sm))
        }
    }
}
