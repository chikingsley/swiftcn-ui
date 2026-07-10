// ============================================================
// Alert.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Variants

public enum SCAlertVariant: CaseIterable, Sendable {
    case `default`, destructive
}

// MARK: - Component

/// Displays an inline callout for user attention — shadcn's `Alert`.
/// This is a banner embedded in the layout, not a modal dialog.
///
///     SCAlert(icon: "terminal", title: "Heads up!",
///             description: "You can add components to your app using the CLI.")
///
///     SCAlert(variant: .destructive, icon: "exclamationmark.triangle") {
///         SCAlertTitle("Error")
///         SCAlertDescription("Your session has expired. Please log in again.")
///     }
public struct SCAlert<Content: View>: View {
    @Environment(\.theme) private var theme

    var variant: SCAlertVariant
    var icon: String?
    @ViewBuilder var content: Content

    /// Slot-based initializer — compose `SCAlertTitle`, `SCAlertDescription`,
    /// or any custom views.
    /// - Parameters:
    ///   - variant: `.default` (neutral) or `.destructive` (error-tinted).
    ///   - icon: SF Symbol name shown leading the text, or `nil` for none.
    public init(
        variant: SCAlertVariant = .default,
        icon: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.variant = variant
        self.icon = icon
        self.content = content()
    }

    public var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if let icon {
                Image(systemName: icon)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundStyle(variant == .destructive ? theme.destructive : theme.foreground)
            }
            VStack(alignment: .leading, spacing: 4) {
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(16)
        .background(background, in: shape)
        .overlay(shape.strokeBorder(strokeColor))
        .environment(\.scAlertVariant, variant)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.radius, style: .continuous)
    }

    private var background: Color {
        switch variant {
        case .default:     theme.background
        case .destructive: theme.destructive.opacity(0.08)
        }
    }

    private var strokeColor: Color {
        switch variant {
        case .default:     theme.border
        case .destructive: theme.destructive.opacity(0.5)
        }
    }
}

public extension SCAlert where Content == TupleView<(SCAlertTitle, SCAlertDescription?)> {
    /// Convenience for the common icon + title + description anatomy.
    ///
    ///     SCAlert(icon: "terminal", title: "Heads up!",
    ///             description: "You can add components using the CLI.")
    init(
        icon: String? = nil,
        title: String,
        description: String? = nil,
        variant: SCAlertVariant = .default
    ) {
        self.init(variant: variant, icon: icon) {
            SCAlertTitle(title)
            if let description {
                SCAlertDescription(description)
            }
        }
    }
}

// MARK: - Subcomponents

/// The alert's heading line. Renders in the destructive color inside a
/// `.destructive` alert.
public struct SCAlertTitle: View {
    @Environment(\.theme) private var theme
    @Environment(\.scAlertVariant) private var variant

    var text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(variant == .destructive ? theme.destructive : theme.foreground)
    }
}

/// The alert's supporting copy, in a muted tone.
public struct SCAlertDescription: View {
    @Environment(\.theme) private var theme
    @Environment(\.scAlertVariant) private var variant

    var text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(.footnote)
            .foregroundStyle(
                variant == .destructive
                    ? theme.destructive.opacity(0.9)
                    : theme.mutedForeground
            )
    }
}

// MARK: - Environment plumbing

/// Lets `SCAlertTitle`/`SCAlertDescription` pick up the enclosing alert's
/// variant without explicit wiring — the environment is the cascade.
private struct SCAlertVariantKey: EnvironmentKey {
    static let defaultValue: SCAlertVariant = .default
}

private extension EnvironmentValues {
    var scAlertVariant: SCAlertVariant {
        get { self[SCAlertVariantKey.self] }
        set { self[SCAlertVariantKey.self] = newValue }
    }
}

// MARK: - Previews

#Preview("Alert") {
    SCPreview {
        SCAlert(
            icon: "terminal",
            title: "Heads up!",
            description: "You can add components to your app using the CLI."
        )
    }
}

#Preview("Alert · destructive") {
    SCPreview {
        SCAlert(
            icon: "exclamationmark.triangle",
            title: "Error",
            description: "Your session has expired. Please log in again.",
            variant: .destructive
        )
    }
}

#Preview("Alert · slots") {
    SCPreview {
        SCAlert(icon: "checkmark.circle") {
            SCAlertTitle("Payment received")
            SCAlertDescription("A receipt was sent to your inbox.")
            SCBadge("Order #1024", variant: .secondary)
        }
    }
}
