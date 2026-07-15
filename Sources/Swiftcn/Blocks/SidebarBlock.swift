// ============================================================
// SidebarBlock.swift — swiftcn-ui
// Depends on: Theme/, Components/ (Sidebar, Breadcrumb, Avatar)
//
// Behaviorally complete SwiftUI port of shadcn/ui's sidebar-07:
// team switching, collapsible navigation, project actions, and
// a user account menu all perform real state changes or emit a
// required action to the owning application.
// ============================================================
import SwiftUI

// MARK: - Models

public struct SCSidebarTeam: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let plan: String
    public let systemImage: String

    public init(id: String, name: String, plan: String, systemImage: String) {
        self.id = id
        self.name = name
        self.plan = plan
        self.systemImage = systemImage
    }
}

public struct SCSidebarUser: Hashable, Sendable {
    public let name: String
    public let email: String
    public let avatarURL: URL?
    public let fallback: String

    public init(name: String, email: String, avatarURL: URL? = nil, fallback: String) {
        self.name = name
        self.email = email
        self.avatarURL = avatarURL
        self.fallback = fallback
    }
}

public struct SCSidebarNavigationItem: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let systemImage: String?
    public let items: [SCSidebarNavigationItem]
    public let initiallyExpanded: Bool

    public init(
        id: String,
        title: String,
        systemImage: String? = nil,
        items: [SCSidebarNavigationItem] = [],
        initiallyExpanded: Bool = false
    ) {
        self.id = id
        self.title = title
        self.systemImage = systemImage
        self.items = items
        self.initiallyExpanded = initiallyExpanded
    }
}

public struct SCSidebarProject: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let systemImage: String

    public init(id: String, name: String, systemImage: String) {
        self.id = id
        self.name = name
        self.systemImage = systemImage
    }
}

public struct SCSidebarBlockData: Sendable {
    public var teams: [SCSidebarTeam]
    public var user: SCSidebarUser
    public var navigation: [SCSidebarNavigationItem]
    public var projects: [SCSidebarProject]
    public var secondaryNavigation: [SCSidebarNavigationItem]

    public init(
        teams: [SCSidebarTeam],
        user: SCSidebarUser,
        navigation: [SCSidebarNavigationItem],
        projects: [SCSidebarProject],
        secondaryNavigation: [SCSidebarNavigationItem] = []
    ) {
        self.teams = teams
        self.user = user
        self.navigation = navigation
        self.projects = projects
        self.secondaryNavigation = secondaryNavigation
    }

    public static let sidebar07 = SCSidebarBlockData(
        teams: [
            SCSidebarTeam(
                id: "acme-inc",
                name: "Acme Inc",
                plan: "Enterprise",
                systemImage: "square.stack.3d.up"
            ),
            SCSidebarTeam(
                id: "acme-corp",
                name: "Acme Corp.",
                plan: "Startup",
                systemImage: "waveform"
            ),
            SCSidebarTeam(
                id: "evil-corp",
                name: "Evil Corp.",
                plan: "Free",
                systemImage: "command"
            ),
        ],
        user: SCSidebarUser(
            name: "shadcn",
            email: "m@example.com",
            fallback: "CN"
        ),
        navigation: [
            SCSidebarNavigationItem(
                id: "playground",
                title: "Playground",
                systemImage: "apple.terminal",
                items: [
                    SCSidebarNavigationItem(id: "playground-history", title: "History"),
                    SCSidebarNavigationItem(id: "playground-starred", title: "Starred"),
                    SCSidebarNavigationItem(id: "playground-settings", title: "Settings"),
                ],
                initiallyExpanded: true
            ),
            SCSidebarNavigationItem(
                id: "models",
                title: "Models",
                systemImage: "cube",
                items: [
                    SCSidebarNavigationItem(id: "models-genesis", title: "Genesis"),
                    SCSidebarNavigationItem(id: "models-explorer", title: "Explorer"),
                    SCSidebarNavigationItem(id: "models-quantum", title: "Quantum"),
                ]
            ),
            SCSidebarNavigationItem(
                id: "documentation",
                title: "Documentation",
                systemImage: "book",
                items: [
                    SCSidebarNavigationItem(id: "docs-introduction", title: "Introduction"),
                    SCSidebarNavigationItem(id: "docs-get-started", title: "Get Started"),
                    SCSidebarNavigationItem(id: "docs-tutorials", title: "Tutorials"),
                    SCSidebarNavigationItem(id: "docs-changelog", title: "Changelog"),
                ]
            ),
            SCSidebarNavigationItem(
                id: "settings",
                title: "Settings",
                systemImage: "gearshape",
                items: [
                    SCSidebarNavigationItem(id: "settings-general", title: "General"),
                    SCSidebarNavigationItem(id: "settings-team", title: "Team"),
                    SCSidebarNavigationItem(id: "settings-billing", title: "Billing"),
                    SCSidebarNavigationItem(id: "settings-limits", title: "Limits"),
                ]
            ),
        ],
        projects: [
            SCSidebarProject(id: "design-engineering", name: "Design Engineering", systemImage: "paintbrush"),
            SCSidebarProject(id: "sales-marketing", name: "Sales & Marketing", systemImage: "chart.pie"),
            SCSidebarProject(id: "travel", name: "Travel", systemImage: "airplane"),
        ]
    )
}

