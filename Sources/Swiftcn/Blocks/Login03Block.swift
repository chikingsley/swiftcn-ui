// ============================================================
// Blocks/Login03Block.swift — swiftcn-ui
// Depends on: Theme/ · Card.swift · Field.swift · Input.swift ·
//             Button.swift · Typography.swift ·
//             Signup01Block.swift (shared parts) ·
//             Login02Block.swift (shared login parts)
//
// Port of shadcn/ui's `login-03` block: a brand row above a
// centered card on a muted page — Apple/Google sign-in first,
// then email and password with a forgot-password link, Login, a
// sign-up prompt, and the terms footnote.
// ============================================================
import SwiftUI

// MARK: - Block

/// The swiftcn port of shadcn/ui's `login-03` block. Field state lives
/// inside the block; wire behavior through the required closures. The
/// upstream brand anchor points at "#", so the mark renders as static
/// identity here.
///
///     SCLogin03Block(
///         onSubmit: { email, password in signIn(email, password) },
///         onForgotPassword: { showReset() },
///         onApple: { signInWithApple() },
///         onGoogle: { signInWithGoogle() },
///         onSignUp: { showSignUp() },
///         onTerms: { showTerms() },
///         onPrivacy: { showPrivacy() }
///     )
public struct SCLogin03Block: View {
    @Environment(\.theme) private var theme

    private let onSubmit: (String, String) -> Void
    private let onForgotPassword: () -> Void
    private let onApple: () -> Void
    private let onGoogle: () -> Void
    private let onSignUp: () -> Void
    private let onTerms: () -> Void
    private let onPrivacy: () -> Void

    @State private var email = ""
    @State private var password = ""

    public init(
        onSubmit: @escaping (String, String) -> Void,
        onForgotPassword: @escaping () -> Void,
        onApple: @escaping () -> Void,
        onGoogle: @escaping () -> Void,
        onSignUp: @escaping () -> Void,
        onTerms: @escaping () -> Void,
        onPrivacy: @escaping () -> Void
    ) {
        self.onSubmit = onSubmit
        self.onForgotPassword = onForgotPassword
        self.onApple = onApple
        self.onGoogle = onGoogle
        self.onSignUp = onSignUp
        self.onTerms = onTerms
        self.onPrivacy = onPrivacy
    }

    public var body: some View {
        VStack(spacing: 24) {
            brandRow
            card
            SCAuthTermsFootnote(onTerms: onTerms, onPrivacy: onPrivacy)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: 384)
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.muted)
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

    private var card: some View {
        SCCard {
            SCCardHeader {
                VStack(spacing: 4) {
                    SCCardTitle("Welcome back")
                    SCCardDescription("Login with your Apple or Google account")
                }
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
            }
            SCCardContent {
                SCFieldGroup {
                    VStack(spacing: 12) {
                        Button(action: onApple) {
                            Label("Login with Apple", systemImage: "apple.logo")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.sc(.outline))
                        Button(action: onGoogle) {
                            Label("Login with Google", systemImage: "globe")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.sc(.outline))
                    }
                    SCFieldSeparator { Text("Or continue with") }
                    SCField("Email", required: true) {
                        SCAuthEmailInput(email: $email)
                    }
                    SCLoginPasswordRow(
                        password: $password,
                        onForgotPassword: onForgotPassword,
                        onSubmit: submit
                    )
                    VStack(spacing: 12) {
                        Button(action: submit) {
                            Text("Login").frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.sc())
                        .disabled(!isSubmissionReady)
                        SCLoginSignUpPrompt(onSignUp: onSignUp)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }

    private var isSubmissionReady: Bool {
        SCAuthValidation.login(email: email, password: password)
    }

    private func submit() {
        guard isSubmissionReady else { return }
        onSubmit(email, password)
    }
}

// MARK: - Previews

#Preview("Login03") {
    @Previewable @State var lastAction = "Submit the form or choose an action."

    SCPreview {
        VStack(spacing: 8) {
            SCLogin03Block(
                onSubmit: { email, _ in lastAction = "Login: \(email)" },
                onForgotPassword: { lastAction = "Forgot password" },
                onApple: { lastAction = "Login with Apple" },
                onGoogle: { lastAction = "Login with Google" },
                onSignUp: { lastAction = "Sign up" },
                onTerms: { lastAction = "Terms of Service" },
                onPrivacy: { lastAction = "Privacy Policy" }
            )
            Text(lastAction).scMuted()
        }
    }
    .frame(height: 780)
}
