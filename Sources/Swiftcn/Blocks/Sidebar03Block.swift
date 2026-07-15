// ============================================================
// Sidebar03Block.swift — swiftcn-ui
// Depends on: Sidebar01Block (shared documentation sidebar engine)
// ============================================================
import SwiftUI

/// Typed application actions emitted by the functional sidebar-03 block.
public enum SCSidebar03Action: Hashable, Sendable {
    case openProduct
    case selectSection(String)
    case selectNavigation(String)
    case openBreadcrumbSection(String)
}

extension SCSidebar01Data {
    /// The current sidebar-03 documentation catalog and static brand version.
    public static var sidebar03: SCSidebar01Data {
        var data = documentationWithCommunity
        data.versions = ["1.0.0"]
        data.defaultVersion = "1.0.0"
        return data
    }
}

/// Sidebar-03 is the submenu configuration of the shared documentation
/// sidebar engine. Parent destinations and every nested destination are real.
public struct SCSidebar03Block<Detail: View>: View {
    private let data: SCSidebar01Data
    private let selection: Binding<String>?
    private let persistenceKey: String?
    private let onAction: (SCSidebar03Action) -> Void
    private let detail: (String) -> Detail

    public init(
        data: SCSidebar01Data = .sidebar03,
        selection: Binding<String>? = nil,
        persistenceKey: String? = "sc.sidebar03.open",
        onAction: @escaping (SCSidebar03Action) -> Void,
        @ViewBuilder detail: @escaping (_ selection: String) -> Detail
    ) {
        self.data = data
        self.selection = selection
        self.persistenceKey = persistenceKey
        self.onAction = onAction
        self.detail = detail
    }

    public init(
        data: SCSidebar01Data = .sidebar03,
        selection: Binding<String>? = nil,
        persistenceKey: String? = "sc.sidebar03.open",
        onAction: @escaping (SCSidebar03Action) -> Void,
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

#Preview("Sidebar block · sidebar-03") {
    @Previewable @State var lastAction = "Choose a section or submenu destination."

    SCPreview {
        SCSidebar03Block(
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
