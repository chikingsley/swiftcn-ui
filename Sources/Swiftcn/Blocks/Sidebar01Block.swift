// ============================================================
// Sidebar01Block.swift — swiftcn-ui
// Depends on: Theme/, Components/Sidebar, Breadcrumb
//
// Functional SwiftUI port of shadcn/ui's sidebar-01: version switching,
// searchable grouped documentation navigation, selection, breadcrumb routing,
// and a caller-owned detail surface.
// ============================================================
import SwiftUI

// MARK: - Models

/// A documentation navigation destination used by the functional sidebar-01 block.
public struct SCSidebar01NavigationItem: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String

    public init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}

public struct SCSidebar01Section: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let items: [SCSidebar01NavigationItem]

    public init(
        id: String,
        title: String,
        items: [SCSidebar01NavigationItem]
    ) {
        self.id = id
        self.title = title
        self.items = items
    }
}

public struct SCSidebar01Data: Sendable {
    public var productName: String
    public var versions: [String]
    public var defaultVersion: String
    public var sections: [SCSidebar01Section]
    public var defaultSelectionID: String

    public init(
        productName: String,
        versions: [String],
        defaultVersion: String,
        sections: [SCSidebar01Section],
        defaultSelectionID: String
    ) {
        self.productName = productName
        self.versions = versions
        self.defaultVersion = defaultVersion
        self.sections = sections
        self.defaultSelectionID = defaultSelectionID
    }

    public static let sidebar01 = SCSidebar01Data(
        productName: "Documentation",
        versions: ["1.0.1", "1.1.0-alpha", "2.0.0-beta1"],
        defaultVersion: "1.0.1",
        sections: [
            SCSidebar01Section(
                id: "getting-started",
                title: "Getting Started",
                items: [
                    SCSidebar01NavigationItem(id: "installation", title: "Installation"),
                    SCSidebar01NavigationItem(id: "project-structure", title: "Project Structure"),
                ]
            ),
            SCSidebar01Section(
                id: "build-your-application",
                title: "Build Your Application",
                items: [
                    SCSidebar01NavigationItem(id: "routing", title: "Routing"),
                    SCSidebar01NavigationItem(id: "data-fetching", title: "Data Fetching"),
                    SCSidebar01NavigationItem(id: "rendering", title: "Rendering"),
                    SCSidebar01NavigationItem(id: "caching", title: "Caching"),
                    SCSidebar01NavigationItem(id: "styling", title: "Styling"),
                    SCSidebar01NavigationItem(id: "optimizing", title: "Optimizing"),
                    SCSidebar01NavigationItem(id: "configuring", title: "Configuring"),
                    SCSidebar01NavigationItem(id: "testing", title: "Testing"),
                    SCSidebar01NavigationItem(id: "authentication", title: "Authentication"),
                    SCSidebar01NavigationItem(id: "deploying", title: "Deploying"),
                    SCSidebar01NavigationItem(id: "upgrading", title: "Upgrading"),
                    SCSidebar01NavigationItem(id: "examples", title: "Examples"),
                ]
            ),
            SCSidebar01Section(
                id: "api-reference",
                title: "API Reference",
                items: [
                    SCSidebar01NavigationItem(id: "components", title: "Components"),
                    SCSidebar01NavigationItem(id: "file-conventions", title: "File Conventions"),
                    SCSidebar01NavigationItem(id: "functions", title: "Functions"),
                    SCSidebar01NavigationItem(id: "next-config-options", title: "next.config.js Options"),
                    SCSidebar01NavigationItem(id: "cli", title: "CLI"),
                    SCSidebar01NavigationItem(id: "edge-runtime", title: "Edge Runtime"),
                ]
            ),
            SCSidebar01Section(
                id: "architecture",
                title: "Architecture",
                items: [
                    SCSidebar01NavigationItem(id: "accessibility", title: "Accessibility"),
                    SCSidebar01NavigationItem(id: "fast-refresh", title: "Fast Refresh"),
                    SCSidebar01NavigationItem(id: "next-compiler", title: "Next.js Compiler"),
                    SCSidebar01NavigationItem(id: "supported-browsers", title: "Supported Browsers"),
                    SCSidebar01NavigationItem(id: "turbopack", title: "Turbopack"),
                ]
            ),
        ],
        defaultSelectionID: "data-fetching"
    )

