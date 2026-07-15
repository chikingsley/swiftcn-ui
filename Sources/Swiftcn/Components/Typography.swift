// ============================================================
// Typography.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Component

/// shadcn/ui's typography styles as chainable view styles.
///
/// Upstream ships no typography component — the docs page documents the
/// utility-class styles for prose: h1–h4, p, blockquote, list, inline code,
/// lead, large, small, and muted. Each style here is a `ViewModifier` that
/// reads the theme from the environment, so muted styles pick up
/// `theme.mutedForeground` and inline code sits on `theme.muted` — exposed as
/// `View` methods for a shadcn-like call site:
///
///     Text("Taxing Laughter").scH1()
///     Text("The People of the Kingdom").scH2(bordered: true)
///     Text("The king, seeing how much happier…").scP()
///     Text("\"After all,\" he said…").scBlockquote()
///     Text("swift build").scInlineCode()
///     SCBulletList(["First", "Second", "Third"])
///
/// Document-flow margins (`mt-6`, `my-6`, `scroll-m-20`) stay with the
/// caller's stack spacing; the document-table example is served by the Table
/// component rather than a text style.
extension View {
    /// shadcn `h1` — centered large title, extrabold, tight tracking, heading level 1.
    ///
    /// Pass `centered: false` when reusing the type treatment outside a prose
    /// document where the official full-width centered block is not wanted.
    public func scH1(centered: Bool = true) -> some View {
        modifier(SCH1Style(centered: centered))
    }

    /// shadcn `h2` — title, semibold, tight tracking, heading level 2.
    ///
    /// Upstream's `h2` carries a full-width bottom rule (`border-b pb-2`).
    /// The rule is enabled by default and expands to the proposed width like
    /// the official block heading. Pass `bordered: false` when only the type
    /// treatment is needed in a compact composition.
    public func scH2(bordered: Bool = true) -> some View {
        modifier(SCH2Style(bordered: bordered))
    }

    /// shadcn `h3` — title2, semibold, tight tracking, heading level 3.
    public func scH3() -> some View { modifier(SCH3Style()) }

    /// shadcn `h4` — title3, semibold, tight tracking, heading level 4.
    public func scH4() -> some View { modifier(SCH4Style()) }

    /// shadcn `p` — body with the relaxed prose line height (`leading-7`).
    public func scP() -> some View { modifier(SCPStyle()) }

    /// shadcn `blockquote` — italic body behind a 2-point leading rule.
    /// The rule sits on the leading edge, so it follows layout direction.
    public func scBlockquote() -> some View { modifier(SCBlockquoteStyle()) }

    /// shadcn `lead` — title3 in the muted foreground color, for intros.
    public func scLead() -> some View { modifier(SCLeadStyle()) }

    /// shadcn `large` — body, semibold.
    public func scLarge() -> some View { modifier(SCLargeStyle()) }

    /// shadcn `small` — footnote, medium.
    public func scSmall() -> some View { modifier(SCSmallStyle()) }

    /// shadcn `muted` — footnote in the muted foreground color.
    public func scMuted() -> some View { modifier(SCMutedStyle()) }

    /// shadcn inline `code` — monospaced footnote on a muted chip.
    public func scInlineCode() -> some View { modifier(SCInlineCodeStyle()) }
}

/// shadcn typography `list` — a bulleted prose list (`list-disc`, spaced rows).
///
/// Rows accept arbitrary content through a per-element builder; a string-array
/// convenience covers the plain-text case. Bullets are decorative and hidden
/// from accessibility; each row's content keeps its own semantics.
///
///     SCBulletList(["1st level of puns: 5 gold coins",
///                   "2nd level of jokes: 10 gold coins"])
///
///     SCBulletList(items, id: \.id) { item in
///         Text(item.title).scSmall()
///     }
public struct SCBulletList<Data: RandomAccessCollection, ID: Hashable, RowContent: View>: View {
    @Environment(\.theme) private var theme

    private let data: Data
    private let id: KeyPath<Data.Element, ID>
    private let rowContent: (Data.Element) -> RowContent

    public init(
        _ data: Data,
        id: KeyPath<Data.Element, ID>,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
    ) {
        self.data = data
        self.id = id
        self.rowContent = rowContent
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(data, id: id) { element in
                HStack(alignment: .firstTextBaseline, spacing: 12) {
                    Text(verbatim: "•")
                        .font(.body)
                        .foregroundStyle(theme.foreground)
                        .accessibilityHidden(true)
                    rowContent(element)
                }
            }
        }
        .padding(.leading, 12)
    }
}

