// ============================================================
// DisplayDemos.swift — Swiftcn macOS Showcase
// Live demos for the Display category.
// ============================================================
import Charts
import SwiftUI
import Swiftcn

// MARK: - Accordion

struct AccordionDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            SCAccordion {
                SCAccordionItem(
                    "Is it accessible?",
                    content: "Yes. It uses native buttons, so focus and traits come for free."
                )
                SCAccordionItem(
                    "Is it styled?",
                    content: "Yes. It comes with default styles that match the other components' aesthetic."
                )
                SCAccordionItem(
                    "Is it animated?",
                    content: "Yes. It's animated by default with a snappy spring."
                )
            }
        }
    }
}

// MARK: - Avatar

struct AvatarDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            DemoSection("Sizes") {
                HStack(spacing: 12) {
                    SCAvatar(url: URL(string: "https://github.com/shadcn.png"), fallback: "CN", size: .sm)
                    SCAvatar(url: URL(string: "https://github.com/shadcn.png"), fallback: "CN")
                    SCAvatar(url: URL(string: "https://github.com/shadcn.png"), fallback: "CN", size: .lg)
                    SCAvatar(url: nil, fallback: "AB", size: .custom(72))
                }
            }
            DemoSection("Group with overflow") {
                SCAvatarGroup(
                    avatars: [
                        (URL(string: "https://github.com/shadcn.png"), "CN"),
                        (nil, "AB"),
                        (nil, "CD"),
                        (nil, "EF"),
                        (nil, "GH"),
                    ], max: 3)
            }
        }
    }
}

// MARK: - Badge

struct BadgeDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            WrappingRow {
                SCBadge("Badge")
                SCBadge("Secondary", variant: .secondary)
                SCBadge("Destructive", variant: .destructive)
                SCBadge("Outline", variant: .outline)
            }
            WrappingRow {
                SCBadge {
                    Label("Verified", systemImage: "checkmark.seal.fill")
                }
                SCBadge("99+", variant: .destructive)
            }
        }
    }
}

// MARK: - Card

struct CardDemo: View {
    @State private var lastAction = "Choose an action."

    var body: some View {
        VStack(spacing: 8) {
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
                    Button("Cancel") { lastAction = "Cancelled" }.buttonStyle(.sc(.outline))
                    Button("Deploy") { lastAction = "Deployed" }.buttonStyle(.sc())
                }
            }
            Text(lastAction).scMuted()
        }
    }
}

// MARK: - Carousel

struct CarouselDemo: View {
    @Environment(\.theme) private var theme

    private struct Slide: Identifiable {
        let id: Int
        var label: String { "\(id + 1)" }
    }

