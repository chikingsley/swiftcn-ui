// ============================================================
// Blocks/LoginBlock.swift — swiftcn-ui
// Depends on: Theme/ · Card.swift · Field.swift · Input.swift ·
//             Label.swift · Button.swift · Typography.swift ·
//             Signup01Block.swift (shared email input)
// ============================================================
import SwiftUI

// MARK: - Block

/// A complete login screen — the swiftcn port of shadcn/ui's `login-01`
/// block. A centered card with email + password fields, a primary Login
/// action, social sign-in, and a sign-up prompt. Email and password state
/// live inside the block; wire up behavior through the required closures.
///
///     SCLoginBlock(
///         onSubmit: { email, password in signIn(email, password) },
///         onForgotPassword: { showReset() },
///         onSignUp: { showSignUp() },
///         onGoogle: { signInWithGoogle() }
///     )
public struct SCLoginBlock: View {
    @Environment(\.theme) private var theme

    private let onSubmit: (String, String) -> Void
    private let onForgotPassword: () -> Void
    private let onSignUp: () -> Void
    private let onGoogle: () -> Void

    @State private var email = ""
    @State private var password = ""

    /// Creates a login screen.
    /// - Parameters:
    ///   - onSubmit: Called with `(email, password)` when Login is tapped.
    ///   - onForgotPassword: Called when "Forgot your password?" is tapped.
    ///   - onSignUp: Called when "Sign up" is tapped.
    ///   - onGoogle: Called when "Login with Google" is tapped.
    public init(
        onSubmit: @escaping (String, String) -> Void,
        onForgotPassword: @escaping () -> Void,
        onSignUp: @escaping () -> Void,
        onGoogle: @escaping () -> Void
    ) {
        self.onSubmit = onSubmit
        self.onForgotPassword = onForgotPassword
        self.onSignUp = onSignUp
        self.onGoogle = onGoogle
    }

    public var body: some View {
        card
            .frame(maxWidth: 384)
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.background)
    }

    // MARK: Card

    private var card: some View {
        SCCard {
            SCCardHeader {
                SCCardTitle("Login to your account")
                SCCardDescription("Enter your email below to login to your account")
            }
            SCCardContent {
                VStack(spacing: 16) {
                    SCField("Email", required: true) {
                        emailInput
                    }
                    passwordField
                    actions
                }
            }
        }
    }

    // MARK: Fields

    private var emailInput: some View {
        SCAuthEmailInput(email: $email)
    }

    /// `SCField` composes its own label with no trailing accessory slot, so
    /// this row rebuilds the field anatomy by hand (same 6pt rhythm) to fit
    /// the "Forgot your password?" link beside the label.
    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                SCLabel("Password", required: true)
                Spacer()
                Button("Forgot your password?", action: onForgotPassword)
                    .buttonStyle(.sc(.link, size: .sm))
                    .padding(.trailing, -12)  // cancel style inset so text meets the field edge
            }
            SCInput("Password", text: $password, secure: true, onSubmit: submit)
        }
    }

    // MARK: Actions

    private var actions: some View {
        VStack(spacing: 12) {
            Button(action: submit) {
                Text("Login")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.sc())
            .disabled(!isSubmissionReady)

            Button(action: onGoogle) {
                Label("Login with Google", systemImage: "globe")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.sc(.outline))

            signUpPrompt.frame(maxWidth: .infinity)
        }
    }

    private var isSubmissionReady: Bool {
        SCAuthValidation.login(email: email, password: password)
    }

    private func submit() {
        guard isSubmissionReady else { return }
        onSubmit(email, password)
    }

    private var signUpPrompt: some View {
        HStack(spacing: 4) {
            Text("Don't have an account?")
                .scMuted()
            Button(action: onSignUp) {
                Text("Sign up")
                    .font(.footnote.weight(.medium))
                    .underline()
                    .foregroundStyle(theme.foreground)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Previews

#Preview("Login") {
    @Previewable @State var lastAction = "Submit the form or choose an account action."

    SCPreview {
        VStack(spacing: 8) {
            SCLoginBlock(
                onSubmit: { email, _ in lastAction = "Login: \(email)" },
                onForgotPassword: { lastAction = "Forgot password" },
                onSignUp: { lastAction = "Sign up" },
                onGoogle: { lastAction = "Sign in with Google" }
            )
            Text(lastAction).scMuted()
        }
    }
}

#Preview("Login · with Google") {
    @Previewable @State var lastAction = "Choose a login method."

    SCPreview {
        VStack(spacing: 8) {
            SCLoginBlock(
                onSubmit: { _, _ in lastAction = "Login" },
                onForgotPassword: { lastAction = "Forgot password" },
                onSignUp: { lastAction = "Sign up" },
                onGoogle: { lastAction = "Google" }
            )
            Text(lastAction).scMuted()
        }
    }
}
