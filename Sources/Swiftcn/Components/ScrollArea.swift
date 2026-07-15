// ============================================================
// ScrollArea.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Scrollbar configuration

/// Visibility of a native scrollbar for one Scroll Area axis.
public enum SCScrollBarVisibility: Hashable, Sendable {
    case automatic
    case visible
    case hidden

    fileprivate var nativeValue: ScrollIndicatorVisibility {
        switch self {
        case .automatic: .automatic
        case .visible: .visible
        case .hidden: .hidden
        }
    }
}

/// A real scrollbar configuration consumed by the nearest `SCScrollArea`.
///
/// SwiftUI owns the native scrollbar and thumb so they remain draggable,
/// keyboard-aware, platform-adaptive, and accessibility-correct. Declaring a
/// Scrollbar selects its axis and visibility; it is not a decorative overlay.
public struct SCScrollBar {
    public let orientation: Axis
    public let visibility: SCScrollBarVisibility

    public init(
        orientation: Axis = .vertical,
        visibility: SCScrollBarVisibility = .automatic
    ) {
        self.orientation = orientation
        self.visibility = visibility
    }
}

// MARK: - Builder

private enum SCScrollAreaNode {
    case viewportContent(AnyView)
    case scrollbar(SCScrollBar)
}

/// The opaque result produced by `SCScrollAreaBuilder`.
public struct SCScrollAreaContent {
    fileprivate var nodes: [SCScrollAreaNode]

    fileprivate init(nodes: [SCScrollAreaNode] = []) {
        self.nodes = nodes
    }
}

/// Separates arbitrary viewport content from Scrollbar declarations.
@resultBuilder
public enum SCScrollAreaBuilder {
    public static func buildExpression<Content: View>(
        _ content: Content
    ) -> SCScrollAreaContent {
        SCScrollAreaContent(nodes: [.viewportContent(AnyView(content))])
    }

    public static func buildExpression(
        _ scrollbar: SCScrollBar
    ) -> SCScrollAreaContent {
        SCScrollAreaContent(nodes: [.scrollbar(scrollbar)])
    }

    public static func buildBlock(
        _ components: SCScrollAreaContent...
    ) -> SCScrollAreaContent {
        SCScrollAreaContent(nodes: components.flatMap(\.nodes))
    }

    public static func buildOptional(
        _ component: SCScrollAreaContent?
    ) -> SCScrollAreaContent {
        component ?? SCScrollAreaContent()
    }

    public static func buildEither(
        first component: SCScrollAreaContent
    ) -> SCScrollAreaContent {
        component
    }

    public static func buildEither(
        second component: SCScrollAreaContent
    ) -> SCScrollAreaContent {
        component
    }

    public static func buildArray(
        _ components: [SCScrollAreaContent]
    ) -> SCScrollAreaContent {
        SCScrollAreaContent(nodes: components.flatMap(\.nodes))
    }

    public static func buildLimitedAvailability(
        _ component: SCScrollAreaContent
    ) -> SCScrollAreaContent {
        component
    }
}

// MARK: - Root

