// ============================================================
// Breadcrumb.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Root

/// A semantic container for a composable breadcrumb trail.
public struct SCBreadcrumb: View {
    private let accessibilityLabel: String
    private let content: AnyView

    public init<Content: View>(
        accessibilityLabel: String = "Breadcrumb",
        @ViewBuilder content: () -> Content
    ) {
        self.accessibilityLabel = accessibilityLabel
        self.content = AnyView(content())
    }

    public var body: some View {
        content
            .accessibilityElement(children: .contain)
            .accessibilityLabel(Text(accessibilityLabel))
    }
}

// MARK: - List

/// A wrapping list of breadcrumb items and separators.
public struct SCBreadcrumbList<Content: View>: View {
    @Environment(\.layoutDirection) private var layoutDirection

    private let horizontalSpacing: CGFloat
    private let verticalSpacing: CGFloat
    private let content: Content

    public init(
        horizontalSpacing: CGFloat = 6,
        verticalSpacing: CGFloat = 4,
        @ViewBuilder content: () -> Content
    ) {
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.content = content()
    }

    public var body: some View {
        SCBreadcrumbFlowLayout(
            horizontalSpacing: horizontalSpacing,
            verticalSpacing: verticalSpacing,
            layoutDirection: layoutDirection
        ) {
            content
        }
        .font(.footnote)
    }
}

private struct SCBreadcrumbFlowLayout: Layout {
    var horizontalSpacing: CGFloat
    var verticalSpacing: CGFloat
    var layoutDirection: LayoutDirection

    func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) -> CGSize {
        let lines = makeLines(maxWidth: proposal.width ?? .infinity, subviews: subviews)
        let width = lines.map(\.width).max() ?? 0
        let height = lines.enumerated().reduce(CGFloat.zero) { result, entry in
            result + entry.element.height + (entry.offset == 0 ? 0 : verticalSpacing)
        }
        return CGSize(width: min(width, proposal.width ?? width), height: height)
    }

    func placeSubviews(
        in bounds: CGRect,
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache: inout Void
    ) {
        let lines = makeLines(maxWidth: bounds.width, subviews: subviews)
        var y = bounds.minY

        for line in lines {
            var x = layoutDirection == .leftToRight ? bounds.minX : bounds.maxX
            for item in line.items {
                let originX: CGFloat
                if layoutDirection == .leftToRight {
                    originX = x
                    x += item.size.width + horizontalSpacing
                } else {
                    originX = x - item.size.width
                    x -= item.size.width + horizontalSpacing
                }
                item.subview.place(
                    at: CGPoint(x: originX, y: y + (line.height - item.size.height) / 2),
                    anchor: .topLeading,
                    proposal: ProposedViewSize(item.size)
                )
            }
            y += line.height + verticalSpacing
        }
    }

    private func makeLines(maxWidth: CGFloat, subviews: Subviews) -> [Line] {
        var lines: [Line] = []
        var line = Line()

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            let nextWidth =
                line.items.isEmpty
                ? size.width
                : line.width + horizontalSpacing + size.width

            if !line.items.isEmpty, nextWidth > maxWidth {
                lines.append(line)
                line = Line()
            }
            line.append(subview: subview, size: size, spacing: horizontalSpacing)
        }
        if !line.items.isEmpty { lines.append(line) }
        return lines
    }

    private struct Item {
        var subview: LayoutSubview
        var size: CGSize
    }

    private struct Line {
        var items: [Item] = []
        var width: CGFloat = 0
        var height: CGFloat = 0

        mutating func append(subview: LayoutSubview, size: CGSize, spacing: CGFloat) {
            if !items.isEmpty { width += spacing }
            items.append(Item(subview: subview, size: size))
            width += size.width
            height = max(height, size.height)
        }
    }
}

// MARK: - Item

/// One composable entry in a breadcrumb list.
public struct SCBreadcrumbItem: View {
    fileprivate let convenienceLabel: String?
    fileprivate let convenienceAction: (() -> Void)?
    private let content: AnyView

    public init<Content: View>(@ViewBuilder content: () -> Content) {
        convenienceLabel = nil
        convenienceAction = nil
        self.content = AnyView(content())
    }

    /// Convenience entry used by `SCBreadcrumb(items:maxVisible:)`.
    public init(_ label: String, action: (() -> Void)? = nil) {
        convenienceLabel = label
        convenienceAction = action
        if let action {
            content = AnyView(SCBreadcrumbLink(action: action) { Text(label) })
        } else {
            content = AnyView(SCBreadcrumbPage(label))
        }
    }

    public var body: some View {
        HStack(spacing: 0) {
            content
        }
    }
}

// MARK: - Link

/// A native action or URL link styled for a breadcrumb trail.
public struct SCBreadcrumbLink<Label: View>: View {
    private enum Target {
        case action(() -> Void)
        case destination(URL)
    }

    private let target: Target
    private let label: Label

    public init(
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        target = .action(action)
        self.label = label()
    }

    public init(
        destination: URL,
        @ViewBuilder label: () -> Label
    ) {
        target = .destination(destination)
        self.label = label()
    }

    public var body: some View {
        Group {
            switch target {
            case .action(let action):
                Button(action: action) { label }
                    .buttonStyle(SCBreadcrumbLinkButtonStyle())
            case .destination(let destination):
                Link(destination: destination) { label }
                    .buttonStyle(SCBreadcrumbLinkButtonStyle())
            }
        }
    }
}

/// Breadcrumb-link chrome reusable by native navigation controls.
public struct SCBreadcrumbLinkModifier: ViewModifier {
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    @State private var isHovered = false

    public init() {}

