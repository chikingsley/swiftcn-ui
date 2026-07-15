// ============================================================
// Sidebar10Block.swift — swiftcn-ui
// Depends on: SidebarBlock (team model), Popover, Sidebar primitives
// ============================================================
import SwiftUI

public struct SCSidebar10NavigationItem: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let systemImage: String
    public let badge: String?

    public init(
        id: String,
        title: String,
        systemImage: String,
        badge: String? = nil
    ) {
        self.id = id
        self.title = title
        self.systemImage = systemImage
        self.badge = badge
    }
}

public struct SCSidebar10Favorite: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let emoji: String

    public init(id: String, name: String, emoji: String) {
        self.id = id
        self.name = name
        self.emoji = emoji
    }
}

public struct SCSidebar10Workspace: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let emoji: String
    public let pages: [SCSidebar10Favorite]

    public init(
        id: String,
        name: String,
        emoji: String,
        pages: [SCSidebar10Favorite]
    ) {
        self.id = id
        self.name = name
        self.emoji = emoji
        self.pages = pages
    }
}

public struct SCSidebar10Data: Sendable {
    public var teams: [SCSidebarTeam]
    public var mainNavigation: [SCSidebar10NavigationItem]
    public var favorites: [SCSidebar10Favorite]
    public var workspaces: [SCSidebar10Workspace]
    public var secondaryNavigation: [SCSidebar10NavigationItem]
    public var pageTitle: String
    public var lastEditedLabel: String
    public var defaultSelectionID: String

    public init(
        teams: [SCSidebarTeam],
        mainNavigation: [SCSidebar10NavigationItem],
        favorites: [SCSidebar10Favorite],
        workspaces: [SCSidebar10Workspace],
        secondaryNavigation: [SCSidebar10NavigationItem],
        pageTitle: String,
        lastEditedLabel: String,
        defaultSelectionID: String
    ) {
        self.teams = teams
        self.mainNavigation = mainNavigation
        self.favorites = favorites
        self.workspaces = workspaces
        self.secondaryNavigation = secondaryNavigation
        self.pageTitle = pageTitle
        self.lastEditedLabel = lastEditedLabel
        self.defaultSelectionID = defaultSelectionID
    }

