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