    /// The shared five-section catalog used by documentation sidebar blocks
    /// whose upstream sample includes the Community group.
    static var documentationWithCommunity: SCSidebar01Data {
        var data = sidebar01
        data.sections.append(
            SCSidebar01Section(
                id: "community",
                title: "Community",
                items: [
                    SCSidebar01NavigationItem(
                        id: "contribution-guide",
                        title: "Contribution Guide"
                    )
                ]
            )
        )
        return data
    }
}

public enum SCSidebar01Action: Hashable, Sendable {
    case selectVersion(String)
    case search(String)
    case openProduct
    case selectSection(String)
    case selectNavigation(String)
    case openBreadcrumbSection(String)
}

enum SCDocumentationSidebarSectionStyle {
    case staticGroups
    case collapsible
    case submenus
    case collapsibleSubmenus
}

enum SCDocumentationSidebarHeaderStyle {
    case versionSwitcherAndSearch
    case staticBrand(version: String)
    case staticBrandAndSearch(version: String)
}

// MARK: - Version switcher

public struct SCSidebar01VersionSwitcher: View {
    @Environment(\.scSidebarIconRail) private var iconRail
    @Environment(\.theme) private var theme

    private let productName: String
    private let versions: [String]
    @Binding private var selection: String
    private let onSelect: (String) -> Void

    public init(
        productName: String,
        versions: [String],
        selection: Binding<String>,
        onSelect: @escaping (String) -> Void
    ) {
        self.productName = productName
        self.versions = versions
        self._selection = selection
        self.onSelect = onSelect
    }

    public var body: some View {
        Menu {
            ForEach(versions, id: \.self) { version in
                Button {
                    selection = version
                    onSelect(version)
                } label: {
                    if version == selection {
                        Label("v\(version)", systemImage: "checkmark")
                    } else {
                        Text("v\(version)")
                    }
                }
            }
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "square.stack.3d.up")
                    .font(.system(size: 15, weight: .semibold))
                    .frame(width: 32, height: 32)
                    .background(theme.sidebarPrimary)
                    .foregroundStyle(theme.sidebarPrimaryForeground)
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                if !iconRail {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(productName)
                            .font(.subheadline.weight(.medium))
                        Text("v\(selection)")
                            .font(.caption)
                    }
                    .lineLimit(1)
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption.weight(.medium))
                }
            }
            .padding(.horizontal, iconRail ? 0 : 8)
            .frame(maxWidth: .infinity, alignment: iconRail ? .center : .leading)
            .frame(height: 48)
            .contentShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .disabled(versions.isEmpty)
        .foregroundStyle(theme.sidebarForeground)
        .accessibilityLabel("Select documentation version")
        .accessibilityValue(selection)
    }
}

// MARK: - Block

public struct SCSidebar01Block<Detail: View>: View {
    @Environment(\.theme) private var theme

    @State private var internalVersion: String
    @State private var internalSearch = ""
    @State private var internalSelection: String
    @State private var expandedSections: Set<String>

    private let data: SCSidebar01Data
    private let externalVersion: Binding<String>?
    private let externalSearch: Binding<String>?
    private let externalSelection: Binding<String>?
    private let persistenceKey: String?
    private let headerStyle: SCDocumentationSidebarHeaderStyle
    private let sectionStyle: SCDocumentationSidebarSectionStyle
    private let submenuStyle: SCSidebarMenuSubStyle
    private let layoutVariant: SCSidebarVariant
    private let expandedWidth: CGFloat
    private let onSectionExpansion: (String, Bool) -> Void
    private let onAction: (SCSidebar01Action) -> Void
    private let detail: (String) -> Detail