/// A focusable native ScrollView with composable content and scrollbar axes.
///
/// With no explicit Scrollbar, the Root uses a vertical native scrollbar. A
/// horizontal Scrollbar declaration produces the official horizontal example;
/// declaring both axes produces a two-axis viewport and native corner.
public struct SCScrollArea: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.theme) private var theme
    @FocusState private var isFocused: Bool

    private let explicitAxes: Axis.Set?
    private let isDisabled: Bool
    private let bounceBehavior: ScrollBounceBehavior
    private let showsFocusRing: Bool
    private let isBordered: Bool
    private let cornerRadius: CGFloat
    private let accessibilityLabel: String?
    private let nodes: [SCScrollAreaNode]

    public init(
        axes: Axis.Set? = nil,
        isDisabled: Bool = false,
        bounceBehavior: ScrollBounceBehavior = .basedOnSize,
        showsFocusRing: Bool = true,
        isBordered: Bool = false,
        cornerRadius: CGFloat = 6,
        accessibilityLabel: String? = nil,
        @SCScrollAreaBuilder content: () -> SCScrollAreaContent
    ) {
        self.explicitAxes = axes
        self.isDisabled = isDisabled
        self.bounceBehavior = bounceBehavior
        self.showsFocusRing = showsFocusRing
        self.isBordered = isBordered
        self.cornerRadius = max(cornerRadius, 0)
        self.accessibilityLabel = accessibilityLabel
        self.nodes = content().nodes
    }

    public var body: some View {
        ScrollView(resolvedAxes) {
            ForEach(Array(viewportContent.enumerated()), id: \.offset) { _, content in
                content
            }
        }
        .scrollIndicators(verticalVisibility.nativeValue, axes: .vertical)
        .scrollIndicators(horizontalVisibility.nativeValue, axes: .horizontal)
        .scrollBounceBehavior(bounceBehavior, axes: resolvedAxes)
        .scrollDisabled(isDisabled || !isEnabled)
        .focusable(!isDisabled && isEnabled)
        .focused($isFocused)
        .clipShape(viewportShape)
        .overlay {
            viewportShape.strokeBorder(borderColor, lineWidth: borderWidth)
        }
        .accessibilityElement(children: .contain)
        .modifier(SCScrollAreaAccessibilityLabel(label: accessibilityLabel))
    }

    private var viewportContent: [AnyView] {
        nodes.compactMap { node in
            if case .viewportContent(let content) = node { return content }
            return nil
        }
    }

    private var scrollbars: [SCScrollBar] {
        nodes.compactMap { node in
            if case .scrollbar(let scrollbar) = node { return scrollbar }
            return nil
        }
    }

    private var resolvedAxes: Axis.Set {
        if let explicitAxes { return explicitAxes }
        guard !scrollbars.isEmpty else { return .vertical }
        var axes: Axis.Set = []
        for scrollbar in scrollbars {
            axes.insert(scrollbar.orientation == .vertical ? .vertical : .horizontal)
        }
        return axes
    }

    private var verticalVisibility: SCScrollBarVisibility {
        visibility(for: .vertical)
    }

    private var horizontalVisibility: SCScrollBarVisibility {
        visibility(for: .horizontal)
    }

    private func visibility(for orientation: Axis) -> SCScrollBarVisibility {
        if let scrollbar = scrollbars.last(where: { $0.orientation == orientation }) {
            return scrollbar.visibility
        }
        let axis: Axis.Set = orientation == .vertical ? .vertical : .horizontal
        return resolvedAxes.contains(axis) ? .automatic : .hidden
    }

    private var viewportShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
    }

    private var borderColor: Color {
        showsFocusRing && isFocused ? theme.ring.opacity(0.5) : theme.border
    }

    private var borderWidth: CGFloat {
        if showsFocusRing && isFocused { return 3 }
        return isBordered ? 1 : 0
    }
}

private struct SCScrollAreaAccessibilityLabel: ViewModifier {
    let label: String?

    @ViewBuilder
    func body(content: Content) -> some View {
        if let label {
            content.accessibilityLabel(label)
        } else {
            content
        }
    }
}

// MARK: - Previews

#Preview("Scroll Area · vertical") {
    SCPreview {
        SCScrollArea(isBordered: true, accessibilityLabel: "Version tags") {
            LazyVStack(alignment: .leading, spacing: 8) {
                Text("Tags").font(.headline)
                ForEach(0..<50, id: \.self) { index in
                    Text("v1.2.0-beta.\(50 - index)")
                    SCSeparator()
                }
            }
            .padding(16)
        }
        .frame(width: 192, height: 288)
    }
}

#Preview("Scroll Area · horizontal") {
    SCPreview {
        SCScrollArea(isBordered: true, accessibilityLabel: "Artwork") {
            LazyHStack(spacing: 16) {
                ForEach(["Ornella", "Tom", "Vladimir"], id: \.self) { artist in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Theme.default.muted)
                        .frame(width: 150, height: 200)
                        .overlay { Text(artist) }
                }
            }
            .padding(16)
            SCScrollBar(orientation: .horizontal)
        }
        .frame(width: 384, height: 240)
    }
}