    public static let sidebar10 = SCSidebar10Data(
        teams: SCSidebarBlockData.sidebar07.teams,
        mainNavigation: [
            SCSidebar10NavigationItem(id: "search", title: "Search", systemImage: "magnifyingglass"),
            SCSidebar10NavigationItem(id: "ask-ai", title: "Ask AI", systemImage: "sparkles"),
            SCSidebar10NavigationItem(id: "home", title: "Home", systemImage: "house"),
            SCSidebar10NavigationItem(id: "inbox", title: "Inbox", systemImage: "tray", badge: "10"),
        ],
        favorites: [
            SCSidebar10Favorite(id: "project-management", name: "Project Management & Task Tracking", emoji: "📊"),
            SCSidebar10Favorite(id: "family-recipes", name: "Family Recipe Collection & Meal Planning", emoji: "🍳"),
            SCSidebar10Favorite(id: "fitness-tracker", name: "Fitness Tracker & Workout Routines", emoji: "💪"),
            SCSidebar10Favorite(id: "book-notes", name: "Book Notes & Reading List", emoji: "📚"),
            SCSidebar10Favorite(id: "gardening", name: "Sustainable Gardening Tips & Plant Care", emoji: "🌱"),
            SCSidebar10Favorite(id: "language-learning", name: "Language Learning Progress & Resources", emoji: "🗣️"),
            SCSidebar10Favorite(id: "home-renovation", name: "Home Renovation Ideas & Budget Tracker", emoji: "🏠"),
            SCSidebar10Favorite(id: "personal-finance", name: "Personal Finance & Investment Portfolio", emoji: "💰"),
            SCSidebar10Favorite(id: "watchlist", name: "Movie & TV Show Watchlist with Reviews", emoji: "🎬"),
            SCSidebar10Favorite(id: "daily-habits", name: "Daily Habit Tracker & Goal Setting", emoji: "✅"),
        ],
        workspaces: [
            SCSidebar10Workspace(
                id: "personal-life",
                name: "Personal Life Management",
                emoji: "🏠",
                pages: [
                    SCSidebar10Favorite(id: "daily-journal", name: "Daily Journal & Reflection", emoji: "📔"),
                    SCSidebar10Favorite(id: "health-wellness", name: "Health & Wellness Tracker", emoji: "🍏"),
                    SCSidebar10Favorite(id: "personal-growth", name: "Personal Growth & Learning Goals", emoji: "🌟"),
                ]
            ),
            SCSidebar10Workspace(
                id: "professional-development",
                name: "Professional Development",
                emoji: "💼",
                pages: [
                    SCSidebar10Favorite(id: "career-objectives", name: "Career Objectives & Milestones", emoji: "🎯"),
                    SCSidebar10Favorite(id: "skill-acquisition", name: "Skill Acquisition & Training Log", emoji: "🧠"),
                    SCSidebar10Favorite(id: "networking", name: "Networking Contacts & Events", emoji: "🤝"),
                ]
            ),
            SCSidebar10Workspace(
                id: "creative-projects",
                name: "Creative Projects",
                emoji: "🎨",
                pages: [
                    SCSidebar10Favorite(id: "writing-ideas", name: "Writing Ideas & Story Outlines", emoji: "✍️"),
                    SCSidebar10Favorite(id: "art-portfolio", name: "Art & Design Portfolio", emoji: "🖼️"),
                    SCSidebar10Favorite(id: "music-practice", name: "Music Composition & Practice Log", emoji: "🎵"),
                ]
            ),
            SCSidebar10Workspace(
                id: "home-management",
                name: "Home Management",
                emoji: "🏡",
                pages: [
                    SCSidebar10Favorite(
                        id: "household-budget", name: "Household Budget & Expense Tracking", emoji: "💰"),
                    SCSidebar10Favorite(id: "home-maintenance", name: "Home Maintenance Schedule & Tasks", emoji: "🔧"),
                    SCSidebar10Favorite(id: "family-calendar", name: "Family Calendar & Event Planning", emoji: "📅"),
                ]
            ),
            SCSidebar10Workspace(
                id: "travel-adventure",
                name: "Travel & Adventure",
                emoji: "🧳",
                pages: [
                    SCSidebar10Favorite(id: "trip-planning", name: "Trip Planning & Itineraries", emoji: "🗺️"),
                    SCSidebar10Favorite(id: "travel-bucket-list", name: "Travel Bucket List & Inspiration", emoji: "🌎"),
                    SCSidebar10Favorite(id: "travel-journal", name: "Travel Journal & Photo Gallery", emoji: "📸"),
                ]
            ),
        ],
        secondaryNavigation: [
            SCSidebar10NavigationItem(id: "calendar", title: "Calendar", systemImage: "calendar"),
            SCSidebar10NavigationItem(id: "settings", title: "Settings", systemImage: "gearshape"),
            SCSidebar10NavigationItem(id: "templates", title: "Templates", systemImage: "square.grid.2x2"),
            SCSidebar10NavigationItem(id: "trash", title: "Trash", systemImage: "trash"),
            SCSidebar10NavigationItem(id: "help", title: "Help", systemImage: "questionmark.bubble"),
        ],
        pageTitle: "Project Management & Task Tracking",
        lastEditedLabel: "Edit Oct 08",
        defaultSelectionID: "home"
    )
}

public enum SCSidebar10FavoriteAction: Hashable, Sendable {
    case removeFromFavorites
    case copyLink
    case openInNewWindow
    case delete
}

public enum SCSidebar10PageAction: CaseIterable, Hashable, Sendable {
    case customizePage
    case turnIntoWiki
    case copyLink
    case duplicate
    case moveTo
    case moveToTrash
    case undo
    case viewAnalytics
    case versionHistory
    case showDeletedPages
    case notifications
    case `import`
    case export

    fileprivate var label: String {
        switch self {
        case .customizePage: "Customize Page"
        case .turnIntoWiki: "Turn into wiki"
        case .copyLink: "Copy Link"
        case .duplicate: "Duplicate"
        case .moveTo: "Move to"
        case .moveToTrash: "Move to Trash"
        case .undo: "Undo"
        case .viewAnalytics: "View analytics"
        case .versionHistory: "Version History"
        case .showDeletedPages: "Show deleted pages"
        case .notifications: "Notifications"
        case .import: "Import"
        case .export: "Export"
        }
    }

