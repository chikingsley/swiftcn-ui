// ============================================================
// Card.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Component

/// A themed surface for grouping related content — the swiftcn port of
/// shadcn/ui's compound Card. Compose it from the subcomponents below;
/// every region is a `@ViewBuilder` slot, so any view goes.
///
///     SCCard {
///         SCCardHeader {
///             SCCardTitle("Create project")
///             SCCardDescription("Deploy your new project in one click.")
///         }
///         SCCardContent {
///             Text("Any view goes here.")
///         }
///         SCCardFooter {
///             Button("Deploy") {}.buttonStyle(.sc())
///         }
///     }
public struct SCCard<Content: View>: View {
    @Environment(\.theme) private var theme

    @ViewBuilder var content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) { content }
            .padding(24)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(theme.cardForeground)
            .background(theme.card, in: shape)
            .overlay { shape.strokeBorder(theme.border) }
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.radius + 2, style: .continuous)
    }
}

// MARK: - Subcomponents

/// Groups a card's title and description with tight vertical rhythm.
public struct SCCardHeader<Content: View>: View {
    @ViewBuilder var content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) { content }
    }
}

/// The card's heading text.
///
///     SCCardTitle("Create project")
public struct SCCardTitle: View {
    @Environment(\.theme) private var theme

    var text: Text

    public init(_ text: Text) {
        self.text = text
    }

    public init(_ title: String) {
        self.text = Text(title)
    }

    public var body: some View {
        text
            .font(.headline.weight(.semibold))
            .foregroundStyle(theme.cardForeground)
            .accessibilityAddTraits(.isHeader)
    }
}

/// Supporting copy under the title, set in the muted foreground color.
///
///     SCCardDescription("Deploy your new project in one click.")
public struct SCCardDescription: View {
    @Environment(\.theme) private var theme

    var text: Text

    public init(_ text: Text) {
        self.text = text
    }

    public init(_ description: String) {
        self.text = Text(description)
    }

    public var body: some View {
        text
            .font(.subheadline)
            .foregroundStyle(theme.mutedForeground)
    }
}

/// The card's main content region — a plain slot with no styling of its own.
public struct SCCardContent<Content: View>: View {
    @ViewBuilder var content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
    }
}

/// A horizontal row of trailing actions, typically buttons.
public struct SCCardFooter<Content: View>: View {
    @ViewBuilder var content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        HStack(spacing: 8) { content }
    }
}

// MARK: - Previews

#Preview("Card") {
    SCPreview {
        SCCard {
            SCCardHeader {
                SCCardTitle("Create project")
                SCCardDescription("Deploy your new project in one click.")
            }
            SCCardContent {
                HStack(spacing: 8) {
                    Text("Framework")
                        .font(.subheadline)
                    SCBadge("SwiftUI", variant: .secondary)
                }
            }
            SCCardFooter {
                Button("Cancel") {}.buttonStyle(.sc(.outline))
                Button("Deploy") {}.buttonStyle(.sc())
            }
        }
    }
}

#Preview("Card · text only") {
    SCPreview {
        SCCard {
            SCCardHeader {
                SCCardTitle("Notifications")
                SCCardDescription("You have 3 unread messages.")
            }
        }
    }
}
