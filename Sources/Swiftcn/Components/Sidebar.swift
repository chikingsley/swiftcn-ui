// ============================================================
// Sidebar.swift — swiftcn-ui
// Depends on: Theme/
//
// SwiftUI port of shadcn/ui's Sidebar — a composable, collapsible
// app sidebar. The whole family lives in this one file, mirroring
// shadcn's single sidebar.tsx:
//
//     SCSidebarLayout(collapsible: .icon) {
//         SCSidebarHeader { … }
//         SCSidebarContent {
//             SCSidebarGroup("Platform") {
//                 SCSidebarMenu {
//                     SCSidebarMenuButton("Home", systemImage: "house") { … }
//                 }
//             }
//         }
//         SCSidebarFooter { … }
//     } detail: {
//         …  // put an SCSidebarTrigger() in your top bar
//     }
// ============================================================
import SwiftUI
import Observation

// MARK: - Variants

/// How the sidebar collapses — shadcn's `collapsible` prop.
public enum SCSidebarCollapsible: Hashable, Sendable {
    /// Slides fully offscreen when collapsed.
    case offcanvas
    /// Collapses to a 56pt icon rail.
    case icon
    /// Never collapses.
    case none
}

/// Which edge of the layout the sidebar occupies.
public enum SCSidebarSide: Hashable, Sendable {
    case leading, trailing
}

// MARK: - Metrics

enum SCSidebarMetrics {
    static let expandedWidth: CGFloat = 272
    static let railWidth: CGFloat = 56
    static let animation: Animation = .snappy(duration: 0.25)
    static let storageKey = "sc.sidebar.open"
}

// MARK: - State

/// Shared sidebar state — the SwiftUI analog of shadcn's `SidebarProvider`
/// + `useSidebar` hook. `SCSidebarLayout` owns one and injects it into the
/// environment; read it anywhere in the hierarchy via
/// `@Environment(\.scSidebar)`.
@Observable
public final class SCSidebarState {
    /// Whether the sidebar is expanded (drives regular-width layouts).
    public var isOpen: Bool
    /// Whether the sidebar sheet is presented (drives compact-width layouts).
    public var openMobile: Bool
    /// The collapse behavior of the owning layout.
    public var collapsible: SCSidebarCollapsible

    /// True when the sidebar is currently the 56pt icon rail
    /// (`collapsible == .icon` and closed).
    public var isIconCollapsed: Bool { collapsible == .icon && !isOpen }

    public init(
        isOpen: Bool = true,
        openMobile: Bool = false,
        collapsible: SCSidebarCollapsible = .offcanvas
    ) {
        self.isOpen = isOpen
        self.openMobile = openMobile
        self.collapsible = collapsible
    }

    /// Toggles the expanded/collapsed state. On compact widths, toggle
    /// `openMobile` instead — `SCSidebarTrigger` picks the right one
    /// automatically.
    public func toggle() {
        isOpen.toggle()
    }
}

// MARK: - Environment

private struct SCSidebarStateKey: EnvironmentKey {
    static let defaultValue = SCSidebarState()
}

private struct SCSidebarIconRailKey: EnvironmentKey {
    static let defaultValue = false
}

extension EnvironmentValues {
    /// The enclosing sidebar's state — swiftcn's `useSidebar`. Read it to
    /// toggle or inspect the sidebar from anywhere inside `SCSidebarLayout`.
    public internal(set) var scSidebar: SCSidebarState {
        get { self[SCSidebarStateKey.self] }
        set { self[SCSidebarStateKey.self] = newValue }
    }

    /// Whether the enclosing sidebar pane is currently rendering as the
    /// icon rail. Set by `SCSidebarLayout`; pieces read it to adapt.
    /// (Always false inside the compact-width sheet.)
    var scSidebarIconRail: Bool {
        get { self[SCSidebarIconRailKey.self] }
        set { self[SCSidebarIconRailKey.self] = newValue }
    }
}

