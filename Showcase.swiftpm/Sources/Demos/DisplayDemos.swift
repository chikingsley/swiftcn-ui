// ============================================================
// DisplayDemos.swift — Swiftcn Showcase
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
                SCAvatarGroup(avatars: [
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
    var body: some View {
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

// MARK: - Chat

/// The full chat suite in one stage: markers, bubbles, an attachment, the
/// typing indicator, and a live composer that appends to local state.
struct ChatDemo: View {
    @Environment(\.theme) private var theme

    private struct SentMessage: Identifiable {
        let id = UUID()
        let text: String
    }

    @State private var draft = ""
    @State private var sent: [SentMessage] = []

    var body: some View {
        VStack(spacing: 0) {
            SCMessageScroller {
                SCMessageMarker("Today")
                SCMessage(role: .received, avatar: (nil, "SD"), sender: "Sofia Davis") {
                    SCMessageBubble("Hi, how can I help you today?", role: .received)
                }
                SCMessage(role: .sent, timestamp: "9:41 AM") {
                    SCMessageBubble("Hey, I'm having trouble with my account.", role: .sent)
                    SCMessageAttachment(filename: "invoice-2026.pdf", size: "1.2 MB", systemImage: "doc.text")
                }
                SCMessageMarker("New", variant: .unread)
                SCMessage(role: .received, avatar: (nil, "SD")) {
                    SCMessageBubble("What seems to be the problem?", role: .received)
                }
                ForEach(sent) { message in
                    SCMessage(role: .sent) {
                        SCMessageBubble(message.text, role: .sent)
                    }
                }
                SCMessage(role: .received, avatar: (nil, "SD")) {
                    SCTypingIndicator()
                }
            }
            SCChatInputBar(text: $draft) {
                sent.append(SentMessage(text: draft))
                draft = ""
            }
        }
        .frame(height: 400)
        .clipShape(RoundedRectangle(cornerRadius: theme.radius, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: theme.radius, style: .continuous)
                .strokeBorder(theme.border)
        }
    }
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
    var body: some View {
        SCEmpty(
            "No results",
            systemImage: "magnifyingglass",
            description: "Try adjusting your search or removing filters."
        ) {
            Button("Clear filters") {}.buttonStyle(.sc(.outline, size: .sm))
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

    private var columns: [SCTableColumn<Invoice>] {
        [
            SCTableColumn("Invoice", width: .min(80)) { $0.id },
            SCTableColumn("Status") { $0.status },
            SCTableColumn("Method") { $0.method },
            SCTableColumn(
                "Amount",
                alignment: .trailing,
                comparator: { $0.amount < $1.amount },
                value: { $0.amount.formatted(.currency(code: "USD").precision(.fractionLength(2))) }
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
            DemoSection("Selectable rows · sortable Amount") {
                SCTable(
                    rows: invoices,
                    columns: columns,
                    selection: $selection
                )
            }
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
