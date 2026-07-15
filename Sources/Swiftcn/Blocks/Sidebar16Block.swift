// ============================================================
// Sidebar16Block.swift — swiftcn-ui
// Depends on: SidebarBlock, Breadcrumb, Separator, Input
// ============================================================
import SwiftUI

public struct SCSidebar16Data: Sendable {
    public var sidebar: SCSidebarBlockData
    public var organization: SCSidebarTeam
    public var breadcrumbRootTitle: String
    public var defaultSelectionID: String

    public init(
        sidebar: SCSidebarBlockData,
        organization: SCSidebarTeam,
        breadcrumbRootTitle: String,
        defaultSelectionID: String
    ) {
        self.sidebar = sidebar
        self.organization = organization
        self.breadcrumbRootTitle = breadcrumbRootTitle
        self.defaultSelectionID = defaultSelectionID
    }

    public static let sidebar16 = SCSidebar16Data(
        sidebar: .sidebar08,
        organization: .sidebar08Organization,
        breadcrumbRootTitle: "Build Your Application",
        defaultSelectionID: "playground"
    )
}

public enum SCSidebar16Action: Hashable, Sendable {
    case sidebar(SCSidebarBlockAction)
    case search(String)
    case submitSearch(String)
}

/// An application sidebar beneath a persistent site header. The header and
/// sidebar share one state object, so its trigger, keyboard shortcut, compact
/// sheet, navigation, search, project menus, and account menu are all real.
public struct SCSidebar16Block<Detail: View>: View {
    @Environment(\.theme) private var theme

    @State private var internalSelection: String
    @State private var internalSearch: String
    @State private var sidebarState: SCSidebarState

    private let data: SCSidebar16Data
    private let externalSelection: Binding<String>?
    private let expandedNavigationIDs: Binding<Set<String>>?
    private let externalSearch: Binding<String>?
    private let persistenceKey: String?
    private let onAction: (SCSidebar16Action) -> Void
    private let detail: (String) -> Detail

    public init(
        data: SCSidebar16Data = .sidebar16,
        selection: Binding<String>? = nil,
        expandedNavigationIDs: Binding<Set<String>>? = nil,
        search: Binding<String>? = nil,
        persistenceKey: String? = "sc.sidebar16.open",
        onAction: @escaping (SCSidebar16Action) -> Void,
        @ViewBuilder detail: @escaping (_ selection: String) -> Detail
    ) {
        self.data = data
        self.externalSelection = selection
        self.expandedNavigationIDs = expandedNavigationIDs
        self.externalSearch = search
        self.persistenceKey = persistenceKey
        self.onAction = onAction
        self.detail = detail

        let initialOpen =
            persistenceKey.flatMap {
                UserDefaults.standard.object(forKey: $0) as? Bool
            } ?? true
        _internalSelection = State(
            initialValue: selection?.wrappedValue ?? data.defaultSelectionID
        )
        _internalSearch = State(initialValue: search?.wrappedValue ?? "")
        _sidebarState = State(
            initialValue: SCSidebarState(
                isOpen: initialOpen,
                collapsible: .offcanvas
            )
        )
    }

    public init(
        data: SCSidebar16Data = .sidebar16,
        selection: Binding<String>? = nil,
        expandedNavigationIDs: Binding<Set<String>>? = nil,
        search: Binding<String>? = nil,
        persistenceKey: String? = "sc.sidebar16.open",
        onAction: @escaping (SCSidebar16Action) -> Void,
        @ViewBuilder detail: @escaping () -> Detail
    ) {
        self.init(
            data: data,
            selection: selection,
            expandedNavigationIDs: expandedNavigationIDs,
            search: search,
            persistenceKey: persistenceKey,
            onAction: onAction,
            detail: { _ in detail() }
        )
    }

    public var body: some View {
        VStack(spacing: 0) {
            siteHeader
            SCSidebarBlock(
                data: data.sidebar,
                activeTeamID: nil,
                selection: selectionBinding,
                expandedNavigationIDs: expandedNavigationIDs,
                collapsible: .offcanvas,
                persistenceKey: persistenceKey,
                variant: .sidebar,
                sidebarState: sidebarState,
                showsDetailHeader: false,
                headerStyle: .organization(data.organization),
                navigationStyle: .selectableRowsWithSeparateDisclosure,
                showsSecondaryNavigation: true,
                onAction: { onAction(.sidebar($0)) },
                detail: { selection in
                    detail(selection)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.background)
        .environment(\.scSidebar, sidebarState)
    }

    private var selectedID: String {
        externalSelection?.wrappedValue ?? internalSelection
    }

    private var selectionBinding: Binding<String> {
        Binding(
            get: { selectedID },
            set: { value in
                if let externalSelection {
                    externalSelection.wrappedValue = value
                } else {
                    internalSelection = value
                }
            }
        )
    }

    private var searchValue: String {
        externalSearch?.wrappedValue ?? internalSearch
    }

    private var searchBinding: Binding<String> {
        Binding(
            get: { searchValue },
            set: { value in
                if let externalSearch {
                    externalSearch.wrappedValue = value
                } else {
                    internalSearch = value
                }
                onAction(.search(value))
            }
        )
    }

    private var siteHeader: some View {
        HStack(spacing: 12) {
            SCSidebarTrigger()
            SCSeparator(.vertical, isDecorative: true)
                .frame(height: 16)
            ViewThatFits(in: .horizontal) {
                fullBreadcrumb
                EmptyView()
            }
            Spacer(minLength: 0)
            SCSidebarInput(
                "Type to search...",
                text: searchBinding,
                icon: "magnifyingglass",
                onSubmit: { onAction(.submitSearch(searchValue)) }
            )
            .frame(maxWidth: 240)
        }
        .padding(.horizontal, 16)
        .frame(height: 56)
        .background(theme.background)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(theme.border)
                .frame(height: 1)
                .accessibilityHidden(true)
        }
    }

    private var fullBreadcrumb: some View {
        SCBreadcrumb {
            SCBreadcrumbList {
                SCBreadcrumbItem {
                    SCBreadcrumbLink(
                        action: { onAction(.sidebar(.openBreadcrumbRoot)) },
                        label: { Text(data.breadcrumbRootTitle) }
                    )
                }
                SCBreadcrumbSeparator()
                SCBreadcrumbItem {
                    SCBreadcrumbPage(selectedTitle)
                }
            }
        }
    }

    private var selectedTitle: String {
        for item in data.sidebar.navigation {
            if item.id == selectedID { return item.title }
            if let child = item.items.first(where: { $0.id == selectedID }) {
                return child.title
            }
        }
        if let project = data.sidebar.projects.first(where: { $0.id == selectedID }) {
            return project.name
        }
        return data.sidebar.secondaryNavigation.first(where: { $0.id == selectedID })?.title
            ?? selectedID
    }
}

// MARK: - Previews

#Preview("Sidebar block · sidebar-16") {
    @Previewable @State var lastAction = "Use the header or sidebar."

    SCPreview {
        SCSidebar16Block(
            persistenceKey: nil,
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
        .frame(width: 1100, height: 760)
    }
}