// MARK: - Layout

/// The sidebar shell: a sidebar pane plus your main content, with collapse
/// animation, ⌘B toggling, `@AppStorage` persistence, and an automatic
/// sheet fallback on compact widths (iPhone).
///
///     SCSidebarLayout(collapsible: .icon, side: .leading) {
///         SCSidebarHeader { … }
///         SCSidebarContent { … }
///         SCSidebarFooter { … }
///     } detail: {
///         …
///     }
public struct SCSidebarLayout<SidebarContent: View, Detail: View>: View {
    @Environment(\.theme) private var theme
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    @AppStorage(SCSidebarMetrics.storageKey) private var persistedOpen = true
    @State private var state: SCSidebarState

    private let collapsible: SCSidebarCollapsible
    private let side: SCSidebarSide
    private let sidebar: SidebarContent
    private let detail: Detail

    /// - Parameters:
    ///   - collapsible: How the sidebar collapses (default `.offcanvas`).
    ///   - side: Which edge the sidebar occupies (default `.leading`).
    ///   - sidebar: Sidebar content — compose `SCSidebarHeader`,
    ///     `SCSidebarContent`, and `SCSidebarFooter`.
    ///   - detail: The main content pane.
    public init(
        collapsible: SCSidebarCollapsible = .offcanvas,
        side: SCSidebarSide = .leading,
        @ViewBuilder sidebar: () -> SidebarContent,
        @ViewBuilder detail: () -> Detail
    ) {
        self.collapsible = collapsible
        self.side = side
        self.sidebar = sidebar()
        self.detail = detail()
        // Restore the persisted open state (mirrors shadcn's cookie).
        let restored = UserDefaults.standard
            .object(forKey: SCSidebarMetrics.storageKey) as? Bool ?? true
        _state = State(initialValue: SCSidebarState(
            isOpen: restored, collapsible: collapsible
        ))
    }

    public var body: some View {
        Group {
            if isCompact {
                compactLayout
            } else {
                regularLayout
            }
        }
        .background(keyboardToggle)
        .environment(\.scSidebar, state)
        .onChange(of: state.isOpen) { _, newValue in
            persistedOpen = newValue
        }
        .onChange(of: collapsible) { _, newValue in
            state.collapsible = newValue
        }
        .onChange(of: isCompact) { _, _ in
            state.openMobile = false
        }
    }

    // MARK: Regular width (iPad / Mac)

    private var regularLayout: some View {
        HStack(spacing: 0) {
            if side == .leading {
                pane
                divider
            }
            detailContainer
            if side == .trailing {
                divider
                pane
            }
        }
        .overlay(alignment: side == .leading ? .leading : .trailing) {
            if collapsible != .none {
                SCSidebarRail(side: side)
                    .padding(
                        side == .leading ? .leading : .trailing,
                        max(paneWidth - 3, 0)
                    )
            }
        }
        .animation(SCSidebarMetrics.animation, value: state.isOpen)
        .background(theme.background)
    }

    private var pane: some View {
        sidebarStack
            .environment(\.scSidebarIconRail, isIconRail)
            .foregroundStyle(theme.sidebarForeground)
            .frame(maxHeight: .infinity)
            .frame(width: contentWidth)
            .frame(width: paneWidth, alignment: side == .leading ? .trailing : .leading)
            .clipped()
            .background(theme.sidebar.ignoresSafeArea())
    }

    private var divider: some View {
        Rectangle()
            .fill(theme.sidebarBorder)
            .frame(width: 1)
            .ignoresSafeArea()
    }