    var body: some View {
        SCCarousel(items: (0..<5).map(Slide.init)) { slide in
            RoundedRectangle(cornerRadius: theme.radius + 2, style: .continuous)
                .fill(theme.muted)
                .frame(height: 200)
                .overlay {
                    Text(slide.label)
                        .font(.largeTitle.weight(.semibold))
                        .foregroundStyle(theme.foreground)
                }
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Chart

struct ChartDemo: View {
    private struct Point: Identifiable {
        let id = UUID()
        let month: String
        let desktop: Double
        let mobile: Double
    }

    private let data: [Point] = [
        .init(month: "Jan", desktop: 186, mobile: 80),
        .init(month: "Feb", desktop: 305, mobile: 200),
        .init(month: "Mar", desktop: 237, mobile: 120),
        .init(month: "Apr", desktop: 73, mobile: 190),
        .init(month: "May", desktop: 209, mobile: 130),
        .init(month: "Jun", desktop: 214, mobile: 140),
    ]

    var body: some View {
        Chart(data) { point in
            BarMark(
                x: .value("Month", point.month),
                y: .value("Desktop", point.desktop)
            )
            .foregroundStyle(by: .value("Series", "Desktop"))
            .cornerRadius(3)

            BarMark(
                x: .value("Month", point.month),
                y: .value("Mobile", point.mobile)
            )
            .foregroundStyle(by: .value("Series", "Mobile"))
            .cornerRadius(3)
        }
        .scChartStyle()
        .frame(height: 240)
    }
}

// MARK: - Attachment

/// Every attachment state, both sizes, and the scrolling group.
struct AttachmentDemo: View {
    @State private var lastAction = "Attachments render metadata, upload state, and actions."

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            DemoSection("States") {
                VStack(alignment: .leading, spacing: 10) {
                    SCAttachment(state: .idle) {
                        SCAttachmentMedia { Image(systemName: "paperclip") }
                        SCAttachmentContent {
                            SCAttachmentTitle("Drop a file")
                            SCAttachmentDescription("Waiting for upload")
                        }
                    }
                    SCAttachment(state: .uploading) {
                        SCAttachmentMedia { SCSpinner(size: 16) }
                        SCAttachmentContent {
                            SCAttachmentTitle("quarterly-report.pdf")
                            SCAttachmentDescription("Uploading · 72%")
                        }
                        SCAttachmentActions {
                            SCAttachmentAction(
                                action: { lastAction = "Upload canceled" },
                                label: { Image(systemName: "xmark") }
                            )
                            .accessibilityLabel("Cancel upload")
                        }
                    }
                    SCAttachment(state: .error) {
                        SCAttachmentMedia { Image(systemName: "exclamationmark.triangle") }
                        SCAttachmentContent {
                            SCAttachmentTitle("archive.zip")
                            SCAttachmentDescription("Upload failed")
                        }
                    }
                }
            }
            DemoSection("Full-card trigger & group") {
                SCAttachmentGroup {
                    ForEach(["design-brief.pdf", "logo.svg", "photo.heic", "specs.numbers"], id: \.self) { name in
                        SCAttachmentTrigger(
                            action: { lastAction = "Opened \(name)" },
                            content: {
                                SCAttachment(size: .small) {
                                    SCAttachmentMedia { Image(systemName: "doc") }
                                    SCAttachmentContent {
                                        SCAttachmentTitle(name)
                                        SCAttachmentDescription("1.1 MB")
                                    }
                                }
                            }
                        )
                        .accessibilityLabel("Open \(name)")
                    }
                }
                .frame(width: 420)
            }
            Text(lastAction).scMuted()
        }
    }
}

// MARK: - Bubble

/// All seven bubble variants, alignment, grouping, and reactions.
struct BubbleDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            DemoSection("Variants") {
                VStack(alignment: .leading, spacing: 8) {
                    SCBubble { SCBubbleContent("Default — primary surface.") }
                    SCBubble(variant: .secondary) { SCBubbleContent("Secondary surface.") }
                    SCBubble(variant: .muted) { SCBubbleContent("Muted surface.") }
                    SCBubble(variant: .tinted) { SCBubbleContent("Tinted from the primary color.") }
                    SCBubble(variant: .outline) { SCBubbleContent("Outline surface.") }
                    SCBubble(variant: .ghost) { SCBubbleContent("Ghost — no surface, full width.") }
                    SCBubble(variant: .destructive) { SCBubbleContent("Something went wrong.") }
                }
                .frame(width: 340)
            }
            DemoSection("Group & reactions") {
                VStack(spacing: 16) {
                    SCBubbleGroup {
                        SCBubble(variant: .muted) { SCBubbleContent("It's always a one-line change 😭.") }
                        SCBubble(variant: .muted) { SCBubbleContent("Alright, let me take a look.") }
                            .scBubbleReactions(accessibilityLabel: "Reactions: thumbs up") { Text("👍") }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    SCBubble(align: .end) { SCBubbleContent("It's a one-line change.") }
                }
                .frame(width: 340)
            }
        }
    }
}

// MARK: - Marker

/// The three marker variants plus the live-status shimmer pairing.
struct MarkerDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            DemoSection("Variants") {
                VStack(spacing: 16) {
                    SCMarker {
                        SCMarkerIcon { Image(systemName: "checkmark") }
                        SCMarkerContent("Explored 4 files")
                    }
                    SCMarker(variant: .border) { SCMarkerContent("Yesterday") }
                    SCMarker(variant: .separator) { SCMarkerContent("Today") }
                }
                .frame(width: 340)
            }
            DemoSection("Live status") {
                VStack(spacing: 16) {
                    SCMarker {
                        SCMarkerIcon { SCSpinner(size: 16) }
                        SCMarkerContent("Thinking…").scShimmer()
                    }
                    SCMarker(variant: .separator) {
                        SCMarkerContent("Reading 4 files").scShimmer()
                    }
                }
                .frame(width: 340)
            }
        }
    }
}