    fileprivate var systemImage: String {
        switch self {
        case .customizePage: "gearshape"
        case .turnIntoWiki: "doc.text"
        case .copyLink: "link"
        case .duplicate: "doc.on.doc"
        case .moveTo: "arrowshape.turn.up.right"
        case .moveToTrash: "trash"
        case .undo: "arrow.uturn.backward"
        case .viewAnalytics: "chart.xyaxis.line"
        case .versionHistory: "square.stack.3d.up"
        case .showDeletedPages: "trash.slash"
        case .notifications: "bell"
        case .import: "arrow.up"
        case .export: "arrow.down"
        }
    }

    fileprivate static let groups: [[SCSidebar10PageAction]] = [
        [.customizePage, .turnIntoWiki],
        [.copyLink, .duplicate, .moveTo, .moveToTrash],
        [.undo, .viewAnalytics, .versionHistory, .showDeletedPages, .notifications],
        [.import, .export],
    ]
}

public enum SCSidebar10Action: Hashable, Sendable {
    case selectTeam(String)
    case addTeam
    case selectMainNavigation(String)
    case selectFavorite(String)
    case favorite(String, SCSidebar10FavoriteAction)
    case showMoreFavorites
    case selectWorkspace(String)
    case setWorkspaceExpanded(String, Bool)
    case addPage(String)
    case selectPage(String)
    case showMoreWorkspaces
    case selectSecondaryNavigation(String)
    case setPageStarred(Bool)
    case setActionsPresented(Bool)
    case pageAction(SCSidebar10PageAction)
}

/// A functional Notion-style sidebar and page-actions popover. Navigation,
/// expansion, menus, star state, and presentation may be caller-controlled.
public struct SCSidebar10Block<Detail: View>: View {
    @State private var internalTeamID: String
    @State private var internalSelection: String
    @State private var internalExpandedWorkspaceIDs: Set<String>
    @State private var internalPageStarred = false
    @State private var internalActionsPresented = false

    private let data: SCSidebar10Data
    private let externalTeamID: Binding<String>?
    private let externalSelection: Binding<String>?
    private let externalExpandedWorkspaceIDs: Binding<Set<String>>?
    private let externalPageStarred: Binding<Bool>?
    private let externalActionsPresented: Binding<Bool>?
    private let persistenceKey: String?
    private let customHeader: ((String) -> AnyView)?
    private let onAction: (SCSidebar10Action) -> Void
    private let detail: (String) -> Detail

    public init(
        data: SCSidebar10Data = .sidebar10,
        activeTeamID: Binding<String>? = nil,
        selection: Binding<String>? = nil,
        expandedWorkspaceIDs: Binding<Set<String>>? = nil,
        pageStarred: Binding<Bool>? = nil,
        actionsPresented: Binding<Bool>? = nil,
        persistenceKey: String? = "sc.sidebar10.open",
        onAction: @escaping (SCSidebar10Action) -> Void,
        @ViewBuilder detail: @escaping (_ selection: String) -> Detail
    ) {
        self.data = data
        self.externalTeamID = activeTeamID
        self.externalSelection = selection
        self.externalExpandedWorkspaceIDs = expandedWorkspaceIDs
        self.externalPageStarred = pageStarred
        self.externalActionsPresented = actionsPresented
        self.persistenceKey = persistenceKey
        self.customHeader = nil
        self.onAction = onAction
        self.detail = detail

        _internalTeamID = State(initialValue: activeTeamID?.wrappedValue ?? data.teams.first?.id ?? "")
        _internalSelection = State(initialValue: selection?.wrappedValue ?? data.defaultSelectionID)
        _internalExpandedWorkspaceIDs = State(
            initialValue: expandedWorkspaceIDs?.wrappedValue ?? []
        )
        _internalPageStarred = State(initialValue: pageStarred?.wrappedValue ?? false)
        _internalActionsPresented = State(initialValue: actionsPresented?.wrappedValue ?? false)
    }