    private var detailContainer: some View {
        detail.frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var isIconRail: Bool {
        collapsible == .icon && !state.isOpen
    }

    /// The width the sidebar's children lay out at.
    private var contentWidth: CGFloat {
        isIconRail ? SCSidebarMetrics.railWidth : SCSidebarMetrics.expandedWidth
    }

    /// The width the pane actually occupies in the HStack.
    private var paneWidth: CGFloat {
        guard collapsible != .none, !state.isOpen else {
            return SCSidebarMetrics.expandedWidth
        }
        return collapsible == .icon ? SCSidebarMetrics.railWidth : 0
    }

    // MARK: Compact width (iPhone)

    private var compactLayout: some View {
        @Bindable var sidebarState = state
        return detailContainer
            .background(theme.background)
            .sheet(isPresented: $sidebarState.openMobile) {
                sidebarStack
                    .foregroundStyle(theme.sidebarForeground)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(theme.sidebar)
                    .presentationDetents([.large])
                    .presentationDragIndicator(.visible)
                    .presentationBackground(theme.sidebar)
            }
    }

    // MARK: Shared

    private var sidebarStack: some View {
        VStack(spacing: 0) { sidebar }
    }

    /// Hidden button that binds ⌘B to the toggle, cross-platform.
    private var keyboardToggle: some View {
        Button("") {
            if isCompact {
                state.openMobile.toggle()
            } else {
                state.toggle()
            }
        }
        .keyboardShortcut("b", modifiers: .command)
        .buttonStyle(.plain)
        .opacity(0)
        .frame(width: 0, height: 0)
        .accessibilityHidden(true)
    }

    private var isCompact: Bool {
        #if os(iOS)
        return horizontalSizeClass == .compact
        #else
        return false
        #endif
    }
}

// MARK: - Header / Content / Footer

/// The sidebar's top slot — app identity, workspace switcher, search.
public struct SCSidebarHeader<Content: View>: View {
    @Environment(\.scSidebarIconRail) private var iconRail
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: iconRail ? .center : .leading, spacing: 8) {
            content
        }
        .frame(maxWidth: .infinity, alignment: iconRail ? .center : .leading)
        .padding(12)
    }
}

/// The sidebar's scrollable middle slot — holds `SCSidebarGroup`s.
public struct SCSidebarContent<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                content
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// The sidebar's bottom slot — user row, sign-out, version.
public struct SCSidebarFooter<Content: View>: View {
    @Environment(\.scSidebarIconRail) private var iconRail
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: iconRail ? .center : .leading, spacing: 8) {
            content
        }
        .frame(maxWidth: .infinity, alignment: iconRail ? .center : .leading)
        .padding(12)
    }
}

// MARK: - Group / Menu

/// A labeled section inside `SCSidebarContent`. The label hides on the
/// icon rail.
public struct SCSidebarGroup<Content: View>: View {
    @Environment(\.theme) private var theme
    @Environment(\.scSidebarIconRail) private var iconRail

    private let label: String?
    private let content: Content

    public init(_ label: String? = nil, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if let label, !iconRail {
                Text(label)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(theme.sidebarForeground.opacity(0.6))
                    .lineLimit(1)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .transition(.opacity)
            }
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
    }
}

/// A vertical stack of `SCSidebarMenuButton`s.
public struct SCSidebarMenu<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            content
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 8)
    }
}

/// A single navigation row: icon + label + optional count pill. On the
/// icon rail it renders as a centered icon only.
///
///     SCSidebarMenuButton("Inbox", systemImage: "tray", badge: "3") { … }
public struct SCSidebarMenuButton: View {
    @Environment(\.theme) private var theme
    @Environment(\.scSidebarIconRail) private var iconRail

    private let label: String
    private let systemImage: String?
    private let isActive: Bool
    private let badge: String?
    private let action: () -> Void

