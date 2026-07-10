// ============================================================
// Item.swift — swiftcn-ui
// Depends on: Theme/ (previews also use Badge.swift)
// ============================================================
import SwiftUI

// MARK: - Variants

public enum SCItemVariant: CaseIterable, Sendable {
    case `default`, outline
}

// MARK: - Component

/// A generic list row — the swiftcn port of shadcn/ui's Item. Leading media,
/// a title with optional muted description, and a trailing accessory are all
/// `@ViewBuilder` slots.
///
///     SCItem("Notifications", description: "Manage alert settings.") {
///         Image(systemName: "bell")
///     } trailing: {
///         Image(systemName: "chevron.right")
///     }
///
///     SCItem(variant: .outline) {
///         Image(systemName: "person.crop.circle")
///     } title: {
///         Text("Profile")
///     }
public struct SCItem<Leading: View, Title: View, Description: View, Trailing: View>: View {
    @Environment(\.theme) private var theme

    var variant: SCItemVariant
    var leading: Leading
    var title: Title
    var description: Description
    var trailing: Trailing

    public init(
        variant: SCItemVariant = .default,
        @ViewBuilder leading: () -> Leading = { EmptyView() },
        @ViewBuilder title: () -> Title,
        @ViewBuilder description: () -> Description = { EmptyView() },
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.variant = variant
        self.leading = leading()
        self.title = title()
        self.description = description()
        self.trailing = trailing()
    }

    public var body: some View {
        switch variant {
        case .default:
            row
                .padding(.vertical, 8)
        case .outline:
            row
                .padding(16)
                .overlay { shape.strokeBorder(theme.border) }
        }
    }

    private var row: some View {
        HStack(spacing: 12) {
            leading
            VStack(alignment: .leading, spacing: 2) {
                title
                    .font(.subheadline.weight(.medium))
                description
                    .font(.footnote)
                    .foregroundStyle(theme.mutedForeground)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            trailing
        }
        .foregroundStyle(theme.foreground)
        .accessibilityElement(children: .combine)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.radius, style: .continuous)
    }
}

// MARK: - Convenience

public extension SCItem where Title == Text, Description == EmptyView {
    /// A row with a plain-text title.
    init(
        _ title: String,
        variant: SCItemVariant = .default,
        @ViewBuilder leading: () -> Leading = { EmptyView() },
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.init(
            variant: variant,
            leading: leading,
            title: { Text(title) },
            trailing: trailing
        )
    }
}

public extension SCItem where Title == Text, Description == Text {
    /// A row with a plain-text title and muted description.
    init(
        _ title: String,
        description: String,
        variant: SCItemVariant = .default,
        @ViewBuilder leading: () -> Leading = { EmptyView() },
        @ViewBuilder trailing: () -> Trailing = { EmptyView() }
    ) {
        self.init(
            variant: variant,
            leading: leading,
            title: { Text(title) },
            description: { Text(description) },
            trailing: trailing
        )
    }
}

// MARK: - Previews

#Preview("Item") {
    SCPreview {
        VStack(spacing: 0) {
            SCItem("Notifications", description: "Choose how you want to be notified.") {
                Image(systemName: "bell")
            } trailing: {
                Image(systemName: "chevron.right")
            }
            SCItem("Appearance", description: "Customize the look and feel.") {
                Image(systemName: "paintbrush")
            } trailing: {
                SCBadge("New", variant: .secondary)
            }
            SCItem("Sign out")
        }
    }
}

#Preview("Item · outline") {
    SCPreview {
        SCItem("Basic plan", description: "Up to 3 projects, community support.", variant: .outline) {
            Image(systemName: "shippingbox")
        } trailing: {
            SCBadge("Current")
        }
    }
}
