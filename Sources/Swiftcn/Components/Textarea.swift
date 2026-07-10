// ============================================================
// Textarea.swift — swiftcn-ui
// Depends on: Theme/ · Field.swift (reads \.scFieldInvalid)
// ============================================================
import SwiftUI

// MARK: - Component

/// A themed multi-line text area — shadcn's Textarea on a native `TextEditor`.
///
/// Shares `SCInput`'s border treatment: `theme.input` at rest, `theme.ring`
/// while focused, and `theme.destructive` inside an `SCField` with an error.
/// Shows a muted placeholder while empty.
///
///     SCTextarea("Type your message here.", text: $message)
///     SCTextarea("Bio", text: $bio, minHeight: 140)
public struct SCTextarea: View {
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.scFieldInvalid) private var isInvalid
    @FocusState private var isFocused: Bool

    @Binding private var text: String
    private let placeholder: String
    private let minHeight: CGFloat

    /// Creates a text area.
    /// - Parameters:
    ///   - placeholder: Muted text shown while `text` is empty.
    ///   - text: The edited string.
    ///   - minHeight: Minimum editor height in points (grows with content).
    public init(_ placeholder: String, text: Binding<String>, minHeight: CGFloat = 100) {
        self.placeholder = placeholder
        self._text = text
        self.minHeight = minHeight
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .font(.subheadline)
                .foregroundStyle(theme.foreground)
                .scrollContentBackground(.hidden)
                .focused($isFocused)
                .frame(minHeight: minHeight, alignment: .topLeading)

            if text.isEmpty {
                Text(placeholder)
                    .font(.subheadline)
                    .foregroundStyle(theme.mutedForeground)
                    .padding(editorTextInsets)
                    .allowsHitTesting(false)
            }
        }
        .padding(contentPadding)
        .background(theme.background, in: shape)
        .overlay(shape.strokeBorder(strokeColor, lineWidth: isFocused ? 1.5 : 1))
        .contentShape(shape)
        .onTapGesture { isFocused = true }
        .opacity(isEnabled ? 1 : 0.5)
        .animation(.easeOut(duration: 0.15), value: isFocused)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.radius, style: .continuous)
    }

    private var strokeColor: Color {
        if isInvalid {
            theme.destructive
        } else if isFocused {
            theme.ring
        } else {
            theme.input
        }
    }

    /// Outer padding, minus `TextEditor`'s intrinsic insets (5pt line-fragment
    /// padding on both platforms; 8pt top inset on iOS only), so the text
    /// sits 12pt from the border like `SCInput`.
    private var contentPadding: EdgeInsets {
        #if os(iOS)
        EdgeInsets(top: 4, leading: 7, bottom: 4, trailing: 7)
        #else
        EdgeInsets(top: 12, leading: 7, bottom: 12, trailing: 7)
        #endif
    }

    /// Aligns the placeholder with `TextEditor`'s intrinsic text origin.
    private var editorTextInsets: EdgeInsets {
        #if os(iOS)
        EdgeInsets(top: 8, leading: 5, bottom: 0, trailing: 0)
        #else
        EdgeInsets(top: 0, leading: 5, bottom: 0, trailing: 0)
        #endif
    }
}

// MARK: - Previews

#Preview("Textarea") {
    @Previewable @State var message = ""
    SCPreview {
        SCTextarea("Type your message here.", text: $message)
    }
}

#Preview("Textarea · states") {
    @Previewable @State var filled = "swiftcn brings shadcn/ui's design language to SwiftUI."
    @Previewable @State var empty = ""
    SCPreview {
        VStack(spacing: 12) {
            SCTextarea("Bio", text: $filled, minHeight: 80)
            SCTextarea("Disabled", text: $empty, minHeight: 80)
                .disabled(true)
        }
    }
}