    /// - Parameters:
    ///   - label: The row title (hidden on the icon rail).
    ///   - systemImage: Optional SF Symbol shown at the leading edge.
    ///   - isActive: Highlights the row with `theme.sidebarAccent`.
    ///   - badge: Optional trailing count pill (hidden on the icon rail).
    ///   - action: Runs on tap.
    public init(
        _ label: String,
        systemImage: String? = nil,
        isActive: Bool = false,
        badge: String? = nil,
        action: @escaping () -> Void
    ) {
        self.label = label
        self.systemImage = systemImage
        self.isActive = isActive
        self.badge = badge
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if let systemImage {
                    Image(systemName: systemImage)
                        .font(.system(size: 16, weight: .medium))
                        .frame(width: 20, height: 20)
                }
                if !iconRail {
                    Text(label)
                        .font(.subheadline.weight(.medium))
                        .lineLimit(1)
                    Spacer(minLength: 0)
                    if let badge {
                        Text(badge)
                            .font(.caption2.weight(.semibold))
                            .lineLimit(1)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .foregroundStyle(theme.sidebarPrimaryForeground)
                            .background(theme.sidebarPrimary, in: Capsule())
                    }
                }
            }
            .transition(.opacity)
            .padding(.horizontal, iconRail ? 0 : 10)
            .frame(maxWidth: .infinity, alignment: iconRail ? .center : .leading)
            .frame(height: 36)
            .contentShape(RoundedRectangle(cornerRadius: theme.radius - 2, style: .continuous))
        }
        .buttonStyle(SCSidebarMenuButtonStyle(isActive: isActive))
        .animation(SCSidebarMetrics.animation, value: iconRail)
        .accessibilityLabel(Text(label))
        .accessibilityValue(badge.map(Text.init) ?? Text(""))
        .accessibilityAddTraits(isActive ? .isSelected : [])
    }
}

private struct SCSidebarMenuButtonStyle: ButtonStyle {
    @Environment(\.theme) private var theme
    let isActive: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                background(pressed: configuration.isPressed),
                in: RoundedRectangle(cornerRadius: theme.radius - 2, style: .continuous)
            )
            .foregroundStyle(isActive ? theme.sidebarAccentForeground : theme.sidebarForeground)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }

    private func background(pressed: Bool) -> Color {
        if isActive { return theme.sidebarAccent }
        return pressed ? theme.sidebarAccent.opacity(0.6) : .clear
    }
}

/// An indented sub-menu with a leading guide line. Hidden entirely on the
/// icon rail.
public struct SCSidebarMenuSub<Content: View>: View {
    @Environment(\.theme) private var theme
    @Environment(\.scSidebarIconRail) private var iconRail

    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        if !iconRail {
            VStack(alignment: .leading, spacing: 2) {
                content
            }
            .padding(.leading, 28)
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .leading) {
                Rectangle()
                    .fill(theme.sidebarBorder)
                    .frame(width: 1)
                    .padding(.leading, 18)
                    .padding(.vertical, 4)
            }
            .transition(.opacity)
        }
    }
}

// MARK: - Trigger / Separator / Rail

/// An icon button that toggles the sidebar — put one in the detail pane's
/// top bar. On compact widths it presents the sheet; otherwise it
/// expands/collapses the pane.
public struct SCSidebarTrigger: View {
    @Environment(\.theme) private var theme
    @Environment(\.scSidebar) private var state
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    public init() {}

    public var body: some View {
        Button {
            if isCompact {
                state.openMobile.toggle()
            } else {
                state.toggle()
            }
        } label: {
            Image(systemName: "sidebar.leading")
                .font(.system(size: 16, weight: .medium))
                .frame(width: 32, height: 32)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .foregroundStyle(theme.foreground)
        .accessibilityLabel("Toggle Sidebar")
    }

    private var isCompact: Bool {
        #if os(iOS)
        return horizontalSizeClass == .compact
        #else
        return false
        #endif
    }
}

/// A hairline divider for use inside the sidebar.
public struct SCSidebarSeparator: View {
    @Environment(\.theme) private var theme

    public init() {}

    public var body: some View {
        Rectangle()
            .fill(theme.sidebarBorder)
            .frame(height: 1)
            .padding(.horizontal, 12)
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
