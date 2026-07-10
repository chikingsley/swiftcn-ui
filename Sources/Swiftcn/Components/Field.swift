// ============================================================
// Field.swift — swiftcn-ui
// Depends on: Theme/ · Label.swift (SCLabel)
// ============================================================
import SwiftUI

// MARK: - Environment

/// Environment key set by `SCField` while it has a validation `error`.
/// Controls (`SCInput`, `SCTextarea`) read it to tint their border destructive.
public struct SCFieldInvalidKey: EnvironmentKey {
    public static let defaultValue = false
}

public extension EnvironmentValues {
    /// `true` inside an `SCField` whose `error` is non-nil. Custom controls
    /// can read this to render their own invalid state.
    var scFieldInvalid: Bool {
        get { self[SCFieldInvalidKey.self] }
        set { self[SCFieldInvalidKey.self] = newValue }
    }
}

// MARK: - Component

/// A form field — shadcn's Field (the 2025 replacement for Form). Stacks a
/// label, any control, and a description or error caption. When `error` is
/// set, it replaces the description and the control is told it's invalid via
/// `\.scFieldInvalid`.
///
///     SCField("Email", required: true, description: "We'll never share it.") {
///         SCInput("you@example.com", text: $email, icon: "envelope")
///     }
///
///     SCField("Email", error: "Enter a valid email address.") {
///         SCInput("you@example.com", text: $email)
///     }
public struct SCField<Control: View>: View {
    @Environment(\.theme) private var theme

    private let label: String?
    private let required: Bool
    private let description: String?
    private let error: String?
    private let control: Control

    /// Creates a field.
    /// - Parameters:
    ///   - label: Optional label rendered as an `SCLabel` above the control.
    ///   - required: Marks the label with a destructive asterisk.
    ///   - description: Muted helper text below the control.
    ///   - error: Validation message; when non-nil it replaces `description`
    ///     and flags the control invalid through `\.scFieldInvalid`.
    ///   - control: The field's control (an `SCInput`, `SCTextarea`, …).
    public init(
        _ label: String? = nil,
        required: Bool = false,
        description: String? = nil,
        error: String? = nil,
        @ViewBuilder control: () -> Control
    ) {
        self.label = label
        self.required = required
        self.description = description
        self.error = error
        self.control = control()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let label {
                SCLabel(label, required: required)
            }

            control
                .environment(\.scFieldInvalid, error != nil)

            if let error {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(theme.destructive)
            } else if let description {
                Text(description)
                    .font(.caption)
                    .foregroundStyle(theme.mutedForeground)
            }
        }
    }
}

// MARK: - Previews

#Preview("Field") {
    @Previewable @State var email = ""
    SCPreview {
        SCField("Email", required: true, description: "We'll never share your email.") {
            SCInput("you@example.com", text: $email, icon: "envelope")
        }
    }
}

#Preview("Field · invalid") {
    @Previewable @State var email = "not-an-email"
    @Previewable @State var bio = ""
    SCPreview {
        VStack(spacing: 16) {
            SCField("Email", required: true, error: "Enter a valid email address.") {
                SCInput("you@example.com", text: $email, icon: "envelope")
            }
            SCField("Bio", description: "Tell us about yourself.", error: "Bio is required.") {
                SCTextarea("A few words…", text: $bio, minHeight: 80)
            }
        }
    }
}
