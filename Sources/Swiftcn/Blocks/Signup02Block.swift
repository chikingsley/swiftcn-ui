// ============================================================
// Blocks/Signup02Block.swift — swiftcn-ui
// Depends on: Theme/ · Field.swift · Input.swift · Button.swift ·
//             Typography.swift · Signup01Block.swift (shared parts) ·
//             Signup04Block.swift (media placeholder)
//
// Port of shadcn/ui's `signup-02` block: a two-column page — a
// brand row and card-less signup form on the left, a media panel
// on the right — with full name, email, password, and confirm
// fields, Create Account, and GitHub sign-up.
// ============================================================
import SwiftUI

// MARK: - Block

/// The swiftcn port of shadcn/ui's `signup-02` block. Field state lives
/// inside the block; wire behavior through the required closures. The media
/// panel is a builder slot (upstream's placeholder image) and collapses when
/// the two-column layout does not fit, matching the upstream `lg:`
/// breakpoint. The upstream brand anchor points at "#", so the mark renders
/// as static identity here.
///
///     SCSignup02Block(
///         onSubmit: { details in createAccount(details) },
///         onGitHub: { signUpWithGitHub() },
///         onSignIn: { showLogin() }
///     )
public struct SCSignup02Block<Media: View>: View {
    @Environment(\.theme) private var theme

    private let onSubmit: (SCSignupDetails) -> Void
    private let onGitHub: () -> Void
    private let onSignIn: () -> Void
    private let media: Media

    @State private var details = SCSignupDetails()

    public init(
        onSubmit: @escaping (SCSignupDetails) -> Void,
        onGitHub: @escaping () -> Void,
        onSignIn: @escaping () -> Void,
        @ViewBuilder media: () -> Media
    ) {
        self.onSubmit = onSubmit
        self.onGitHub = onGitHub
        self.onSignIn = onSignIn
        self.media = media()
    }

    public var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 0) {
                formColumn
                    .frame(minWidth: 420, maxWidth: .infinity)
                media
                    .frame(minWidth: 380, maxWidth: .infinity, maxHeight: .infinity)
                    .clipped()
            }
            formColumn
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.background)
    }

    private var formColumn: some View {
        VStack(spacing: 16) {
            brandRow
                .frame(maxWidth: .infinity, alignment: .leading)
            Spacer(minLength: 0)
            form
                .frame(maxWidth: 320)
            Spacer(minLength: 0)
        }
        .padding(24)
    }

    private var brandRow: some View {
        HStack(spacing: 8) {
            RoundedRectangle(cornerRadius: theme.radius - 2, style: .continuous)
                .fill(theme.primary)
                .frame(width: 24, height: 24)
                .overlay {
                    Image(systemName: "square.stack.3d.up")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(theme.primaryForeground)
                }
            Text("Acme Inc.")
                .font(.subheadline.weight(.medium))
        }
        .accessibilityElement(children: .combine)
    }

    private var form: some View {
        SCFieldGroup {
            VStack(spacing: 4) {
                Text("Create your account").scH3()
                Text("Fill in the form below to create your account")
                    .scMuted()
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            SCField("Full Name", required: true) {
                SCInput("John Doe", text: $details.name)
            }
            SCField(
                "Email",
                required: true,
                description: "We'll use this to contact you. We will not share your email with anyone else."
            ) {
                SCAuthEmailInput(email: $details.email)
            }
            SCField("Password", required: true, description: "Must be at least 8 characters long.") {
                SCInput("Password", text: $details.password, secure: true)
            }
            SCField("Confirm Password", required: true, description: "Please confirm your password.") {
                SCInput("Confirm Password", text: $details.confirmPassword, secure: true, onSubmit: submit)
            }
            Button(action: submit) {
                Text("Create Account").frame(maxWidth: .infinity)
            }
            .buttonStyle(.sc())
            .disabled(!isSubmissionReady)
            SCFieldSeparator { Text("Or continue with") }
            VStack(spacing: 12) {
                Button(action: onGitHub) {
                    Label("Sign up with GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.sc(.outline))
                SCSignupSignInPrompt(onSignIn: onSignIn)
                    .frame(maxWidth: .infinity)
            }
        }
    }

    private var isSubmissionReady: Bool {
        SCAuthValidation.signup(details, requiresName: true)
    }

    private func submit() {
        guard isSubmissionReady else { return }
        onSubmit(details)
    }
}

extension SCSignup02Block where Media == SCAuthMediaPlaceholder {
    public init(
        onSubmit: @escaping (SCSignupDetails) -> Void,
        onGitHub: @escaping () -> Void,
        onSignIn: @escaping () -> Void
    ) {
        self.init(
            onSubmit: onSubmit,
            onGitHub: onGitHub,
            onSignIn: onSignIn,
            media: { SCAuthMediaPlaceholder() }
        )
    }
}

// MARK: - Previews

#Preview("Signup02") {
    @Previewable @State var lastAction = "Submit the form or choose an action."

    SCPreview {
        VStack(spacing: 8) {
            SCSignup02Block(
                onSubmit: { lastAction = "Create account: \($0.email)" },
                onGitHub: { lastAction = "Sign up with GitHub" },
                onSignIn: { lastAction = "Sign in" }
            )
            .frame(width: 1000, height: 720)
            Text(lastAction).scMuted()
        }
    }
}
