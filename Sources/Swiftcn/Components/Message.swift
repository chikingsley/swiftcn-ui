// ============================================================
// Message.swift — swiftcn-ui
// Depends on: Theme/
//
// SwiftUI port of shadcn/ui's Message (June 2026 chat release):
// lays out a row in the conversation with avatar, alignment,
// header, content, footer, and grouped messages. The surface
// itself is the companion Bubble component. Upstream parts:
// MessageGroup · Message · MessageAvatar · MessageContent ·
// MessageHeader · MessageFooter.
//
//     SCMessage(align: .end) {
//         SCMessageAvatar { SCAvatar(url: nil, fallback: "ME") }
//         SCMessageContent {
//             SCBubble { SCBubbleContent("It's a one-line change.") }
//             SCMessageFooter { Text("Delivered") }
//         }
//     }
// ============================================================
import SwiftUI

// MARK: - Alignment

/// Which side of the conversation a message row sits on — shadcn's `align`
/// prop. `.start` reads as "received", `.end` as "sent".
public enum SCMessageAlignment: CaseIterable, Equatable, Hashable, Sendable {
    case start
    case end
}

// MARK: - Environment & preferences

private struct SCMessageAlignmentKey: EnvironmentKey {
    static let defaultValue = SCMessageAlignment.start
}

private struct SCMessageOuterDirectionKey: EnvironmentKey {
    static let defaultValue: LayoutDirection? = nil
}

private struct SCMessageHasFooterKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    fileprivate var scMessageAlignment: SCMessageAlignment {
        get { self[SCMessageAlignmentKey.self] }
        set { self[SCMessageAlignmentKey.self] = newValue }
    }

    fileprivate var scMessageOuterDirection: LayoutDirection? {
        get { self[SCMessageOuterDirectionKey.self] }
        set { self[SCMessageOuterDirectionKey.self] = newValue }
    }

    fileprivate var scMessageHasFooter: Bool {
        get { self[SCMessageHasFooterKey.self] }
        set { self[SCMessageHasFooterKey.self] = newValue }
    }
}

/// Bubbles "a footer exists" up from `SCMessageFooter` so `SCMessage` can
/// lift the avatar clear of it — upstream's
/// `group-has-data-[slot=message-footer]` selector.
private struct SCMessageFooterPreferenceKey: PreferenceKey {
    static let defaultValue = false

    static func reduce(value: inout Bool, nextValue: () -> Bool) {
        value = value || nextValue()
    }
}

// MARK: - Group

/// Stacks consecutive messages from the same sender — shadcn's
/// `MessageGroup`.
///
///     SCMessageGroup {
///         SCMessage { … }
///         SCMessage { … }
///     }
public struct SCMessageGroup<Content: View>: View {
    private let spacing: CGFloat
    private let content: Content

    /// Creates a message group. Put `SCMessage` rows inside.
    public init(spacing: CGFloat = 8, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: spacing) {
            content
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .contain)
    }
}

// MARK: - Message

/// A row in the conversation — shadcn's `Message`. Compose it from
/// `SCMessageAvatar` and `SCMessageContent`; `align` mirrors upstream's
/// `flex-row-reverse`, so `.end` rows place the avatar on the trailing
/// side and right-align the content column.
///
///     SCMessage {
///         SCMessageAvatar { SCAvatar(url: nil, fallback: "R") }
///         SCMessageContent {
///             SCBubble(variant: .muted) { SCBubbleContent("It's 4:55 PM. On a Friday.") }
///         }
///     }
public struct SCMessage<Content: View>: View {
    @Environment(\.layoutDirection) private var layoutDirection
    @State private var hasFooter = false

    private let align: SCMessageAlignment
    private let spacing: CGFloat
    private let content: Content

    /// Creates a message row.
    /// - Parameters:
    ///   - align: `.start` (received, leading) or `.end` (sent, trailing).
    ///   - content: An optional `SCMessageAvatar` followed by
    ///     `SCMessageContent`.
    public init(
        align: SCMessageAlignment = .start,
        spacing: CGFloat = 8,
        @ViewBuilder content: () -> Content
    ) {
        self.align = align
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        HStack(alignment: .bottom, spacing: spacing) {
            content
        }
        // Reversing the layout direction reverses the row — upstream's
        // data-[align=end]:flex-row-reverse. SCMessageAvatar and
        // SCMessageContent restore the outer direction for their content.
        .environment(\.layoutDirection, align == .end ? layoutDirection.scFlipped : layoutDirection)
        .environment(\.scMessageOuterDirection, layoutDirection)
        .environment(\.scMessageAlignment, align)
        .environment(\.scMessageHasFooter, hasFooter)
        .onPreferenceChange(SCMessageFooterPreferenceKey.self) { hasFooter = $0 }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .contain)
    }
}

extension LayoutDirection {
    fileprivate var scFlipped: LayoutDirection {
        self == .leftToRight ? .rightToLeft : .leftToRight
    }
}

// MARK: - Avatar

