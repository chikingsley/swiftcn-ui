import SwiftUI

#if os(macOS)
    import AppKit
#endif

// MARK: - Trigger / Separator / Rail

/// An icon button that toggles the sidebar — put one in the detail pane's
/// top bar. On compact widths it presents the sheet; otherwise it
/// expands/collapses the pane.
public struct SCSidebarTrigger: View {
    @Environment(\.scSidebar) private var state

    public init() {}

    public var body: some View {
        Button(action: state.toggle) {
            Image(systemName: state.side == .leading ? "sidebar.leading" : "sidebar.trailing")
                .font(.system(size: 16, weight: .medium))
                .frame(width: 32, height: 32)
                .contentShape(Rectangle())
        }
        .buttonStyle(.sc(.ghost, size: .iconSM))
        .accessibilityLabel("Toggle Sidebar")
        .accessibilityIdentifier("sidebar.toggle")
        .accessibilityValue(
            state.isCompact ? (state.openMobile ? "Expanded" : "Collapsed") : (state.isOpen ? "Expanded" : "Collapsed")
        )
        .scTooltip("Toggle sidebar", edge: .bottom)
        .help("Toggle Sidebar")
    }
}

/// A hairline divider for use inside the sidebar.
public struct SCSidebarSeparator: View {
    @Environment(\.theme) private var theme

    private let isDecorative: Bool
    private let accessibilityLabel: String

    public init(
        isDecorative: Bool = false,
        accessibilityLabel: String = "Separator"
    ) {
        self.isDecorative = isDecorative
        self.accessibilityLabel = accessibilityLabel
    }

    public var body: some View {
        SCSeparator(
            isDecorative: isDecorative,
            accessibilityLabel: accessibilityLabel
        )
        .environment(\.theme, separatorTheme)
        .padding(.horizontal, 12)
    }

    private var separatorTheme: Theme {
        var separatorTheme = theme
        separatorTheme.border = theme.sidebarBorder
        return separatorTheme
    }
}

/// An invisible 6pt strip along the sidebar's inner edge — tap or drag it
/// to toggle. `SCSidebarLayout` includes one automatically.
public struct SCSidebarRail: View {
    @Environment(\.scSidebar) private var state

    private let side: SCSidebarSide

    public init(side: SCSidebarSide = .leading) {
        self.side = side
    }

    public var body: some View {
        Color.clear
            .frame(width: 6)
            .frame(maxHeight: .infinity)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { value in
                        let dx = value.translation.width
                        if abs(dx) < 12 {
                            state.toggle()
                        } else {
                            state.isOpen = side == .leading ? dx > 0 : dx < 0
                        }
                    }
            )
            .accessibilityLabel("Toggle Sidebar")
            .accessibilityAddTraits(.isButton)
            .accessibilityAction { state.toggle() }
            .help("Toggle Sidebar")
            #if os(macOS)
                .onHover { isHovered in
                    if isHovered {
                        NSCursor.resizeLeftRight.push()
                    } else {
                        NSCursor.pop()
                    }
                }
            #endif
    }
}

// MARK: - Previews

/// Reference demo — shadcn's sidebar-07 block (icon collapse), used by the
/// previews below. Toggle with the trigger, ⌘B, or the rail on the divider.
private struct SidebarDemo: View {
    let collapsible: SCSidebarCollapsible
    @Binding var selection: String

    var body: some View {
        SCSidebarLayout(collapsible: collapsible) {
            SCSidebarHeader {
                SidebarDemoIdentity()
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
                        row("Sales & Travel", icon: "airplane")
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
                SidebarDemoUser()
            }
        } detail: {
            SidebarDemoDetail(title: selection)
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

/// App identity for the demo header — logo tile plus name, name hidden on
/// the icon rail.
private struct SidebarDemoIdentity: View {
    @Environment(\.theme) private var theme
    @Environment(\.scSidebarIconRail) private var iconRail

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
            if !iconRail {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Swiftcn")
                        .font(.subheadline.weight(.semibold))
                    Text("v2.0")
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

/// User row for the demo footer — initials circle plus name/email.
private struct SidebarDemoUser: View {
    @Environment(\.theme) private var theme
    @Environment(\.scSidebarIconRail) private var iconRail

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(theme.sidebarAccent)
                .frame(width: 32, height: 32)
                .overlay {
                    Text("AC")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(theme.sidebarAccentForeground)
                }
            if !iconRail {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Alex Chen")
                        .font(.subheadline.weight(.medium))
                    Text("alex@example.com")
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

/// Detail pane for the demo — top bar with trigger + placeholder content.
private struct SidebarDemoDetail: View {
    @Environment(\.theme) private var theme
    let title: String

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                SCSidebarTrigger()
                Rectangle()
                    .fill(theme.border)
                    .frame(width: 1, height: 16)
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.foreground)
                Spacer()
            }
            .padding(.horizontal, 12)
            .frame(height: 52)
            Rectangle()
                .fill(theme.border)
                .frame(height: 1)
            VStack(spacing: 16) {
                HStack(spacing: 16) {
                    ForEach(0..<3) { _ in
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.background)
    }
}

#Preview("Sidebar · sidebar-07 (icon collapse)") {
    @Previewable @State var selection = "Home"
    SidebarDemo(collapsible: .icon, selection: $selection)
        .frame(width: 900, height: 600)
        .theme(.default)
}

#Preview("Sidebar · offcanvas") {
    @Previewable @State var selection = "Inbox"
    SidebarDemo(collapsible: .offcanvas, selection: $selection)
        .frame(width: 900, height: 600)
        .theme(.default)
}
