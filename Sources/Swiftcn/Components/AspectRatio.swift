// ============================================================
// AspectRatio.swift — swiftcn-ui
// Depends on: none
// ============================================================
import SwiftUI

/// Constrains arbitrary content to a width-to-height ratio.
///
///     SCAspectRatio(ratio: 16 / 9) {
///         Image("Landscape")
///             .resizable()
///             .scaledToFill()
///     }
public struct SCAspectRatio<Content: View>: View {
    private let ratio: CGFloat
    private let alignment: Alignment
    private let content: Content

    public init(
        ratio: CGFloat,
        alignment: Alignment = .center,
        @ViewBuilder content: () -> Content
    ) {
        precondition(ratio.isFinite && ratio > 0, "SCAspectRatio requires a positive finite ratio")
        self.ratio = ratio
        self.alignment = alignment
        self.content = content()
    }

    public var body: some View {
        Color.clear
            .aspectRatio(ratio, contentMode: .fit)
            .overlay(alignment: alignment) {
                content
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
            }
            .clipped()
    }
}

// MARK: - Previews

#Preview("Aspect Ratio") {
    SCPreview {
        SCAspectRatio(ratio: 16 / 9) {
            LinearGradient(
                colors: [.indigo, .cyan],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            Text("16:9")
                .font(.title.bold())
                .foregroundStyle(.white)
        }
        .frame(width: 420)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
