// ============================================================
// Dialog.swift — swiftcn-ui
// Depends on: Theme/, Button.swift (SCButtonStyle)
// ============================================================
import SwiftUI

// MARK: - Environment

private struct SCDismissDialogKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

public extension EnvironmentValues {
    /// Dismisses the nearest dialog presented with `.scDialog(isPresented:)`.
    /// The presenting modifier injects this closure, so any view inside the
    /// dialog content can dismiss it:
    ///
    ///     @Environment(\.scDismissDialog) private var dismissDialog
    ///     Button("Cancel") { dismissDialog() }
    var scDismissDialog: () -> Void {
        get { self[SCDismissDialogKey.self] }
        set { self[SCDismissDialogKey.self] = newValue }
    }
}

// MARK: - Presentation

public extension View {
    /// Presents a centered modal dialog over this view — swiftcn's `Dialog`.
    ///
    /// Pure SwiftUI: the dialog renders in an overlay on this view (no UIKit
    /// window, no `.sheet`), so it themes, previews, and composes like any
    /// other view. Attach it to the container the scrim should cover.
    ///
    ///     .scDialog(isPresented: $showDialog) {
    ///         SCDialogContent {
    ///             SCDialogHeader {
    ///                 SCDialogTitle("Edit profile")
    ///                 SCDialogDescription("Make changes and save.")
    ///             }
    ///             SCDialogFooter {
    ///                 Button("Save changes") { … }.buttonStyle(.sc())
    ///             }
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///   - isPresented: Controls the dialog's visibility.
    ///   - dismissOnScrimTap: Whether tapping the scrim dismisses the dialog.
    ///   - content: The dialog view — typically an `SCDialogContent`.
    func scDialog<DialogContent: View>(
        isPresented: Binding<Bool>,
        dismissOnScrimTap: Bool = true,
        @ViewBuilder content: @escaping () -> DialogContent
    ) -> some View {
        modifier(SCDialogModifier(
            isPresented: isPresented,
            dismissOnScrimTap: dismissOnScrimTap,
            dialog: content
        ))
    }
}

private struct SCDialogModifier<DialogContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    var dismissOnScrimTap: Bool
    var dialog: () -> DialogContent

    func body(content: Content) -> some View {
        content.overlay {
            ZStack {
                if isPresented {
                    // shadcn's bg-black/50 overlay — the one sanctioned raw color.
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .onTapGesture {
                            if dismissOnScrimTap { isPresented = false }
                        }
                        .accessibilityHidden(true)
                        .transition(AnyTransition.opacity)

                    dialog()
                        .environment(\.scDismissDialog, { isPresented = false })
                        .padding(24)
                        .accessibilityAddTraits(.isModal)
                        .transition(AnyTransition.scale(scale: 0.95).combined(with: .opacity))
                }
            }
            .animation(.snappy(duration: 0.25), value: isPresented)
        }
    }
}

// MARK: - Component

/// The styled panel of a dialog: themed surface, border, shadow, and an
/// automatic close button wired to `\.scDismissDialog`.
public struct SCDialogContent<Content: View>: View {
    @Environment(\.theme) private var theme
    @Environment(\.scDismissDialog) private var dismissDialog

    var showsClose: Bool
    @ViewBuilder var content: Content

    /// Creates the dialog panel.
    /// - Parameters:
    ///   - showsClose: Whether the automatic close button is shown.
    ///   - content: Dialog regions — header, body views, footer.
    public init(showsClose: Bool = true, @ViewBuilder content: () -> Content) {
        self.showsClose = showsClose
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) { content }
            .padding(24)
            .frame(maxWidth: 420, alignment: .leading)
            .background {
                shape
                    .fill(theme.background)
                    .shadow(radius: 20, y: 8)
            }
            .overlay { shape.strokeBorder(theme.border) }
            .overlay(alignment: .topTrailing) {
                if showsClose {
                    Button {
                        dismissDialog()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.footnote.weight(.semibold))
                            .foregroundStyle(theme.mutedForeground)
                    }
                    .buttonStyle(.sc(.ghost, size: .icon))
                    .padding(8)
                    .accessibilityLabel("Close")
                }
            }
            .foregroundStyle(theme.foreground)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.radius + 2, style: .continuous)
    }
}

// MARK: - Subcomponents

/// Groups a dialog's title and description at the top of the panel.
public struct SCDialogHeader<Content: View>: View {
    @ViewBuilder var content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) { content }
    }
}

/// A dialog's title line.
public struct SCDialogTitle: View {
    @Environment(\.theme) private var theme
    var text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(.headline)
            .foregroundStyle(theme.foreground)
    }
}

/// Secondary explanatory text beneath a dialog's title.
public struct SCDialogDescription: View {
    @Environment(\.theme) private var theme
    var text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(theme.mutedForeground)
    }
}

/// The trailing-aligned action row at the bottom of a dialog.
public struct SCDialogFooter<Content: View>: View {
    @ViewBuilder var content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        HStack(spacing: 8) { content }
            .frame(maxWidth: .infinity, alignment: .trailing)
    }
}

// MARK: - Previews

/// Demonstrates dismissing from inside the dialog via `\.scDismissDialog`.
private struct DialogPreviewCancelButton: View {
    @Environment(\.scDismissDialog) private var dismissDialog

    var body: some View {
        Button("Cancel") { dismissDialog() }
            .buttonStyle(.sc(.outline))
    }
}

#Preview("Dialog") {
    @Previewable @State var isPresented = false

    SCPreview {
        Button("Open dialog") { isPresented = true }
            .buttonStyle(.sc(.outline))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .scDialog(isPresented: $isPresented) {
        SCDialogContent {
            SCDialogHeader {
                SCDialogTitle("Edit profile")
                SCDialogDescription("Make changes to your profile here. Click save when you're done.")
            }
            SCDialogFooter {
                DialogPreviewCancelButton()
                Button("Continue") { isPresented = false }
                    .buttonStyle(.sc())
            }
        }
    }
}
