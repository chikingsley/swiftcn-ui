// ============================================================
// Input.swift — swiftcn-ui
// Depends on: Theme/ · Field.swift (reads \.scFieldInvalid)
// ============================================================
import SwiftUI

// MARK: - InputConvertible

/// A value that can round-trip through the text of an `SCInput`.
///
/// `String`, `Int`, and `Double` conform out of the box, letting `SCInput`
/// edit numbers directly (with the matching keyboard on iOS):
///
///     SCInput("Age", value: $age)      // Int    → .numberPad
///     SCInput("Price", value: $price)  // Double → .decimalPad
public protocol InputConvertible: CustomStringConvertible {
    /// Creates a value from user-typed text. Return `nil` to reject the text —
    /// the previous value is kept while the user keeps typing.
    init?(_ description: String)
}

extension String: InputConvertible {}
extension Int: InputConvertible {}
extension Double: InputConvertible {}

// MARK: - Component

/// A themed single-line text field — shadcn's Input on a native `TextField`.
///
/// Anatomy: optional leading SF Symbol icon, the text field, and an optional
/// trailing slot. The border uses `theme.input`, switching to `theme.ring`
/// while focused and `theme.destructive` inside an `SCField` with an error.
///
///     SCInput("Email", text: $email, icon: "envelope")
///     SCInput("Age", value: $age)
///     SCInput("Search", text: $query) {
///         Button { query = "" } label: { Image(systemName: "xmark.circle.fill") }
///             .buttonStyle(.plain)
///     }
public struct SCInput<Value: InputConvertible, Trailing: View>: View {
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.scFieldInvalid) private var isInvalid
    @FocusState private var isFocused: Bool

    @Binding private var value: Value
    private let placeholder: String
    private let icon: String?
    private let trailing: Trailing

    /// Text mirror of `value` so partial entries ("1." while typing 1.5)
    /// aren't reformatted mid-keystroke.
    @State private var text: String

    /// Creates an input bound to any `InputConvertible` value, with a
    /// trailing accessory slot.
    public init(
        _ placeholder: String,
        value: Binding<Value>,
        icon: String? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.placeholder = placeholder
        self._value = value
        self.icon = icon
        self.trailing = trailing()
        self._text = State(initialValue: value.wrappedValue.description)
    }

    public var body: some View {
        HStack(spacing: 8) {
            if let icon {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(theme.mutedForeground)
            }

            field

            trailing
                .foregroundStyle(theme.mutedForeground)
        }
        .padding(.horizontal, 12)
        .frame(height: 40)
        .background(theme.background, in: shape)
        .overlay(shape.strokeBorder(strokeColor, lineWidth: isFocused ? 1.5 : 1))
        .contentShape(shape)
        .onTapGesture { isFocused = true }
        .opacity(isEnabled ? 1 : 0.5)
        .animation(.easeOut(duration: 0.15), value: isFocused)
        .onChange(of: text) { _, newText in
            if let parsed = Value(newText) {
                value = parsed
            }
        }
        .onChange(of: value.description) { _, newDescription in
            // External binding change — don't clobber equivalent in-progress text.
            if Value(text)?.description != newDescription {
                text = newDescription
            }
        }
    }

    private var field: some View {
        TextField(placeholder, text: $text, prompt: Text(placeholder).foregroundStyle(theme.mutedForeground))
            .textFieldStyle(.plain)
            .font(.subheadline)
            .foregroundStyle(theme.foreground)
            .focused($isFocused)
            #if os(iOS)
            .keyboardType(keyboardType)
            #endif
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

    #if os(iOS)
    private var keyboardType: UIKeyboardType {
        if Value.self == Int.self { return .numberPad }
        if Value.self == Double.self { return .decimalPad }
        return .default
    }
    #endif
}

// MARK: - Convenience initializers

public extension SCInput where Trailing == EmptyView {
    /// Creates an input bound to any `InputConvertible` value.
    init(_ placeholder: String, value: Binding<Value>, icon: String? = nil) {
        self.init(placeholder, value: value, icon: icon) { EmptyView() }
    }
}

public extension SCInput where Value == String, Trailing == EmptyView {
    /// Creates a plain text input — the primary form.
    ///
    ///     SCInput("Email", text: $email, icon: "envelope")
    init(_ placeholder: String, text: Binding<String>, icon: String? = nil) {
        self.init(placeholder, value: text, icon: icon) { EmptyView() }
    }
}

public extension SCInput where Value == String {
    /// Creates a plain text input with a trailing accessory slot.
    init(
        _ placeholder: String,
        text: Binding<String>,
        icon: String? = nil,
        @ViewBuilder trailing: () -> Trailing
    ) {
        self.init(placeholder, value: text, icon: icon, trailing: trailing)
    }
}

// MARK: - Previews

#Preview("Input") {
    @Previewable @State var email = ""
    SCPreview {
        VStack(spacing: 12) {
            SCInput("Email", text: $email, icon: "envelope")
            SCInput("Email", text: $email)
            SCInput("Disabled", text: $email).disabled(true)
        }
    }
}

#Preview("Input · numeric") {
    @Previewable @State var age = 0
    @Previewable @State var price = 0.0
    SCPreview {
        VStack(spacing: 12) {
            SCInput("Age", value: $age)
            SCInput("Price", value: $price, icon: "dollarsign")
        }
    }
}

#Preview("Input · trailing slot") {
    @Previewable @State var query = "swiftcn"
    SCPreview {
        SCInput("Search", text: $query, icon: "magnifyingglass") {
            Button {
                query = ""
            } label: {
                Image(systemName: "xmark.circle.fill")
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Clear search")
        }
    }
}
