// ============================================================
// NumberTicker.swift — swiftcn-ui (Effects)
// Depends on: SwiftUI
// ============================================================
import SwiftUI

// MARK: - Effect

public enum SCNumberTickerDirection: Sendable, Hashable {
    case up
    case down
}

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
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private let value: Double
    private let startValue: Double
    private let direction: SCNumberTickerDirection
    private let delay: TimeInterval
    private let format: FloatingPointFormatStyle<Double>

    @State private var displayedValue: Double

    /// - Parameters:
    ///   - value: The target when counting up and the starting value when
    ///     counting down, matching the upstream contract.
    ///   - startValue: The starting value when counting up and the target when
    ///     counting down.
    ///   - direction: Whether to count up from `startValue` or down from
    ///     `value`.
    ///   - delay: Seconds to wait after the view enters the hierarchy.
    ///   - format: How the number is rendered (defaults to `.number`).
    public init(
        value: Double,
        startValue: Double = 0,
        direction: SCNumberTickerDirection = .up,
        delay: TimeInterval = 0,
        format: FloatingPointFormatStyle<Double> = .number
    ) {
        self.value = value
        self.startValue = startValue
        self.direction = direction
        self.delay = delay
        self.format = format
        _displayedValue = State(initialValue: direction == .down ? value : startValue)
    }

    /// Displays an integer with no fraction digits.
    ///
    public init(
        value: Int,
        startValue: Int = 0,
        direction: SCNumberTickerDirection = .up,
        delay: TimeInterval = 0
    ) {
        self.init(
            value: Double(value),
            startValue: Double(startValue),
            direction: direction,
            delay: delay,
            format: .number.precision(.fractionLength(0))
        )
    }

    public var body: some View {
        SCInterpolatedNumberText(value: displayedValue, format: format)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(terminalValue, format: format))
            .task(id: configuration) {
                await restartAnimation()
            }
    }

    private var configuration: Configuration {
        Configuration(value: value, startValue: startValue, direction: direction, delay: delay)
    }

    private var initialValue: Double {
        direction == .down ? value : startValue
    }

    private var terminalValue: Double {
        direction == .down ? startValue : value
    }

    @MainActor
    private func restartAnimation() async {
        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            displayedValue = initialValue
        }

        let seconds = delay.isFinite ? max(delay, 0) : 0
        if seconds > 0 {
            do {
                try await Task.sleep(for: .seconds(seconds))
            } catch {
                return
            }
        }
        guard !Task.isCancelled else { return }

        if reduceMotion || !initialValue.isFinite || !terminalValue.isFinite {
            withTransaction(transaction) {
                displayedValue = terminalValue
            }
        } else {
            withAnimation(.spring(response: 0.8, dampingFraction: 1)) {
                displayedValue = terminalValue
            }
        }
    }

    private struct Configuration: Hashable {
        let value: Double
        let startValue: Double
        let direction: SCNumberTickerDirection
        let delay: TimeInterval
    }
}

private struct SCInterpolatedNumberText: View, @preconcurrency Animatable {
    var value: Double
    let format: FloatingPointFormatStyle<Double>

    var animatableData: Double {
        get { value }
        set { value = newValue }
    }

    var body: some View {
        Text(value, format: format)
            .monospacedDigit()
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