/// The avatar slot of a message row — shadcn's `MessageAvatar`. Anchors to
/// the row bottom and lifts clear of a footer when one is present. Put an
/// `SCAvatar` (or any small view) inside.
///
///     SCMessageAvatar { SCAvatar(url: nil, fallback: "CN", size: .sm) }
public struct SCMessageAvatar<Content: View>: View {
    @Environment(\.theme) private var theme
    @Environment(\.scMessageOuterDirection) private var outerDirection
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.scMessageHasFooter) private var hasFooter

    private let content: Content

    /// Creates the avatar slot.
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .environment(\.layoutDirection, outerDirection ?? layoutDirection)
            .frame(minWidth: 32, minHeight: 32)
            .background(theme.muted, in: Circle())
            .clipShape(Circle())
            // Stay clear of the footer line — upstream's -translate-y-8.
            .offset(y: hasFooter ? -26 : 0)
    }
}

extension SCMessageAvatar where Content == EmptyView {
    /// Reserves the avatar column for a grouped message without repeating the
    /// sender image, matching the official empty MessageAvatar composition.
    public init() {
        self.init { EmptyView() }
    }
}

// MARK: - Content

/// Wraps the header, bubbles/attachments, and footer of a message —
/// shadcn's `MessageContent`. Children right-align on `.end` rows.
public struct SCMessageContent<Content: View>: View {
    @Environment(\.scMessageAlignment) private var align
    @Environment(\.scMessageOuterDirection) private var outerDirection
    @Environment(\.layoutDirection) private var layoutDirection

    private let spacing: CGFloat
    private let content: Content

    /// Creates the content column of a message row.
    public init(spacing: CGFloat = 10, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: align == .end ? .trailing : .leading, spacing: spacing) {
            content
        }
        .frame(maxWidth: .infinity, alignment: align == .end ? .trailing : .leading)
        // Restored last so the column and its alignment resolve in the
        // original direction; only the row order stays reversed.
        .environment(\.layoutDirection, outerDirection ?? layoutDirection)
    }
}

// MARK: - Header

/// Content above the message surface — sender names, badges — shadcn's
/// `MessageHeader`.
///
///     SCMessageHeader { Text("Olivia") }
public struct SCMessageHeader<Content: View>: View {
    @Environment(\.theme) private var theme
    @Environment(\.scMessageAlignment) private var align

    private let spacing: CGFloat
    private let content: Content

    /// Creates a message header line.
    public init(spacing: CGFloat = 4, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        HStack(spacing: spacing) {
            content
        }
        .font(.caption.weight(.medium))
        .foregroundStyle(theme.mutedForeground)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: align == .end ? .trailing : .leading)
    }
}

// MARK: - Footer

/// Content below the message surface — delivery status, timestamps,
/// actions — shadcn's `MessageFooter`. Follows the message side.
///
///     SCMessageFooter { Text("Read Yesterday") }
public struct SCMessageFooter<Content: View>: View {
    @Environment(\.theme) private var theme
    @Environment(\.scMessageAlignment) private var align

    private let spacing: CGFloat
    private let content: Content

    /// Creates a message footer line.
    public init(spacing: CGFloat = 4, @ViewBuilder content: () -> Content) {
        self.spacing = spacing
        self.content = content()
    }

    public var body: some View {
        HStack(spacing: spacing) {
            content
        }
        .font(.caption.weight(.medium))
        .foregroundStyle(theme.mutedForeground)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: align == .end ? .trailing : .leading)
        .preference(key: SCMessageFooterPreferenceKey.self, value: true)
    }
}

// MARK: - Previews

#Preview("Message · conversation") {
    SCPreview {
        VStack(spacing: 24) {
            SCMessage(align: .end) {
                SCMessageAvatar { SCAvatar(url: nil, fallback: "ME", size: .sm) }
                SCMessageContent {
                    SCBubble { SCBubbleContent("Deploying to prod real quick.") }
                }
            }
            SCMessage {
                SCMessageAvatar { SCAvatar(url: nil, fallback: "R", size: .sm) }
                SCMessageContent {
                    SCBubble(variant: .muted) { SCBubbleContent("It's 4:55 PM. On a Friday.") }
                }
            }
            SCMessage(align: .end) {
                SCMessageAvatar { SCAvatar(url: nil, fallback: "ME", size: .sm) }
                SCMessageContent {
                    SCBubble { SCBubbleContent("It's a one-line change.") }
                    SCMessageFooter { Text("Delivered") }
                }
            }
        }
        .frame(width: 360)
    }
}

#Preview("Message · header & footer") {
    SCPreview {
        VStack(spacing: 24) {
            SCMessage {
                SCMessageContent {
                    SCMessageHeader { Text("Olivia") }
                    SCBubble(variant: .muted) { SCBubbleContent("I already checked the logs.") }
                }
            }
            SCMessage(align: .end) {
                SCMessageContent {
                    SCBubble { SCBubbleContent("Send the report to the team.") }
                    SCMessageFooter { Text("Read Yesterday") }
                }
            }
        }
        .frame(width: 360)
    }
}

#Preview("Message · group") {
    SCPreview {
        SCMessageGroup {
            SCMessage {
                SCMessageAvatar()
                SCMessageContent {
                    SCBubble(variant: .muted) { SCBubbleContent("It's always a one-line change 😭.") }
                }
            }
            SCMessage {
                SCMessageAvatar { SCAvatar(url: nil, fallback: "R", size: .sm) }
                SCMessageContent {
                    SCBubble(variant: .muted) { SCBubbleContent("Alright, let me take a look.") }
                }
            }
        }
        .frame(width: 360)
    }
}
