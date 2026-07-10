// ============================================================
// InputOTP.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Component

/// One-time-code entry — shadcn's InputOTP. Renders a row of digit boxes
/// (optionally grouped with a dash) driven by a single hidden text field, so
/// paste, deletion, and iOS code autofill all behave natively. Tap anywhere
/// to focus; non-digits are filtered and input is clamped to `length`.
///
///     SCInputOTP(code: $code)                            // 6 digits, 3 + 3
///     SCInputOTP(code: $code, length: 4, groupSize: nil) // 4, ungrouped
///     SCInputOTP(code: $code) { code in verify(code) }   // fires when full
public struct SCInputOTP: View {
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @FocusState private var isFocused: Bool

    @Binding private var code: String
    private let length: Int
    private let groupSize: Int?
    private let onComplete: ((String) -> Void)?

    /// Creates a one-time-code input.
    /// - Parameters:
    ///   - code: The entered digits (kept filtered to at most `length` digits).
    ///   - length: Total number of digits.
    ///   - groupSize: Digits per group, separated by a dash; `nil` for one
    ///     continuous row.
    ///   - onComplete: Called with the code each time it reaches full length.
    public init(
        code: Binding<String>,
        length: Int = 6,
        groupSize: Int? = 3,
        onComplete: ((String) -> Void)? = nil
    ) {
        self._code = code
        self.length = length
        self.groupSize = groupSize
        self.onComplete = onComplete
    }

    public var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<length, id: \.self) { index in
                box(at: index)
                if isGroupBoundary(after: index) {
                    Capsule()
                        .fill(theme.border)
                        .frame(width: 10, height: 2)
                }
            }
        }
        .background(hiddenField)
        .contentShape(Rectangle())
        .onTapGesture { isFocused = true }
        .opacity(isEnabled ? 1 : 0.5)
        .animation(.easeOut(duration: 0.15), value: code)
        .animation(.easeOut(duration: 0.15), value: isFocused)
        .onChange(of: code) { _, newValue in
            let sanitized = String(newValue.filter(\.isNumber).prefix(length))
            guard sanitized == newValue else {
                code = sanitized
                return
            }
            if sanitized.count == length {
                onComplete?(sanitized)
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("One-time code")
        .accessibilityValue(code)
    }

    // MARK: Boxes

    private func box(at index: Int) -> some View {
        ZStack {
            if let digit = digit(at: index) {
                Text(String(digit))
                    .font(.title3.weight(.medium).monospacedDigit())
                    .foregroundStyle(theme.foreground)
            }
        }
        .frame(width: 40, height: 48)
        .background(theme.background, in: shape)
        .overlay(
            shape.strokeBorder(
                index == activeIndex ? theme.ring : theme.input,
                lineWidth: index == activeIndex ? 1.5 : 1
            )
        )
    }

    /// The single focusable field that owns all input.
    private var hiddenField: some View {
        TextField("", text: $code)
            .textFieldStyle(.plain)
            .focused($isFocused)
            .autocorrectionDisabled()
            .frame(width: 1, height: 1)
            .opacity(0.01)
            .accessibilityHidden(true)
            #if os(iOS)
            .keyboardType(.numberPad)
            .textContentType(.oneTimeCode)
            #endif
    }

    // MARK: Helpers

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.radius, style: .continuous)
    }

    /// The box the next digit lands in (the last box once full); highlighted
    /// only while focused.
    private var activeIndex: Int? {
        isFocused ? min(code.count, length - 1) : nil
    }

    private func digit(at index: Int) -> Character? {
        guard index < code.count else { return nil }
        return Array(code)[index]
    }

    private func isGroupBoundary(after index: Int) -> Bool {
        guard let groupSize, groupSize > 0 else { return false }
        return (index + 1).isMultiple(of: groupSize) && index + 1 < length
    }
}

// MARK: - Previews

#Preview("InputOTP") {
    @Previewable @State var code = ""
    SCPreview {
        VStack(spacing: 16) {
            SCInputOTP(code: $code)
            Text("Entered: \(code)")
                .font(.caption)
                .foregroundStyle(Theme.default.mutedForeground)
        }
    }
}

#Preview("InputOTP · variants") {
    @Previewable @State var grouped = "1234"
    @Previewable @State var plain = "12"
    SCPreview {
        VStack(spacing: 16) {
            SCInputOTP(code: $grouped, length: 8, groupSize: 4)
            SCInputOTP(code: $plain, length: 4, groupSize: nil)
            SCInputOTP(code: $plain, length: 4, groupSize: nil)
                .disabled(true)
        }
    }
}
