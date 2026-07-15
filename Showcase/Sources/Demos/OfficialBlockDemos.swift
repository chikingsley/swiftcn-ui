import SwiftUI
import Swiftcn

// MARK: - Official authentication blocks

struct OfficialAuthBlockDemo: View {
    let blockID: String

    @State private var lastAction = "Use the form or one of its account actions."

    var body: some View {
        VStack(spacing: 8) {
            authBlock
                .frame(minHeight: 620)
            Text(lastAction)
                .scMuted()
        }
    }

    @ViewBuilder
    private var authBlock: some View {
        switch blockID {
        case "login-02":
            SCLogin02Block(
                onSubmit: { email, _ in submitted("Login", email: email) },
                onForgotPassword: { record("Forgot password") },
                onGitHub: { record("Continue with GitHub") },
                onSignUp: { record("Open sign up") }
            )
        case "login-03":
            SCLogin03Block(
                onSubmit: { email, _ in submitted("Login", email: email) },
                onForgotPassword: { record("Forgot password") },
                onApple: { record("Continue with Apple") },
                onGoogle: { record("Continue with Google") },
                onSignUp: { record("Open sign up") },
                onTerms: { record("Open terms") },
                onPrivacy: { record("Open privacy") }
            )
        case "login-04":
            SCLogin04Block(
                onSubmit: { email, _ in submitted("Login", email: email) },
                onForgotPassword: { record("Forgot password") },
                onApple: { record("Continue with Apple") },
                onGoogle: { record("Continue with Google") },
                onMeta: { record("Continue with Meta") },
                onSignUp: { record("Open sign up") },
                onTerms: { record("Open terms") },
                onPrivacy: { record("Open privacy") }
            )
        case "login-05":
            SCLogin05Block(
                onSubmit: { submitted("Login", email: $0) },
                onApple: { record("Continue with Apple") },
                onGoogle: { record("Continue with Google") },
                onSignUp: { record("Open sign up") },
                onTerms: { record("Open terms") },
                onPrivacy: { record("Open privacy") }
            )
        case "signup-01":
            SCSignup01Block(
                onSubmit: { submitted("Create account", email: $0.email) },
                onGoogle: { record("Continue with Google") },
                onSignIn: { record("Open sign in") }
            )
        case "signup-02":
            SCSignup02Block(
                onSubmit: { submitted("Create account", email: $0.email) },
                onGitHub: { record("Continue with GitHub") },
                onSignIn: { record("Open sign in") }
            )
        case "signup-03":
            SCSignup03Block(
                onSubmit: { submitted("Create account", email: $0.email) },
                onSignIn: { record("Open sign in") },
                onTerms: { record("Open terms") },
                onPrivacy: { record("Open privacy") }
            )
        case "signup-04":
            SCSignup04Block(
                onSubmit: { submitted("Create account", email: $0.email) },
                onApple: { record("Continue with Apple") },
                onGoogle: { record("Continue with Google") },
                onMeta: { record("Continue with Meta") },
                onSignIn: { record("Open sign in") },
                onTerms: { record("Open terms") },
                onPrivacy: { record("Open privacy") }
            )
        case "signup-05":
            SCSignup05Block(
                onSubmit: { submitted("Create account", email: $0) },
                onApple: { record("Continue with Apple") },
                onGoogle: { record("Continue with Google") },
                onSignIn: { record("Open sign in") },
                onTerms: { record("Open terms") },
                onPrivacy: { record("Open privacy") }
            )
        default:
            Text("Unknown authentication block: \(blockID)")
        }
    }

    private func submitted(_ action: String, email: String) {
        lastAction = "\(action): \(email.isEmpty ? "no email" : email)"
    }

    private func record(_ action: String) {
        lastAction = action
    }
}

// MARK: - Official sidebar blocks

struct OfficialSidebarBlockDemo: View {
    let blockID: String

    @State private var lastAction = "Use the sidebar controls to exercise this block."

    var body: some View {
        OfficialBlockStage {
            sidebarBlock
                .frame(minHeight: 650)
        }
    }

