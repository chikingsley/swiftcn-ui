// ============================================================
// Blocks/Signup03Block.swift — swiftcn-ui
// Depends on: Theme/ · Card.swift · Field.swift · Input.swift ·
//             Button.swift · Typography.swift ·
//             Signup01Block.swift (shared parts)
//
// Port of shadcn/ui's `signup-03` block: a brand row above a
// centered card on a muted page — full name, email, a
// password/confirm grid, Create Account, a sign-in prompt, and
// the terms footnote.
// ============================================================
import SwiftUI

// MARK: - Block

/// The swiftcn port of shadcn/ui's `signup-03` block. Field state lives
/// inside the block; wire behavior through the required closures. The
/// upstream brand anchor points at "#", so the mark renders as static
/// identity here.
///
///     SCSignup03Block(
///         onSubmit: { details in createAccount(details) },
///         onSignIn: { showLogin() },
///         onTerms: { showTerms() },
///         onPrivacy: { showPrivacy() }
///     )
public struct SCSignup03Block: View {
    @Environment(\.theme) private var theme

    private let onSubmit: (SCSignupDetails) -> Void
    private let onSignIn: () -> Void
    private let onTerms: () -> Void
    private let onPrivacy: () -> Void

    @State private var details = SCSignupDetails()

    public init(
        onSubmit: @escaping (SCSignupDetails) -> Void,
        onSignIn: @escaping () -> Void,
        onTerms: @escaping () -> Void,
        onPrivacy: @escaping () -> Void
    ) {
        self.onSubmit = onSubmit
        self.onSignIn = onSignIn
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
                    SCCardTitle("Create your account")
                    SCCardDescription("Enter your email below to create your account")
                }
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
            }
            SCCardContent {
                SCFieldGroup {
                    SCField("Full Name", required: true) {
                        SCInput("John Doe", text: $details.name)
                    }
                    SCField("Email", required: true) {
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
                    VStack(spacing: 12) {
                        Button(action: submit) {
                            Text("Create Account").frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.sc())
                        .disabled(!isSubmissionReady)
                        SCSignupSignInPrompt(onSignIn: onSignIn)
                            .frame(maxWidth: .infinity)
                    }
                }
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

// MARK: - Previews

#Preview("Signup03") {
    @Previewable @State var lastAction = "Submit the form or choose an action."

    SCPreview {
        VStack(spacing: 8) {
            SCSignup03Block(
                onSubmit: { lastAction = "Create account: \($0.email)" },
                onSignIn: { lastAction = "Sign in" },
                onTerms: { lastAction = "Terms of Service" },
                onPrivacy: { lastAction = "Privacy Policy" }
            )
            Text(lastAction).scMuted()
        }
    }
    .frame(height: 780)
}
