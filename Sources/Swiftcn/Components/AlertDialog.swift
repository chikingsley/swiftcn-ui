// ============================================================
// AlertDialog.swift — swiftcn-ui
// Depends on: Theme/, Button.swift (SCButtonStyle)
// ============================================================
import SwiftUI

// MARK: - Variants

/// The intent of an alert dialog's confirm action.
public enum SCAlertDialogRole: CaseIterable, Sendable {
    case `default`, destructive
}

// MARK: - Presentation

public extension View {
    /// Presents a modal confirmation dialog — swiftcn's `AlertDialog`.
    ///
    /// Unlike `.scDialog`, an alert interrupts: there is no close button and
    /// tapping the scrim does not dismiss — the user must choose an action.
    /// Pure SwiftUI: the alert renders in an overlay on this view, so it
    /// themes, previews, and composes like any other view.
    ///
    ///     .scAlertDialog(
    ///         isPresented: $showDelete,
    ///         title: "Delete account?",
    ///         message: "This action cannot be undone.",
    ///         confirmLabel: "Delete",
    ///         role: .destructive
    ///     ) {
    ///         deleteAccount()
    ///     }
    ///
    /// - Parameters:
    ///   - isPresented: Controls the alert's visibility.
    ///   - title: The question or statement requiring a decision.
    ///   - message: Supporting detail about the consequences.
    ///   - confirmLabel: Label of the confirming button.
    ///   - cancelLabel: Label of the cancelling button.
    ///   - role: `.destructive` renders the confirm button destructively.
    ///   - onConfirm: Runs when the user confirms (after dismissal).
    func scAlertDialog(
        isPresented: Binding<Bool>,
        title: String,
        message: String,
        confirmLabel: String = "Continue",
        cancelLabel: String = "Cancel",
        role: SCAlertDialogRole = .default,
        onConfirm: @escaping () -> Void
    ) -> some View {
        modifier(SCAlertDialogModifier(
            isPresented: isPresented,
            title: title,
            message: message,
            confirmLabel: confirmLabel,
            cancelLabel: cancelLabel,
            role: role,
            onConfirm: onConfirm
        ))
    }
}

// MARK: - Modifier

private struct SCAlertDialogModifier: ViewModifier {
    @Environment(\.theme) private var theme

    @Binding var isPresented: Bool
    var title: String
    var message: String
    var confirmLabel: String
    var cancelLabel: String
    var role: SCAlertDialogRole
    var onConfirm: () -> Void

    func body(content: Content) -> some View {
        content.overlay {
            ZStack {
                if isPresented {
                    // shadcn's bg-black/50 overlay — the one sanctioned raw color.
                    // Deliberately not tappable-to-dismiss: an alert demands a choice.
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .accessibilityHidden(true)
                        .transition(AnyTransition.opacity)

                    alert
                        .accessibilityAddTraits(.isModal)
                        .transition(AnyTransition.scale(scale: 0.95).combined(with: .opacity))
                }
            }
            .animation(.snappy(duration: 0.25), value: isPresented)
        }
    }

    // Same visual language as SCDialogContent, duplicated so this file stays
    // self-contained (the copy-paste unit) without importing Dialog.swift.
    private var alert: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(theme.foreground)
                Text(message)
                    .font(.subheadline)
                    .foregroundStyle(theme.mutedForeground)
            }

            HStack(spacing: 8) {
                Button(cancelLabel) {
                    isPresented = false
                }
                .buttonStyle(.sc(.outline))

                Button(confirmLabel) {
                    isPresented = false
                    onConfirm()
                }
                .buttonStyle(.sc(role == .destructive ? .destructive : .default))
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(24)
        .frame(maxWidth: 420, alignment: .leading)
        .background {
            shape
                .fill(theme.background)
                .shadow(radius: 20, y: 8)
        }
        .overlay { shape.strokeBorder(theme.border) }
        .foregroundStyle(theme.foreground)
        .padding(24)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.radius + 2, style: .continuous)
    }
}

// MARK: - Previews

#Preview("AlertDialog · destructive") {
    @Previewable @State var isPresented = false

    SCPreview {
        Button("Delete account") { isPresented = true }
            .buttonStyle(.sc(.destructive))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .scAlertDialog(
        isPresented: $isPresented,
        title: "Delete account?",
        message: "This action cannot be undone. This will permanently delete your account and remove your data from our servers.",
        confirmLabel: "Delete",
        role: .destructive
    ) {
        print("Account deleted")
    }
}
