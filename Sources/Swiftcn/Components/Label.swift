// ============================================================
// Label.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Component

/// A form label — shadcn's Label. Pair it with a control, or let `SCField`
/// compose it for you.
///
///     SCLabel("Email")
///     SCLabel("Password", required: true)   // shows a destructive asterisk
public struct SCLabel: View {
    @Environment(\.theme) private var theme

    private let text: String
    private let required: Bool

    public init(_ text: String, required: Bool = false) {
        self.text = text
        self.required = required
    }

    public var body: some View {
        label
            .font(.footnote.weight(.medium))
    }

    private var label: Text {
        var label = Text(text).foregroundStyle(theme.foreground)
        if required {
            label = label + Text(" *").foregroundStyle(theme.destructive)
        }
        return label
    }
}

// MARK: - Previews

#Preview("Label") {
    SCPreview {
        VStack(alignment: .leading, spacing: 8) {
            SCLabel("Email")
            SCLabel("Password", required: true)
        }
    }
}