    public init(
        data: SCSidebar01Data = .sidebar01,
        version: Binding<String>? = nil,
        search: Binding<String>? = nil,
        selection: Binding<String>? = nil,
        persistenceKey: String? = "sc.sidebar01.open",
        onAction: @escaping (SCSidebar01Action) -> Void,
        @ViewBuilder detail: @escaping (_ selection: String) -> Detail
    ) {
        self.init(
            data: data,
            version: version,
            search: search,
            selection: selection,
            persistenceKey: persistenceKey,
            headerStyle: .versionSwitcherAndSearch,
            sectionStyle: .staticGroups,
            expandedSectionIDs: [],
            onSectionExpansion: { _, _ in },
            onAction: onAction,
            detail: detail
        )
    }

    init(
        data: SCSidebar01Data,
        version: Binding<String>?,
        search: Binding<String>?,
        selection: Binding<String>?,
        persistenceKey: String?,
        headerStyle: SCDocumentationSidebarHeaderStyle,
        sectionStyle: SCDocumentationSidebarSectionStyle,
        submenuStyle: SCSidebarMenuSubStyle = .indented,
        layoutVariant: SCSidebarVariant = .sidebar,
        expandedWidth: CGFloat = 272,
        expandedSectionIDs: Set<String>,
        onSectionExpansion: @escaping (String, Bool) -> Void,
        onAction: @escaping (SCSidebar01Action) -> Void,
        @ViewBuilder detail: @escaping (_ selection: String) -> Detail
    ) {
        self.data = data
        self.externalVersion = version
        self.externalSearch = search
        self.externalSelection = selection
        self.persistenceKey = persistenceKey
        self.headerStyle = headerStyle
        self.sectionStyle = sectionStyle
        self.submenuStyle = submenuStyle
        self.layoutVariant = layoutVariant
        self.expandedWidth = expandedWidth
        self.onSectionExpansion = onSectionExpansion
        self.onAction = onAction
        self.detail = detail

        let initialVersion =
            version?.wrappedValue.isEmpty == false
            ? version?.wrappedValue
            : (data.versions.contains(data.defaultVersion) ? data.defaultVersion : data.versions.first)
        _internalVersion = State(initialValue: initialVersion ?? "")
        _internalSearch = State(initialValue: search?.wrappedValue ?? "")
        _internalSelection = State(
            initialValue: selection?.wrappedValue ?? Self.initialSelection(in: data)
        )
        _expandedSections = State(initialValue: expandedSectionIDs)
    }

    public init(
        data: SCSidebar01Data = .sidebar01,
        version: Binding<String>? = nil,
        search: Binding<String>? = nil,
        selection: Binding<String>? = nil,
        persistenceKey: String? = "sc.sidebar01.open",
        onAction: @escaping (SCSidebar01Action) -> Void,
        @ViewBuilder detail: @escaping () -> Detail
    ) {
        self.init(
            data: data,
            version: version,
            search: search,
            selection: selection,
            persistenceKey: persistenceKey,
            onAction: onAction,
            detail: { _ in detail() }
        )
    }

    public var body: some View {
        SCSidebarLayout(
            collapsible: .offcanvas,
            variant: layoutVariant,
            persistenceKey: persistenceKey,
            expandedWidth: expandedWidth
        ) {
            SCSidebarHeader {
                documentationHeader
            }
            SCSidebarContent {
                if filteredSections.isEmpty {
                    SCSidebarGroup {
                        Text("No results")
                            .font(.footnote)
                            .foregroundStyle(theme.sidebarForeground.opacity(0.65))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .accessibilityLabel("No navigation results")
                    }
                } else if case .submenus = sectionStyle {
                    navigationSubmenus(filteredSections)
                } else if case .collapsibleSubmenus = sectionStyle {
                    navigationCollapsibleSubmenus(filteredSections)
                } else {
                    ForEach(filteredSections) { section in
                        navigationSection(section)
                    }
                }
            }
        } detail: {
            VStack(spacing: 0) {
                topBar
                Rectangle()
                    .fill(theme.border)
                    .frame(height: 1)
                    .accessibilityHidden(true)
                detail(selectedID)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.background)
        }
        .onChange(of: searchText) { _, value in
            onAction(.search(value))
        }
    }

