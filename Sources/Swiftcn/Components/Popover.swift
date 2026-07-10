// ============================================================
// Popover.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Modifier

public extension View {
    /// Presents a themed, anchored popover — shadcn's Popover built on the
    /// native `.popover`, which supplies anchoring, the arrow, and
    /// tap-outside dismissal. On iPhone the presentation stays a true
    /// popover instead of adapting to a sheet.
    ///
    /// The content is styled with swiftcn's popover tokens: `theme.popover`
    /// background, `theme.popoverForeground` text, 16pt padding, and a
    /// 200pt minimum width.
    ///
    /// > Note: The popover chrome — arrow included — is tinted via
    /// > `presentationBackground`, so the arrow color follows
    /// > `theme.popover` and cannot be styled independently.
    ///
    ///     Button("Open popover") { isPresented = true }
    ///         .scPopover(isPresented: $isPresented) {
    ///             Text("Place content for the popover here.")
    ///         }
    func scPopover<Content: View>(
        isPresented: Binding<Bool>,
        arrowEdge: Edge = .top,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        popover(isPresented: isPresented, arrowEdge: arrowEdge) {
            SCPopoverContent { content() }
        }
    }
}

// MARK: - Component

/// Applies swiftcn's popover styling to presented content.
private struct SCPopoverContent<Content: View>: View {
    @Environment(\.theme) private var theme

    @ViewBuilder var content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(16)
            .frame(minWidth: 200, alignment: .leading)
            .foregroundStyle(theme.popoverForeground)
            .presentationBackground(theme.popover)
            .presentationCompactAdaptation(.popover)
    }
}

// MARK: - Previews

#Preview("Popover") {
    @Previewable @State var isPresented = false

    SCPreview {
        Button("Open popover") { isPresented.toggle() }
            .buttonStyle(.sc(.outline))
            .scPopover(isPresented: $isPresented) {
                VStack(alignment: .leading, spacing: 12) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Dimensions")
                            .font(.subheadline.weight(.semibold))
                        Text("Set the dimensions for the layer.")
                            .font(.footnote)
                            .foregroundStyle(Theme.default.mutedForeground)
                    }
                    HStack {
                        Text("Width").font(.footnote)
                        Spacer()
                        Text("100%").font(.footnote.weight(.medium))
                    }
                    HStack {
                        Text("Height").font(.footnote)
                        Spacer()
                        Text("25px").font(.footnote.weight(.medium))
                    }
                }
            }
    }
    .frame(height: 400)
}
