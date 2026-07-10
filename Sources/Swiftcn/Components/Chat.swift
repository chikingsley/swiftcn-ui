// ============================================================
// Chat.swift — swiftcn-ui
// Depends on: Theme/ · Avatar.swift
//
// SwiftUI port of shadcn/ui's Chat suite — message bubbles,
// full message rows, attachments, date/unread markers, a typing
// indicator, a bottom-anchored scroller, and an input bar. The
// whole family lives in this one file, mirroring shadcn's
// single chat source:
//
//     SCMessageScroller {
//         SCMessageMarker("Today")
//         SCMessage(role: .received, avatar: (nil, "SD"), sender: "Sofia") {
//             SCMessageBubble("Hi, how can I help?", role: .received)
//         }
//         SCMessage(role: .sent, timestamp: "9:41 AM") {
//             SCMessageBubble("I can't log in.", role: .sent)
//         }
//         SCTypingIndicator()
//     }
//     SCChatInputBar(text: $draft) { send() }
// ============================================================
import SwiftUI

// MARK: - Variants

/// Which side of the conversation a message belongs to.
public enum SCMessageRole: Hashable, Sendable {
    /// Authored by the current user — trailing-aligned, primary-colored.
    case sent
    /// Authored by the other party — leading-aligned, muted-colored.
    case received
}

/// The flavor of an `SCMessageMarker`.
public enum SCMessageMarkerVariant: Hashable, Sendable {
    /// A centered capsule label — "Today", "Yesterday", "May 4".
    case date
    /// A destructive-tinted rule flanking the label — the unread divider.
    case unread
}

// MARK: - Bubble

/// A single chat bubble — the smallest unit of the chat suite.
///
/// Sent bubbles use `theme.primary`, received bubbles `theme.muted`. The
/// corner on the "tail side" (bottom-trailing for sent, bottom-leading for
/// received) is tightened so consecutive bubbles read as a thread.
///
///     SCMessageBubble("Hey, I'm having trouble with my account.", role: .sent)
///     SCMessageBubble(role: .received) {
///         Label("Payment received", systemImage: "checkmark.circle")
///     }
public struct SCMessageBubble<Content: View>: View {
    @Environment(\.theme) private var theme

    var role: SCMessageRole
    @ViewBuilder var content: Content

    /// Creates a bubble with arbitrary content.
    /// - Parameters:
    ///   - role: `.sent` (primary) or `.received` (muted).
    ///   - content: The bubble's content — usually text, but any view works.
    public init(role: SCMessageRole, @ViewBuilder content: () -> Content) {
        self.role = role
        self.content = content()
    }

    public var body: some View {
        content
            .font(.subheadline)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(background, in: shape)
            .foregroundStyle(foreground)
            .frame(maxWidth: 300, alignment: role == .sent ? .trailing : .leading)
    }

    private var background: Color {
        role == .sent ? theme.primary : theme.muted
    }

    private var foreground: Color {
        role == .sent ? theme.primaryForeground : theme.foreground
    }

    private var shape: UnevenRoundedRectangle {
        let radius = theme.radius + 6
        return UnevenRoundedRectangle(
            topLeadingRadius: radius,
            bottomLeadingRadius: role == .received ? 4 : radius,
            bottomTrailingRadius: role == .sent ? 4 : radius,
            topTrailingRadius: radius,
            style: .continuous
        )
    }
}

public extension SCMessageBubble where Content == Text {
    /// Creates a text bubble — the primary form.
    ///
    ///     SCMessageBubble("What seems to be the problem?", role: .received)
    init(_ text: String, role: SCMessageRole) {
        self.init(role: role) { Text(text) }
    }
}

// MARK: - Message row

/// A full message row: an optional avatar (received only), an optional
/// sender name, the bubble content, and an optional timestamp. The row
/// pins to the leading edge for received messages and the trailing edge
/// for sent ones.
///
///     SCMessage(role: .received, avatar: (nil, "SD"), sender: "Sofia", timestamp: "9:41 AM") {
///         SCMessageBubble("Hi, how can I help you today?", role: .received)
///     }
///     SCMessage(role: .sent) {
///         SCMessageBubble("I can't log in.", role: .sent)
///     }
public struct SCMessage<Content: View>: View {
    @Environment(\.theme) private var theme

