// ============================================================
// BlockDemos.swift — Swiftcn Showcase
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
                onApple: { lastAction = "Login with Apple tapped" },
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
    var body: some View {
        BlockStage {
            SCSettingsBlock()
                .frame(height: 640)
        }
    }
}

// MARK: - Sidebar (sidebar-07)

struct SidebarBlockDemo: View {
    var body: some View {
        BlockStage {
            SCSidebarBlock()
                .frame(minHeight: 600)
        }
    }
}

// MARK: - Dashboard (dashboard-01)

struct DashboardBlockDemo: View {
    var body: some View {
        BlockStage {
            SCDashboardBlock()
                .frame(minHeight: 600)
        }
    }
}

// MARK: - Chat (chat-01)

struct ChatBlockDemo: View {
    var body: some View {
        BlockStage {
            SCChatBlock()
                .frame(minHeight: 600)
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
