// ============================================================
// Sidebar14Block.swift — swiftcn-ui
// Depends on: Sidebar, Breadcrumb
// ============================================================
import SwiftUI

public struct SCSidebar14Page: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String

    public init(id: String, title: String) {
        self.id = id
        self.title = title
    }
}

public struct SCSidebar14Section: Identifiable, Hashable, Sendable {
    public let id: String
    public let title: String
    public let pages: [SCSidebar14Page]

    public init(id: String, title: String, pages: [SCSidebar14Page]) {
        self.id = id
        self.title = title
        self.pages = pages
    }
}

public struct SCSidebar14Data: Sendable {
    public var sections: [SCSidebar14Section]
    public var defaultSelectionID: String

    public init(sections: [SCSidebar14Section], defaultSelectionID: String) {
        self.sections = sections
        self.defaultSelectionID = defaultSelectionID
    }

    public static let sidebar14 = SCSidebar14Data(
        sections: [
            section(
                "getting-started",
                title: "Getting Started",
                pages: [
                    page("installation", "Installation"),
                    page("project-structure", "Project Structure"),
                ]
            ),
            section(
                "build-your-application",
                title: "Build Your Application",
                pages: [
                    page("routing", "Routing"),
                    page("data-fetching", "Data Fetching"),
                    page("rendering", "Rendering"),
                    page("caching", "Caching"),
                    page("styling", "Styling"),
                    page("optimizing", "Optimizing"),
                    page("configuring", "Configuring"),
                    page("testing", "Testing"),
                    page("authentication", "Authentication"),
                    page("deploying", "Deploying"),
                    page("upgrading", "Upgrading"),
                    page("examples", "Examples"),
                ]
            ),
            section(
                "api-reference",
                title: "API Reference",
                pages: [
                    page("components", "Components"),
                    page("file-conventions", "File Conventions"),
                    page("functions", "Functions"),
                    page("next-config-options", "next.config.js Options"),
                    page("cli", "CLI"),
                    page("edge-runtime", "Edge Runtime"),
                ]
            ),
            section(
                "architecture",
                title: "Architecture",
                pages: [
                    page("accessibility", "Accessibility"),
                    page("fast-refresh", "Fast Refresh"),
                    page("next-js-compiler", "Next.js Compiler"),
                    page("supported-browsers", "Supported Browsers"),
                    page("turbopack", "Turbopack"),
                ]
            ),
            section(
                "community",
                title: "Community",
                pages: [page("contribution-guide", "Contribution Guide")]
            ),
        ],
        defaultSelectionID: "data-fetching"
    )

    private static func section(
        _ id: String,
        title: String,
        pages: [SCSidebar14Page]
    ) -> SCSidebar14Section {
        SCSidebar14Section(id: id, title: title, pages: pages)
    }

    private static func page(_ id: String, _ title: String) -> SCSidebar14Page {
        SCSidebar14Page(id: id, title: title)
    }
}

public enum SCSidebar14Action: Hashable, Sendable {
    case selectSection(String)
    case selectPage(String)
    case openBreadcrumbSection(String)
}

/// A right-side table-of-contents sidebar with real selection and routing.
public struct SCSidebar14Block<Detail: View>: View {
    @Environment(\.theme) private var theme

    @State private var internalSelection: String

    private let data: SCSidebar14Data
    private let externalSelection: Binding<String>?
    private let persistenceKey: String?
    private let onAction: (SCSidebar14Action) -> Void
    private let detail: (String) -> Detail

    public init(
        data: SCSidebar14Data = .sidebar14,
        selection: Binding<String>? = nil,
        persistenceKey: String? = "sc.sidebar14.open",
        onAction: @escaping (SCSidebar14Action) -> Void,
        @ViewBuilder detail: @escaping (_ selection: String) -> Detail
    ) {
        self.data = data
        self.externalSelection = selection
        self.persistenceKey = persistenceKey
        self.onAction = onAction
        self.detail = detail
        _internalSelection = State(
            initialValue: selection?.wrappedValue ?? data.defaultSelectionID
        )
    }

    public init(
        data: SCSidebar14Data = .sidebar14,
        selection: Binding<String>? = nil,
        persistenceKey: String? = "sc.sidebar14.open",
        onAction: @escaping (SCSidebar14Action) -> Void,
        @ViewBuilder detail: @escaping () -> Detail
    ) {
        self.init(
            data: data,
            selection: selection,
            persistenceKey: persistenceKey,
            onAction: onAction,
            detail: { _ in detail() }
        )
    }

    public var body: some View {
        SCSidebarLayout(
            collapsible: .offcanvas,
            side: .trailing,
            persistenceKey: persistenceKey
        ) {
            SCSidebarContent {
                SCSidebarGroup {
                    SCSidebarGroupLabel { Text("Table of Contents") }
                    SCSidebarGroupContent {
                        SCSidebarMenu {
                            ForEach(data.sections) { section in
                                sectionRow(section)
                            }
                        }
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
    }

    private var selectedID: String {
        externalSelection?.wrappedValue ?? internalSelection
    }

    private func sectionRow(_ section: SCSidebar14Section) -> some View {
        SCSidebarMenuItem {
            VStack(alignment: .leading, spacing: 2) {
                SCSidebarMenuButton(
                    section.title,
                    isActive: selectedID == section.id,
                    action: {
                        setSelection(section.id)
                        onAction(.selectSection(section.id))
                    }
                )
                if !section.pages.isEmpty {
                    SCSidebarMenuSub {
                        ForEach(section.pages) { page in
                            SCSidebarMenuSubItem {
                                SCSidebarMenuSubButton(
                                    page.title,
                                    isActive: selectedID == page.id,
                                    action: {
                                        setSelection(page.id)
                                        onAction(.selectPage(page.id))
                                    }
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            breadcrumb
            Spacer(minLength: 0)
            SCSidebarTrigger()
        }
        .padding(.horizontal, 16)
        .frame(height: 64)
    }

    private var breadcrumb: some View {
        SCBreadcrumb {
            SCBreadcrumbList {
                if let selectedSection, selectedSection.id != selectedID {
                    SCBreadcrumbItem {
                        SCBreadcrumbLink(
                            action: {
                                onAction(.openBreadcrumbSection(selectedSection.id))
                            },
                            label: { Text(selectedSection.title) }
                        )
                    }
                    SCBreadcrumbSeparator()
                }
                SCBreadcrumbItem {
                    SCBreadcrumbPage(selectedTitle)
                }
            }
        }
    }

    private var selectedSection: SCSidebar14Section? {
        data.sections.first { section in
            section.id == selectedID || section.pages.contains { $0.id == selectedID }
        }
    }

    private var selectedTitle: String {
        if let section = data.sections.first(where: { $0.id == selectedID }) {
            return section.title
        }
        return selectedSection?.pages.first(where: { $0.id == selectedID })?.title ?? selectedID
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

#Preview("Sidebar block · sidebar-14") {
    @Previewable @State var lastAction = "Select a documentation page."

    SCPreview {
        SCSidebar14Block(
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
        .frame(width: 1000, height: 700)
    }
}