    var role: SCMessageRole
    var avatar: (URL?, String)?
    var sender: String?
    var timestamp: String?
    @ViewBuilder var content: Content

    /// Creates a message row.
    /// - Parameters:
    ///   - role: Which side the message sits on.
    ///   - avatar: `(url, fallback initials)` shown as a 28pt circle beside
    ///     received messages. Ignored for sent messages.
    ///   - sender: Name above the first bubble. Shown for received messages only.
    ///   - timestamp: Caption below the bubbles, e.g. `"9:41 AM"`.
    ///   - content: The bubble(s) — usually one or more `SCMessageBubble`s,
    ///     optionally an `SCMessageAttachment`.
    public init(
        role: SCMessageRole,
        avatar: (URL?, String)? = nil,
        sender: String? = nil,
        timestamp: String? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.role = role
        self.avatar = avatar
        self.sender = sender
        self.timestamp = timestamp
        self.content = content()
    }

    public var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if role == .received {
                if let avatar {
                    SCAvatar(url: avatar.0, fallback: avatar.1, size: .custom(28))
                }
                column
                Spacer(minLength: 32)
            } else {
                Spacer(minLength: 32)
                column
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var column: some View {
        VStack(alignment: role == .sent ? .trailing : .leading, spacing: 4) {
            if let sender, role == .received {
                Text(sender)
                    .font(.caption2)
                    .foregroundStyle(theme.mutedForeground)
                    .padding(.leading, 2)
            }
            content
            if let timestamp {
                Text(timestamp)
                    .font(.caption2)
                    .foregroundStyle(theme.mutedForeground)
            }
        }
    }
}

// MARK: - Attachment

/// A file-attachment card: an icon tile, the filename, and an optional
/// size caption inside a bordered container. Renders standalone in an
/// `SCMessage` or alongside a bubble.
///
///     SCMessageAttachment(filename: "invoice-2026.pdf", size: "1.2 MB", systemImage: "doc.text")
public struct SCMessageAttachment: View {
    @Environment(\.theme) private var theme

    var filename: String
    var size: String?
    var systemImage: String

    /// Creates an attachment card.
    /// - Parameters:
    ///   - filename: The file's display name.
    ///   - size: Optional human-readable size, e.g. `"1.2 MB"`.
    ///   - systemImage: SF Symbol for the icon tile.
    public init(filename: String, size: String? = nil, systemImage: String = "doc") {
        self.filename = filename
        self.size = size
        self.systemImage = systemImage
    }

    public var body: some View {
        HStack(spacing: 10) {
            iconTile
            VStack(alignment: .leading, spacing: 2) {
                Text(filename)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(theme.foreground)
                    .lineLimit(1)
                if let size {
                    Text(size)
                        .font(.caption2)
                        .foregroundStyle(theme.mutedForeground)
                }
            }
            Spacer(minLength: 0)
        }
        .padding(8)
        .frame(maxWidth: 260)
        .background(theme.background, in: containerShape)
        .overlay(containerShape.strokeBorder(theme.border))
        .accessibilityElement(children: .combine)
    }

    private var iconTile: some View {
        RoundedRectangle(cornerRadius: theme.radius - 2, style: .continuous)
            .fill(theme.secondary)
            .frame(width: 36, height: 36)
            .overlay {
                Image(systemName: systemImage)
                    .font(.subheadline)
                    .foregroundStyle(theme.secondaryForeground)
            }
    }

    private var containerShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.radius, style: .continuous)
    }
}

// MARK: - Marker

/// A centered divider between message groups — a date capsule or the
/// destructive-tinted "new messages" rule.
///
///     SCMessageMarker("Today")
///     SCMessageMarker("New", variant: .unread)
public struct SCMessageMarker: View {
    @Environment(\.theme) private var theme

    var text: String
    var variant: SCMessageMarkerVariant