public enum SCSidebarProjectAction: Hashable, Sendable {
    case view
    case share
    case delete
}

public enum SCSidebarUserAction: Hashable, Sendable {
    case upgrade
    case account
    case billing
    case notifications
    case logOut
}

public enum SCSidebarBlockAction: Hashable, Sendable {
    case openBreadcrumbRoot
    case openOrganization
    case selectTeam(String)
    case addTeam
    case selectNavigation(String)
    case setNavigationExpanded(String, Bool)
    case selectProject(String)
    case project(String, SCSidebarProjectAction)
    case showMoreProjects
    case selectSecondaryNavigation(String)
    case user(SCSidebarUserAction)
}

enum SCSidebarApplicationHeaderStyle {
    case teamSwitcher
    case organization(SCSidebarTeam)
}

enum SCSidebarApplicationNavigationStyle {
    case collapsibleRows
    case selectableRowsWithSeparateDisclosure
}

// MARK: - Team switcher

public struct SCSidebarTeamSwitcher: View {
    @Environment(\.theme) private var theme
    @Environment(\.scSidebarIconRail) private var iconRail

    @Binding private var activeTeamID: String
    private let teams: [SCSidebarTeam]
    private let onSelect: (SCSidebarTeam) -> Void
    private let onAddTeam: () -> Void

    public init(
        teams: [SCSidebarTeam],
        activeTeamID: Binding<String>,
        onSelect: @escaping (SCSidebarTeam) -> Void,
        onAddTeam: @escaping () -> Void
    ) {
        self.teams = teams
        self._activeTeamID = activeTeamID
        self.onSelect = onSelect
        self.onAddTeam = onAddTeam
    }

    public var body: some View {
        if let activeTeam {
            Menu {
                Section {
                    ForEach(Array(teams.enumerated()), id: \.element.id) { index, team in
                        teamButton(team, index: index)
                    }
                } header: {
                    Text("Teams")
                }
                Divider()
                Button(action: onAddTeam) {
                    Label("Add team", systemImage: "plus")
                }
            } label: {
                controlLabel(
                    title: activeTeam.name,
                    subtitle: activeTeam.plan,
                    systemImage: activeTeam.systemImage
                )
            }
            .menuStyle(.button)
            .buttonStyle(.plain)
            .menuIndicator(.hidden)
            .accessibilityLabel("Switch team")
            .accessibilityValue(activeTeam.name)
        }
    }

    private var activeTeam: SCSidebarTeam? {
        teams.first { $0.id == activeTeamID } ?? teams.first
    }

