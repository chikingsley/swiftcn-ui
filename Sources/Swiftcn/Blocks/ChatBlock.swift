// ============================================================
// Blocks/ChatBlock.swift — swiftcn-ui
// Depends on: Theme/ · Chat.swift · Avatar.swift · Button.swift ·
//             Separator.swift
//
// SwiftUI port of shadcn/ui's chat-01 block — a full messaging
// screen: contact header, bottom-anchored conversation with date
// and unread markers, an attachment, a typing indicator, and a
// live composer:
//
//     SCChatBlock()
// ============================================================
import SwiftUI

// MARK: - Block

/// shadcn/ui's `chat-01` block as a ready-made screen: a contact header
/// (avatar, name, email, new-conversation button) over a bottom-anchored
/// `SCMessageScroller` and an `SCChatInputBar`. The conversation is
/// hardcoded demo data; the composer appends sent messages to local
/// state, so the preview is fully interactive.
///
///     SCChatBlock()
public struct SCChatBlock: View {
    @Environment(\.theme) private var theme

    @State private var draft = ""
    @State private var sent: [SentMessage] = []

    private struct SentMessage: Identifiable {
        let id = UUID()
        let text: String
    }

    public init() {}

    public var body: some View {
        VStack(spacing: 0) {
            header
            SCSeparator()
            conversation
            SCChatInputBar(text: $draft, onSend: send)
        }
        .background(theme.background)
    }

    // MARK: Header

    private var header: some View {
        HStack(spacing: 12) {
            SCAvatar(url: nil, fallback: "SC", size: .custom(36))
            VStack(alignment: .leading, spacing: 2) {
                Text("Sofia Davis")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(theme.foreground)
                Text("m@example.com")
                    .font(.caption)
                    .foregroundStyle(theme.mutedForeground)
            }
            Spacer()
            Button {
                // New conversation
            } label: {
                Image(systemName: "plus")
            }
            .buttonStyle(.sc(.outline, size: .icon))
            .accessibilityLabel(Text("New message"))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: Conversation

    private var conversation: some View {
        SCMessageScroller {
            SCMessage(role: .received, avatar: (nil, "SC"), sender: "Sofia Davis") {
                SCMessageBubble("Hi, how can I help you today?", role: .received)
            }
            SCMessage(role: .sent) {
                SCMessageBubble("Hey, I'm having trouble with my account.", role: .sent)
            }
            SCMessage(role: .received, avatar: (nil, "SC")) {
                SCMessageBubble("What seems to be the problem?", role: .received)
            }

            SCMessageMarker("Today")

            SCMessage(role: .sent, timestamp: "9:41 AM") {
                SCMessageBubble("I can't log in — here's the invoice you asked for.", role: .sent)
                SCMessageAttachment(filename: "invoice-2026.pdf", size: "1.2 MB", systemImage: "doc.text")
            }

            SCMessageMarker("New", variant: .unread)

            SCMessage(role: .received, avatar: (nil, "SC"), timestamp: "9:45 AM") {
                SCMessageBubble("Thanks! Give me a moment to look into it.", role: .received)
            }

            ForEach(sent) { message in
                SCMessage(role: .sent) {
                    SCMessageBubble(message.text, role: .sent)
                }
            }

            SCMessage(role: .received, avatar: (nil, "SC")) {
                SCTypingIndicator()
            }
        }
    }

    // MARK: Actions

    private func send() {
        let trimmed = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        sent.append(SentMessage(text: trimmed))
        draft = ""
    }
}

// MARK: - Previews

#Preview("ChatBlock · chat-01") {
    SCPreview {
        SCChatBlock()
            .frame(height: 640)
    }
}
