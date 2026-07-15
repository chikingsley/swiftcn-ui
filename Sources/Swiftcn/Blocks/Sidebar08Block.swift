// ============================================================
// Sidebar08Block.swift — swiftcn-ui
// Depends on: SidebarBlock (shared application sidebar engine)
// ============================================================
import SwiftUI

/// Typed application actions emitted by the functional sidebar-08 block.
public enum SCSidebar08Action: Hashable, Sendable {
    case openBreadcrumbRoot
    case openOrganization
    case selectNavigation(String)
    case setNavigationExpanded(String, Bool)
    case selectProject(String)
    case project(String, SCSidebarProjectAction)
    case showMoreProjects
    case selectSecondaryNavigation(String)
    case user(SCSidebarUserAction)
}

extension SCSidebarTeam {
    /// The static organization identity in the current sidebar-08 sample.
    public static let sidebar08Organization = SCSidebarTeam(
        id: "acme-inc",
        name: "Acme Inc",
        plan: "Enterprise",
        systemImage: "command"
    )
}

extension SCSidebarBlockData {
    /// The complete current sidebar-08 application navigation sample.
    public static let sidebar08 = SCSidebarBlockData(
        teams: [],
        user: SCSidebarBlockData.sidebar07.user,
        navigation: SCSidebarBlockData.sidebar07.navigation,
        projects: SCSidebarBlockData.sidebar07.projects,
        secondaryNavigation: [
            SCSidebarNavigationItem(
                id: "support",
                title: "Support",
                systemImage: "lifepreserver"
            ),
            SCSidebarNavigationItem(
                id: "feedback",
                title: "Feedback",
                systemImage: "paperplane"
            ),
        ]
    )
}

/// Sidebar-08 configures the shared application engine with a static
/// organization header, separately selectable/disclosable primary rows, and
/// secondary navigation pinned below Projects.
public struct SCSidebar08Block<Detail: View>: View {
    private let data: SCSidebarBlockData
    private let organization: SCSidebarTeam
    private let selection: Binding<String>?
    private let persistenceKey: String?
    private let onAction: (SCSidebar08Action) -> Void
    private let detail: (String) -> Detail

    public init(
        data: SCSidebarBlockData = .sidebar08,
        organization: SCSidebarTeam = .sidebar08Organization,
        selection: Binding<String>? = nil,
        persistenceKey: String? = "sc.sidebar08.open",
        onAction: @escaping (SCSidebar08Action) -> Void,
        @ViewBuilder detail: @escaping (_ selection: String) -> Detail
    ) {
        self.data = data
        self.organization = organization
        self.selection = selection
        self.persistenceKey = persistenceKey
        self.onAction = onAction
        self.detail = detail
    }

    public init(
        data: SCSidebarBlockData = .sidebar08,
        organization: SCSidebarTeam = .sidebar08Organization,
        selection: Binding<String>? = nil,
        persistenceKey: String? = "sc.sidebar08.open",
        onAction: @escaping (SCSidebar08Action) -> Void,
        @ViewBuilder detail: @escaping () -> Detail
    ) {
        self.init(
            data: data,
            organization: organization,
            selection: selection,
            persistenceKey: persistenceKey,
            onAction: onAction,
            detail: { _ in detail() }
        )
    }

    public var body: some View {
        SCSidebarBlock(
            data: data,
            activeTeamID: nil,
            selection: selection,
            collapsible: .offcanvas,
            persistenceKey: persistenceKey,
            headerStyle: .organization(organization),
            navigationStyle: .selectableRowsWithSeparateDisclosure,
            showsSecondaryNavigation: true,
            onAction: forward,
            detail: detail
        )
    }

    private func forward(_ action: SCSidebarBlockAction) {
        switch action {
        case .openBreadcrumbRoot:
            onAction(.openBreadcrumbRoot)
        case .openOrganization:
            onAction(.openOrganization)
        case .selectTeam, .addTeam:
            break
        case .selectNavigation(let id):
            onAction(.selectNavigation(id))
        case .setNavigationExpanded(let id, let isExpanded):
            onAction(.setNavigationExpanded(id, isExpanded))
        case .selectProject(let id):
            onAction(.selectProject(id))
        case .project(let id, let projectAction):
            onAction(.project(id, projectAction))
        case .showMoreProjects:
            onAction(.showMoreProjects)
        case .selectSecondaryNavigation(let id):
            onAction(.selectSecondaryNavigation(id))
        case .user(let userAction):
            onAction(.user(userAction))
        }
    }
}

// MARK: - Previews

#Preview("Sidebar block · sidebar-08") {
    @Previewable @State var lastAction = "Use any application navigation control."

    SCPreview {
        SCSidebar08Block(
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
