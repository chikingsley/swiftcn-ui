// ============================================================
// Sidebar05Block.swift — swiftcn-ui
// Depends on: Sidebar01Block (shared documentation sidebar engine)
// ============================================================
import SwiftUI

/// Typed application actions emitted by the functional sidebar-05 block.
public enum SCSidebar05Action: Hashable, Sendable {
    case openProduct
    case search(String)
    case selectNavigation(String)
    case openBreadcrumbSection(String)
    case setSectionExpanded(String, Bool)
}

extension SCSidebar01Data {
    /// The current sidebar-05 documentation catalog and static brand version.
    public static var sidebar05: SCSidebar01Data {
        var data = documentationWithCommunity
        data.versions = ["1.0.0"]
        data.defaultVersion = "1.0.0"
        return data
    }
}

/// Sidebar-05 configures the shared documentation engine with real search and
/// independently collapsible nested navigation groups.
public struct SCSidebar05Block<Detail: View>: View {
    private let data: SCSidebar01Data
    private let search: Binding<String>?
    private let selection: Binding<String>?
    private let persistenceKey: String?
    private let onAction: (SCSidebar05Action) -> Void
    private let detail: (String) -> Detail

    public init(
        data: SCSidebar01Data = .sidebar05,
        search: Binding<String>? = nil,
        selection: Binding<String>? = nil,
        persistenceKey: String? = "sc.sidebar05.open",
        onAction: @escaping (SCSidebar05Action) -> Void,
        @ViewBuilder detail: @escaping (_ selection: String) -> Detail
    ) {
        self.data = data
        self.search = search
        self.selection = selection
        self.persistenceKey = persistenceKey
        self.onAction = onAction
        self.detail = detail
    }

    public init(
        data: SCSidebar01Data = .sidebar05,
        search: Binding<String>? = nil,
        selection: Binding<String>? = nil,
        persistenceKey: String? = "sc.sidebar05.open",
        onAction: @escaping (SCSidebar05Action) -> Void,
        @ViewBuilder detail: @escaping () -> Detail
    ) {
        self.init(
            data: data,
            search: search,
            selection: selection,
            persistenceKey: persistenceKey,
            onAction: onAction,
            detail: { _ in detail() }
        )
    }

    public var body: some View {
        SCSidebar01Block(
            data: data,
            version: nil,
            search: search,
            selection: selection,
            persistenceKey: persistenceKey,
            headerStyle: .staticBrandAndSearch(version: data.defaultVersion),
            sectionStyle: .collapsibleSubmenus,
            expandedSectionIDs: initialExpandedSectionIDs,
            onSectionExpansion: { onAction(.setSectionExpanded($0, $1)) },
            onAction: forward,
            detail: detail
        )
    }

    private var initialExpandedSectionIDs: Set<String> {
        guard data.sections.indices.contains(1) else { return [] }
        return [data.sections[1].id]
    }

    private func forward(_ action: SCSidebar01Action) {
        switch action {
        case .selectVersion, .selectSection:
            break
        case .search(let query):
            onAction(.search(query))
        case .openProduct:
            onAction(.openProduct)
        case .selectNavigation(let id):
            onAction(.selectNavigation(id))
        case .openBreadcrumbSection(let id):
            onAction(.openBreadcrumbSection(id))
        }
    }
}

// MARK: - Previews

#Preview("Sidebar block · sidebar-05") {
    @Previewable @State var lastAction = "Search, disclose a section, or choose a page."

    SCPreview {
        SCSidebar05Block(
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