    @ViewBuilder
    private func teamButton(_ team: SCSidebarTeam, index: Int) -> some View {
        let button = Button {
            activeTeamID = team.id
            onSelect(team)
        } label: {
            Label(team.name, systemImage: team.systemImage)
        }
        if index < 9 {
            button.keyboardShortcut(
                KeyEquivalent(Character(String(index + 1))),
                modifiers: .command
            )
        } else {
            button
        }
    }

    private func controlLabel(title: String, subtitle: String, systemImage: String) -> some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: max(theme.radius - 2, 4), style: .continuous)
                .fill(theme.sidebarPrimary)
                .frame(width: 32, height: 32)
                .overlay {
                    Image(systemName: systemImage)
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundStyle(theme.sidebarPrimaryForeground)
                }
            if !iconRail {
                VStack(alignment: .leading, spacing: 0) {
                    Text(title).font(.subheadline.weight(.semibold))
                    Text(subtitle)
                        .font(.caption2)
                        .foregroundStyle(theme.sidebarForeground.opacity(0.6))
                }
                .lineLimit(1)
                Spacer(minLength: 0)
                Image(systemName: "chevron.up.chevron.down")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(theme.sidebarForeground.opacity(0.6))
            }
        }
        .padding(.horizontal, iconRail ? 0 : 8)
        .frame(maxWidth: .infinity, alignment: iconRail ? .center : .leading)
        .frame(height: 44)
        .contentShape(RoundedRectangle(cornerRadius: theme.radius - 2, style: .continuous))
    }
}

// MARK: - User menu

public struct SCSidebarUserMenu: View {
    @Environment(\.theme) private var theme
    @Environment(\.scSidebarIconRail) private var iconRail

    private let user: SCSidebarUser
    private let onAction: (SCSidebarUserAction) -> Void

    public init(user: SCSidebarUser, onAction: @escaping (SCSidebarUserAction) -> Void) {
        self.user = user
        self.onAction = onAction
    }

    public var body: some View {
        Menu {
            Section {
                Button {
                    onAction(.upgrade)
                } label: {
                    Label("Upgrade to Pro", systemImage: "sparkles")
                }
            } header: {
                Text("\(user.name) · \(user.email)")
            }
            Divider()
            Section {
                Button {
                    onAction(.account)
                } label: {
                    Label("Account", systemImage: "checkmark.seal")
                }
                Button {
                    onAction(.billing)
                } label: {
                    Label("Billing", systemImage: "creditcard")
                }
                Button {
                    onAction(.notifications)
                } label: {
                    Label("Notifications", systemImage: "bell")
                }
            }
            Divider()
            Button(role: .destructive) {
                onAction(.logOut)
            } label: {
                Label("Log out", systemImage: "rectangle.portrait.and.arrow.right")
            }
        } label: {
            HStack(spacing: 8) {
                SCAvatar(url: user.avatarURL, fallback: user.fallback, size: .sm)
                if !iconRail {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(user.name).font(.subheadline.weight(.medium))
                        Text(user.email)
                            .font(.caption2)
                            .foregroundStyle(theme.sidebarForeground.opacity(0.6))
                    }
                    .lineLimit(1)
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(theme.sidebarForeground.opacity(0.6))
                }
            }
            .padding(.horizontal, iconRail ? 0 : 8)
            .frame(maxWidth: .infinity, alignment: iconRail ? .center : .leading)
            .frame(height: 44)
            .contentShape(RoundedRectangle(cornerRadius: theme.radius - 2, style: .continuous))
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .accessibilityLabel("User menu")
        .accessibilityValue(user.name)
    }
}

// MARK: - Block

/// A functional SwiftUI adaptation of shadcn's `sidebar-07` application shell.
public struct SCSidebarBlock<Detail: View>: View {
    @Environment(\.theme) private var theme

    @State private var internalActiveTeamID: String
    @State private var internalSelection: String
    @State private var internalExpandedNavigationIDs: Set<String>