    @ViewBuilder
    private var documentationHeader: some View {
        switch headerStyle {
        case .versionSwitcherAndSearch:
            SCSidebarMenu {
                SCSidebarMenuItem {
                    SCSidebar01VersionSwitcher(
                        productName: data.productName,
                        versions: data.versions,
                        selection: versionBinding,
                        onSelect: { onAction(.selectVersion($0)) }
                    )
                }
            }
            SCSidebarGroupContent {
                documentationSearch
            }
        case .staticBrand(let version):
            documentationBrand(version: version)
        case .staticBrandAndSearch(let version):
            documentationBrand(version: version)
            SCSidebarGroupContent {
                documentationSearch
            }
        }
    }

    private func documentationBrand(version: String) -> some View {
        SCSidebarMenu {
            SCSidebarMenuItem {
                SCSidebarMenuButton(
                    size: .lg,
                    accessibilityLabel: Text("Open \(data.productName)"),
                    collapsedTooltip: data.productName,
                    action: { onAction(.openProduct) },
                    content: { collapsed in
                        HStack(spacing: 10) {
                            Image(systemName: "square.stack.3d.up")
                                .font(.system(size: 15, weight: .semibold))
                                .frame(width: 32, height: 32)
                                .background(theme.sidebarPrimary)
                                .foregroundStyle(theme.sidebarPrimaryForeground)
                                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            if !collapsed {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(data.productName)
                                        .font(.subheadline.weight(.medium))
                                    Text("v\(version)")
                                        .font(.caption)
                                }
                                .lineLimit(1)
                            }
                        }
                    }
                )
            }
        }
    }

    private var documentationSearch: some View {
        SCSidebarInput(
            "Search the docs...",
            text: searchBinding,
            icon: "magnifyingglass"
        )
        .accessibilityLabel("Search documentation")
    }

    private var versionBinding: Binding<String> {
        externalVersion ?? $internalVersion
    }

    private var searchBinding: Binding<String> {
        externalSearch ?? $internalSearch
    }

    private var searchText: String {
        externalSearch?.wrappedValue ?? internalSearch
    }

    private var selectedID: String {
        externalSelection?.wrappedValue ?? internalSelection
    }

    private var filteredSections: [SCSidebar01Section] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return data.sections }
        return data.sections.compactMap { section in
            let items =
                section.title.localizedCaseInsensitiveContains(query)
                ? section.items
                : section.items.filter { $0.title.localizedCaseInsensitiveContains(query) }
            guard !items.isEmpty else { return nil }
            return SCSidebar01Section(id: section.id, title: section.title, items: items)
        }
    }

    @ViewBuilder
    private func navigationSection(_ section: SCSidebar01Section) -> some View {
        switch sectionStyle {
        case .staticGroups:
            SCSidebarGroup(section.title) {
                navigationItems(section.items)
            }
        case .collapsible:
            SCSidebarGroup {
                SCSidebarGroupLabel {
                    Button {
                        toggleSection(section.id)
                    } label: {
                        HStack(spacing: 8) {
                            Text(section.title)
                            Spacer(minLength: 0)
                            Image(systemName: "chevron.right")
                                .font(.caption2.weight(.semibold))
                                .rotationEffect(.degrees(sectionIsExpanded(section.id) ? 90 : 0))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    .accessibilityValue(sectionIsExpanded(section.id) ? "Expanded" : "Collapsed")
                }
                if sectionIsExpanded(section.id) {
                    navigationItems(section.items)
                }
            }
        case .submenus:
            EmptyView()
        case .collapsibleSubmenus:
            EmptyView()
        }
    }

    private func navigationSubmenus(_ sections: [SCSidebar01Section]) -> some View {
        SCSidebarGroup {
            SCSidebarMenu {
                ForEach(sections) { section in
                    SCSidebarMenuItem {
                        SCSidebarMenuButton(
                            section.title,
                            isActive: selectedID == section.id,
                            action: { selectSection(section.id) }
                        )
                        SCSidebarMenuSub(style: submenuStyle) {
                            ForEach(section.items) { item in
                                SCSidebarMenuSubItem {
                                    SCSidebarMenuSubButton(
                                        item.title,
                                        isActive: selectedID == item.id,
                                        action: { select(item.id) }
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func navigationCollapsibleSubmenus(_ sections: [SCSidebar01Section]) -> some View {
        SCSidebarGroup {
            SCSidebarMenu {
                ForEach(sections) { section in
                    SCSidebarMenuItem {
                        SCSidebarMenuButton(
                            accessibilityLabel: Text(section.title),
                            collapsedTooltip: section.title,
                            action: { toggleSection(section.id) },
                            content: { collapsed in
                                if !collapsed {
                                    Text(section.title)
                                        .font(.subheadline.weight(.medium))
                                        .lineLimit(1)
                                }
                            },
                            trailing: { collapsed in
                                if !collapsed {
                                    Image(
                                        systemName: sectionIsExpanded(section.id)
                                            ? "minus" : "plus"
                                    )
                                    .font(.caption.weight(.semibold))
                                }
                            }
                        )
                        .accessibilityValue(
                            sectionIsExpanded(section.id) ? "Expanded" : "Collapsed"
                        )
                        if sectionIsExpanded(section.id) {
                            SCSidebarMenuSub(style: submenuStyle) {
                                ForEach(section.items) { item in
                                    SCSidebarMenuSubItem {
                                        SCSidebarMenuSubButton(
                                            item.title,
                                            isActive: selectedID == item.id,
                                            action: { select(item.id) }
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    private func navigationItems(_ items: [SCSidebar01NavigationItem]) -> some View {
        SCSidebarGroupContent {
            SCSidebarMenu {
                ForEach(items) { item in
                    SCSidebarMenuItem {
                        SCSidebarMenuButton(
                            item.title,
                            isActive: selectedID == item.id,
                            action: { select(item.id) }
                        )
                    }
                }
            }
        }
    }

    private func sectionIsExpanded(_ id: String) -> Bool {
        !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            || expandedSections.contains(id)
    }

    private func toggleSection(_ id: String) {
        let willExpand = !expandedSections.contains(id)
        if willExpand {
            expandedSections.insert(id)
        } else {
            expandedSections.remove(id)
        }
        onSectionExpansion(id, willExpand)
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            SCSidebarTrigger()
            SCSeparator(.vertical, isDecorative: true)
                .frame(height: 16)
            ViewThatFits(in: .horizontal) {
                fullBreadcrumb
                currentPageBreadcrumb
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .frame(height: 64)
    }

    private var fullBreadcrumb: some View {
        SCBreadcrumb {
            SCBreadcrumbList {
                SCBreadcrumbItem {
                    SCBreadcrumbLink(action: openSelectedSection) {
                        Text(selectedSection?.title ?? "Documentation")
                    }
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

    private var selectedSection: SCSidebar01Section? {
        data.sections.first { section in
            section.id == selectedID || section.items.contains { $0.id == selectedID }
        }
    }

    private var selectedTitle: String {
        if selectedSection?.id == selectedID {
            return selectedSection?.title ?? selectedID
        }
        return selectedSection?.items.first(where: { $0.id == selectedID })?.title ?? selectedID
    }

    private func select(_ id: String) {
        if let externalSelection {
            externalSelection.wrappedValue = id
        } else {
            internalSelection = id
        }
        onAction(.selectNavigation(id))
    }

    private func selectSection(_ id: String) {
        if let externalSelection {
            externalSelection.wrappedValue = id
        } else {
            internalSelection = id
        }
        onAction(.selectSection(id))
    }

    private func openSelectedSection() {
        if let selectedSection {
            onAction(.openBreadcrumbSection(selectedSection.id))
        }
    }

    private static func initialSelection(in data: SCSidebar01Data) -> String {
        if data.sections.contains(where: { section in
            section.items.contains { $0.id == data.defaultSelectionID }
        }) {
            return data.defaultSelectionID
        }
        return data.sections.first?.items.first?.id ?? ""
    }
}

// MARK: - Previews

#Preview("Sidebar block · sidebar-01") {
    @Previewable @State var lastAction = "Use the version, search, navigation, or breadcrumb controls."

    SCPreview {
        SCSidebar01Block(
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
        .frame(width: 1000, height: 700)
    }
}
