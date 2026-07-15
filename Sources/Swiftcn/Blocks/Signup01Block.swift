// ============================================================
// Blocks/Signup01Block.swift — swiftcn-ui
// Depends on: Theme/ · Card.swift · Field.swift · Input.swift ·
//             Button.swift · Typography.swift
//
// Port of shadcn/ui's `signup-01` block: a centered card with
// full name, email, password, and confirm-password fields, a
// Create Account action, Google sign-up, and a sign-in prompt.
// ============================================================
import SwiftUI

// MARK: - Submission

/// The values a signup block hands to its `onSubmit` closure. Blocks without
/// a given field submit it as an empty string.
public struct SCSignupDetails: Hashable, Sendable {
    public var name: String
    public var email: String
    public var password: String
    public var confirmPassword: String

    public init(
        name: String = "",
        email: String = "",
        password: String = "",
        confirmPassword: String = ""
    ) {
        self.name = name
        self.email = email
        self.password = password
        self.confirmPassword = confirmPassword
    }
}

enum SCAuthValidation {
    static func email(_ email: String) -> Bool {
        let email = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let parts = email.split(separator: "@", omittingEmptySubsequences: false)
        return parts.count == 2
            && parts.allSatisfy { !$0.isEmpty }
            && email.rangeOfCharacter(from: .whitespacesAndNewlines) == nil
    }

    static func login(email: String, password: String) -> Bool {
        self.email(email) && hasText(password)
    }

    static func signup(_ details: SCSignupDetails, requiresName: Bool) -> Bool {
        (!requiresName || hasText(details.name))
            && email(details.email)
            && hasText(details.password)
            && hasText(details.confirmPassword)
    }

    private static func hasText(_ value: String) -> Bool {
        !value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

// MARK: - Block

/// The swiftcn port of shadcn/ui's `signup-01` block. Field state lives
/// inside the block; wire behavior through the required closures.
///
///     SCSignup01Block(
///         onSubmit: { details in createAccount(details) },
///         onGoogle: { signUpWithGoogle() },
///         onSignIn: { showLogin() }
///     )
public struct SCSignup01Block: View {
    @Environment(\.theme) private var theme

    private let onSubmit: (SCSignupDetails) -> Void
    private let onGoogle: () -> Void
    private let onSignIn: () -> Void

    @State private var details = SCSignupDetails()

    /// Creates the signup screen.
    /// - Parameters:
    ///   - onSubmit: Called with the entered details when Create Account is tapped.
    ///   - onGoogle: Called when "Sign up with Google" is tapped.
    ///   - onSignIn: Called when "Sign in" is tapped.
    public init(
        onSubmit: @escaping (SCSignupDetails) -> Void,
        onGoogle: @escaping () -> Void,
        onSignIn: @escaping () -> Void
    ) {
        self.onSubmit = onSubmit
        self.onGoogle = onGoogle
        self.onSignIn = onSignIn
    }

    public var body: some View {
        card
            .frame(maxWidth: 384)
            .padding(24)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.background)
    }

    private var card: some View {
        SCCard {
            SCCardHeader {
                SCCardTitle("Create an account")
                SCCardDescription("Enter your information below to create your account")
            }
            SCCardContent {
                SCFieldGroup {
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
                    VStack(spacing: 12) {
                        Button(action: submit) {
                            Text("Create Account").frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.sc())
                        .disabled(!isSubmissionReady)
                        Button(action: onGoogle) {
                            Label("Sign up with Google", systemImage: "globe")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.sc(.outline))
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

// MARK: - Shared signup parts

/// The email input every signup block uses: email keyboard intent, no
/// autocorrection or capitalization.
public struct SCAuthEmailInput: View {
    @Binding private var email: String
    private let onSubmit: (() -> Void)?

    public init(email: Binding<String>, onSubmit: (() -> Void)? = nil) {
        self._email = email
        self.onSubmit = onSubmit
    }

    public var body: some View {
        let input = SCInput("m@example.com", text: $email, kind: .email, onSubmit: onSubmit)
            .autocorrectionDisabled()
        #if os(iOS)
            input.textInputAutocapitalization(.never)
        #else
            input
        #endif
    }
}

/// "Already have an account? Sign in" — the sign-in prompt shared by the
/// signup blocks.
public struct SCSignupSignInPrompt: View {
    @Environment(\.theme) private var theme

    private let onSignIn: () -> Void

    public init(onSignIn: @escaping () -> Void) {
        self.onSignIn = onSignIn
    }

    public var body: some View {
        HStack(spacing: 4) {
            Text("Already have an account?")
                .scMuted()
            Button(action: onSignIn) {
                Text("Sign in")
                    .font(.footnote.weight(.medium))
                    .underline()
                    .foregroundStyle(theme.foreground)
            }
            .buttonStyle(.plain)
        }
    }
}

/// "By clicking continue, you agree to our Terms of Service and Privacy
/// Policy." — the terms footnote shared by the signup blocks that show it.
public struct SCAuthTermsFootnote: View {
    @Environment(\.theme) private var theme

    private let onTerms: () -> Void
    private let onPrivacy: () -> Void

    public init(onTerms: @escaping () -> Void, onPrivacy: @escaping () -> Void) {
        self.onTerms = onTerms
        self.onPrivacy = onPrivacy
    }

    public var body: some View {
        VStack(spacing: 2) {
            HStack(spacing: 4) {
                Text("By clicking continue, you agree to our").scMuted()
                linkButton("Terms of Service", action: onTerms)
            }
            HStack(spacing: 4) {
                Text("and").scMuted()
                linkButton("Privacy Policy", action: onPrivacy)
                Text(".").scMuted()
            }
        }
        .multilineTextAlignment(.center)
        .frame(maxWidth: .infinity)
    }

    private func linkButton(_ title: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.footnote)
                .underline()
                .foregroundStyle(theme.mutedForeground)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Previews

#Preview("Signup01") {
    @Previewable @State var lastAction = "Submit the form or choose an action."

    SCPreview {
        VStack(spacing: 8) {
            SCSignup01Block(
                onSubmit: { lastAction = "Create account: \($0.email)" },
                onGoogle: { lastAction = "Sign up with Google" },
                onSignIn: { lastAction = "Sign in" }
            )
            Text(lastAction).scMuted()
        }
    }
    .frame(height: 760)
}
