// ============================================================
// Breadcrumb.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Item

/// One entry in an `SCBreadcrumb` trail. Items with an `action` render as
/// tappable links; the last item is the current page and is never tappable.
public struct SCBreadcrumbItem {
    public var label: String
    public var action: (() -> Void)?

    public init(_ label: String, action: (() -> Void)? = nil) {
        self.label = label
        self.action = action
    }
}

// MARK: - Component

/// Displays the path to the current resource using a hierarchy of links.
///
///     SCBreadcrumb(items: [
///         SCBreadcrumbItem("Home") { path = .home },
///         SCBreadcrumbItem("Components") { path = .components },
///         SCBreadcrumbItem("Breadcrumb"),
///     ])
///
/// Set `maxVisible` to collapse long trails behind an ellipsis — the first
/// item and the last two are kept.
public struct SCBreadcrumb: View {
    @Environment(\.theme) private var theme

    var items: [SCBreadcrumbItem]
    var maxVisible: Int?

    /// - Parameters:
    ///   - items: The trail, in order; the last item is the current page.
    ///   - maxVisible: When set and exceeded, the middle of the trail is
    ///     replaced by an ellipsis. `nil` (default) shows every item.
    public init(items: [SCBreadcrumbItem], maxVisible: Int? = nil) {
        self.items = items
        self.maxVisible = maxVisible
    }

    public var body: some View {
        HStack(spacing: 6) {
            ForEach(Array(elements.enumerated()), id: \.offset) { index, element in
                if index > 0 {
                    separator
                }
                elementView(element)
            }
        }
        .font(.footnote)
    }

    // MARK: Elements

    private enum Element {
        case item(SCBreadcrumbItem, isLast: Bool)
        case ellipsis
    }

    private var elements: [Element] {
        guard let maxVisible, items.count > maxVisible, items.count >= 4 else {
            return items.enumerated().map { .item($0.element, isLast: $0.offset == items.count - 1) }
        }
        return [
            .item(items[0], isLast: false),
            .ellipsis,
            .item(items[items.count - 2], isLast: false),
            .item(items[items.count - 1], isLast: true),
        ]
    }

    @ViewBuilder
    private func elementView(_ element: Element) -> some View {
        switch element {
        case .item(let item, let isLast):
            if isLast {
                Text(item.label)
                    .fontWeight(.medium)
                    .foregroundStyle(theme.foreground)
                    .lineLimit(1)
            } else if let action = item.action {
                Button(item.label, action: action)
                    .buttonStyle(SCBreadcrumbLinkStyle())
            } else {
                Text(item.label)
                    .foregroundStyle(theme.mutedForeground)
                    .lineLimit(1)
            }
        case .ellipsis:
            SCBreadcrumbEllipsis()
        }
    }

    private var separator: some View {
        Image(systemName: "chevron.right")
            .font(.caption2)
            .foregroundStyle(theme.mutedForeground)
            .accessibilityHidden(true)
    }
}

// MARK: - Subcomponents

/// The "…" placeholder shown where a breadcrumb trail is collapsed.
public struct SCBreadcrumbEllipsis: View {
    @Environment(\.theme) private var theme

    public init() {}

    public var body: some View {
        Image(systemName: "ellipsis")
            .font(.footnote)
            .foregroundStyle(theme.mutedForeground)
            .accessibilityLabel(Text("More"))
    }
}

// MARK: - Style

private struct SCBreadcrumbLinkStyle: ButtonStyle {
    @Environment(\.theme) private var theme

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .lineLimit(1)
            .foregroundStyle(configuration.isPressed ? theme.foreground : theme.mutedForeground)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Previews

#Preview("Breadcrumb") {
    SCPreview {
        SCBreadcrumb(items: [
            SCBreadcrumbItem("Home") {},
            SCBreadcrumbItem("Components") {},
            SCBreadcrumbItem("Breadcrumb"),
        ])
    }
}

#Preview("Breadcrumb · truncated") {
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
    }
}
