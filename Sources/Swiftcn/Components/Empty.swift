// ============================================================
// Empty.swift — swiftcn-ui
// Depends on: Theme/ (previews also use Button.swift)
// ============================================================
import SwiftUI

// MARK: - Component

/// A centered empty state — the swiftcn port of shadcn/ui's Empty and the
/// themed cousin of `ContentUnavailableView`. Icon and actions are
/// `@ViewBuilder` slots; the icon is framed in a muted circle.
///
///     SCEmpty(
///         "No results",
///         systemImage: "magnifyingglass",
///         description: "Try adjusting your search."
///     ) {
///         Button("Clear filters") {}.buttonStyle(.sc(.outline))
///     }
public struct SCEmpty<Icon: View, Actions: View>: View {
    @Environment(\.theme) private var theme

    var title: String
    var description: String?
    var icon: Icon
    var actions: Actions

    public init(
        _ title: String,
        description: String? = nil,
        @ViewBuilder icon: () -> Icon = { EmptyView() },
        @ViewBuilder actions: () -> Actions = { EmptyView() }
    ) {
        self.title = title
        self.description = description
        self.icon = icon()
        self.actions = actions()
    }

    public var body: some View {
        VStack(spacing: 6) {
            if Icon.self != EmptyView.self {
                icon
                    .font(.title2)
                    .foregroundStyle(theme.mutedForeground)
                    .frame(width: 56, height: 56)
                    .background(theme.muted, in: Circle())
                    .padding(.bottom, 10)
                    .accessibilityHidden(true)
            }
            Text(title)
                .font(.headline)
                .foregroundStyle(theme.foreground)
                .multilineTextAlignment(.center)
            if let description {
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(theme.mutedForeground)
                    .multilineTextAlignment(.center)
            }
            if Actions.self != EmptyView.self {
                HStack(spacing: 8) { actions }
                    .padding(.top, 16)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 24)
        .padding(.vertical, 48)
    }
}

// MARK: - Convenience

public extension SCEmpty where Icon == Image {
    /// An empty state with an SF Symbol icon.
    init(
        _ title: String,
        systemImage: String,
        description: String? = nil,
        @ViewBuilder actions: () -> Actions = { EmptyView() }
    ) {
        self.init(
            title,
            description: description,
            icon: { Image(systemName: systemImage) },
            actions: actions
        )
    }
}

// MARK: - Previews

#Preview("Empty") {
    SCPreview {
        SCEmpty(
            "No results",
            systemImage: "magnifyingglass",
            description: "Try adjusting your search or removing filters."
        ) {
            Button("Clear filters") {}.buttonStyle(.sc(.outline, size: .sm))
        }
    }
}

#Preview("Empty · text only") {
    SCPreview {
        SCEmpty(
            "No notifications",
            description: "You're all caught up."
        )
    }
}
