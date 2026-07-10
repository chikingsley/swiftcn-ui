// ============================================================
// Typography.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Component

/// shadcn/ui's typography scale as chainable view styles.
///
/// Each style is a `ViewModifier` that reads the theme from the environment,
/// so muted styles pick up `theme.mutedForeground` and inline code sits on
/// `theme.muted` — exposed as `View` methods for a shadcn-like call site:
///
///     Text("Taxing Laughter").scH1()
///     Text("The Joke Tax").scH2()
///     Text("People stopped telling jokes").scLead()
///     Text("swift build").scInlineCode()
public extension View {
    /// shadcn `h1` — large title, bold, tight tracking.
    func scH1() -> some View { modifier(SCH1Style()) }

    /// shadcn `h2` — title, bold.
    func scH2() -> some View { modifier(SCH2Style()) }

    /// shadcn `h3` — title2, semibold.
    func scH3() -> some View { modifier(SCH3Style()) }

    /// shadcn `h4` — title3, semibold.
    func scH4() -> some View { modifier(SCH4Style()) }

    /// shadcn `lead` — title3 in the muted foreground color, for intros.
    func scLead() -> some View { modifier(SCLeadStyle()) }

    /// shadcn `large` — body, semibold.
    func scLarge() -> some View { modifier(SCLargeStyle()) }

    /// shadcn `small` — footnote, medium.
    func scSmall() -> some View { modifier(SCSmallStyle()) }

    /// shadcn `muted` — footnote in the muted foreground color.
    func scMuted() -> some View { modifier(SCMutedStyle()) }

    /// shadcn inline `code` — monospaced footnote on a muted chip.
    func scInlineCode() -> some View { modifier(SCInlineCodeStyle()) }
}

// MARK: - Modifiers

private struct SCH1Style: ViewModifier {
    @Environment(\.theme) private var theme

    func body(content: Content) -> some View {
        content
            .font(.largeTitle.weight(.bold))
            .tracking(-0.5)
            .foregroundStyle(theme.foreground)
    }
}

private struct SCH2Style: ViewModifier {
    @Environment(\.theme) private var theme

    func body(content: Content) -> some View {
        content
            .font(.title.weight(.bold))
            .foregroundStyle(theme.foreground)
    }
}

private struct SCH3Style: ViewModifier {
    @Environment(\.theme) private var theme

    func body(content: Content) -> some View {
        content
            .font(.title2.weight(.semibold))
            .foregroundStyle(theme.foreground)
    }
}

private struct SCH4Style: ViewModifier {
    @Environment(\.theme) private var theme

    func body(content: Content) -> some View {
        content
            .font(.title3.weight(.semibold))
            .foregroundStyle(theme.foreground)
    }
}

private struct SCLeadStyle: ViewModifier {
    @Environment(\.theme) private var theme

    func body(content: Content) -> some View {
        content
            .font(.title3)
            .foregroundStyle(theme.mutedForeground)
    }
}

private struct SCLargeStyle: ViewModifier {
    @Environment(\.theme) private var theme

    func body(content: Content) -> some View {
        content
            .font(.body.weight(.semibold))
            .foregroundStyle(theme.foreground)
    }
}

private struct SCSmallStyle: ViewModifier {
    @Environment(\.theme) private var theme

    func body(content: Content) -> some View {
        content
            .font(.footnote.weight(.medium))
            .foregroundStyle(theme.foreground)
    }
}

private struct SCMutedStyle: ViewModifier {
    @Environment(\.theme) private var theme

    func body(content: Content) -> some View {
        content
            .font(.footnote)
            .foregroundStyle(theme.mutedForeground)
    }
}

private struct SCInlineCodeStyle: ViewModifier {
    @Environment(\.theme) private var theme

    func body(content: Content) -> some View {
        content
            .font(.footnote.weight(.semibold).monospaced())
            .padding(.horizontal, 5)
            .padding(.vertical, 2)
            .foregroundStyle(theme.foreground)
            .background(theme.muted, in: chip)
    }

    private var chip: RoundedRectangle {
        RoundedRectangle(cornerRadius: max(min(theme.radius - 4, 6), 4), style: .continuous)
    }
}

// MARK: - Previews

#Preview("Typography") {
    SCPreview {
        VStack(alignment: .leading, spacing: 16) {
            Text("Taxing Laughter").scH1()
            Text("The People of the Kingdom").scH2()
            Text("The Joke Tax").scH3()
            Text("People stopped telling jokes").scH4()
            Text("A modal dialog that interrupts the user with important content.")
                .scLead()
            Text("Are you absolutely sure?").scLarge()
            Text("Email address").scSmall()
            Text("Enter your email address.").scMuted()
            Text("swift build").scInlineCode()
        }
    }
}