    public init<Header: View>(
        data: SCSidebar10Data = .sidebar10,
        activeTeamID: Binding<String>? = nil,
        selection: Binding<String>? = nil,
        expandedWorkspaceIDs: Binding<Set<String>>? = nil,
        persistenceKey: String? = "sc.sidebar10.open",
        onAction: @escaping (SCSidebar10Action) -> Void,
        @ViewBuilder header: @escaping (_ selection: String) -> Header,
        @ViewBuilder detail: @escaping (_ selection: String) -> Detail
    ) {
        self.data = data
        self.externalTeamID = activeTeamID
        self.externalSelection = selection
        self.externalExpandedWorkspaceIDs = expandedWorkspaceIDs
        self.externalPageStarred = nil
        self.externalActionsPresented = nil
        self.persistenceKey = persistenceKey
        self.customHeader = { AnyView(header($0)) }
        self.onAction = onAction
        self.detail = detail

        _internalTeamID = State(initialValue: activeTeamID?.wrappedValue ?? data.teams.first?.id ?? "")
        _internalSelection = State(initialValue: selection?.wrappedValue ?? data.defaultSelectionID)
        _internalExpandedWorkspaceIDs = State(
            initialValue: expandedWorkspaceIDs?.wrappedValue ?? []
        )
    }

    public init(
        data: SCSidebar10Data = .sidebar10,
        activeTeamID: Binding<String>? = nil,
        selection: Binding<String>? = nil,
        expandedWorkspaceIDs: Binding<Set<String>>? = nil,
        pageStarred: Binding<Bool>? = nil,
        actionsPresented: Binding<Bool>? = nil,
        persistenceKey: String? = "sc.sidebar10.open",
        onAction: @escaping (SCSidebar10Action) -> Void,
        @ViewBuilder detail: @escaping () -> Detail
    ) {
        self.init(
            data: data,
            activeTeamID: activeTeamID,
            selection: selection,
            expandedWorkspaceIDs: expandedWorkspaceIDs,
            pageStarred: pageStarred,
            actionsPresented: actionsPresented,
            persistenceKey: persistenceKey,
            onAction: onAction,
            detail: { _ in detail() }
        )
    }