    private let data: SCSidebarBlockData
    private let externalActiveTeamID: Binding<String>?
    private let externalSelection: Binding<String>?
    private let externalExpandedNavigationIDs: Binding<Set<String>>?
    private let collapsible: SCSidebarCollapsible
    private let persistenceKey: String?
    private let variant: SCSidebarVariant
    private let externalSidebarState: SCSidebarState?
    private let showsDetailHeader: Bool
    private let headerStyle: SCSidebarApplicationHeaderStyle
    private let navigationStyle: SCSidebarApplicationNavigationStyle
    private let showsSecondaryNavigation: Bool
    private let onAction: (SCSidebarBlockAction) -> Void
    private let detail: (String) -> Detail

    public init(
        data: SCSidebarBlockData = .sidebar07,
        activeTeamID: Binding<String>? = nil,
        selection: Binding<String>? = nil,
        expandedNavigationIDs: Binding<Set<String>>? = nil,
        persistenceKey: String? = "sc.sidebar07.open",
        onAction: @escaping (SCSidebarBlockAction) -> Void,
        @ViewBuilder detail: @escaping (_ selection: String) -> Detail
    ) {
        self.init(
            data: data,
            activeTeamID: activeTeamID,
            selection: selection,
            expandedNavigationIDs: expandedNavigationIDs,
            collapsible: .icon,
            persistenceKey: persistenceKey,
            variant: .inset,
            sidebarState: nil,
            showsDetailHeader: true,
            headerStyle: .teamSwitcher,
            navigationStyle: .collapsibleRows,
            showsSecondaryNavigation: false,
            onAction: onAction,
            detail: detail
        )
    }

    init(
        data: SCSidebarBlockData,
        activeTeamID: Binding<String>?,
        selection: Binding<String>?,
        expandedNavigationIDs: Binding<Set<String>>? = nil,
        collapsible: SCSidebarCollapsible,
        persistenceKey: String?,
        variant: SCSidebarVariant = .inset,
        sidebarState: SCSidebarState? = nil,
        showsDetailHeader: Bool = true,
        headerStyle: SCSidebarApplicationHeaderStyle,
        navigationStyle: SCSidebarApplicationNavigationStyle,
        showsSecondaryNavigation: Bool,
        onAction: @escaping (SCSidebarBlockAction) -> Void,
        @ViewBuilder detail: @escaping (_ selection: String) -> Detail
    ) {
        self.data = data
        self.externalActiveTeamID = activeTeamID
        self.externalSelection = selection
        self.externalExpandedNavigationIDs = expandedNavigationIDs
        self.collapsible = collapsible
        self.persistenceKey = persistenceKey
        self.variant = variant
        self.externalSidebarState = sidebarState
        self.showsDetailHeader = showsDetailHeader
        self.headerStyle = headerStyle
        self.navigationStyle = navigationStyle
        self.showsSecondaryNavigation = showsSecondaryNavigation
        self.onAction = onAction
        self.detail = detail

        let initialTeam = activeTeamID?.wrappedValue ?? data.teams.first?.id ?? ""
        let initialSelection = selection?.wrappedValue ?? Self.initialSelection(in: data)
        _internalActiveTeamID = State(initialValue: initialTeam)
        _internalSelection = State(initialValue: initialSelection)
        _internalExpandedNavigationIDs = State(
            initialValue: expandedNavigationIDs?.wrappedValue
                ?? Set(data.navigation.filter(\.initiallyExpanded).map(\.id))
        )
    }

    public init(
        data: SCSidebarBlockData = .sidebar07,
        activeTeamID: Binding<String>? = nil,
        selection: Binding<String>? = nil,
        expandedNavigationIDs: Binding<Set<String>>? = nil,
        persistenceKey: String? = "sc.sidebar07.open",
        onAction: @escaping (SCSidebarBlockAction) -> Void,
        @ViewBuilder detail: @escaping () -> Detail
    ) {
        self.init(
            data: data,
            activeTeamID: activeTeamID,
            selection: selection,
            expandedNavigationIDs: expandedNavigationIDs,
            persistenceKey: persistenceKey,
            onAction: onAction,
            detail: { _ in detail() }
        )
    }

