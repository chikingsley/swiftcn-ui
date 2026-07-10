// ============================================================
// NavigationDemos.swift — Swiftcn Showcase
// Live demos for the Navigation category.
// ============================================================
import SwiftUI
import Swiftcn

// MARK: - Breadcrumb

struct BreadcrumbDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SCBreadcrumb(items: [
                SCBreadcrumbItem("Home") {},
                SCBreadcrumbItem("Components") {},
                SCBreadcrumbItem("Breadcrumb"),
            ])
            DemoSection("Truncated") {
                SCBreadcrumb(
                    items: [
                        SCBreadcrumbItem("Home") {},
                        SCBreadcrumbItem("Documentation") {},
                        SCBreadcrumbItem("Building Blocks") {},
                        SCBreadcrumbItem("Components") {},
                        SCBreadcrumbItem("Breadcrumb"),
                    ],
                    maxVisible: 4
                )
            }
        }
    }
}

// MARK: - Command

/// The ⌘K palette over a bounded stage (the scrim covers the stage, not the
/// app), plus the same list inline in a bordered box.
struct CommandDemo: View {
    @Environment(\.theme) private var theme
    @State private var showPalette = false

    private static let groups = [
        SCCommandGroup(label: "Suggestions", items: [
            SCCommandItem(title: "Calendar", systemImage: "calendar") {},
            SCCommandItem(title: "Search Emoji", systemImage: "face.smiling", keywords: ["smiley", "emoticon"]) {},
            SCCommandItem(title: "Calculator", systemImage: "plus.forwardslash.minus", keywords: ["math"]) {},
        ]),
        SCCommandGroup(label: "Settings", items: [
            SCCommandItem(title: "Profile", systemImage: "person", shortcut: "⌘P") {},
            SCCommandItem(title: "Billing", systemImage: "creditcard", shortcut: "⌘B") {},
            SCCommandItem(title: "Settings", systemImage: "gearshape", shortcut: "⌘S") {},
        ]),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            DemoSection("Palette") {
                Button {
                    showPalette = true
                } label: {
                    HStack(spacing: 8) {
                        Text("Open command palette")
                        SCKbdGroup(["⌘", "K"])
                    }
                }
                .buttonStyle(.sc(.outline))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(height: 420)
                .scCommandPalette(isPresented: $showPalette, groups: Self.groups)
            }
            DemoSection("Inline list") {
                SCCommandList(groups: Self.groups)
                    .frame(height: 300)
                    .background(
                        theme.popover,
                        in: RoundedRectangle(cornerRadius: theme.radius + 4, style: .continuous)
                    )
                    .overlay {
                        RoundedRectangle(cornerRadius: theme.radius + 4, style: .continuous)
                            .strokeBorder(theme.border)
                    }
            }
        }
    }
}

// MARK: - Pagination

struct PaginationDemo: View {
    @State private var page = 2
    @State private var windowed = 25

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            DemoSection("10 pages") {
                pagination {
                    SCPagination(current: $page, total: 10)
                }
            }
            DemoSection("Windowed · 50 pages") {
                pagination {
                    SCPagination(current: $windowed, total: 50)
                }
            }
        }
    }

    /// Pagination rows are wider than an iPhone stage; let them scroll.
    private func pagination<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        ScrollView(.horizontal) {
            content()
        }
        .scrollIndicators(.hidden)
    }
}

// MARK: - Tabs

struct TabsDemo: View {
    private enum DemoTab: String, CaseIterable {
        case account, password, settings

        var item: SCTabItem<DemoTab> {
            SCTabItem(value: self, label: rawValue.capitalized)
        }
    }

    @State private var segmented: DemoTab = .account
    @State private var underline: DemoTab = .account

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            DemoSection("Segmented") {
                SCTabs(selection: $segmented, tabs: DemoTab.allCases.map(\.item)) { tab in
                    panel(for: tab)
                }
            }
            DemoSection("Underline") {
                SCTabs(selection: $underline, variant: .underline, tabs: DemoTab.allCases.map(\.item)) { tab in
                    panel(for: tab)
                }
            }
        }
    }

    @ViewBuilder
    private func panel(for tab: DemoTab) -> some View {
        Group {
            switch tab {
            case .account:
                Text("Make changes to your account here.")
            case .password:
                Text("Change your password here.")
            case .settings:
                Text("Edit your notification settings.")
            }
        }
        .font(.subheadline)
    }
}

// MARK: - Sidebar

/// A miniature SCSidebarLayout embedded in a bounded stage. The Showcase's
/// own shell is the full-size version of this exact component.
struct SidebarComponentDemo: View {
    @Environment(\.theme) private var theme
    @State private var selection = "Home"

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("This app's shell is an SCSidebarLayout — the demo below embeds a second, self-contained one. Toggle it with its trigger or drag its rail.")
                .scMuted()
            miniSidebar
                .frame(height: 480)
                .clipShape(RoundedRectangle(cornerRadius: theme.radius, style: .continuous))
                .overlay {
                    RoundedRectangle(cornerRadius: theme.radius, style: .continuous)
                        .strokeBorder(theme.border)
                }
        }
    }

    private var miniSidebar: some View {
        SCSidebarLayout(collapsible: .icon, persistenceKey: nil) {
            SCSidebarHeader {
                HStack(spacing: 8) {
                    RoundedRectangle(cornerRadius: theme.radius - 2, style: .continuous)
                        .fill(theme.sidebarPrimary)
                        .frame(width: 32, height: 32)
                        .overlay {
                            Image(systemName: "swift")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundStyle(theme.sidebarPrimaryForeground)
                        }
                }
            }
            SCSidebarContent {
                SCSidebarGroup("Platform") {
                    SCSidebarMenu {
                        row("Home", icon: "house")
                        row("Inbox", icon: "tray", badge: "3")
                        row("Settings", icon: "gearshape")
                    }
                }
                SCSidebarGroup("Projects") {
                    SCSidebarMenu {
                        row("Design Engineering", icon: "paintbrush")
                        row("Documentation", icon: "book")
                        SCSidebarMenuSub {
                            row("Get Started")
                            row("Changelog")
                        }
                    }
                }
            }
            SCSidebarSeparator()
            SCSidebarFooter {
                Text("swiftcn v2")
                    .font(.caption)
                    .foregroundStyle(theme.sidebarForeground.opacity(0.6))
            }
        } detail: {
            VStack(spacing: 0) {
                HStack(spacing: 12) {
                    SCSidebarTrigger()
                    Text(selection)
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                }
                .padding(.horizontal, 12)
                .frame(height: 48)
                Rectangle()
                    .fill(theme.border)
                    .frame(height: 1)
                RoundedRectangle(cornerRadius: theme.radius, style: .continuous)
                    .fill(theme.muted)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(12)
            }
            .background(theme.background)
        }
    }

    private func row(_ label: String, icon: String? = nil, badge: String? = nil) -> some View {
        SCSidebarMenuButton(
            label,
            systemImage: icon,
            isActive: selection == label,
            badge: badge
        ) {
            selection = label
        }
    }
}
