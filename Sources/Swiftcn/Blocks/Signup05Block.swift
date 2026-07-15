// ============================================================
// Blocks/Signup05Block.swift — swiftcn-ui
// Depends on: Theme/ · Field.swift · Input.swift · Button.swift ·
//             Typography.swift · Signup01Block.swift (shared parts)
//
// Port of shadcn/ui's `signup-05` block: a minimal, card-less
// signup with a brand mark, an email-only field, Create Account,
// an "Or" separator, Apple and Google sign-up, and the terms
// footnote.
// ============================================================
import SwiftUI

// MARK: - Block

/// The swiftcn port of shadcn/ui's `signup-05` block. Email state lives
/// inside the block; wire behavior through the required closures. The
/// upstream brand anchor points at "#", so the mark renders as static
/// identity here; wrap the block header in your own control if the brand
/// should navigate.
///
///     SCSignup05Block(
///         onSubmit: { email in createAccount(email) },
///         onApple: { signUpWithApple() },
///         onGoogle: { signUpWithGoogle() },
///         onSignIn: { showLogin() },
///         onTerms: { showTerms() },
///         onPrivacy: { showPrivacy() }
///     )
public struct SCSignup05Block: View {
    @Environment(\.theme) private var theme

    private let onSubmit: (String) -> Void
    private let onApple: () -> Void
    private let onGoogle: () -> Void
    private let onSignIn: () -> Void
    private let onTerms: () -> Void
    private let onPrivacy: () -> Void

    @State private var email = ""

    /// Creates the signup screen.
    /// - Parameters:
    ///   - onSubmit: Called with the entered email when Create Account is tapped.
    ///   - onApple: Called when "Continue with Apple" is tapped.
    ///   - onGoogle: Called when "Continue with Google" is tapped.
    ///   - onSignIn: Called when "Sign in" is tapped.
    ///   - onTerms: Called when "Terms of Service" is tapped.
    ///   - onPrivacy: Called when "Privacy Policy" is tapped.
    public init(
        onSubmit: @escaping (String) -> Void,
        onApple: @escaping () -> Void,
        onGoogle: @escaping () -> Void,
        onSignIn: @escaping () -> Void,
        onTerms: @escaping () -> Void,
        onPrivacy: @escaping () -> Void
    ) {
        self.onSubmit = onSubmit
        self.onApple = onApple
        self.onGoogle = onGoogle
        self.onSignIn = onSignIn
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
                    Text("Create Account").frame(maxWidth: .infinity)
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
            SCSignupSignInPrompt(onSignIn: onSignIn)
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

#Preview("Signup05") {
    @Previewable @State var lastAction = "Submit the form or choose an action."

    SCPreview {
        VStack(spacing: 8) {
            SCSignup05Block(
                onSubmit: { lastAction = "Create account: \($0)" },
                onApple: { lastAction = "Continue with Apple" },
                onGoogle: { lastAction = "Continue with Google" },
                onSignIn: { lastAction = "Sign in" },
                onTerms: { lastAction = "Terms of Service" },
                onPrivacy: { lastAction = "Privacy Policy" }
            )
            Text(lastAction).scMuted()
        }
    }
    .frame(height: 640)
}
