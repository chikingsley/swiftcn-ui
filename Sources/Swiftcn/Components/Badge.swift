// ============================================================
// Badge.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Variants

public enum SCBadgeVariant: CaseIterable, Sendable {
    case `default`, secondary, destructive, outline
}

// MARK: - Component

/// Displays a small status pill.
///
///     SCBadge("New")
///     SCBadge("Beta", variant: .secondary)
///     SCBadge(variant: .outline) { Label("Verified", systemImage: "checkmark.seal") }
public struct SCBadge<Content: View>: View {
    @Environment(\.theme) private var theme

    var variant: SCBadgeVariant
    @ViewBuilder var content: Content

    public init(variant: SCBadgeVariant = .default, @ViewBuilder content: () -> Content) {
        self.variant = variant
        self.content = content()
    }

    public var body: some View {
        content
            .font(.caption.weight(.medium))
            .lineLimit(1)
            .padding(.vertical, 3)
            .padding(.horizontal, 10)
            .background(background, in: Capsule())
            .overlay {
                if variant == .outline {
                    Capsule().strokeBorder(theme.border)
                }
            }
            .foregroundStyle(foreground)
    }

    private var background: Color {
        switch variant {
        case .default:     theme.primary
        case .secondary:   theme.secondary
        case .destructive: theme.destructive
        case .outline:     .clear
        }
    }

    private var foreground: Color {
        switch variant {
        case .default:     theme.primaryForeground
        case .secondary:   theme.secondaryForeground
        case .destructive: theme.destructiveForeground
        case .outline:     theme.foreground
        }
    }
}

public extension SCBadge where Content == Text {
    init(_ label: String, variant: SCBadgeVariant = .default) {
        self.init(variant: variant) { Text(label) }
    }
}

// MARK: - Previews

#Preview("Badge") {
    SCPreview {
        HStack(spacing: 8) {
            SCBadge("Badge")
            SCBadge("Secondary", variant: .secondary)
            SCBadge("Destructive", variant: .destructive)
            SCBadge("Outline", variant: .outline)
        }
    }
}

#Preview("Badge · content") {
    SCPreview {
        HStack(spacing: 8) {
            SCBadge {
                Label("Verified", systemImage: "checkmark.seal.fill")
            }
            SCBadge("99+", variant: .destructive)
        }
    }
}
