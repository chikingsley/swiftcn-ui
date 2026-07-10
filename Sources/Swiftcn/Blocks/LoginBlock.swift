// ============================================================
// Blocks/LoginBlock.swift — swiftcn-ui
// Depends on: Theme/ · Card.swift · Field.swift · Input.swift ·
//             Label.swift · Button.swift · Separator.swift ·
//             Typography.swift
// ============================================================
import SwiftUI

// MARK: - Block

/// A complete login screen — the swiftcn port of shadcn/ui's `login-01`
/// block. A centered card with email + password fields, a primary Login
/// action, social sign-in, and a sign-up prompt. Email and password state
/// live inside the block; wire up behavior through the optional closures.
///
///     SCLoginBlock(
///         onSubmit: { email, password in signIn(email, password) },
///         onForgotPassword: { showReset() },
///         onSignUp: { showSignUp() },
///         onApple: { signInWithApple() }
///     )
public struct SCLoginBlock: View {
    @Environment(\.theme) private var theme

    private let onSubmit: ((String, String) -> Void)?
    private let onForgotPassword: (() -> Void)?
    private let onSignUp: (() -> Void)?
    private let onApple: (() -> Void)?
    private let onGoogle: (() -> Void)?

    @State private var email = ""
    @State private var password = ""

    /// Creates a login screen.
    /// - Parameters:
    ///   - onSubmit: Called with `(email, password)` when Login is tapped.
    ///   - onForgotPassword: Called when "Forgot your password?" is tapped.
    ///   - onSignUp: Called when "Sign up" is tapped.
    ///   - onApple: Called when "Login with Apple" is tapped.
    ///   - onGoogle: When non-nil, adds a "Login with Google" button and
    ///     calls this closure when it is tapped.
    public init(
        onSubmit: ((String, String) -> Void)? = nil,
        onForgotPassword: (() -> Void)? = nil,
        onSignUp: (() -> Void)? = nil,
        onApple: (() -> Void)? = nil,
        onGoogle: (() -> Void)? = nil
    ) {
        self.onSubmit = onSubmit
        self.onForgotPassword = onForgotPassword
        self.onSignUp = onSignUp
        self.onApple = onApple
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
                SCCardTitle("Login")
                SCCardDescription("Enter your email below to login to your account")
            }
            SCCardContent {
                VStack(spacing: 16) {
                    SCField("Email") {
                        emailInput
                    }
                    passwordField
                    actions
                }
            }
            SCCardFooter {
                signUpPrompt
                    .frame(maxWidth: .infinity)
            }
        }
    }

    // MARK: Fields

    @ViewBuilder private var emailInput: some View {
        let input = SCInput("m@example.com", text: $email, icon: "envelope")
            .autocorrectionDisabled()
        #if os(iOS)
        input.textInputAutocapitalization(.never)
        #else
        input
        #endif
    }

    /// `SCField` composes its own label with no trailing accessory slot, so
    /// this row rebuilds the field anatomy by hand (same 6pt rhythm) to fit
    /// the "Forgot your password?" link beside the label.
    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                SCLabel("Password")
                Spacer()
                Button("Forgot your password?") {
                    onForgotPassword?()
                }
                .buttonStyle(.sc(.link, size: .sm))
                .padding(.trailing, -12) // cancel the style's inset so text meets the field edge
            }
            SCInput("Password", text: $password, secure: true)
        }
    }

    // MARK: Actions

    private var actions: some View {
        VStack(spacing: 12) {
            Button {
                onSubmit?(email, password)
            } label: {
                Text("Login")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.sc())

            SCSeparator(label: "or continue with")

            Button {
                onApple?()
            } label: {
                Label("Login with Apple", systemImage: "apple.logo")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.sc(.outline))

            if onGoogle != nil {
                Button {
                    onGoogle?()
                } label: {
                    Label("Login with Google", systemImage: "globe")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.sc(.outline))
            }
        }
    }

    private var signUpPrompt: some View {
        HStack(spacing: 4) {
            Text("Don't have an account?")
                .scMuted()
            Button {
                onSignUp?()
            } label: {
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
    SCPreview {
        SCLoginBlock(
            onSubmit: { email, _ in print("login: \(email)") },
            onForgotPassword: {},
            onSignUp: {},
            onApple: {}
        )
    }
}

#Preview("Login · with Google") {
    SCPreview {
        SCLoginBlock(onApple: {}, onGoogle: {})
    }
}