extension SCBulletList where Data.Element: Identifiable, ID == Data.Element.ID {
    public init(
        _ data: Data,
        @ViewBuilder rowContent: @escaping (Data.Element) -> RowContent
    ) {
        self.init(data, id: \.id, rowContent: rowContent)
    }
}

extension SCBulletList where Data == Range<Int>, ID == Int, RowContent == AnyView {
    /// Plain-text rows in the body prose style.
    public init(_ items: [String]) {
        self.init(items.indices, id: \.self) { index in
            AnyView(Text(items[index]).font(.body))
        }
    }
}

/// The shared table component used for shadcn's prose table example.
///
/// Keeping this as an alias makes Typography's documented table treatment
/// installable without introducing a second table implementation.
public typealias SCTypographyTable = SCTable

// MARK: - Modifiers

private struct SCH1Style: ViewModifier {
    @Environment(\.theme) private var theme

    let centered: Bool

    func body(content: Content) -> some View {
        content
            .font(.largeTitle.weight(.heavy))
            .tracking(-0.5)
            .multilineTextAlignment(centered ? .center : .leading)
            .frame(maxWidth: centered ? .infinity : nil, alignment: centered ? .center : .leading)
            .foregroundStyle(theme.foreground)
            .accessibilityAddTraits(.isHeader)
            .accessibilityHeading(.h1)
    }
}

private struct SCH2Style: ViewModifier {
    @Environment(\.theme) private var theme

    let bordered: Bool

    func body(content: Content) -> some View {
        content
            .font(.title.weight(.semibold))
            .tracking(-0.4)
            .foregroundStyle(theme.foreground)
            .frame(maxWidth: bordered ? .infinity : nil, alignment: .leading)
            .padding(.bottom, bordered ? 8 : 0)
            .overlay(alignment: .bottom) {
                if bordered {
                    Rectangle()
                        .fill(theme.border)
                        .frame(height: 1)
                }
            }
            .accessibilityAddTraits(.isHeader)
            .accessibilityHeading(.h2)
    }
}

private struct SCH3Style: ViewModifier {
    @Environment(\.theme) private var theme

    func body(content: Content) -> some View {
        content
            .font(.title2.weight(.semibold))
            .tracking(-0.35)
            .foregroundStyle(theme.foreground)
            .accessibilityAddTraits(.isHeader)
            .accessibilityHeading(.h3)
    }
}

private struct SCH4Style: ViewModifier {
    @Environment(\.theme) private var theme

    func body(content: Content) -> some View {
        content
            .font(.title3.weight(.semibold))
            .tracking(-0.3)
            .foregroundStyle(theme.foreground)
            .accessibilityAddTraits(.isHeader)
            .accessibilityHeading(.h4)
    }
}

private struct SCPStyle: ViewModifier {
    @Environment(\.theme) private var theme

    func body(content: Content) -> some View {
        content
            .font(.body)
            .lineSpacing(7)
            .foregroundStyle(theme.foreground)
    }
}

private struct SCBlockquoteStyle: ViewModifier {
    @Environment(\.theme) private var theme

    func body(content: Content) -> some View {
        content
            .font(.body.italic())
            .lineSpacing(7)
            .foregroundStyle(theme.foreground)
            .padding(.leading, 22)
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(theme.border)
                    .frame(width: 2)
            }
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
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Taxing Laughter").scH1()
                Text("The People of the Kingdom").scH2(bordered: true)
                Text("The Joke Tax").scH3()
                Text("People stopped telling jokes").scH4()
                Text(
                    "The king, seeing how much happier his subjects were, "
                        + "realized the error of his ways and repealed the joke tax."
                )
                .scP()
                Text(
                    "\"After all,\" he said, \"everyone enjoys a good joke, "
                        + "so it's only fair that they should pay for the privilege.\""
                )
                .scBlockquote()
                SCBulletList([
                    "1st level of puns: 5 gold coins",
                    "2nd level of jokes: 10 gold coins",
                    "3rd level of one-liners: 20 gold coins",
                ])
                Text("A modal dialog that interrupts the user with important content.")
                    .scLead()
                Text("Are you absolutely sure?").scLarge()
                Text("Email address").scSmall()
                Text("Enter your email address.").scMuted()
                Text("swift build").scInlineCode()
            }
            .padding()
        }
    }
}

#Preview("Typography RTL") {
    SCPreview {
        VStack(alignment: .leading, spacing: 16) {
            Text("اقتباس مع مسطرة على الحافة الأمامية")
                .scBlockquote()
            SCBulletList(["البند الأول", "البند الثاني"])
        }
        .environment(\.layoutDirection, .rightToLeft)
    }
}
