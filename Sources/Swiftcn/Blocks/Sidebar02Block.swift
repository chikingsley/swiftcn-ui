// ============================================================
// Sidebar02Block.swift — swiftcn-ui
// Depends on: Sidebar01Block (shared documentation sidebar engine)
// ============================================================
import SwiftUI

/// Typed application actions emitted by the functional sidebar-02 block.
public enum SCSidebar02Action: Hashable, Sendable {
    case selectVersion(String)
    case search(String)
    case selectNavigation(String)
    case openBreadcrumbSection(String)
    case setSectionExpanded(String, Bool)
}

extension SCSidebar01Data {
    /// The complete current sidebar-02 sample data, adding the Community
    /// section to sidebar-01's documentation catalog.
    public static var sidebar02: SCSidebar01Data {
        documentationWithCommunity
    }
}

/// Sidebar-02 is a thin composition over sidebar-01's documentation engine;
/// its defining behavior is independently collapsible, initially open groups.
public struct SCSidebar02Block<Detail: View>: View {
    private let data: SCSidebar01Data
    private let version: Binding<String>?
    private let search: Binding<String>?
    private let selection: Binding<String>?
    private let persistenceKey: String?
    private let onAction: (SCSidebar02Action) -> Void
    private let detail: (String) -> Detail

    public init(
        data: SCSidebar01Data = .sidebar02,
        version: Binding<String>? = nil,
        search: Binding<String>? = nil,
        selection: Binding<String>? = nil,
        persistenceKey: String? = "sc.sidebar02.open",
        onAction: @escaping (SCSidebar02Action) -> Void,
        @ViewBuilder detail: @escaping (_ selection: String) -> Detail
    ) {
        self.data = data
        self.version = version
        self.search = search
        self.selection = selection
        self.persistenceKey = persistenceKey
        self.onAction = onAction
        self.detail = detail
    }

    public init(
        data: SCSidebar01Data = .sidebar02,
        version: Binding<String>? = nil,
        search: Binding<String>? = nil,
        selection: Binding<String>? = nil,
        persistenceKey: String? = "sc.sidebar02.open",
        onAction: @escaping (SCSidebar02Action) -> Void,
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
        SCSidebar01Block(
            data: data,
            version: version,
            search: search,
            selection: selection,
            persistenceKey: persistenceKey,
            headerStyle: .versionSwitcherAndSearch,
            sectionStyle: .collapsible,
            expandedSectionIDs: Set(data.sections.map(\.id)),
            onSectionExpansion: { onAction(.setSectionExpanded($0, $1)) },
            onAction: forward,
            detail: detail
        )
    }

    private func forward(_ action: SCSidebar01Action) {
        switch action {
        case .selectVersion(let version):
            onAction(.selectVersion(version))
        case .search(let query):
            onAction(.search(query))
        case .openProduct:
            break
        case .selectSection(let id):
            onAction(.selectNavigation(id))
        case .selectNavigation(let id):
            onAction(.selectNavigation(id))
        case .openBreadcrumbSection(let id):
            onAction(.openBreadcrumbSection(id))
        }
    }
}

// MARK: - Previews

#Preview("Sidebar block · sidebar-02") {
    @Previewable @State var lastAction = "Collapse a section or choose a page."

    SCPreview {
        SCSidebar02Block(
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