// MARK: - Message

/// Conversation rows: alignment, avatars, headers, footers, and groups.
struct MessageDemo: View {
    var body: some View {
        VStack(spacing: 20) {
            SCMessage(align: .end) {
                SCMessageAvatar { SCAvatar(url: nil, fallback: "ME", size: .sm) }
                SCMessageContent {
                    SCBubble { SCBubbleContent("Deploying to prod real quick.") }
                }
            }
            SCMessage {
                SCMessageAvatar { SCAvatar(url: nil, fallback: "R", size: .sm) }
                SCMessageContent {
                    SCMessageHeader { Text("Rabbit") }
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
            SCMessage {
                SCMessageAvatar { SCAvatar(url: nil, fallback: "R", size: .sm) }
                SCMessageContent {
                    SCBubbleGroup {
                        SCBubble(variant: .muted) { SCBubbleContent("It's always a one-line change 😭.") }
                        SCBubble(variant: .muted) { SCBubbleContent("Alright, let me take a look.") }
                    }
                }
            }
        }
        .frame(width: 380)
    }
}

// MARK: - Message Scroller

/// A live conversation: bottom-anchored, turn-anchoring on send, a
/// streaming simulation, and the floating scroll-to-end control.
struct MessageScrollerDemo: View {
    @Environment(\.theme) private var theme

    private struct DemoMessage: Identifiable {
        let id: String
        var text: String
        let isFromUser: Bool
    }

    @State private var messages: [DemoMessage] = [
        .init(id: "m1", text: "The scroll behavior in our chat is driving me nuts.", isFromUser: true),
        .init(
            id: "m2",
            text: "That's the classic streaming scroll problem. The scroller pins the viewport "
                + "to the live edge while replies stream in — but only while you're already at the end.",
            isFromUser: false
        ),
        .init(id: "m3", text: "And when someone sends a new message?", isFromUser: true),
        .init(
            id: "m4",
            text: "Turn anchoring settles the new turn near the top, with a peek of the previous "
                + "exchange left visible above it.",
            isFromUser: false
        ),
    ]
    @State private var sendCount = 0
    @State private var scroller = SCMessageScrollerState()

    var body: some View {
        VStack(spacing: 12) {
            SCMessageScroller(state: scroller) {
                SCMessageScrollerViewport {
                    SCMessageScrollerContent {
                        ForEach(messages) { message in
                            SCMessageScrollerItem(messageId: message.id, scrollAnchor: message.isFromUser) {
                                SCMessage(align: message.isFromUser ? .end : .start) {
                                    SCMessageContent {
                                        SCBubble(
                                            variant: message.isFromUser ? .default : .muted,
                                            align: message.isFromUser ? .end : .start
                                        ) {
                                            SCBubbleContent(message.text)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(16)
                }
                SCMessageScrollerButton()
            }
            .frame(height: 380)
            .clipShape(RoundedRectangle(cornerRadius: theme.radius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: theme.radius, style: .continuous)
                    .strokeBorder(theme.border)
            }
            HStack(spacing: 8) {
                Button("Send", action: send)
                    .buttonStyle(.sc(size: .sm))
                Button("Jump to first") { scroller.scrollToMessage("m1") }
                    .buttonStyle(.sc(.outline, size: .sm))
                Spacer()
                Text("Anchor: \(scroller.currentAnchorId ?? "–")").scMuted()
            }
        }
        .frame(width: 420)
    }

    private func send() {
        sendCount += 1
        let turn = sendCount
        messages.append(.init(id: "sent-\(turn)", text: "Follow-up question #\(turn)?", isFromUser: true))
        stream(
            reply: "Reply #\(turn): the viewport follows this text while it streams in, "
                + "because you were already at the live edge when it started.",
            id: "reply-\(turn)"
        )
    }

    /// Appends a reply word by word so the follow-output behavior is visible.
    private func stream(reply: String, id: String) {
        messages.append(.init(id: id, text: "", isFromUser: false))
        let words = reply.split(separator: " ").map(String.init)
        Task { @MainActor in
            for word in words {
                try? await Task.sleep(for: .milliseconds(90))
                guard let index = messages.firstIndex(where: { $0.id == id }) else { return }
                messages[index].text += messages[index].text.isEmpty ? word : " \(word)"
            }
        }
    }
}

// MARK: - Response

struct ResponseDemo: View {
    var body: some View {
        ScrollView {
            SCResponse(Self.sample)
                .padding(.trailing, 8)
        }
        .frame(width: 520, height: 420)
    }

    private static let sample = """
        ## Shipping a component

        Swiftcn components are **open code**: copy the source into your app \
        and own it. A response like this one renders streamed markdown from \
        an [assistant](https://ui.elevenlabs.io) turn.

        ### Steps

        1. Install the `theme` item first.
        2. Run `swiftcn add response`.
        3. Add the MarkdownUI package dependency and build.

        > Components read semantic tokens, so one preset swap re-themes \
        > every response.

        ```swift
        SCResponse("**Hello!** How can I help you today?")
        ```

        | Token | Role |
        | --- | --- |
        | `muted` | Code surfaces |
        | `border` | Rules and table lines |
        | `primary` | Links |

        ---

        That's it — *happy shipping*.
        """
}

// MARK: - Collapsible

struct CollapsibleDemo: View {
    @State private var isOpen = true

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            SCCollapsible(isOpen: $isOpen) {
                Text("@peduarte starred 3 repositories")
            } content: {
                VStack(alignment: .leading, spacing: 8) {
                    Text("@radix-ui/primitives")
                    Text("@radix-ui/colors")
                    Text("@stitches/react")
                }
                .font(.footnote.monospaced())
            }
            SCCollapsible {
                Text("Can I use this in my project?")
            } content: {
                Text("Yes. Free to use for personal and commercial projects.")
            }
        }
    }
}

// MARK: - Empty

struct EmptyDemo: View {
    @State private var filtersCleared = false

    var body: some View {
        VStack(spacing: 8) {
            SCEmpty(
                filtersCleared ? "Filters cleared" : "No results",
                systemImage: "magnifyingglass",
                description: "Try adjusting your search or removing filters."
            ) {
                Button("Clear filters") { filtersCleared = true }
                    .buttonStyle(.sc(.outline, size: .sm))
            }
        }
    }
}

// MARK: - Item

struct ItemDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
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
            SCItem("Basic plan", description: "Up to 3 projects, community support.", variant: .outline) {
                Image(systemName: "shippingbox")
            } trailing: {
                SCBadge("Current")
            }
        }
    }
}

// MARK: - Kbd

struct KbdDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 4) {
                SCKbd("⌘")
                SCKbd("⇧")
                SCKbd("P")
            }
            SCKbd("Ctrl+B")
            SCKbdGroup(["⌥", "Space"])
        }
    }
}