    public func body(content: Content) -> some View {
        content
            .lineLimit(1)
            .foregroundStyle(isHovered ? theme.foreground : theme.mutedForeground)
            .contentShape(Rectangle())
            .opacity(isEnabled ? 1 : 0.5)
            .onHover { isHovered = $0 }
    }
}

extension View {
    /// Styles a caller-owned `NavigationLink`, `Link`, or `Button` as a breadcrumb link.
    public func scBreadcrumbLink() -> some View {
        modifier(SCBreadcrumbLinkModifier())
    }
}

public struct SCBreadcrumbLinkButtonStyle: ButtonStyle {
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scBreadcrumbLink()
            .opacity(configuration.isPressed ? 0.72 : 1)
    }
}

// MARK: - Page

/// The non-interactive current page in a breadcrumb trail.
public struct SCBreadcrumbPage<Content: View>: View {
    @Environment(\.theme) private var theme

    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .fontWeight(.medium)
            .foregroundStyle(theme.foreground)
            .lineLimit(1)
            .accessibilityElement(children: .combine)
            .accessibilityValue(Text("Current page"))
    }
}

extension SCBreadcrumbPage where Content == Text {
    public init(_ text: String) {
        self.init { Text(text) }
    }
}

// MARK: - Separator and ellipsis

/// A presentation-only separator between breadcrumb items.
public struct SCBreadcrumbSeparator: View {
    @Environment(\.theme) private var theme

    private let content: AnyView

    public init<Content: View>(@ViewBuilder content: () -> Content) {
        self.content = AnyView(content())
    }

    public init() {
        content = AnyView(Image(systemName: "chevron.forward"))
    }

    public var body: some View {
        content
            .font(.caption2)
            .foregroundStyle(theme.mutedForeground)
            .accessibilityHidden(true)
    }
}

/// The accessible “More” placeholder for collapsed breadcrumb items.
public struct SCBreadcrumbEllipsis: View {
    @Environment(\.theme) private var theme

    private let accessibilityLabel: String

    public init(accessibilityLabel: String = "More") {
        self.accessibilityLabel = accessibilityLabel
    }

    public var body: some View {
        Image(systemName: "ellipsis")
            .font(.footnote)
            .foregroundStyle(theme.mutedForeground)
            .frame(width: 20, height: 20)
            .accessibilityLabel(Text(accessibilityLabel))
    }
}

// MARK: - Array convenience

extension SCBreadcrumb {
    /// Builds the composable primitives from the original array API.
    public init(
        items: [SCBreadcrumbItem],
        maxVisible: Int? = nil,
        accessibilityLabel: String = "Breadcrumb"
    ) {
        self.init(accessibilityLabel: accessibilityLabel) {
            SCBreadcrumbArrayContent(items: items, maxVisible: maxVisible)
        }
    }
}

private struct SCBreadcrumbArrayContent: View {
    @Environment(\.theme) private var theme

    var items: [SCBreadcrumbItem]
    var maxVisible: Int?

    var body: some View {
        SCBreadcrumbList {
            ForEach(Array(elements.enumerated()), id: \.offset) { index, element in
                if index > 0 { SCBreadcrumbSeparator() }
                switch element {
                case .item(let item, let isCurrent):
                    if let label = item.convenienceLabel {
                        if isCurrent {
                            SCBreadcrumbItem { SCBreadcrumbPage(label) }
                        } else if let action = item.convenienceAction {
                            SCBreadcrumbItem {
                                SCBreadcrumbLink(action: action) { Text(label) }
                            }
                        } else {
                            SCBreadcrumbItem {
                                Text(label)
                                    .foregroundStyle(theme.mutedForeground)
                                    .lineLimit(1)
                            }
                        }
                    } else {
                        item
                    }
                case .ellipsis:
                    SCBreadcrumbItem { SCBreadcrumbEllipsis() }
                }
            }
        }
    }

    private enum Element {
        case item(SCBreadcrumbItem, isCurrent: Bool)
        case ellipsis
    }

    private var elements: [Element] {
        guard !items.isEmpty else { return [] }
        guard let maxVisible, items.count > maxVisible else {
            return items.enumerated().map {
                .item($0.element, isCurrent: $0.offset == items.count - 1)
            }
        }

        let limit = max(maxVisible, 3)
        let suffixCount = max(limit - 2, 1)
        let suffix = items.suffix(suffixCount)
        return [.item(items[0], isCurrent: false), .ellipsis]
            + suffix.enumerated().map { offset, item in
                .item(item, isCurrent: offset == suffix.count - 1)
            }
    }
}

// MARK: - Previews

#Preview("Breadcrumb · composition") {
    SCPreview {
        SCBreadcrumb {
            SCBreadcrumbList {
                SCBreadcrumbItem {
                    SCBreadcrumbLink(action: {}, label: { Text("Home") })
                }
                SCBreadcrumbSeparator()
                SCBreadcrumbItem {
                    SCBreadcrumbLink(action: {}, label: { Text("Components") })
                }
                SCBreadcrumbSeparator { Text("/") }
                SCBreadcrumbItem { SCBreadcrumbPage("Breadcrumb") }
            }
        }
    }
}

#Preview("Breadcrumb · collapsed convenience") {
    SCPreview {
        SCBreadcrumb(
            items: [
                SCBreadcrumbItem("Home") {},
                SCBreadcrumbItem("Documentation") {},
                SCBreadcrumbItem("Building Blocks") {},
                SCBreadcrumbItem("Components") {},
                SCBreadcrumbItem("Breadcrumb"),
            ],
            maxVisible: 4
        )
        .frame(width: 260)
    }
}
