// ============================================================
// Sheet.swift — swiftcn-ui
// Depends on: Theme/, Button.swift (SCButtonStyle)
// ============================================================
import SwiftUI

// MARK: - Variants

/// The container edge an `scSheet` slides in from.
public enum SCSheetEdge: CaseIterable, Sendable {
    case top, bottom, leading, trailing
}

private extension SCSheetEdge {
    var isHorizontal: Bool {
        self == .leading || self == .trailing
    }

    var alignment: Alignment {
        switch self {
        case .top:      .top
        case .bottom:   .bottom
        case .leading:  .leading
        case .trailing: .trailing
        }
    }

    var moveEdge: Edge {
        switch self {
        case .top:      .top
        case .bottom:   .bottom
        case .leading:  .leading
        case .trailing: .trailing
        }
    }

    /// The panel side that carries the separator line — the side facing the
    /// content the sheet slid over.
    var borderAlignment: Alignment {
        switch self {
        case .top:      .bottom
        case .bottom:   .top
        case .leading:  .trailing
        case .trailing: .leading
        }
    }
}

// MARK: - Environment

private struct SCDismissSheetKey: EnvironmentKey {
    static let defaultValue: () -> Void = {}
}

public extension EnvironmentValues {
    /// Dismisses the nearest sheet presented with `.scSheet(isPresented:)`.
    /// The presenting modifier injects this closure, so any view inside the
    /// sheet content can dismiss it:
    ///
    ///     @Environment(\.scDismissSheet) private var dismissSheet
    ///     Button("Done") { dismissSheet() }
    var scDismissSheet: () -> Void {
        get { self[SCDismissSheetKey.self] }
        set { self[SCDismissSheetKey.self] = newValue }
    }
}

private struct SCSheetEdgeKey: EnvironmentKey {
    static let defaultValue: SCSheetEdge = .trailing
}

private extension EnvironmentValues {
    /// The edge the enclosing sheet is pinned to; lets `SCSheetContent`
    /// size itself and place its separator line without extra parameters.
    var scSheetEdge: SCSheetEdge {
        get { self[SCSheetEdgeKey.self] }
        set { self[SCSheetEdgeKey.self] = newValue }
    }
}

// MARK: - Presentation

public extension View {
    /// Presents a panel that slides in from a container edge — swiftcn's
    /// `Sheet` (a slide-over, unlike SwiftUI's `.sheet`).
    ///
    /// Pure SwiftUI: the panel renders in an overlay on this view (no UIKit
    /// window, no `.sheet`), so it themes, previews, and composes like any
    /// other view. Leading/trailing sheets are full height and at most 360pt
    /// (or 85% of the container) wide; top/bottom sheets are full width and
    /// hug their content's height.
    ///
    ///     .scSheet(isPresented: $showSettings) {
    ///         SCSheetContent {
    ///             SCSheetHeader {
    ///                 SCSheetTitle("Settings")
    ///                 SCSheetDescription("Manage your preferences.")
    ///             }
    ///             // rows…
    ///         }
    ///     }
    ///
    /// - Parameters:
    ///   - isPresented: Controls the sheet's visibility.
    ///   - edge: The container edge the panel is pinned to.
    ///   - dismissOnScrimTap: Whether tapping the scrim dismisses the sheet.
    ///   - content: The sheet view — typically an `SCSheetContent`.
    func scSheet<SheetContent: View>(
        isPresented: Binding<Bool>,
        edge: SCSheetEdge = .trailing,
        dismissOnScrimTap: Bool = true,
        @ViewBuilder content: @escaping () -> SheetContent
    ) -> some View {
        modifier(SCSheetModifier(
            isPresented: isPresented,
            edge: edge,
            dismissOnScrimTap: dismissOnScrimTap,
            sheet: content
        ))
    }
}

private struct SCSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    var edge: SCSheetEdge
    var dismissOnScrimTap: Bool
    var sheet: () -> SheetContent

    func body(content: Content) -> some View {
        content.overlay {
            GeometryReader { proxy in
                ZStack(alignment: edge.alignment) {
                    if isPresented {
                        // shadcn's bg-black/50 overlay — the one sanctioned raw color.
                        Color.black.opacity(0.5)
                            .ignoresSafeArea()
                            .onTapGesture {
                                if dismissOnScrimTap { isPresented = false }
                            }
                            .accessibilityHidden(true)
                            .transition(AnyTransition.opacity)

                        sheet()
                            .environment(\.scDismissSheet, { isPresented = false })
                            .environment(\.scSheetEdge, edge)
                            .frame(width: edge.isHorizontal ? min(360, proxy.size.width * 0.85) : nil)
                            .frame(
                                maxWidth: edge.isHorizontal ? nil : .infinity,
                                maxHeight: edge.isHorizontal ? .infinity : nil
                            )
                            .accessibilityAddTraits(.isModal)
                            .transition(AnyTransition.move(edge: edge.moveEdge))
                    }
                }
                .animation(.snappy(duration: 0.25), value: isPresented)
            }
        }
    }
}

// MARK: - Component

/// The styled panel of a sheet: themed surface, a separator line on the side
/// facing the content, and an automatic close button wired to
/// `\.scDismissSheet`.
public struct SCSheetContent<Content: View>: View {
    @Environment(\.theme) private var theme
    @Environment(\.scDismissSheet) private var dismissSheet
    @Environment(\.scSheetEdge) private var edge

    var showsClose: Bool
    @ViewBuilder var content: Content

    /// Creates the sheet panel.
    /// - Parameters:
    ///   - showsClose: Whether the automatic close button is shown.
    ///   - content: Sheet regions — header, rows, actions.
    public init(showsClose: Bool = true, @ViewBuilder content: () -> Content) {
        self.showsClose = showsClose
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 16) { content }
            .padding(24)
            .frame(
                maxWidth: .infinity,
                maxHeight: edge.isHorizontal ? .infinity : nil,
                alignment: .topLeading
            )
            .background(theme.background)
            .overlay(alignment: edge.borderAlignment) {
                Rectangle()
                    .fill(theme.border)
                    .frame(
                        width: edge.isHorizontal ? 1 : nil,
                        height: edge.isHorizontal ? nil : 1
                    )
            }
            .overlay(alignment: .topTrailing) {
                if showsClose {
                    Button {
                        dismissSheet()
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
}

// MARK: - Subcomponents

/// Groups a sheet's title and description at the top of the panel.
public struct SCSheetHeader<Content: View>: View {
    @ViewBuilder var content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) { content }
    }
}

/// A sheet's title line.
public struct SCSheetTitle: View {
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

/// Secondary explanatory text beneath a sheet's title.
public struct SCSheetDescription: View {
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

// MARK: - Previews

#Preview("Sheet · trailing") {
    @Previewable @State var isPresented = false
    @Previewable @State var notifications = true
    @Previewable @State var autoSave = false

    SCPreview {
        Button("Open sheet") { isPresented = true }
            .buttonStyle(.sc(.outline))
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    .scSheet(isPresented: $isPresented) {
        SCSheetContent {
            SCSheetHeader {
                SCSheetTitle("Settings")
                SCSheetDescription("Manage your account preferences.")
            }

            Toggle("Notifications", isOn: $notifications)
                .font(.subheadline)
            Toggle("Auto-save", isOn: $autoSave)
                .font(.subheadline)
            HStack {
                Text("Version")
                Spacer()
                Text("2.0.0")
                    .foregroundStyle(Theme.default.mutedForeground)
            }
            .font(.subheadline)

            Button("Save changes") { isPresented = false }
                .buttonStyle(.sc())
        }
    }
}