// MARK: - Resizable

struct ResizableDemo: View {
    @Environment(\.theme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Drag a divider to resize; double-tap its handle to reset.")
                .scMuted()
            SCResizableSplit(fraction: 0.35) {
                pane("One")
            } second: {
                SCResizableSplit(.vertical, fraction: 0.4) {
                    pane("Two")
                } second: {
                    pane("Three")
                }
            }
            .frame(height: 260)
        }
    }

    private func pane(_ label: String) -> some View {
        RoundedRectangle(cornerRadius: theme.radius, style: .continuous)
            .fill(theme.muted)
            .overlay {
                Text(label)
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(theme.foreground)
            }
            .padding(6)
    }
}

// MARK: - Separator

struct SeparatorDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("swiftcn-ui")
                .font(.subheadline.weight(.medium))
            SCSeparator()
            HStack(spacing: 12) {
                Text("Docs").font(.subheadline)
                SCSeparator(.vertical)
                Text("Source").font(.subheadline)
                SCSeparator(.vertical)
                Text("Blog").font(.subheadline)
            }
            .frame(height: 20)
            SCSeparator(label: "or continue with")
        }
    }
}

// MARK: - Table

struct TableDemo: View {
    private struct Invoice: Identifiable {
        let id: String
        let status: String
        let method: String
        let amount: Double
    }

