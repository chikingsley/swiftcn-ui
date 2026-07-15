// ============================================================
// Sidebar11Block.swift — swiftcn-ui
// Depends on: Sidebar, Breadcrumb, Separator
// ============================================================
import SwiftUI

public struct SCSidebar11Change: Identifiable, Hashable, Sendable {
    public let id: String
    public let path: String
    public let state: String

    public init(id: String? = nil, path: String, state: String) {
        self.id = id ?? path
        self.path = path
        self.state = state
    }
}

public struct SCSidebar11TreeNode: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let children: [SCSidebar11TreeNode]

    public init(
        id: String,
        name: String,
        children: [SCSidebar11TreeNode] = []
    ) {
        self.id = id
        self.name = name
        self.children = children
    }
}

public struct SCSidebar11Data: Sendable {
    public var changes: [SCSidebar11Change]
    public var tree: [SCSidebar11TreeNode]
    public var defaultSelectionID: String
    public var initiallyExpandedFolderIDs: Set<String>

    public init(
        changes: [SCSidebar11Change],
        tree: [SCSidebar11TreeNode],
        defaultSelectionID: String,
        initiallyExpandedFolderIDs: Set<String> = []
    ) {
        self.changes = changes
        self.tree = tree
        self.defaultSelectionID = defaultSelectionID
        self.initiallyExpandedFolderIDs = initiallyExpandedFolderIDs
    }

    public static let sidebar11 = SCSidebar11Data(
        changes: [
            SCSidebar11Change(path: "README.md", state: "M"),
            SCSidebar11Change(path: "api/hello/route.ts", state: "U"),
            SCSidebar11Change(path: "app/layout.tsx", state: "M"),
        ],
        tree: [
            folder(
                "app",
                children: [
                    folder(
                        "app/api",
                        name: "api",
                        children: [
                            folder(
                                "app/api/hello",
                                name: "hello",
                                children: [file("app/api/hello/route.ts", name: "route.ts")]
                            )
                        ]
                    ),
                    file("app/page.tsx", name: "page.tsx"),
                    file("app/layout.tsx", name: "layout.tsx"),
                    folder(
                        "app/blog",
                        name: "blog",
                        children: [file("app/blog/page.tsx", name: "page.tsx")]
                    ),
                ]
            ),
            folder(
                "components",
                children: [
                    folder(
                        "components/ui",
                        name: "ui",
                        children: [
                            file("components/ui/button.tsx", name: "button.tsx"),
                            file("components/ui/card.tsx", name: "card.tsx"),
                        ]
                    ),
                    file("components/header.tsx", name: "header.tsx"),
                    file("components/footer.tsx", name: "footer.tsx"),
                ]
            ),
            folder("lib", children: [file("lib/util.ts", name: "util.ts")]),
            folder(
                "public",
                children: [
                    file("public/favicon.ico", name: "favicon.ico"),
                    file("public/vercel.svg", name: "vercel.svg"),
                ]
            ),
            file(".eslintrc.json"),
            file(".gitignore"),
            file("next.config.js"),
            file("tailwind.config.js"),
            file("package.json"),
            file("README.md"),
        ],
        defaultSelectionID: "components/ui/button.tsx",
        initiallyExpandedFolderIDs: ["components", "components/ui"]
    )

    private static func folder(
        _ id: String,
        name: String? = nil,
        children: [SCSidebar11TreeNode]
    ) -> SCSidebar11TreeNode {
        SCSidebar11TreeNode(
            id: id,
            name: name ?? id.split(separator: "/").last.map(String.init) ?? id,
            children: children
        )
    }

    private static func file(
        _ id: String,
        name: String? = nil
    ) -> SCSidebar11TreeNode {
        SCSidebar11TreeNode(
            id: id,
            name: name ?? id.split(separator: "/").last.map(String.init) ?? id
        )
    }
}

public enum SCSidebar11Action: Hashable, Sendable {
    case selectChange(String)
    case selectFile(String)
    case setFolderExpanded(String, Bool)
    case openBreadcrumbPath(String)
}

/// A functional source-control changes and file-tree sidebar with arbitrary
/// caller data, controlled selection/expansion, and caller-owned detail.
public struct SCSidebar11Block<Detail: View>: View {
    @Environment(\.theme) private var theme

    @State private var internalSelection: String
    @State private var internalExpandedFolderIDs: Set<String>

    private let data: SCSidebar11Data
    private let externalSelection: Binding<String>?
    private let externalExpandedFolderIDs: Binding<Set<String>>?
    private let persistenceKey: String?
    private let onAction: (SCSidebar11Action) -> Void
    private let detail: (String) -> Detail

    public init(
        data: SCSidebar11Data = .sidebar11,
        selection: Binding<String>? = nil,
        expandedFolderIDs: Binding<Set<String>>? = nil,
        persistenceKey: String? = "sc.sidebar11.open",
        onAction: @escaping (SCSidebar11Action) -> Void,
        @ViewBuilder detail: @escaping (_ selection: String) -> Detail
    ) {
        self.data = data
        self.externalSelection = selection
        self.externalExpandedFolderIDs = expandedFolderIDs
        self.persistenceKey = persistenceKey
        self.onAction = onAction
        self.detail = detail
        _internalSelection = State(initialValue: selection?.wrappedValue ?? data.defaultSelectionID)
        _internalExpandedFolderIDs = State(
            initialValue: expandedFolderIDs?.wrappedValue ?? data.initiallyExpandedFolderIDs
        )
    }

