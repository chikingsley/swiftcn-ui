// ============================================================
// Sidebar04Block.swift — swiftcn-ui
// Depends on: Sidebar01Block (shared documentation sidebar engine)
// ============================================================
import SwiftUI

/// Typed application actions emitted by the functional sidebar-04 block.
public enum SCSidebar04Action: Hashable, Sendable {
    case openProduct
    case selectSection(String)
    case selectNavigation(String)
    case openBreadcrumbSection(String)
}

extension SCSidebar01Data {
    /// The current sidebar-04 documentation catalog and static brand version.
    public static var sidebar04: SCSidebar01Data {
        var data = documentationWithCommunity
        data.versions = ["1.0.0"]
        data.defaultVersion = "1.0.0"
        return data
    }
}

/// Sidebar-04 configures the shared documentation engine as a wider floating
/// sidebar with compact, guide-less submenus.
public struct SCSidebar04Block<Detail: View>: View {
    private let data: SCSidebar01Data
    private let selection: Binding<String>?
    private let persistenceKey: String?
    private let onAction: (SCSidebar04Action) -> Void
    private let detail: (String) -> Detail

    public init(
        data: SCSidebar01Data = .sidebar04,
        selection: Binding<String>? = nil,
        persistenceKey: String? = "sc.sidebar04.open",
        onAction: @escaping (SCSidebar04Action) -> Void,
        @ViewBuilder detail: @escaping (_ selection: String) -> Detail
    ) {
        self.data = data
        self.selection = selection
        self.persistenceKey = persistenceKey
        self.onAction = onAction
        self.detail = detail
    }

    public init(
        data: SCSidebar01Data = .sidebar04,
        selection: Binding<String>? = nil,
        persistenceKey: String? = "sc.sidebar04.open",
        onAction: @escaping (SCSidebar04Action) -> Void,
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
        SCSidebar01Block(
            data: data,
            version: nil,
            search: nil,
            selection: selection,
            persistenceKey: persistenceKey,
            headerStyle: .staticBrand(version: data.defaultVersion),
            sectionStyle: .submenus,
            submenuStyle: .flush,
            layoutVariant: .floating,
            expandedWidth: 304,
            expandedSectionIDs: [],
            onSectionExpansion: { _, _ in },
            onAction: forward,
            detail: detail
        )
    }

    private func forward(_ action: SCSidebar01Action) {
        switch action {
        case .selectVersion, .search:
            break
        case .openProduct:
            onAction(.openProduct)
        case .selectSection(let id):
            onAction(.selectSection(id))
        case .selectNavigation(let id):
            onAction(.selectNavigation(id))
        case .openBreadcrumbSection(let id):
            onAction(.openBreadcrumbSection(id))
        }
    }
}

// MARK: - Previews

#Preview("Sidebar block · sidebar-04") {
    @Previewable @State var lastAction = "Choose a section or submenu destination."

    SCPreview {
        SCSidebar04Block(
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
