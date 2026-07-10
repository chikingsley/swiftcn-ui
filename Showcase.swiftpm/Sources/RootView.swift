// ============================================================
// RootView.swift — Swiftcn Showcase
// The gallery shell: SCSidebarLayout dogfooding the flagship.
// ============================================================
import SwiftUI
import Swiftcn

struct RootView: View {
    @State private var selectionID = "button"

    private var selected: ComponentEntry {
        Catalog.all.first { $0.id == selectionID } ?? Catalog.all[0]
    }

    var body: some View {
        SCSidebarLayout(collapsible: .icon) {
            SCSidebarHeader {
                SidebarWordmark()
            }
            SCSidebarContent {
                ForEach(Category.allCases) { category in
                    SCSidebarGroup(category.title) {
                        SCSidebarMenu {
                            ForEach(Catalog.entries(in: category)) { entry in
                                SCSidebarMenuButton(
                                    entry.name,
                                    systemImage: entry.icon,
                                    isActive: entry.id == selectionID
                                ) {
                                    selectionID = entry.id
                                }
                            }
                        }
                    }
                }
            }
            SCSidebarSeparator()
            SCSidebarFooter {
                SidebarFooterLink()
            }
        } detail: {
            ComponentDetailView(entry: selected)
        }
    }
}

// MARK: - Sidebar header

/// "swiftcn" wordmark plus a v2 badge; collapses to the logo tile on the
/// icon rail.
private struct SidebarWordmark: View {
    @Environment(\.theme) private var theme
    @Environment(\.scSidebar) private var sidebar

    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: theme.radius - 2, style: .continuous)
                .fill(theme.sidebarPrimary)
                .frame(width: 32, height: 32)
                .overlay {
                    Image(systemName: "swift")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(theme.sidebarPrimaryForeground)
                }
            if !sidebar.isIconCollapsed {
                Text("swiftcn")
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
                SCBadge("v2", variant: .secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: sidebar.isIconCollapsed ? .center : .leading)
    }
}

// MARK: - Sidebar footer

/// Muted repository link row; icon only on the rail.
private struct SidebarFooterLink: View {
    @Environment(\.theme) private var theme
    @Environment(\.scSidebar) private var sidebar

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "link")
                .font(.system(size: 13, weight: .medium))
            if !sidebar.isIconCollapsed {
                Text("github.com/Mobilecn-UI/swiftcn-ui")
                    .font(.caption)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .foregroundStyle(theme.sidebarForeground.opacity(0.6))
        .frame(maxWidth: .infinity, alignment: sidebar.isIconCollapsed ? .center : .leading)
        .padding(.horizontal, sidebar.isIconCollapsed ? 0 : 4)
    }
}

// MARK: - Detail page

struct ComponentDetailView: View {
    @Environment(\.theme) private var theme

    let entry: ComponentEntry

    var body: some View {
        VStack(spacing: 0) {
            topBar
            Rectangle()
                .fill(theme.border)
                .frame(height: 1)
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(entry.description)
                        .scMuted()
                    DemoBox {
                        entry.demoView()
                    }
                    UsageSnippet(code: entry.usage)
                }
                .padding(20)
                .frame(maxWidth: 760, alignment: .leading)
                .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.background)
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            SCSidebarTrigger()
            Rectangle()
                .fill(theme.border)
                .frame(width: 1, height: 16)
            Text(entry.name)
                .scH3()
                .lineLimit(1)
            Spacer()
            SCBadge(entry.category.title, variant: .outline)
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
    }
}

// MARK: - Demo container

/// An SCCard-like bordered stage every demo renders inside.
struct DemoBox<Content: View>: View {
    @Environment(\.theme) private var theme

    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            content
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(theme.card, in: shape)
        .overlay { shape.strokeBorder(theme.border) }
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.radius + 2, style: .continuous)
    }
}

// MARK: - Usage snippet

/// The code tab equivalent: a monospaced, selectable snippet on a muted chip.
struct UsageSnippet: View {
    @Environment(\.theme) private var theme

    let code: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Usage")
                .scSmall()
            ScrollView(.horizontal) {
                Text(code)
                    .font(.system(.footnote, design: .monospaced))
                    .foregroundStyle(theme.foreground)
                    .textSelection(.enabled)
                    .multilineTextAlignment(.leading)
                    .padding(16)
            }
            .scrollIndicators(.hidden)
            .background(theme.muted, in: RoundedRectangle(cornerRadius: theme.radius, style: .continuous))
        }
    }
}