    public var body: some View {
        SCSidebarLayout(
            collapsible: .offcanvas,
            persistenceKey: persistenceKey,
            showsDivider: false
        ) {
            SCSidebarHeader {
                teamSwitcher
                mainNavigation
            }
            SCSidebarContent {
                favoritesGroup
                workspacesGroup
                Spacer(minLength: 0)
                secondaryNavigationGroup
            }
        } detail: {
            VStack(spacing: 0) {
                detailHeader
                detail(selectedID)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .onChange(of: actionsPresentedValue) { _, value in
            onAction(.setActionsPresented(value))
        }
    }

    private var teamBinding: Binding<String> {
        externalTeamID ?? $internalTeamID
    }

    private var selectedID: String {
        externalSelection?.wrappedValue ?? internalSelection
    }

    private var expandedWorkspaceIDsValue: Set<String> {
        externalExpandedWorkspaceIDs?.wrappedValue ?? internalExpandedWorkspaceIDs
    }

    @ViewBuilder
    private var detailHeader: some View {
        if let customHeader {
            customHeader(selectedID)
        } else {
            topBar
        }
    }

    private var pageStarredBinding: Binding<Bool> {
        externalPageStarred ?? $internalPageStarred
    }

    private var actionsPresentedBinding: Binding<Bool> {
        externalActionsPresented ?? $internalActionsPresented
    }

    private var actionsPresentedValue: Bool {
        externalActionsPresented?.wrappedValue ?? internalActionsPresented
    }

    private var activeTeam: SCSidebarTeam? {
        data.teams.first { $0.id == teamBinding.wrappedValue } ?? data.teams.first
    }

    private var teamSwitcher: some View {
        Menu {
            Section("Teams") {
                ForEach(Array(data.teams.enumerated()), id: \.element.id) { index, team in
                    teamButton(team, index: index)
                }
            }
            Divider()
            Button {
                onAction(.addTeam)
            } label: {
                Label("Add team", systemImage: "plus")
            }
        } label: {
            HStack(spacing: 8) {
                if let activeTeam {
                    Image(systemName: activeTeam.systemImage)
                        .font(.caption.weight(.semibold))
                        .frame(width: 20, height: 20)
                        .background(.tint)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
                    Text(activeTeam.name)
                        .font(.subheadline.weight(.medium))
                        .lineLimit(1)
                    Image(systemName: "chevron.down")
                        .font(.caption2)
                        .opacity(0.5)
                }
            }
            .padding(.horizontal, 6)
            .frame(height: 36)
            .contentShape(Rectangle())
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .accessibilityLabel("Switch team")
        .accessibilityValue(activeTeam?.name ?? "No team")
    }

    @ViewBuilder
    private func teamButton(_ team: SCSidebarTeam, index: Int) -> some View {
        let button = Button {
            teamBinding.wrappedValue = team.id
            onAction(.selectTeam(team.id))
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

    private var mainNavigation: some View {
        SCSidebarMenu {
            ForEach(data.mainNavigation) { item in
                SCSidebarMenuItem {
                    SCSidebarMenuButton(
                        item.title,
                        systemImage: item.systemImage,
                        isActive: selectedID == item.id,
                        badge: item.badge
                    ) {
                        setSelection(item.id)
                        onAction(.selectMainNavigation(item.id))
                    }
                }
            }
        }
    }

    private var favoritesGroup: some View {
        SCSidebarGroup("Favorites") {
            SCSidebarMenu {
                ForEach(data.favorites) { favorite in
                    SCSidebarMenuItem {
                        emojiButton(
                            favorite,
                            action: {
                                setSelection(favorite.id)
                                onAction(.selectFavorite(favorite.id))
                            })
                        favoriteMenu(favorite)
                    }
                }
                SCSidebarMenuItem {
                    SCSidebarMenuButton("More", systemImage: "ellipsis") {
                        onAction(.showMoreFavorites)
                    }
                }
            }
        }
    }

    private func favoriteMenu(_ favorite: SCSidebar10Favorite) -> some View {
        Menu {
            Button {
                onAction(.favorite(favorite.id, .removeFromFavorites))
            } label: {
                Label("Remove from Favorites", systemImage: "star.slash")
            }
            Divider()
            Button {
                onAction(.favorite(favorite.id, .copyLink))
            } label: {
                Label("Copy Link", systemImage: "link")
            }
            Button {
                onAction(.favorite(favorite.id, .openInNewWindow))
            } label: {
                Label("Open in New Window", systemImage: "arrow.up.right.square")
            }
            Divider()
            Button(role: .destructive) {
                onAction(.favorite(favorite.id, .delete))
            } label: {
                Label("Delete", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis")
                .frame(width: 28, height: 28)
                .contentShape(Rectangle())
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .padding(.trailing, 4)
        .accessibilityLabel("Actions for \(favorite.name)")
    }

    private var workspacesGroup: some View {
        SCSidebarGroup("Workspaces") {
            SCSidebarGroupContent {
                SCSidebarMenu {
                    ForEach(data.workspaces) { workspace in
                        workspaceRow(workspace)
                    }
                    SCSidebarMenuItem {
                        SCSidebarMenuButton("More", systemImage: "ellipsis") {
                            onAction(.showMoreWorkspaces)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func workspaceRow(_ workspace: SCSidebar10Workspace) -> some View {
        SCSidebarMenuItem {
            SCSidebarMenuButton(
                isActive: selectedID == workspace.id,
                accessibilityLabel: Text(workspace.name),
                action: {
                    setSelection(workspace.id)
                    onAction(.selectWorkspace(workspace.id))
                },
                content: { collapsed in
                    if !collapsed {
                        HStack(spacing: 8) {
                            Text(workspace.emoji)
                            Text(workspace.name).lineLimit(1)
                        }
                        .padding(.trailing, 64)
                    }
                }
            )
            HStack(spacing: 0) {
                Button {
                    toggleWorkspace(workspace.id)
                } label: {
                    Image(systemName: "chevron.right")
                        .rotationEffect(
                            .degrees(expandedWorkspaceIDsValue.contains(workspace.id) ? 90 : 0)
                        )
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Toggle \(workspace.name)")
                .accessibilityValue(
                    expandedWorkspaceIDsValue.contains(workspace.id) ? "Expanded" : "Collapsed"
                )
                Button {
                    onAction(.addPage(workspace.id))
                } label: {
                    Image(systemName: "plus").frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Add page to \(workspace.name)")
            }
            .padding(.trailing, 4)
        }
        if expandedWorkspaceIDsValue.contains(workspace.id) {
            SCSidebarMenuSub {
                ForEach(workspace.pages) { page in
                    SCSidebarMenuSubItem {
                        SCSidebarMenuSubButton(
                            isActive: selectedID == page.id,
                            accessibilityLabel: Text(page.name),
                            action: {
                                setSelection(page.id)
                                onAction(.selectPage(page.id))
                            },
                            content: {
                                HStack(spacing: 8) {
                                    Text(page.emoji)
                                    Text(page.name).lineLimit(1)
                                }
                            }
                        )
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
                                isActive: selectedID == item.id
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

    private var topBar: some View {
        HStack(spacing: 12) {
            SCSidebarTrigger()
            SCSeparator(.vertical, isDecorative: true).frame(height: 16)
            SCBreadcrumb {
                SCBreadcrumbList {
                    SCBreadcrumbItem { SCBreadcrumbPage(data.pageTitle) }
                }
            }
            Spacer(minLength: 0)
            ViewThatFits(in: .horizontal) {
                Text(data.lastEditedLabel)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.secondary)
                    .fixedSize()
                EmptyView()
            }
            Button {
                pageStarredBinding.wrappedValue.toggle()
                onAction(.setPageStarred(pageStarredBinding.wrappedValue))
            } label: {
                Image(systemName: pageStarredBinding.wrappedValue ? "star.fill" : "star")
                    .frame(width: 28, height: 28)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(pageStarredBinding.wrappedValue ? "Unstar page" : "Star page")
            pageActionsPopover
        }
        .padding(.horizontal, 12)
        .frame(height: 56)
    }

    private var pageActionsPopover: some View {
        SCPopover(
            isPresented: actionsPresentedBinding,
            position: SCPopoverPosition(side: .bottom, alignment: .end)
        ) {
            SCPopoverTrigger {
                Image(systemName: "ellipsis")
                    .frame(width: 28, height: 28)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel("Page actions")
        } content: {
            SCPopoverContent(padding: 0, width: 224) {
                VStack(spacing: 0) {
                    ForEach(indexedPageActionGroups, id: \.offset) { entry in
                        let index = entry.offset
                        let group = entry.element
                        VStack(spacing: 2) {
                            ForEach(group, id: \.self) { action in
                                Button {
                                    performPageAction(action)
                                } label: {
                                    Label(action.label, systemImage: action.systemImage)
                                        .font(.subheadline)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding(.horizontal, 10)
                                        .frame(height: 34)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(6)
                        if index < SCSidebar10PageAction.groups.count - 1 {
                            Divider()
                        }
                    }
                }
            }
        }
    }

    private var indexedPageActionGroups: [(offset: Int, element: [SCSidebar10PageAction])] {
        Array(SCSidebar10PageAction.groups.enumerated())
    }

    private func emojiButton(
        _ favorite: SCSidebar10Favorite,
        action: @escaping () -> Void
    ) -> some View {
        SCSidebarMenuButton(
            isActive: selectedID == favorite.id,
            accessibilityLabel: Text(favorite.name),
            action: action,
            content: { collapsed in
                if !collapsed {
                    HStack(spacing: 8) {
                        Text(favorite.emoji)
                        Text(favorite.name).lineLimit(1)
                    }
                }
            }
        )
    }

    private func toggleWorkspace(_ id: String) {
        var updated = expandedWorkspaceIDsValue
        let willExpand = !updated.contains(id)
        if willExpand {
            updated.insert(id)
        } else {
            updated.remove(id)
        }
        if let externalExpandedWorkspaceIDs {
            externalExpandedWorkspaceIDs.wrappedValue = updated
        } else {
            internalExpandedWorkspaceIDs = updated
        }
        onAction(.setWorkspaceExpanded(id, willExpand))
    }

    private func performPageAction(_ action: SCSidebar10PageAction) {
        onAction(.pageAction(action))
        actionsPresentedBinding.wrappedValue = false
    }

    private func setSelection(_ id: String) {
        if let externalSelection {
            externalSelection.wrappedValue = id
        } else {
            internalSelection = id
        }
    }
}

// MARK: - Previews

#Preview("Sidebar block · sidebar-10") {
    @Previewable @State var lastAction = "Use any sidebar or page action."

    SCPreview {
        SCSidebar10Block(
            onAction: { lastAction = String(describing: $0) },
            detail: { selection in
                VStack(alignment: .leading, spacing: 12) {
                    Text(selection).scH2()
                    Text(lastAction).scMuted()
                    Spacer()
                }
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        )
        .frame(width: 1100, height: 720)
    }
}