    private let invoices: [Invoice] = [
        .init(id: "INV001", status: "Paid", method: "Credit Card", amount: 250),
        .init(id: "INV002", status: "Pending", method: "PayPal", amount: 150),
        .init(id: "INV003", status: "Unpaid", method: "Bank Transfer", amount: 350),
        .init(id: "INV004", status: "Paid", method: "Credit Card", amount: 450),
        .init(id: "INV005", status: "Paid", method: "PayPal", amount: 550),
    ]

    @State private var selection: Set<String> = ["INV002"]
    @State private var sort: SCTableSort?
    @State private var lastAction = "No row action yet"

    private var columns: [SCTableColumn<Invoice>] {
        [
            SCTableColumn("Invoice", width: .min(80)) { $0.id },
            SCTableColumn("Status") { invoice in
                SCBadge(invoice.status, variant: badgeVariant(for: invoice.status))
            },
            SCTableColumn("Method") { $0.method },
            SCTableColumn(
                "Amount",
                alignment: .trailing,
                comparator: { $0.amount < $1.amount },
                value: { $0.amount.formatted(.currency(code: "USD").precision(.fractionLength(2))) }
            ),
            SCTableColumn(
                id: "actions",
                accessibilityLabel: "Actions",
                width: .fixed(64),
                alignment: .trailing,
                header: {
                    Image(systemName: "ellipsis")
                        .accessibilityHidden(true)
                },
                cell: { invoice in
                    Button {
                        lastAction = "Opened \(invoice.id)"
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                    .buttonStyle(.sc(.ghost, size: .icon))
                    .accessibilityLabel("Open actions for \(invoice.id)")
                }
            ),
        ]
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            SCTable(
                rows: invoices,
                columns: columns,
                caption: "A list of your recent invoices."
            )
            DemoSection("Rich cells · controlled sort · independent actions") {
                SCTable(
                    rows: invoices,
                    columns: columns,
                    selection: $selection,
                    selectionBehavior: .checkboxOnly,
                    sort: $sort
                )
                Text("\(selection.count) selected · \(lastAction)")
                    .scMuted()
            }
        }
    }

    private func badgeVariant(for status: String) -> SCBadgeVariant {
        switch status {
        case "Paid": .default
        case "Pending": .secondary
        default: .destructive
        }
    }
}

// MARK: - Typography

struct TypographyDemo: View {
    var body: some View {
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

#Preview("Display · Accordion") { ShowcasePreview { AccordionDemo() } }
#Preview("Display · Avatar") { ShowcasePreview { AvatarDemo() } }
#Preview("Display · Badge") { ShowcasePreview { BadgeDemo() } }
#Preview("Display · Card") { ShowcasePreview { CardDemo() } }
#Preview("Display · Carousel") { ShowcasePreview { CarouselDemo() } }
#Preview("Display · Chart") { ShowcasePreview { ChartDemo() } }
#Preview("Display · Attachment") { ShowcasePreview { AttachmentDemo() } }
#Preview("Display · Bubble") { ShowcasePreview { BubbleDemo() } }
#Preview("Display · Marker") { ShowcasePreview { MarkerDemo() } }
#Preview("Display · Message") { ShowcasePreview { MessageDemo() } }
#Preview("Display · Message Scroller") { ShowcasePreview { MessageScrollerDemo() } }
#Preview("Display · Collapsible") { ShowcasePreview { CollapsibleDemo() } }
#Preview("Display · Empty") { ShowcasePreview { EmptyDemo() } }
#Preview("Display · Item") { ShowcasePreview { ItemDemo() } }
#Preview("Display · Keyboard") { ShowcasePreview { KbdDemo() } }
#Preview("Display · Resizable") { ShowcasePreview { ResizableDemo() } }
#Preview("Display · Separator") { ShowcasePreview { SeparatorDemo() } }
#Preview("Display · Table") { ShowcasePreview(width: 1100) { TableDemo() } }
#Preview("Display · Typography") { ShowcasePreview { TypographyDemo() } }
