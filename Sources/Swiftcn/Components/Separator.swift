// ============================================================
// Separator.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Component

/// A 1pt rule that visually divides content, in the theme's border color.
/// Horizontal separators fill the available width; vertical ones fill the
/// available height. The labeled form renders a centered caption between
/// two rules — the classic "or continue with" divider.
///
///     SCSeparator()
///     SCSeparator(.vertical)
///     SCSeparator(label: "or continue with")
public struct SCSeparator: View {
    @Environment(\.theme) private var theme

    var axis: Axis
    var label: String?

    public init(_ axis: Axis = .horizontal) {
        self.axis = axis
        self.label = nil
    }

    /// A horizontal separator with a centered label.
    public init(label: String) {
        self.axis = .horizontal
        self.label = label
    }

    public var body: some View {
        if let label {
            HStack(spacing: 16) {
                line
                Text(label)
                    .font(.caption)
                    .foregroundStyle(theme.mutedForeground)
                    .lineLimit(1)
                    .fixedSize()
                line
            }
        } else {
            line
        }
    }

    @ViewBuilder
    private var line: some View {
        switch axis {
        case .horizontal:
            theme.border
                .frame(height: 1)
                .frame(maxWidth: .infinity)
                .accessibilityHidden(true)
        case .vertical:
            theme.border
                .frame(width: 1)
                .frame(maxHeight: .infinity)
                .accessibilityHidden(true)
        }
    }
}

// MARK: - Previews

#Preview("Separator") {
    SCPreview {
        VStack(alignment: .leading, spacing: 12) {
            Text("swiftcn-ui")
                .font(.subheadline.weight(.medium))
            SCSeparator()
            HStack(spacing: 12) {
                Text("Docs").font(.subheadline)
                SCSeparator(.vertical)
                Text("Source").font(.subheadline)
                SCSeparator(.vertical)
                Text("Blog").font(.subheadline)
            }
            .frame(height: 20)
        }
    }
}

#Preview("Separator · label") {
    SCPreview {
        SCSeparator(label: "or continue with")
    }
}