    public var body: some View {
        SCSidebarLayout(
            collapsible: collapsible,
            variant: variant,
            persistenceKey: persistenceKey,
            state: externalSidebarState
        ) {
            SCSidebarHeader {
                applicationHeader
            }
            SCSidebarContent {
                navigationGroup
                SCSidebarExpandedOnly { projectsGroup }
                if showsSecondaryNavigation {
                    Spacer(minLength: 0)
                    secondaryNavigationGroup
                }
            }
            SCSidebarFooter {
                SCSidebarUserMenu(user: data.user) { onAction(.user($0)) }
            }
        } detail: {
            VStack(spacing: 0) {
                if showsDetailHeader {
                    topBar
                    Rectangle().fill(theme.border).frame(height: 1)
                }
                detail(selectedID)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.background)
        }
    }

    private var activeTeamBinding: Binding<String> {
        externalActiveTeamID ?? $internalActiveTeamID
    }

    @ViewBuilder
    private var applicationHeader: some View {
        switch headerStyle {
        case .teamSwitcher:
            SCSidebarTeamSwitcher(
                teams: data.teams,
                activeTeamID: activeTeamBinding,
                onSelect: { onAction(.selectTeam($0.id)) },
                onAddTeam: { onAction(.addTeam) }
            )
        case .organization(let organization):
            organizationHeader(organization)
        }
    }

    private func organizationHeader(_ organization: SCSidebarTeam) -> some View {
        SCSidebarMenu {
            SCSidebarMenuItem {
                SCSidebarMenuButton(
                    size: .lg,
                    accessibilityLabel: Text("Open \(organization.name)"),
                    collapsedTooltip: organization.name,
                    action: { onAction(.openOrganization) },
                    content: { collapsed in
                        HStack(spacing: 8) {
                            RoundedRectangle(
                                cornerRadius: max(theme.radius - 2, 4),
                                style: .continuous
                            )
                            .fill(theme.sidebarPrimary)
                            .frame(width: 32, height: 32)
                            .overlay {
                                Image(systemName: organization.systemImage)
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundStyle(theme.sidebarPrimaryForeground)
                            }
                            if !collapsed {
                                VStack(alignment: .leading, spacing: 0) {
                                    Text(organization.name)
                                        .font(.subheadline.weight(.medium))
                                    Text(organization.plan)
                                        .font(.caption2)
                                }
                                .lineLimit(1)
                            }
                        }
                    }
                )
            }
        }
    }

    private var selectedID: String {
        externalSelection?.wrappedValue ?? internalSelection
    }

    private var expandedNavigationIDsValue: Set<String> {
        externalExpandedNavigationIDs?.wrappedValue ?? internalExpandedNavigationIDs
    }

