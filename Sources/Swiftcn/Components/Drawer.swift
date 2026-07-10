// ============================================================
// Drawer.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Environment

private struct SCDismissDrawerKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

public extension EnvironmentValues {
    /// Dismisses the nearest enclosing drawer presented with
    /// `scDrawer(isPresented:content:)`. A no-op outside of a drawer.
    ///
    ///     @Environment(\.scDismissDrawer) private var dismissDrawer
    ///     Button("Cancel") { dismissDrawer() }
    var scDismissDrawer: () -> Void {
        get { self[SCDismissDrawerKey.self] }
        set { self[SCDismissDrawerKey.self] = newValue }
    }
}

// MARK: - Modifier

public extension View {
    /// Presents a vaul-style bottom drawer over this view — shadcn's Drawer.
    ///
    /// The drawer is a pure SwiftUI overlay (no `.sheet`): a scrim plus a
    /// bottom panel that slides in from the bottom edge. Drag the panel down
    /// past 120pt to dismiss; shorter drags spring back. Tapping the scrim
    /// also dismisses. Apply it to a view that fills the screen so the scrim
    /// covers everything.
    ///
    /// Build the panel with ``SCDrawerContent`` and its subcomponents:
    ///
    ///     .scDrawer(isPresented: $showDrawer) {
    ///         SCDrawerContent {
    ///             SCDrawerHeader {
    ///                 SCDrawerTitle("Are you absolutely sure?")
    ///                 SCDrawerDescription("This action cannot be undone.")
    ///             }
    ///             SCDrawerFooter {
    ///                 Button("Confirm") { … }.buttonStyle(.sc())
    ///             }
    ///         }
    ///     }
    ///
    /// Views inside the drawer can dismiss it via `\.scDismissDrawer`.
    func scDrawer<DrawerContent: View>(
        isPresented: Binding<Bool>,
        @ViewBuilder content: @escaping () -> DrawerContent
    ) -> some View {
        modifier(SCDrawerModifier(isPresented: isPresented, drawerContent: content))
    }
}

private struct SCDrawerModifier<DrawerContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    @ViewBuilder var drawerContent: () -> DrawerContent

    @State private var dragOffset: CGFloat = 0

    func body(content: Content) -> some View {
        content.overlay {
            ZStack(alignment: .bottom) {
                if isPresented {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onTapGesture { isPresented = false }

                    drawerContent()
                        .environment(\.scDismissDrawer, { isPresented = false })
                        .offset(y: dragOffset)
                        .gesture(drag)
                        .transition(.move(edge: .bottom))
                }
            }
            .animation(.spring(response: 0.35, dampingFraction: 0.85), value: isPresented)
            .onChange(of: isPresented) { _, presented in
                if presented { dragOffset = 0 }
            }
        }
    }

    /// Panel follows the finger downward (upward drags rubber-band at 1/10
    /// distance); releasing past 120pt dismisses, otherwise springs back.
    private var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                let translation = value.translation.height
                dragOffset = translation >= 0 ? translation : translation / 10
            }
            .onEnded { value in
                if value.translation.height > 120 {
                    isPresented = false
                } else {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                        dragOffset = 0
                    }
                }
            }
    }
}

// MARK: - Component

/// The drawer panel: a centered grabber above your content, on the themed
/// background with rounded top corners. Place it at the root of
/// `scDrawer(isPresented:content:)`'s content.
public struct SCDrawerContent<Content: View>: View {
    @Environment(\.theme) private var theme

    @ViewBuilder var content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(theme.muted)
                .frame(width: 40, height: 5)
                .padding(.top, 8)
            content
        }
        .frame(maxWidth: .infinity)
        .background {
            UnevenRoundedRectangle(
                topLeadingRadius: theme.radius + 6,
                topTrailingRadius: theme.radius + 6,
                style: .continuous
            )
            .fill(theme.background)
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }
}

// MARK: - Subcomponents

/// Groups the drawer's title and description with centered text.
public struct SCDrawerHeader<Content: View>: View {
    @ViewBuilder var content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: 6) { content }
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity)
            .padding(16)
    }
}

/// The drawer's title line.
public struct SCDrawerTitle: View {
    @Environment(\.theme) private var theme

    let text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(.headline)
            .foregroundStyle(theme.foreground)
    }
}

/// Supporting text under the drawer's title.
public struct SCDrawerDescription: View {
    @Environment(\.theme) private var theme

    let text: String

    public init(_ text: String) {
        self.text = text
    }

    public var body: some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(theme.mutedForeground)
    }
}

/// Vertical button stack pinned at the bottom of the drawer.
public struct SCDrawerFooter<Content: View>: View {
    @ViewBuilder var content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: 8) { content }
            .frame(maxWidth: .infinity)
            .padding(16)
    }
}

// MARK: - Previews

#Preview("Drawer") {
    @Previewable @State var isOpen = false

    SCPreview {
        VStack {
            Button("Open Drawer") { isOpen = true }
                .buttonStyle(.sc(.outline))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .frame(height: 500)
        .scDrawer(isPresented: $isOpen) {
            SCDrawerContent {
                SCDrawerHeader {
                    SCDrawerTitle("Are you absolutely sure?")
                    SCDrawerDescription("This action cannot be undone. This will permanently remove your data from our servers.")
                }
                SCDrawerFooter {
                    Button { isOpen = false } label: {
                        Text("Confirm").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.sc())
                    Button { isOpen = false } label: {
                        Text("Cancel").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.sc(.outline))
                }
            }
        }
    }
}
