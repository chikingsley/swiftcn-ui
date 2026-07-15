// ============================================================
// Blocks/Login04Block.swift — swiftcn-ui
// Depends on: Theme/ · Field.swift · Input.swift · Button.swift ·
//             Typography.swift · Signup01Block.swift (shared parts) ·
//             Signup04Block.swift (media placeholder) ·
//             Login02Block.swift (shared login parts)
//
// Port of shadcn/ui's `login-04` block: a wide split card on a
// muted page — the login form beside a media panel — with email
// and password fields, a forgot-password link, Login,
// Apple/Google/Meta providers, a sign-up prompt, and the terms
// footnote.
// ============================================================
import SwiftUI

// MARK: - Block

/// The swiftcn port of shadcn/ui's `login-04` block. Field state lives
/// inside the block; wire behavior through the required closures. The media
/// panel is a builder slot (upstream's placeholder image) and collapses when
/// the split layout does not fit, matching the upstream `md:` breakpoint.
///
///     SCLogin04Block(
///         onSubmit: { email, password in signIn(email, password) },
///         onForgotPassword: { showReset() },
///         onApple: { signInWithApple() },
///         onGoogle: { signInWithGoogle() },
///         onMeta: { signInWithMeta() },
///         onSignUp: { showSignUp() },
///         onTerms: { showTerms() },
///         onPrivacy: { showPrivacy() }
///     )
public struct SCLogin04Block<Media: View>: View {
    @Environment(\.theme) private var theme

    private let onSubmit: (String, String) -> Void
    private let onForgotPassword: () -> Void
    private let onApple: () -> Void
    private let onGoogle: () -> Void
    private let onMeta: () -> Void
    private let onSignUp: () -> Void
    private let onTerms: () -> Void
    private let onPrivacy: () -> Void
    private let media: Media

    @State private var email = ""
    @State private var password = ""

    public init(
        onSubmit: @escaping (String, String) -> Void,
        onForgotPassword: @escaping () -> Void,
        onApple: @escaping () -> Void,
        onGoogle: @escaping () -> Void,
        onMeta: @escaping () -> Void,
        onSignUp: @escaping () -> Void,
        onTerms: @escaping () -> Void,
        onPrivacy: @escaping () -> Void,
        @ViewBuilder media: () -> Media
    ) {
        self.onSubmit = onSubmit
        self.onForgotPassword = onForgotPassword
        self.onApple = onApple
        self.onGoogle = onGoogle
        self.onMeta = onMeta
        self.onSignUp = onSignUp
        self.onTerms = onTerms
        self.onPrivacy = onPrivacy
        self.media = media()
    }

    public var body: some View {
        VStack(spacing: 24) {
            splitCard
            SCAuthTermsFootnote(onTerms: onTerms, onPrivacy: onPrivacy)
                .padding(.horizontal, 24)
        }
        .frame(maxWidth: 896)
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.muted)
    }

    /// Draws Card chrome directly (same tokens as `SCCard`) because the
    /// upstream card is `p-0` with the media panel flush to its edge, which
    /// `SCCard`'s fixed region insets cannot express.
    private var splitCard: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: 0) {
                form
                    .padding(32)
                    .frame(minWidth: 360, maxWidth: .infinity)
                media
                    .frame(minWidth: 300, maxWidth: .infinity, maxHeight: .infinity)
            }
            .fixedSize(horizontal: false, vertical: true)
            form
                .padding(24)
        }
        .foregroundStyle(theme.cardForeground)
        .background(theme.card, in: cardShape)
        .clipShape(cardShape)
        .overlay { cardShape.strokeBorder(theme.border) }
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.radius + 2, style: .continuous)
    }

    private var form: some View {
        SCFieldGroup {
            VStack(spacing: 4) {
                Text("Welcome back").scH3()
                Text("Login to your Acme Inc account").scMuted()
            }
            .frame(maxWidth: .infinity)
            SCField("Email", required: true) {
                SCAuthEmailInput(email: $email)
            }
            SCLoginPasswordRow(
                password: $password,
                onForgotPassword: onForgotPassword,
                onSubmit: submit
            )
            Button(action: submit) {
                Text("Login").frame(maxWidth: .infinity)
            }
            .buttonStyle(.sc())
            .disabled(!isSubmissionReady)
            SCFieldSeparator { Text("Or continue with") }
            HStack(spacing: 16) {
                providerButton("Login with Apple", systemImage: "apple.logo", action: onApple)
                providerButton("Login with Google", systemImage: "globe", action: onGoogle)
                providerButton("Login with Meta", systemImage: "infinity", action: onMeta)
            }
            SCLoginSignUpPrompt(onSignUp: onSignUp)
                .frame(maxWidth: .infinity)
        }
    }

    private var isSubmissionReady: Bool {
        SCAuthValidation.login(email: email, password: password)
    }

    private func submit() {
        guard isSubmissionReady else { return }
        onSubmit(email, password)
    }

    private func providerButton(
        _ accessibilityLabel: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .frame(maxWidth: .infinity)
        }
        .buttonStyle(.sc(.outline))
        .accessibilityLabel(accessibilityLabel)
    }
}

extension SCLogin04Block where Media == SCAuthMediaPlaceholder {
    public init(
        onSubmit: @escaping (String, String) -> Void,
        onForgotPassword: @escaping () -> Void,
        onApple: @escaping () -> Void,
        onGoogle: @escaping () -> Void,
        onMeta: @escaping () -> Void,
        onSignUp: @escaping () -> Void,
        onTerms: @escaping () -> Void,
        onPrivacy: @escaping () -> Void
    ) {
        self.init(
            onSubmit: onSubmit,
            onForgotPassword: onForgotPassword,
            onApple: onApple,
            onGoogle: onGoogle,
            onMeta: onMeta,
            onSignUp: onSignUp,
            onTerms: onTerms,
            onPrivacy: onPrivacy,
            media: { SCAuthMediaPlaceholder() }
        )
    }
}

// MARK: - Previews

#Preview("Login04") {
    @Previewable @State var lastAction = "Submit the form or choose an action."

    SCPreview {
        VStack(spacing: 8) {
            SCLogin04Block(
                onSubmit: { email, _ in lastAction = "Login: \(email)" },
                onForgotPassword: { lastAction = "Forgot password" },
                onApple: { lastAction = "Apple" },
                onGoogle: { lastAction = "Google" },
                onMeta: { lastAction = "Meta" },
                onSignUp: { lastAction = "Sign up" },
                onTerms: { lastAction = "Terms of Service" },
                onPrivacy: { lastAction = "Privacy Policy" }
            )
            .frame(width: 980, height: 640)
            Text(lastAction).scMuted()
        }
    }
}