    private var navigationGroup: some View {
        SCSidebarGroup {
            SCSidebarGroupLabel { Text("Platform") }
            SCSidebarGroupContent {
                SCSidebarMenu {
                    ForEach(data.navigation) { item in
                        navigationItem(item)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func navigationItem(_ item: SCSidebarNavigationItem) -> some View {
        switch navigationStyle {
        case .collapsibleRows:
            SCSidebarMenuItem {
                SCSidebarMenuButton(
                    isActive: itemContainsSelection(item),
                    accessibilityLabel: Text(item.title),
                    collapsedTooltip: item.title,
                    action: { activateCollapsibleNavigation(item) },
                    content: { collapsed in navigationLabel(item, collapsed: collapsed) },
                    trailing: { collapsed in
                        if !collapsed, !item.items.isEmpty {
                            disclosureChevron(item)
                        }
                    }
                )
                .accessibilityValue(
                    item.items.isEmpty
                        ? ""
                        : (expandedNavigationIDsValue.contains(item.id) ? "Expanded" : "Collapsed")
                )
            }
        case .selectableRowsWithSeparateDisclosure:
            SCSidebarMenuItem {
                SCSidebarMenuButton(
                    isActive: selectedID == item.id,
                    accessibilityLabel: Text(item.title),
                    collapsedTooltip: item.title,
                    action: { selectNavigation(item.id) },
                    content: { collapsed in navigationLabel(item, collapsed: collapsed) }
                )
                if !item.items.isEmpty {
                    SCSidebarMenuAction(
                        accessibilityLabel: Text("Toggle \(item.title)"),
                        action: { toggleNavigation(item.id) },
                        content: {
                            Image(systemName: "chevron.right")
                                .font(.caption2.weight(.semibold))
                                .rotationEffect(
                                    .degrees(expandedNavigationIDsValue.contains(item.id) ? 90 : 0)
                                )
                                .animation(
                                    .snappy(duration: 0.2),
                                    value: expandedNavigationIDsValue.contains(item.id)
                                )
                        }
                    )
                }
            }
        }

        if expandedNavigationIDsValue.contains(item.id), !item.items.isEmpty {
            SCSidebarMenuSub {
                ForEach(item.items) { child in
                    SCSidebarMenuSubItem {
                        SCSidebarMenuSubButton(
                            child.title,
                            isActive: selectedID == child.id,
                            action: { selectNavigation(child.id) }
                        )
                    }
                }
            }
        }
    }

    private func navigationLabel(
        _ item: SCSidebarNavigationItem,
        collapsed: Bool
    ) -> some View {
        HStack(spacing: 8) {
            if let systemImage = item.systemImage {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .medium))
                    .frame(width: 20, height: 20)
            }
            if !collapsed {
                Text(item.title)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(1)
            }
        }
    }

    private func disclosureChevron(_ item: SCSidebarNavigationItem) -> some View {
        Image(systemName: "chevron.right")
            .font(.caption2.weight(.semibold))
            .rotationEffect(.degrees(expandedNavigationIDsValue.contains(item.id) ? 90 : 0))
            .animation(.snappy(duration: 0.2), value: expandedNavigationIDsValue.contains(item.id))
    }

    private var projectsGroup: some View {
        SCSidebarGroup("Projects") {
            SCSidebarMenu {
                ForEach(data.projects) { project in
                    SCSidebarMenuItem {
                        SCSidebarMenuButton(
                            project.name,
                            systemImage: project.systemImage,
                            isActive: selectedID == project.id
                        ) {
                            setSelection(project.id)
                            onAction(.selectProject(project.id))
                        }
                        projectMenu(project)
                    }
                }
                SCSidebarMenuItem {
                    SCSidebarMenuButton("More", systemImage: "ellipsis") {
                        onAction(.showMoreProjects)
                    }
                }
            }
        }
    }

    private var secondaryNavigationGroup: some View {
        SCSidebarGroup {
            SCSidebarGroupContent {
                SCSidebarMenu {
                    ForEach(data.secondaryNavigation) { item in
                        SCSidebarMenuItem {
                            SCSidebarMenuButton(
                                item.title,
                                systemImage: item.systemImage,
                                isActive: selectedID == item.id,
                                size: .sm
                            ) {
                                setSelection(item.id)
                                onAction(.selectSecondaryNavigation(item.id))
                            }
                        }
                    }
                }
            }
        }
    }

    private func projectMenu(_ project: SCSidebarProject) -> some View {
        Menu {
            Button {
                onAction(.project(project.id, .view))
            } label: {
                Label("View Project", systemImage: "folder")
            }
            Button {
                onAction(.project(project.id, .share))
            } label: {
                Label("Share Project", systemImage: "arrowshape.turn.up.right")
            }
            Divider()
            Button(role: .destructive) {
                onAction(.project(project.id, .delete))
            } label: {
                Label("Delete Project", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.caption.weight(.semibold))
                .frame(width: 28, height: 28)
                .contentShape(Rectangle())
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .padding(.trailing, 4)
        .accessibilityLabel("Actions for \(project.name)")
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            SCSidebarTrigger()
            SCSeparator(.vertical).frame(height: 16)
            ViewThatFits(in: .horizontal) {
                fullBreadcrumb
                currentPageBreadcrumb
            }
            Spacer()
        }
        .padding(.horizontal, 12)
        .modifier(SCSidebarApplicationHeaderHeight())
    }

    private var fullBreadcrumb: some View {
        SCBreadcrumb {
            SCBreadcrumbList {
                SCBreadcrumbItem {
                    SCBreadcrumbLink(
                        action: { onAction(.openBreadcrumbRoot) },
                        label: { Text("Build Your Application") }
                    )
                }
                SCBreadcrumbSeparator()
                SCBreadcrumbItem { SCBreadcrumbPage(selectedTitle) }
            }
        }
    }

    private var currentPageBreadcrumb: some View {
        SCBreadcrumb {
            SCBreadcrumbList {
                SCBreadcrumbItem { SCBreadcrumbPage(selectedTitle) }
            }
        }
    }

    private var selectedTitle: String {
        Self.navigationTitle(for: selectedID, in: data) ?? selectedID
    }

    private func activateCollapsibleNavigation(_ item: SCSidebarNavigationItem) {
        if item.items.isEmpty {
            selectNavigation(item.id)
        } else {
            toggleNavigation(item.id)
        }
    }

    private func toggleNavigation(_ id: String) {
        var updated = expandedNavigationIDsValue
        let willExpand = !updated.contains(id)
        if willExpand {
            updated.insert(id)
        } else {
            updated.remove(id)
        }
        if let externalExpandedNavigationIDs {
            externalExpandedNavigationIDs.wrappedValue = updated
        } else {
            internalExpandedNavigationIDs = updated
        }
        onAction(.setNavigationExpanded(id, willExpand))
    }

    private func selectNavigation(_ id: String) {
        setSelection(id)
        onAction(.selectNavigation(id))
    }

    private func setSelection(_ id: String) {
        if let externalSelection {
            externalSelection.wrappedValue = id
        } else {
            internalSelection = id
        }
    }

    private func itemContainsSelection(_ item: SCSidebarNavigationItem) -> Bool {
        selectedID == item.id || item.items.contains { $0.id == selectedID }
    }

    private static func initialSelection(in data: SCSidebarBlockData) -> String {
        for item in data.navigation where item.initiallyExpanded {
            return item.items.first?.id ?? item.id
        }
        return data.navigation.first?.id ?? data.projects.first?.id ?? ""
    }

    private static func navigationTitle(for id: String, in data: SCSidebarBlockData) -> String? {
        for item in data.navigation {
            if item.id == id { return item.title }
            if let child = item.items.first(where: { $0.id == id }) { return child.title }
        }
        if let project = data.projects.first(where: { $0.id == id }) { return project.name }
        return data.secondaryNavigation.first(where: { $0.id == id })?.title
    }
}

private struct SCSidebarApplicationHeaderHeight: ViewModifier {
    @Environment(\.scSidebar) private var sidebar

    func body(content: Content) -> some View {
        content
            .frame(height: sidebar.isIconCollapsed ? 48 : 64)
            .animation(.easeInOut(duration: 0.2), value: sidebar.isIconCollapsed)
    }
}

// MARK: - Previews

#Preview("SidebarBlock · sidebar-07") {
    SCPreview {
        SidebarBlockPreviewHarness()
            .frame(width: 1000, height: 700)
    }
}

#Preview("SidebarBlock · controlled") {
    @Previewable @State var team = "acme-inc"
    @Previewable @State var selection = "playground-history"
    @Previewable @State var lastAction = "Use any sidebar control."

    SCPreview {
        SCSidebarBlock(
            activeTeamID: $team,
            selection: $selection,
            onAction: { lastAction = String(describing: $0) },
            detail: { selected in
                VStack(spacing: 8) {
                    Text("Selected: \(selected)")
                    Text(lastAction).scMuted()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        )
        .frame(width: 1000, height: 700)
    }
}

private struct SidebarBlockPreviewHarness: View {
    @State private var lastAction = "Use any sidebar control."

    var body: some View {
        SCSidebarBlock(
            onAction: { lastAction = String(describing: $0) },
            detail: { selection in
                VStack(spacing: 8) {
                    Text(selection).scH3()
                    Text(lastAction).scMuted()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        )
    }
}
