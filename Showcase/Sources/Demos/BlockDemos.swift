// ============================================================
// BlockDemos.swift — Swiftcn macOS Showcase
// Live demos for the Blocks category — full composed screens.
// ============================================================
import SwiftUI
import Swiftcn

// MARK: - Login

struct LoginBlockDemo: View {
    @State private var lastAction: String?

    var body: some View {
        VStack(spacing: 8) {
            SCLoginBlock(
                onSubmit: { email, _ in lastAction = "Login tapped (\(email.isEmpty ? "no email" : email))" },
                onForgotPassword: { lastAction = "Forgot password tapped" },
                onSignUp: { lastAction = "Sign up tapped" },
                onGoogle: { lastAction = "Login with Google tapped" }
            )
            .frame(height: 560)
            if let lastAction {
                Text(lastAction)
                    .scMuted()
            }
        }
    }
}

// MARK: - Settings

struct SettingsBlockDemo: View {
    @State private var lastAction = "Change a preference or choose an account action."

    var body: some View {
        BlockStage {
            VStack(spacing: 8) {
                SCSettingsBlock(
                    onEditProfile: { lastAction = "Edit profile requested" },
                    onDeleteAccount: { lastAction = "Delete account requested" }
                )
                .frame(height: 640)
                Text(lastAction).scMuted()
            }
        }
    }
}

// MARK: - Sidebar (sidebar-07)

struct SidebarBlockDemo: View {
    @State private var data = SCSidebarBlockData.sidebar07
    @State private var team = "acme-inc"
    @State private var selection = "playground-history"
    @State private var lastAction = "Choose a team, destination, project action, or account action."

    var body: some View {
        BlockStage {
            SCSidebarBlock(
                data: data,
                activeTeamID: $team,
                selection: $selection,
                onAction: handle,
                detail: { selected in
                    VStack(spacing: 12) {
                        Text("Destination: \(selected)").scH3()
                        Text(lastAction).scMuted()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            )
            .frame(minHeight: 600)
        }
    }

    private func handle(_ action: SCSidebarBlockAction) {
        switch action {
        case .addTeam:
            let number = data.teams.count + 1
            let newTeam = SCSidebarTeam(
                id: "new-team-\(number)",
                name: "New Team \(number)",
                plan: "Free",
                systemImage: "person.3"
            )
            data.teams.append(newTeam)
            team = newTeam.id
        case .project(let id, .delete):
            data.projects.removeAll { $0.id == id }
        default:
            break
        }
        lastAction = description(for: action)
    }

    private func description(for action: SCSidebarBlockAction) -> String {
        switch action {
        case .openBreadcrumbRoot: "Opened breadcrumb root"
        case .openOrganization: "Opened organization"
        case .selectTeam(let id): "Selected team: \(id)"
        case .addTeam: "Add team requested"
        case .selectNavigation(let id): "Selected navigation: \(id)"
        case .setNavigationExpanded(let id, let expanded):
            "Navigation \(id): \(expanded ? "expanded" : "collapsed")"
        case .selectProject(let id): "Selected project: \(id)"
        case .project(let id, let action): "Project \(id): \(String(describing: action))"
        case .showMoreProjects: "More projects requested"
        case .selectSecondaryNavigation(let id): "Selected secondary navigation: \(id)"
        case .user(let action): "User action: \(String(describing: action))"
        }
    }
}

// MARK: - Dashboard (dashboard-01)

struct DashboardBlockDemo: View {
    @State private var lastAction = "Use the dashboard navigation, table, chart, or account controls."

    var body: some View {
        BlockStage {
            VStack(spacing: 8) {
                SCDashboard01Block(onAction: { lastAction = String(describing: $0) })
                    .frame(minHeight: 600)
                Text(lastAction).scMuted()
            }
        }
    }
}

// MARK: - Stage

/// Clips a full-screen block into a bordered stage so it reads as an
/// embedded screen rather than bleeding into the page.
private struct BlockStage<Content: View>: View {
    @Environment(\.theme) private var theme

    @ViewBuilder var content: Content

    var body: some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: theme.radius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: theme.radius, style: .continuous)
                    .strokeBorder(theme.border)
            }
    }
}

#Preview("Block · Login") {
    ShowcasePreview(width: 700, height: 760) { LoginBlockDemo() }
}

#Preview("Block · Settings") {
    ShowcasePreview(width: 900, height: 760) { SettingsBlockDemo() }
}

#Preview("Block · Sidebar 07") {
    ShowcasePreview(width: 1100, height: 760) { SidebarBlockDemo() }
}

#Preview("Block · Analytics") {
    ShowcasePreview(width: 1100, height: 760) { DashboardBlockDemo() }
}