    /// Creates a marker.
    /// - Parameters:
    ///   - text: The label — a date for `.date`, usually `"New"` for `.unread`.
    ///   - variant: `.date` (muted capsule) or `.unread` (destructive rule).
    public init(_ text: String, variant: SCMessageMarkerVariant = .date) {
        self.text = text
        self.variant = variant
    }

    public var body: some View {
        switch variant {
        case .date:
            Text(text)
                .font(.caption2)
                .foregroundStyle(theme.mutedForeground)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(theme.muted, in: Capsule())
                .frame(maxWidth: .infinity)
        case .unread:
            HStack(spacing: 12) {
                hairline
                Text(text)
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(theme.destructive)
                    .fixedSize()
                hairline
            }
        }
    }

    private var hairline: some View {
        theme.destructive
            .frame(height: 1)
            .frame(maxWidth: .infinity)
            .accessibilityHidden(true)
    }
}

// MARK: - Typing indicator

/// A received-style bubble with three dots pulsing in a staggered wave —
/// "the other party is typing". The animation is phase-driven, so it
/// restarts cleanly whenever the view reappears.
///
///     SCMessage(role: .received, avatar: (nil, "SD")) {
///         SCTypingIndicator()
///     }
public struct SCTypingIndicator: View {
    @Environment(\.theme) private var theme

    public init() {}

    public var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                dot(index: index)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(theme.muted, in: shape)
        .frame(maxWidth: 300, alignment: .leading)
        .accessibilityLabel(Text("Typing"))
    }

    private func dot(index: Int) -> some View {
        Circle()
            .fill(theme.mutedForeground)
            .frame(width: 6, height: 6)
            .phaseAnimator([0, 1, 2]) { dot, phase in
                dot
                    .opacity(phase == index ? 1 : 0.4)
                    .offset(y: phase == index ? -3 : 0)
            } animation: { _ in
                .easeInOut(duration: 0.3)
            }
    }

    private var shape: UnevenRoundedRectangle {
        let radius = theme.radius + 6
        return UnevenRoundedRectangle(
            topLeadingRadius: radius,
            bottomLeadingRadius: 4,
            bottomTrailingRadius: radius,
            topTrailingRadius: radius,
            style: .continuous
        )
    }
}

// MARK: - Scroller

/// The conversation viewport: a lazy, bottom-anchored `ScrollView` that
/// starts at the newest message and (on iOS) dismisses the keyboard
/// interactively as the user drags.
///
///     SCMessageScroller {
///         ForEach(messages) { message in … }
///     }
public struct SCMessageScroller<Content: View>: View {
    @ViewBuilder var content: Content

    /// Creates a scroller. Put `SCMessage` rows and `SCMessageMarker`s inside.
    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        let scroll = ScrollView {
            LazyVStack(spacing: 12) {
                content
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .defaultScrollAnchor(.bottom)
        #if os(iOS)
        return scroll.scrollDismissesKeyboard(.interactively)
        #else
        return scroll
        #endif
    }
}

// MARK: - Input bar

/// The message composer: a rounded input with a built-in circular send
/// button, under a top hairline. The send button disables (and mutes)
/// while the text is empty; Return also sends.
///
///     SCChatInputBar(text: $draft) {
///         messages.append(Message(text: draft))
///         draft = ""
///     }
public struct SCChatInputBar: View {
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @FocusState private var isFocused: Bool

    @Binding private var text: String
    private let placeholder: String
    private let onSend: () -> Void

    /// Creates an input bar.
    /// - Parameters:
    ///   - text: The draft message. The caller clears it after sending.
    ///   - placeholder: Prompt shown while the draft is empty.
    ///   - onSend: Called when the send button is tapped or Return is
    ///     pressed with non-blank text.
    public init(
        text: Binding<String>,
        placeholder: String = "Message…",
        onSend: @escaping () -> Void
    ) {
        self._text = text
        self.placeholder = placeholder
        self.onSend = onSend
    }