    public init(
        data: SCSidebar11Data = .sidebar11,
        selection: Binding<String>? = nil,
        expandedFolderIDs: Binding<Set<String>>? = nil,
        persistenceKey: String? = "sc.sidebar11.open",
        onAction: @escaping (SCSidebar11Action) -> Void,
        @ViewBuilder detail: @escaping () -> Detail
    ) {
        self.init(
            data: data,
            selection: selection,
            expandedFolderIDs: expandedFolderIDs,
            persistenceKey: persistenceKey,
            onAction: onAction,
            detail: { _ in detail() }
        )
    }

    public var body: some View {
        SCSidebarLayout(
            collapsible: .offcanvas,
            persistenceKey: persistenceKey
        ) {
            SCSidebarContent {
                changesGroup
                filesGroup
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
        }
    }

    private var selectedID: String {
        externalSelection?.wrappedValue ?? internalSelection
    }

    private var expandedFolderIDs: Set<String> {
        externalExpandedFolderIDs?.wrappedValue ?? internalExpandedFolderIDs
    }

    private var changesGroup: some View {
        SCSidebarGroup("Changes") {
            SCSidebarGroupContent {
                SCSidebarMenu {
                    ForEach(data.changes) { change in
                        SCSidebarMenuItem {
                            SCSidebarMenuButton(
                                change.path,
                                systemImage: "doc",
                                isActive: selectedID == change.path,
                                badge: change.state
                            ) {
                                setSelection(change.path)
                                onAction(.selectChange(change.path))
                            }
                        }
                    }
                }
            }
        }
    }

    private var filesGroup: some View {
        SCSidebarGroup("Files") {
            SCSidebarGroupContent {
                SCSidebarMenu {
                    ForEach(visibleNodes) { visible in
                        treeRow(visible)
                    }
                }
            }
        }
    }

    private func treeRow(_ visible: SCSidebar11VisibleNode) -> some View {
        let node = visible.node
        let isFolder = !node.children.isEmpty
        return SCSidebarMenuItem {
            SCSidebarMenuButton(
                isActive: !isFolder && selectedID == node.id,
                accessibilityLabel: Text(node.name),
                action: {
                    if isFolder {
                        toggleFolder(node.id)
                    } else {
                        setSelection(node.id)
                        onAction(.selectFile(node.id))
                    }
                },
                content: { collapsed in
                    if !collapsed {
                        HStack(spacing: 8) {
                            if isFolder {
                                Image(systemName: "chevron.right")
                                    .font(.caption2.weight(.semibold))
                                    .rotationEffect(
                                        .degrees(expandedFolderIDs.contains(node.id) ? 90 : 0)
                                    )
                                Image(systemName: "folder")
                            } else {
                                Image(systemName: "doc")
                            }
                            Text(node.name).lineLimit(1)
                        }
                        .padding(.leading, CGFloat(visible.depth) * 16)
                    }
                }
            )
            .accessibilityValue(
                isFolder
                    ? (expandedFolderIDs.contains(node.id) ? "Expanded" : "Collapsed")
                    : ""
            )
        }
    }

    private var visibleNodes: [SCSidebar11VisibleNode] {
        flatten(data.tree, depth: 0)
    }

    private func flatten(
        _ nodes: [SCSidebar11TreeNode],
        depth: Int
    ) -> [SCSidebar11VisibleNode] {
        nodes.flatMap { node in
            var result = [SCSidebar11VisibleNode(node: node, depth: depth)]
            if !node.children.isEmpty, expandedFolderIDs.contains(node.id) {
                result.append(contentsOf: flatten(node.children, depth: depth + 1))
            }
            return result
        }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            SCSidebarTrigger()
            SCSeparator(.vertical, isDecorative: true).frame(height: 16)
            ViewThatFits(in: .horizontal) {
                pathBreadcrumb
                SCBreadcrumb {
                    SCBreadcrumbList {
                        SCBreadcrumbItem {
                            SCBreadcrumbPage(pathComponents.last ?? selectedID)
                        }
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .frame(height: 64)
    }

    private var pathBreadcrumb: some View {
        SCBreadcrumb {
            SCBreadcrumbList {
                ForEach(Array(pathComponents.enumerated()), id: \.offset) { index, component in
                    SCBreadcrumbItem {
                        if index == pathComponents.count - 1 {
                            SCBreadcrumbPage(component)
                        } else {
                            SCBreadcrumbLink(
                                action: { onAction(.openBreadcrumbPath(pathPrefix(through: index))) },
                                label: { Text(component) }
                            )
                        }
                    }
                    if index < pathComponents.count - 1 {
                        SCBreadcrumbSeparator()
                    }
                }
            }
        }
    }

    private var pathComponents: [String] {
        selectedID.split(separator: "/").map(String.init)
    }

    private func pathPrefix(through index: Int) -> String {
        pathComponents.prefix(index + 1).joined(separator: "/")
    }

    private func toggleFolder(_ id: String) {
        var updated = expandedFolderIDs
        let willExpand = !updated.contains(id)
        if willExpand {
            updated.insert(id)
        } else {
            updated.remove(id)
        }
        if let externalExpandedFolderIDs {
            externalExpandedFolderIDs.wrappedValue = updated
        } else {
            internalExpandedFolderIDs = updated
        }
        onAction(.setFolderExpanded(id, willExpand))
    }

    private func setSelection(_ id: String) {
        if let externalSelection {
            externalSelection.wrappedValue = id
        } else {
            internalSelection = id
        }
    }
}

private struct SCSidebar11VisibleNode: Identifiable {
    let node: SCSidebar11TreeNode
    let depth: Int
    var id: String { node.id }
}

// MARK: - Previews

#Preview("Sidebar block · sidebar-11") {
    @Previewable @State var lastAction = "Select a change or navigate the file tree."

    SCPreview {
        SCSidebar11Block(
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
