// ============================================================
// Blocks/Login02Block.swift — swiftcn-ui
// Depends on: Theme/ · Field.swift · Input.swift · Label.swift ·
//             Button.swift · Typography.swift ·
//             Signup01Block.swift (shared email input) ·
//             Signup04Block.swift (media placeholder)
//
// Port of shadcn/ui's `login-02` block: a two-column page — a
// brand row and card-less login form on the left, a media panel
// on the right — with email and password fields, a forgot-
// password link, Login, and GitHub sign-in.
// ============================================================
import SwiftUI

// MARK: - Block

/// The swiftcn port of shadcn/ui's `login-02` block. Field state lives
/// inside the block; wire behavior through the required closures. The media
/// panel is a builder slot (upstream's placeholder image) and collapses when
/// the two-column layout does not fit, matching the upstream `lg:`
/// breakpoint. The upstream brand anchor points at "#", so the mark renders
/// as static identity here.
///
///     SCLogin02Block(
///         onSubmit: { email, password in signIn(email, password) },
///         onForgotPassword: { showReset() },
///         onGitHub: { signInWithGitHub() },
///         onSignUp: { showSignUp() }
///     )
public struct SCLogin02Block<Media: View>: View {
    @Environment(\.theme) private var theme

    private let onSubmit: (String, String) -> Void
    private let onForgotPassword: () -> Void
    private let onGitHub: () -> Void
    private let onSignUp: () -> Void
    private let media: Media

    @State private var email = ""
    @State private var password = ""

    public init(
        onSubmit: @escaping (String, String) -> Void,
        onForgotPassword: @escaping () -> Void,
        onGitHub: @escaping () -> Void,
        onSignUp: @escaping () -> Void,
        @ViewBuilder media: () -> Media
    ) {
        self.onSubmit = onSubmit
        self.onForgotPassword = onForgotPassword
        self.onGitHub = onGitHub
        self.onSignUp = onSignUp
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
                Text("Login to your account").scH3()
                Text("Enter your email below to login to your account")
                    .scMuted()
                    .multilineTextAlignment(.center)
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
            VStack(spacing: 12) {
                Button(action: onGitHub) {
                    Label("Login with GitHub", systemImage: "chevron.left.forwardslash.chevron.right")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.sc(.outline))
                SCLoginSignUpPrompt(onSignUp: onSignUp)
                    .frame(maxWidth: .infinity)
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

extension SCLogin02Block where Media == SCAuthMediaPlaceholder {
    public init(
        onSubmit: @escaping (String, String) -> Void,
        onForgotPassword: @escaping () -> Void,
        onGitHub: @escaping () -> Void,
        onSignUp: @escaping () -> Void
    ) {
        self.init(
            onSubmit: onSubmit,
            onForgotPassword: onForgotPassword,
            onGitHub: onGitHub,
            onSignUp: onSignUp,
            media: { SCAuthMediaPlaceholder() }
        )
    }
}

// MARK: - Shared login parts

/// The password field with the trailing "Forgot your password?" link the
/// login blocks share. `SCField` composes its own label with no trailing
/// accessory slot, so this row rebuilds the field anatomy by hand (same 6pt
/// rhythm) to fit the link beside the label.
public struct SCLoginPasswordRow: View {
    @Binding private var password: String
    private let onForgotPassword: () -> Void
    private let onSubmit: (() -> Void)?

    public init(
        password: Binding<String>,
        onForgotPassword: @escaping () -> Void,
        onSubmit: (() -> Void)? = nil
    ) {
        self._password = password
        self.onForgotPassword = onForgotPassword
        self.onSubmit = onSubmit
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(alignment: .firstTextBaseline) {
                SCLabel("Password", required: true)
                Spacer()
                Button("Forgot your password?", action: onForgotPassword)
                    .buttonStyle(.sc(.link, size: .sm))
                    .padding(.trailing, -12)  // cancel style inset so text meets the field edge
            }
            SCInput("Password", text: $password, secure: true, onSubmit: onSubmit)
        }
    }
}

/// "Don't have an account? Sign up" — the sign-up prompt shared by the
/// login blocks.
public struct SCLoginSignUpPrompt: View {
    @Environment(\.theme) private var theme

    private let onSignUp: () -> Void

    public init(onSignUp: @escaping () -> Void) {
        self.onSignUp = onSignUp
    }

    public var body: some View {
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

#Preview("Login02") {
    @Previewable @State var lastAction = "Submit the form or choose an action."

    SCPreview {
        VStack(spacing: 8) {
            SCLogin02Block(
                onSubmit: { email, _ in lastAction = "Login: \(email)" },
                onForgotPassword: { lastAction = "Forgot password" },
                onGitHub: { lastAction = "Login with GitHub" },
                onSignUp: { lastAction = "Sign up" }
            )
            .frame(width: 1000, height: 720)
            Text(lastAction).scMuted()
        }
    }
}