    @ViewBuilder
    private var sidebarBlock: some View {
        switch blockID {
        case "sidebar-01":
            SCSidebar01Block(
                persistenceKey: nil,
                onAction: { record($0) },
                detail: { destination($0) }
            )
        case "sidebar-02":
            SCSidebar02Block(
                persistenceKey: nil,
                onAction: { record($0) },
                detail: { destination($0) }
            )
        case "sidebar-03":
            SCSidebar03Block(
                persistenceKey: nil,
                onAction: { record($0) },
                detail: { destination($0) }
            )
        case "sidebar-04":
            SCSidebar04Block(
                persistenceKey: nil,
                onAction: { record($0) },
                detail: { destination($0) }
            )
        case "sidebar-05":
            SCSidebar05Block(
                persistenceKey: nil,
                onAction: { record($0) },
                detail: { destination($0) }
            )
        case "sidebar-08":
            SCSidebar08Block(
                persistenceKey: nil,
                onAction: { record($0) },
                detail: { destination($0) }
            )
        case "sidebar-09":
            SCSidebar09Block(
                persistenceKey: nil,
                onAction: { record($0) },
                detail: { folderID, mailID in
                    destination(
                        mailID ?? folderID,
                        context: "Folder: \(folderID)"
                    )
                }
            )
        case "sidebar-10":
            SCSidebar10Block(
                persistenceKey: nil,
                onAction: { record($0) },
                detail: { destination($0) }
            )
        case "sidebar-11":
            SCSidebar11Block(
                persistenceKey: nil,
                onAction: { record($0) },
                detail: { destination($0) }
            )
        case "sidebar-12":
            SCSidebar12Block(
                persistenceKey: nil,
                onAction: { record($0) },
                detail: { date, calendarIDs in
                    destination(
                        date?.formatted(date: .abbreviated, time: .omitted) ?? "No date selected",
                        context: calendarIDs.sorted().joined(separator: ", ")
                    )
                }
            )
        case "sidebar-13":
            SCSidebar13Block(
                defaultPresented: true,
                onAction: { record($0) },
                detail: { destination($0) }
            )
        case "sidebar-14":
            SCSidebar14Block(
                persistenceKey: nil,
                onAction: { record($0) },
                detail: { destination($0) }
            )
        case "sidebar-15":
            SCSidebar15Block(
                leftPersistenceKey: nil,
                onAction: { record($0) },
                detail: { selection, date, calendarIDs in
                    destination(
                        selection,
                        context: sidebar15Context(date: date, calendarIDs: calendarIDs)
                    )
                }
            )
        case "sidebar-16":
            SCSidebar16Block(
                persistenceKey: nil,
                onAction: { record($0) },
                detail: { destination($0) }
            )
        default:
            Text("Unknown sidebar block: \(blockID)")
        }
    }

    private func destination(_ selection: String, context: String? = nil) -> some View {
        VStack(spacing: 12) {
            Text(selection)
                .scH3()
            if let context, !context.isEmpty {
                Text(context)
                    .scMuted()
            }
            Text(lastAction)
                .scMuted()
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func sidebar15Context(date: Date?, calendarIDs: Set<String>) -> String {
        let dateText = date?.formatted(date: .abbreviated, time: .omitted) ?? "No date selected"
        let calendars = calendarIDs.sorted().joined(separator: ", ")
        return calendars.isEmpty ? dateText : "\(dateText) · \(calendars)"
    }

    private func record<Action>(_ action: Action) {
        lastAction = String(describing: action)
    }
}

// MARK: - Shared block stage

private struct OfficialBlockStage<Content: View>: View {
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

#Preview("Official Auth Block") {
    ShowcasePreview(width: 900, height: 760) {
        OfficialAuthBlockDemo(blockID: "login-04")
    }
}

#Preview("Official Sidebar Block") {
    ShowcasePreview(width: 1100, height: 760) {
        OfficialSidebarBlockDemo(blockID: "sidebar-16")
    }
}