    private var isBlank: Bool {
        text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    public var body: some View {
        VStack(spacing: 0) {
            theme.border
                .frame(height: 1)
                .accessibilityHidden(true)
            HStack(spacing: 8) {
                field
                sendButton
            }
            .padding(.leading, 12)
            .padding(.trailing, 4)
            .frame(minHeight: 40)
            .background(theme.background, in: shape)
            .overlay(shape.strokeBorder(isFocused ? theme.ring : theme.input, lineWidth: isFocused ? 1.5 : 1))
            .contentShape(shape)
            .onTapGesture { isFocused = true }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .background(theme.background)
        .opacity(isEnabled ? 1 : 0.5)
        .animation(.easeOut(duration: 0.15), value: isFocused)
    }

    private var field: some View {
        TextField(placeholder, text: $text, prompt: prompt)
            .textFieldStyle(.plain)
            .font(.subheadline)
            .foregroundStyle(theme.foreground)
            .focused($isFocused)
            .submitLabel(.send)
            .onSubmit(send)
    }

    private var prompt: Text {
        Text(placeholder).foregroundStyle(theme.mutedForeground)
    }

    private var sendButton: some View {
        Button(action: send) {
            Image(systemName: "arrow.up")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(isBlank ? theme.mutedForeground : theme.primaryForeground)
                .frame(width: 32, height: 32)
                .background(isBlank ? theme.muted : theme.primary, in: Circle())
        }
        .buttonStyle(.plain)
        .disabled(isBlank)
        .animation(.easeOut(duration: 0.15), value: isBlank)
        .accessibilityLabel(Text("Send"))
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.radius, style: .continuous)
    }

    private func send() {
        guard !isBlank else { return }
        onSend()
    }
}

// MARK: - Previews

#Preview("Message · bubbles") {
    SCPreview {
        VStack(spacing: 12) {
            SCMessage(role: .received, avatar: (nil, "SD"), sender: "Sofia Davis", timestamp: "9:40 AM") {
                SCMessageBubble("Hi, how can I help you today?", role: .received)
            }
            SCMessage(role: .sent, timestamp: "9:41 AM") {
                SCMessageBubble("Hey, I'm having trouble with my account.", role: .sent)
            }
            SCMessage(role: .received, avatar: (nil, "SD")) {
                SCMessageBubble("What seems to be the problem?", role: .received)
            }
        }
    }
}

#Preview("Message · attachment & markers") {
    SCPreview {
        VStack(spacing: 12) {
            SCMessageMarker("Today")
            SCMessage(role: .sent) {
                SCMessageBubble("Here's the invoice from last month.", role: .sent)
                SCMessageAttachment(filename: "invoice-2026.pdf", size: "1.2 MB", systemImage: "doc.text")
            }
            SCMessageMarker("New", variant: .unread)
            SCMessage(role: .received, avatar: (nil, "SD")) {
                SCMessageBubble("Got it, thanks!", role: .received)
            }
        }
    }
}

#Preview("TypingIndicator") {
    SCPreview {
        SCMessage(role: .received, avatar: (nil, "SD")) {
            SCTypingIndicator()
        }
    }
}

#Preview("ChatInputBar") {
    @Previewable @State var draft = ""
    SCPreview {
        VStack(spacing: 24) {
            SCChatInputBar(text: $draft) { draft = "" }
            SCChatInputBar(text: .constant("On my way!")) {}
        }
    }
}

#Preview("Chat · conversation") {
    @Previewable @State var draft = ""
    SCPreview {
        VStack(spacing: 0) {
            SCMessageScroller {
                SCMessageMarker("Today")
                SCMessage(role: .received, avatar: (nil, "SD"), sender: "Sofia Davis") {
                    SCMessageBubble("Hi, how can I help you today?", role: .received)
                }
                SCMessage(role: .sent, timestamp: "9:41 AM") {
                    SCMessageBubble("Hey, I'm having trouble with my account.", role: .sent)
                }
                SCMessage(role: .received, avatar: (nil, "SD")) {
                    SCTypingIndicator()
                }
            }
            SCChatInputBar(text: $draft) { draft = "" }
        }
        .frame(height: 360)
    }
}
