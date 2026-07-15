// ============================================================
// Direction.swift — swiftcn-ui
// Depends on: SwiftUI
// ============================================================
import SwiftUI

/// The logical text and layout direction used by swiftcn components.
public enum SCDirection: String, CaseIterable, Equatable, Hashable, Sendable {
    case ltr
    case rtl

    public init(_ layoutDirection: LayoutDirection) {
        self = layoutDirection == .rightToLeft ? .rtl : .ltr
    }

    public var layoutDirection: LayoutDirection {
        self == .rtl ? .rightToLeft : .leftToRight
    }
}

extension EnvironmentValues {
    /// The current application direction, backed by SwiftUI's native
    /// `layoutDirection` environment value. Components can read this as the
    /// SwiftUI equivalent of shadcn's `useDirection()` hook.
    public var scDirection: SCDirection {
        get { SCDirection(layoutDirection) }
        set { layoutDirection = newValue.layoutDirection }
    }
}

/// Sets text, semantic-edge, control, and layout direction for arbitrary
/// descendant content. Providers can be nested to override a subtree.
public struct SCDirectionProvider<Content: View>: View {
    private let direction: SCDirection
    private let content: Content

    public init(
        _ direction: SCDirection,
        @ViewBuilder content: () -> Content
    ) {
        self.direction = direction
        self.content = content()
    }

    public var body: some View {
        content.environment(\.scDirection, direction)
    }
}

/// Supplies the current direction to a view builder, mirroring the ergonomic
/// role of `useDirection()` for views that do not store an `@Environment` value.
public struct SCDirectionReader<Content: View>: View {
    @Environment(\.scDirection) private var direction

    private let content: (SCDirection) -> Content

    public init(@ViewBuilder content: @escaping (SCDirection) -> Content) {
        self.content = content
    }

    public var body: some View {
        content(direction)
    }
}

extension View {
    /// Sets direction for this view subtree without adding a wrapper view.
    public func scDirection(_ direction: SCDirection) -> some View {
        environment(\.scDirection, direction)
    }
}

// MARK: - Previews

#Preview("Direction · LTR and RTL") {
    SCPreview {
        VStack(spacing: 16) {
            SCDirectionProvider(.ltr) {
                Label("Account settings", systemImage: "chevron.forward")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            SCDirectionProvider(.rtl) {
                Label("إعدادات الحساب", systemImage: "chevron.forward")
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            SCDirectionReader { direction in
                Text("Current direction: \(direction.rawValue)")
            }
        }
    }
}
