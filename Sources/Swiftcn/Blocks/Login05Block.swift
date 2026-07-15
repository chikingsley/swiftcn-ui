// ============================================================
// Blocks/Login05Block.swift — swiftcn-ui
// Depends on: Theme/ · Field.swift · Input.swift · Button.swift ·
//             Typography.swift · Signup01Block.swift (shared parts) ·
//             Login02Block.swift (sign-up prompt)
//
// Port of shadcn/ui's `login-05` block: a minimal, card-less
// login with a brand mark, an email-only field, Login, an "Or"
// separator, Apple and Google sign-in, and the terms footnote.
// ============================================================
import SwiftUI

// MARK: - Block

/// The swiftcn port of shadcn/ui's `login-05` block. Email state lives
/// inside the block; wire behavior through the required closures. The
/// upstream brand anchor points at "#", so the mark renders as static
/// identity here.
///
///     SCLogin05Block(
///         onSubmit: { email in signIn(email) },
///         onApple: { signInWithApple() },
///         onGoogle: { signInWithGoogle() },
///         onSignUp: { showSignUp() },
///         onTerms: { showTerms() },
///         onPrivacy: { showPrivacy() }
///     )
public struct SCLogin05Block: View {
    @Environment(\.theme) private var theme

    private let onSubmit: (String) -> Void
    private let onApple: () -> Void
    private let onGoogle: () -> Void
    private let onSignUp: () -> Void
    private let onTerms: () -> Void
    private let onPrivacy: () -> Void

    @State private var email = ""

    public init(
        onSubmit: @escaping (String) -> Void,
        onApple: @escaping () -> Void,
        onGoogle: @escaping () -> Void,
        onSignUp: @escaping () -> Void,
        onTerms: @escaping () -> Void,
        onPrivacy: @escaping () -> Void
    ) {
        self.onSubmit = onSubmit
        self.onApple = onApple
        self.onGoogle = onGoogle
        self.onSignUp = onSignUp
        self.onTerms = onTerms
        self.onPrivacy = onPrivacy
    }

    public var body: some View {
        VStack(spacing: 24) {
            SCFieldGroup {
                header
                SCField("Email", required: true) {
                    SCAuthEmailInput(email: $email, onSubmit: submit)
                }
                Button(action: submit) {
                    Text("Login").frame(maxWidth: .infinity)
                }
                .buttonStyle(.sc())
                .disabled(!isSubmissionReady)
                SCFieldSeparator { Text("Or") }
                providers
            }
            SCAuthTermsFootnote(onTerms: onTerms, onPrivacy: onPrivacy)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: 384)
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.background)
    }

    private var isSubmissionReady: Bool {
        SCAuthValidation.email(email)
    }

    private func submit() {
        guard isSubmissionReady else { return }
        onSubmit(email)
    }

    private var header: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: theme.radius - 2, style: .continuous)
                .fill(.clear)
                .frame(width: 32, height: 32)
                .overlay {
                    Image(systemName: "square.stack.3d.up")
                        .font(.system(size: 22, weight: .medium))
                }
                .accessibilityLabel("Acme Inc.")
            Text("Welcome to Acme Inc.")
                .scH3()
            SCLoginSignUpPrompt(onSignUp: onSignUp)
        }
        .frame(maxWidth: .infinity)
    }

    private var providers: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 16) {
                appleButton
                googleButton
            }
            VStack(spacing: 16) {
                appleButton
                googleButton
            }
        }
    }

    private var appleButton: some View {
        Button(action: onApple) {
            Label("Continue with Apple", systemImage: "apple.logo")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.sc(.outline))
    }

    private var googleButton: some View {
        Button(action: onGoogle) {
            Label("Continue with Google", systemImage: "globe")
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.sc(.outline))
    }
}

// MARK: - Previews

#Preview("Login05") {
    @Previewable @State var lastAction = "Submit the form or choose an action."

    SCPreview {
        VStack(spacing: 8) {
            SCLogin05Block(
                onSubmit: { lastAction = "Login: \($0)" },
                onApple: { lastAction = "Continue with Apple" },
                onGoogle: { lastAction = "Continue with Google" },
                onSignUp: { lastAction = "Sign up" },
                onTerms: { lastAction = "Terms of Service" },
                onPrivacy: { lastAction = "Privacy Policy" }
            )
            Text(lastAction).scMuted()
        }
    }
    .frame(height: 640)
}
