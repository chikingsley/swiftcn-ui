// ============================================================
// SidebarBlock.swift — swiftcn-ui
// Depends on: Theme/, Components/ (Sidebar, Breadcrumb, Avatar)
//
// SwiftUI port of shadcn/ui's sidebar-07 block — a collapsible
// icon-rail sidebar with team header, nested navigation, and a
// user footer, wrapped around your detail content:
//
//     SCSidebarBlock()                       // placeholder detail
//     SCSidebarBlock { MyContent() }         // your detail content
// ============================================================
import SwiftUI

// MARK: - Block

/// shadcn/ui's `sidebar-07` block as a ready-made screen: an
/// `SCSidebarLayout(collapsible: .icon)` with an app-identity header,
/// "Platform" and "Projects" navigation groups (including a nested
/// sub-menu), and a user footer. The detail pane keeps a persistent top
/// bar — `SCSidebarTrigger`, a hairline, and a breadcrumb — above a
/// `@ViewBuilder` content slot.
///
/// Use the parameterless initializer for the classic placeholder detail
/// (three muted tiles over one tall tile), or pass your own content:
///
///     SCSidebarBlock()
///
///     SCSidebarBlock {
///         MyDocumentView()
///     }
public struct SCSidebarBlock<Detail: View>: View {
    @Environment(\.theme) private var theme

    @State private var selection = "Playground"
    private let detail: Detail

    /// - Parameter detail: Content for the detail pane, rendered below the
    ///   block's built-in top bar (trigger + breadcrumb).
    public init(@ViewBuilder detail: () -> Detail) {
        self.detail = detail()
    }

    public var body: some View {
        SCSidebarLayout(collapsible: .icon) {
            SCSidebarHeader {
                SidebarBlockIdentity()
            }
            SCSidebarContent {
                SCSidebarGroup("Platform") {
                    SCSidebarMenu {
                        row("Playground", icon: "apple.terminal")
                        SCSidebarMenuSub {
                            row("History")
                            row("Starred")
                            row("Settings", key: "Playground Settings")
                        }
                        row("Models", icon: "cube")
                        row("Documentation", icon: "book")
                        row("Settings", icon: "gearshape")
                    }
                }
                SCSidebarGroup("Projects") {
                    SCSidebarMenu {
                        row("Design Engineering", icon: "paintbrush")
                        row("Sales & Marketing", icon: "chart.pie")
                        row("Travel", icon: "airplane")
                    }
                }
            }
            SCSidebarSeparator()
            SCSidebarFooter {
                SidebarBlockUser()
            }
        } detail: {
            VStack(spacing: 0) {
                topBar
                Rectangle()
                    .fill(theme.border)
                    .frame(height: 1)
                detail
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.background)
        }
    }

    // MARK: Top bar

    private var topBar: some View {
        HStack(spacing: 12) {
            SCSidebarTrigger()
            SCSeparator(.vertical)
                .frame(height: 16)
            SCBreadcrumb(items: [
                SCBreadcrumbItem("Building Your Application"),
                SCBreadcrumbItem("Data Fetching"),
            ])
            Spacer()
        }
        .padding(.horizontal, 12)
        .frame(height: 52)
    }

    // MARK: Rows

    private func row(_ label: String, key: String? = nil, icon: String? = nil) -> some View {
        let key = key ?? label
        return SCSidebarMenuButton(label, systemImage: icon, isActive: selection == key) {
            selection = key
        }
    }
}

public extension SCSidebarBlock where Detail == SCSidebarBlockPlaceholder {
    /// The block with its stock placeholder detail — three muted tiles over
    /// one tall tile, matching the shadcn block's skeleton content.
    init() {
        self.init { SCSidebarBlockPlaceholder() }
    }
}

// MARK: - Subcomponents

/// The sidebar-07 placeholder detail: a row of three muted tiles above one
/// tall muted tile. Useful as stand-in content while wiring up a layout.
public struct SCSidebarBlockPlaceholder: View {
    @Environment(\.theme) private var theme

    public init() {}

    public var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                ForEach(0..<3, id: \.self) { _ in
                    RoundedRectangle(cornerRadius: theme.radius, style: .continuous)
                        .fill(theme.muted)
                        .frame(maxWidth: .infinity)
                        .frame(height: 96)
                }
            }
            RoundedRectangle(cornerRadius: theme.radius, style: .continuous)
                .fill(theme.muted)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Header app tile — logo square plus name and plan, collapsing to just
/// the tile on the icon rail.
private struct SidebarBlockIdentity: View {
    @Environment(\.theme) private var theme
    @Environment(\.scSidebarIconRail) private var iconRail

    var body: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: theme.radius - 2, style: .continuous)
                .fill(theme.sidebarPrimary)
                .frame(width: 32, height: 32)
                .overlay {
                    Image(systemName: "square.stack.3d.up")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(theme.sidebarPrimaryForeground)
                }
            if !iconRail {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Acme Inc")
                        .font(.subheadline.weight(.semibold))
                    Text("Enterprise")
                        .font(.caption2)
                        .foregroundStyle(theme.sidebarForeground.opacity(0.6))
                }
                .lineLimit(1)
                .transition(.opacity)
            }
        }
        .frame(maxWidth: .infinity, alignment: iconRail ? .center : .leading)
    }
}

/// Footer user row — initials avatar plus name/email and a switcher
/// chevron, collapsing to just the avatar on the icon rail.
private struct SidebarBlockUser: View {
    @Environment(\.theme) private var theme
    @Environment(\.scSidebarIconRail) private var iconRail

    var body: some View {
        HStack(spacing: 8) {
            SCAvatar(url: nil, fallback: "CN", size: .sm)
            if !iconRail {
                VStack(alignment: .leading, spacing: 0) {
                    Text("shadcn")
                        .font(.subheadline.weight(.medium))
                    Text("m@example.com")
                        .font(.caption2)
                        .foregroundStyle(theme.sidebarForeground.opacity(0.6))
                }
                .lineLimit(1)
                Spacer(minLength: 0)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(theme.sidebarForeground.opacity(0.6))
            }
        }
        .frame(maxWidth: .infinity, alignment: iconRail ? .center : .leading)
    }
}

// MARK: - Previews

#Preview("SidebarBlock · sidebar-07") {
    SCPreview {
        SCSidebarBlock()
            .frame(width: 1000, height: 700)
    }
}

#Preview("SidebarBlock · custom detail") {
    SCPreview {
        SCSidebarBlock {
            VStack(spacing: 8) {
                Text("Data Fetching").scH2()
                Text("Replace the placeholder with any view.").scMuted()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .frame(width: 1000, height: 700)
    }
}
