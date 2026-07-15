// ============================================================
// Blocks/Signup04Block.swift — swiftcn-ui
// Depends on: Theme/ · Card.swift · Field.swift · Input.swift ·
//             Button.swift · Typography.swift ·
//             Signup01Block.swift (shared parts)
//
// Port of shadcn/ui's `signup-04` block: a wide split card on a
// muted page — the signup form beside a media panel — with an
// email field, a password/confirm grid, Apple/Google/Meta
// providers, a sign-in prompt, and the terms footnote.
// ============================================================
import SwiftUI

// MARK: - Block

/// The swiftcn port of shadcn/ui's `signup-04` block. Field state lives
/// inside the block; wire behavior through the required closures. The media
/// panel is a builder slot (upstream's placeholder image) and collapses when
/// the split layout does not fit, matching the upstream `md:` breakpoint.
///
///     SCSignup04Block(
///         onSubmit: { details in createAccount(details) },
///         onApple: { signUpWithApple() },
///         onGoogle: { signUpWithGoogle() },
///         onMeta: { signUpWithMeta() },
///         onSignIn: { showLogin() },
///         onTerms: { showTerms() },
///         onPrivacy: { showPrivacy() }
///     )
public struct SCSignup04Block<Media: View>: View {
    @Environment(\.theme) private var theme

    private let onSubmit: (SCSignupDetails) -> Void
    private let onApple: () -> Void
    private let onGoogle: () -> Void
    private let onMeta: () -> Void
    private let onSignIn: () -> Void
    private let onTerms: () -> Void
    private let onPrivacy: () -> Void
    private let media: Media

    @State private var details = SCSignupDetails()

    public init(
        onSubmit: @escaping (SCSignupDetails) -> Void,
        onApple: @escaping () -> Void,
        onGoogle: @escaping () -> Void,
        onMeta: @escaping () -> Void,
        onSignIn: @escaping () -> Void,
        onTerms: @escaping () -> Void,
        onPrivacy: @escaping () -> Void,
        @ViewBuilder media: () -> Media
    ) {
        self.onSubmit = onSubmit
        self.onApple = onApple
        self.onGoogle = onGoogle
        self.onMeta = onMeta
        self.onSignIn = onSignIn
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
                Text("Create your account").scH3()
                Text("Enter your email below to create your account").scMuted()
            }
            .frame(maxWidth: .infinity)
            SCField(
                "Email",
                required: true,
                description: "We'll use this to contact you. We will not share your email with anyone else."
            ) {
                SCAuthEmailInput(email: $details.email)
            }
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top, spacing: 16) {
                    SCField("Password", required: true) {
                        SCInput("Password", text: $details.password, secure: true)
                    }
                    SCField("Confirm Password", required: true) {
                        SCInput(
                            "Confirm Password",
                            text: $details.confirmPassword,
                            secure: true,
                            onSubmit: submit
                        )
                    }
                }
                SCFieldDescription {
                    Text("Must be at least 8 characters long.")
                }
            }
            Button(action: submit) {
                Text("Create Account").frame(maxWidth: .infinity)
            }
            .buttonStyle(.sc())
            .disabled(!isSubmissionReady)
            SCFieldSeparator { Text("Or continue with") }
            HStack(spacing: 16) {
                providerButton("Sign up with Apple", systemImage: "apple.logo", action: onApple)
                providerButton("Sign up with Google", systemImage: "globe", action: onGoogle)
                providerButton("Sign up with Meta", systemImage: "infinity", action: onMeta)
            }
            SCSignupSignInPrompt(onSignIn: onSignIn)
                .frame(maxWidth: .infinity)
        }
    }

    private var isSubmissionReady: Bool {
        SCAuthValidation.signup(details, requiresName: false)
    }

    private func submit() {
        guard isSubmissionReady else { return }
        onSubmit(details)
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

extension SCSignup04Block where Media == SCAuthMediaPlaceholder {
    public init(
        onSubmit: @escaping (SCSignupDetails) -> Void,
        onApple: @escaping () -> Void,
        onGoogle: @escaping () -> Void,
        onMeta: @escaping () -> Void,
        onSignIn: @escaping () -> Void,
        onTerms: @escaping () -> Void,
        onPrivacy: @escaping () -> Void
    ) {
        self.init(
            onSubmit: onSubmit,
            onApple: onApple,
            onGoogle: onGoogle,
            onMeta: onMeta,
            onSignIn: onSignIn,
            onTerms: onTerms,
            onPrivacy: onPrivacy,
            media: { SCAuthMediaPlaceholder() }
        )
    }
}

// MARK: - Media placeholder

/// The muted media panel standing in for the upstream `/placeholder.svg`
/// image in the split auth blocks. Replace it through the block's `media`
/// builder.
public struct SCAuthMediaPlaceholder: View {
    @Environment(\.theme) private var theme

    public init() {}

    public var body: some View {
        theme.muted
            .overlay {
                Image(systemName: "photo")
                    .font(.system(size: 32))
                    .foregroundStyle(theme.mutedForeground.opacity(0.5))
            }
            .accessibilityHidden(true)
    }
}

// MARK: - Previews

#Preview("Signup04") {
    @Previewable @State var lastAction = "Submit the form or choose an action."

    SCPreview {
        VStack(spacing: 8) {
            SCSignup04Block(
                onSubmit: { lastAction = "Create account: \($0.email)" },
                onApple: { lastAction = "Apple" },
                onGoogle: { lastAction = "Google" },
                onMeta: { lastAction = "Meta" },
                onSignIn: { lastAction = "Sign in" },
                onTerms: { lastAction = "Terms of Service" },
                onPrivacy: { lastAction = "Privacy Policy" }
            )
            .frame(width: 980, height: 700)
            Text(lastAction).scMuted()
        }
    }
}
