// ============================================================
// Spinner.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Component

/// An indeterminate loading indicator: a rotating arc that fades from
/// `mutedForeground` into `primary`.
///
///     SCSpinner()
///     SCSpinner(size: 32, lineWidth: 3)
///     Button { … } label: { HStack { SCSpinner(size: 14); Text("Saving…") } }
public struct SCSpinner: View {
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    private let size: CGFloat
    private let lineWidth: CGFloat

    @State private var isSpinning = false

    /// - Parameters:
    ///   - size: Diameter of the spinner in points. Defaults to 20.
    ///   - lineWidth: Stroke width of the arc. Defaults to 2.
    public init(size: CGFloat = 20, lineWidth: CGFloat = 2) {
        self.size = size
        self.lineWidth = lineWidth
    }

    public var body: some View {
        Circle()
            .trim(from: 0, to: 0.7)
            .stroke(
                AngularGradient(
                    gradient: Gradient(colors: [theme.mutedForeground.opacity(0.3), theme.primary]),
                    center: .center,
                    startAngle: .degrees(0),
                    endAngle: .degrees(252)
                ),
                style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
            )
            .frame(width: size, height: size)
            .rotationEffect(.degrees(isSpinning ? 360 : 0))
            .onAppear {
                withAnimation(.linear(duration: 0.8).repeatForever(autoreverses: false)) {
                    isSpinning = true
                }
            }
            .opacity(isEnabled ? 1 : 0.5)
            .accessibilityLabel(Text("Loading"))
    }
}

// MARK: - Previews

#Preview("Spinner") {
    SCPreview {
        HStack(spacing: 24) {
            SCSpinner(size: 14, lineWidth: 1.5)
            SCSpinner()
            SCSpinner(size: 32, lineWidth: 3)
        }
    }
}

#Preview("Spinner · in context") {
    SCPreview {
        VStack(spacing: 16) {
            Button {} label: {
                HStack(spacing: 8) {
                    SCSpinner(size: 14, lineWidth: 1.5)
                    Text("Please wait")
                }
            }
            .buttonStyle(.sc())
            .disabled(true)
            SCSpinner().disabled(true)
        }
    }
}
