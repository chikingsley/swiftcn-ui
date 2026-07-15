// ============================================================
// Pagination.swift — swiftcn-ui
// Depends on: Theme/, Button.swift
// ============================================================
import SwiftUI

// MARK: - Root composition

/// A navigation landmark for caller-composed page controls.
public struct SCPagination<Content: View>: View {
    private let accessibilityLabel: String
    private let fillsAvailableWidth: Bool
    private let alignment: Alignment
    private let isDisabled: Bool
    private let content: Content

    public init(
        accessibilityLabel: String = "Pagination",
        fillsAvailableWidth: Bool = true,
        alignment: Alignment = .center,
        isDisabled: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.accessibilityLabel = accessibilityLabel
        self.fillsAvailableWidth = fillsAvailableWidth
        self.alignment = alignment
        self.isDisabled = isDisabled
        self.content = content()
    }

    public var body: some View {
        content
            .frame(
                maxWidth: fillsAvailableWidth ? .infinity : nil,
                alignment: alignment
            )
            .disabled(isDisabled)
            .accessibilityElement(children: .contain)
            .accessibilityLabel(Text(accessibilityLabel))
    }
}

/// The horizontal collection of `SCPaginationItem` parts.
public struct SCPaginationContent<Content: View>: View {
    private let spacing: CGFloat
    private let content: Content

    public init(spacing: CGFloat = 4, @ViewBuilder content: () -> Content) {
        self.spacing = max(spacing, 0)
        self.content = content()
    }

    public var body: some View {
        HStack(spacing: spacing) { content }
            .accessibilityElement(children: .contain)
    }
}

/// One structural cell in `SCPaginationContent`.
public struct SCPaginationItem<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View { content }
}

// MARK: - Link

/// A real URL link or native button using the official active-page Button
/// variants: outline when current, ghost otherwise.
public struct SCPaginationLink<Label: View>: View {
    private let destination: URL?
    private let action: (() -> Void)?
    private let isActive: Bool
    private let size: SCButtonSize
    private let isDisabled: Bool
    private let accessibilityLabel: String?
    private let label: Label

    public init(
        destination: URL,
        isActive: Bool = false,
        size: SCButtonSize = .icon,
        isDisabled: Bool = false,
        accessibilityLabel: String? = nil,
        @ViewBuilder label: () -> Label
    ) {
        self.destination = destination
        self.action = nil
        self.isActive = isActive
        self.size = size
        self.isDisabled = isDisabled
        self.accessibilityLabel = accessibilityLabel
        self.label = label()
    }

    public init(
        isActive: Bool = false,
        size: SCButtonSize = .icon,
        isDisabled: Bool = false,
        accessibilityLabel: String? = nil,
        action: @escaping () -> Void,
        @ViewBuilder label: () -> Label
    ) {
        self.destination = nil
        self.action = action
        self.isActive = isActive
        self.size = size
        self.isDisabled = isDisabled
        self.accessibilityLabel = accessibilityLabel
        self.label = label()
    }

    public var body: some View {
        control
            .buttonStyle(.sc(isActive ? .outline : .ghost, size: size))
            .disabled(isDisabled)
            .modifier(
                SCPaginationLinkAccessibility(
                    label: accessibilityLabel,
                    isActive: isActive
                )
            )
    }

    @ViewBuilder
    private var control: some View {
        if let destination {
            Link(destination: destination) { label }
        } else {
            Button(action: action ?? {}) { label }
        }
    }
}

extension SCPaginationLink where Label == Text {
    public init(
        _ title: String,
        destination: URL,
        isActive: Bool = false,
        size: SCButtonSize = .icon,
        isDisabled: Bool = false,
        accessibilityLabel: String? = nil
    ) {
        self.init(
            destination: destination,
            isActive: isActive,
            size: size,
            isDisabled: isDisabled,
            accessibilityLabel: accessibilityLabel
        ) {
            Text(title)
        }
    }

    public init(
        _ title: String,
        isActive: Bool = false,
        size: SCButtonSize = .icon,
        isDisabled: Bool = false,
        accessibilityLabel: String? = nil,
        action: @escaping () -> Void
    ) {
        self.init(
            isActive: isActive,
            size: size,
            isDisabled: isDisabled,
            accessibilityLabel: accessibilityLabel,
            action: action
        ) {
            Text(title)
        }
    }
}

/// A real value-based SwiftUI `NavigationLink` with the same page-link chrome.
public struct SCPaginationNavigationLink<Value: Hashable, Label: View>: View {
    private let value: Value
    private let isActive: Bool
    private let size: SCButtonSize
    private let isDisabled: Bool
    private let accessibilityLabel: String?
    private let label: Label

    public init(
        value: Value,
        isActive: Bool = false,
        size: SCButtonSize = .icon,
        isDisabled: Bool = false,
        accessibilityLabel: String? = nil,
        @ViewBuilder label: () -> Label
    ) {
        self.value = value
        self.isActive = isActive
        self.size = size
        self.isDisabled = isDisabled
        self.accessibilityLabel = accessibilityLabel
        self.label = label()
    }

    public var body: some View {
        NavigationLink(value: value) { label }
            .buttonStyle(.sc(isActive ? .outline : .ghost, size: size))
            .disabled(isDisabled)
            .modifier(
                SCPaginationLinkAccessibility(
                    label: accessibilityLabel,
                    isActive: isActive
                )
            )
    }
}

private struct SCPaginationLinkAccessibility: ViewModifier {
    let label: String?
    let isActive: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if let label, isActive {
            content
                .accessibilityLabel(Text(label))
                .accessibilityValue(Text("Current page"))
                .accessibilityAddTraits(.isSelected)
        } else if let label {
            content.accessibilityLabel(Text(label))
        } else if isActive {
            content
                .accessibilityValue(Text("Current page"))
                .accessibilityAddTraits(.isSelected)
        } else {
            content
        }
    }
}

// MARK: - Previous and next

public enum SCPaginationControlLabelVisibility: CaseIterable, Hashable, Sendable {
    /// Prefer text plus icon, falling back to icon-only when width is tight.
    case automatic
    case visible
    case hidden
}

private enum SCPaginationActivation {
    case destination(URL)
    case action(() -> Void)
}

/// A localized previous-page control with a logical backward icon.
public struct SCPaginationPrevious: View {
    private let activation: SCPaginationActivation
    private let text: String
    private let labelVisibility: SCPaginationControlLabelVisibility
    private let isDisabled: Bool
    private let accessibilityLabel: String

    public init(
        destination: URL,
        text: String = "Previous",
        labelVisibility: SCPaginationControlLabelVisibility = .automatic,
        isDisabled: Bool = false,
        accessibilityLabel: String = "Go to previous page"
    ) {
        self.activation = .destination(destination)
        self.text = text
        self.labelVisibility = labelVisibility
        self.isDisabled = isDisabled
        self.accessibilityLabel = accessibilityLabel
    }

    public init(
        text: String = "Previous",
        labelVisibility: SCPaginationControlLabelVisibility = .automatic,
        isDisabled: Bool = false,
        accessibilityLabel: String = "Go to previous page",
        action: @escaping () -> Void
    ) {
        self.activation = .action(action)
        self.text = text
        self.labelVisibility = labelVisibility
        self.isDisabled = isDisabled
        self.accessibilityLabel = accessibilityLabel
    }

    @ViewBuilder
    public var body: some View {
        switch activation {
        case .destination(let destination):
            SCPaginationLink(
                destination: destination,
                size: .default,
                isDisabled: isDisabled,
                accessibilityLabel: accessibilityLabel
            ) {
                label
            }
        case .action(let action):
            SCPaginationLink(
                size: .default,
                isDisabled: isDisabled,
                accessibilityLabel: accessibilityLabel,
                action: action
            ) {
                label
            }
        }
    }

    @ViewBuilder
    private var label: some View {
        switch labelVisibility {
        case .automatic:
            ViewThatFits(in: .horizontal) {
                fullLabel
                icon
            }
        case .visible:
            fullLabel
        case .hidden:
            icon
        }
    }

    private var fullLabel: some View {
        HStack(spacing: 4) {
            icon
            Text(text)
        }
    }

    private var icon: some View {
        Image(systemName: "chevron.backward")
    }
}

/// A localized next-page control with a logical forward icon.
public struct SCPaginationNext: View {
    private let activation: SCPaginationActivation
    private let text: String
    private let labelVisibility: SCPaginationControlLabelVisibility
    private let isDisabled: Bool
    private let accessibilityLabel: String

    public init(
        destination: URL,
        text: String = "Next",
        labelVisibility: SCPaginationControlLabelVisibility = .automatic,
        isDisabled: Bool = false,
        accessibilityLabel: String = "Go to next page"
    ) {
        self.activation = .destination(destination)
        self.text = text
        self.labelVisibility = labelVisibility
        self.isDisabled = isDisabled
        self.accessibilityLabel = accessibilityLabel
    }

    public init(
        text: String = "Next",
        labelVisibility: SCPaginationControlLabelVisibility = .automatic,
        isDisabled: Bool = false,
        accessibilityLabel: String = "Go to next page",
        action: @escaping () -> Void
    ) {
        self.activation = .action(action)
        self.text = text
        self.labelVisibility = labelVisibility
        self.isDisabled = isDisabled
        self.accessibilityLabel = accessibilityLabel
    }

    @ViewBuilder
    public var body: some View {
        switch activation {
        case .destination(let destination):
            SCPaginationLink(
                destination: destination,
                size: .default,
                isDisabled: isDisabled,
                accessibilityLabel: accessibilityLabel
            ) {
                label
            }
        case .action(let action):
            SCPaginationLink(
                size: .default,
                isDisabled: isDisabled,
                accessibilityLabel: accessibilityLabel,
                action: action
            ) {
                label
            }
        }
    }

    @ViewBuilder
    private var label: some View {
        switch labelVisibility {
        case .automatic:
            ViewThatFits(in: .horizontal) {
                fullLabel
                icon
            }
        case .visible:
            fullLabel
        case .hidden:
            icon
        }
    }

    private var fullLabel: some View {
        HStack(spacing: 4) {
            Text(text)
            icon
        }
    }

    private var icon: some View {
        Image(systemName: "chevron.forward")
    }
}

// MARK: - Ellipsis

/// The noninteractive gap marker between noncontiguous page links.
public struct SCPaginationEllipsis: View {
    @Environment(\.theme) private var theme

    private let accessibilityLabel: String
    private let isAccessibilityHidden: Bool

    public init(
        accessibilityLabel: String = "More pages",
        isAccessibilityHidden: Bool = true
    ) {
        self.accessibilityLabel = accessibilityLabel
        self.isAccessibilityHidden = isAccessibilityHidden
    }

    public var body: some View {
        Image(systemName: "ellipsis")
            .font(.subheadline.weight(.medium))
            .foregroundStyle(theme.mutedForeground)
            .frame(minWidth: 36, minHeight: 36)
            .accessibilityLabel(Text(accessibilityLabel))
            .accessibilityHidden(isAccessibilityHidden)
    }
}

// MARK: - Windowed convenience composition

extension SCPagination where Content == AnyView {
    /// Builds the common controlled, windowed page-number composition from the
    /// same public Root, Content, Item, Link, Previous, Next, and Ellipsis parts.
    public init(
        current: Binding<Int>,
        total: Int,
        maxVisible: Int = 7,
        previousText: String = "Previous",
        nextText: String = "Next",
        controlLabelVisibility: SCPaginationControlLabelVisibility = .automatic,
        accessibilityLabel: String = "Pagination",
        isDisabled: Bool = false,
        formatPage: @escaping (Int) -> String = { String($0) },
        pageAccessibilityLabel: @escaping (Int) -> String = { "Page \($0)" },
        onPageChange: ((Int) -> Void)? = nil
    ) {
        self.init(accessibilityLabel: accessibilityLabel, isDisabled: isDisabled) {
            AnyView(
                SCPaginationWindow(
                    current: current,
                    total: total,
                    maxVisible: maxVisible,
                    previousText: previousText,
                    nextText: nextText,
                    controlLabelVisibility: controlLabelVisibility,
                    formatPage: formatPage,
                    pageAccessibilityLabel: pageAccessibilityLabel,
                    onPageChange: onPageChange
                )
            )
        }
    }
}

private struct SCPaginationWindow: View {
    @Binding var current: Int

    let total: Int
    let maxVisible: Int
    let previousText: String
    let nextText: String
    let controlLabelVisibility: SCPaginationControlLabelVisibility
    let formatPage: (Int) -> String
    let pageAccessibilityLabel: (Int) -> String
    let onPageChange: ((Int) -> Void)?

    var body: some View {
        SCPaginationContent {
            SCPaginationItem {
                SCPaginationPrevious(
                    text: previousText,
                    labelVisibility: controlLabelVisibility,
                    isDisabled: effectiveCurrent <= 1,
                    action: { select(effectiveCurrent - 1) }
                )
            }

            ForEach(cells) { cell in
                SCPaginationItem {
                    switch cell {
                    case .page(let page):
                        SCPaginationLink(
                            isActive: page == effectiveCurrent,
                            accessibilityLabel: pageAccessibilityLabel(page),
                            action: { select(page) },
                            label: { Text(formatPage(page)).monospacedDigit() }
                        )
                    case .ellipsis:
                        SCPaginationEllipsis()
                    }
                }
            }

            SCPaginationItem {
                SCPaginationNext(
                    text: nextText,
                    labelVisibility: controlLabelVisibility,
                    isDisabled: totalPages == 0 || effectiveCurrent >= totalPages,
                    action: { select(effectiveCurrent + 1) }
                )
            }
        }
    }

    private enum Cell: Hashable, Identifiable {
        case page(Int)
        case ellipsis(edge: Int)

        var id: Cell { self }
    }

    private var totalPages: Int {
        max(total, 0)
    }

    private var visibleCellLimit: Int {
        max(maxVisible, 5)
    }

    private var effectiveCurrent: Int {
        guard totalPages > 0 else { return 0 }
        return min(max(current, 1), totalPages)
    }

    private var cells: [Cell] {
        guard totalPages > 0 else { return [] }
        guard totalPages > visibleCellLimit else {
            return (1...totalPages).map(Cell.page)
        }

        if effectiveCurrent <= visibleCellLimit - 3 {
            return (1...(visibleCellLimit - 2)).map(Cell.page)
                + [.ellipsis(edge: 1), .page(totalPages)]
        }

        if effectiveCurrent >= totalPages - (visibleCellLimit - 4) {
            return [.page(1), .ellipsis(edge: 0)]
                + ((totalPages - (visibleCellLimit - 3))...totalPages).map(Cell.page)
        }

        let windowCount = visibleCellLimit - 4
        let low = effectiveCurrent - (windowCount - 1) / 2
        return [.page(1), .ellipsis(edge: 0)]
            + (low...(low + windowCount - 1)).map(Cell.page)
            + [.ellipsis(edge: 1), .page(totalPages)]
    }

    private func select(_ page: Int) {
        guard totalPages > 0 else { return }
        let nextPage = min(max(page, 1), totalPages)
        guard nextPage != current else { return }
        current = nextPage
        onPageChange?(nextPage)
    }
}

// MARK: - Previews

#Preview("Pagination · official composition") {
    SCPreview {
        SCPagination {
            SCPaginationContent {
                SCPaginationItem {
                    SCPaginationPrevious(isDisabled: true, action: {})
                }
                SCPaginationItem {
                    SCPaginationLink("1", action: {})
                }
                SCPaginationItem {
                    SCPaginationLink("2", isActive: true, action: {})
                }
                SCPaginationItem {
                    SCPaginationLink("3", action: {})
                }
                SCPaginationItem {
                    SCPaginationEllipsis()
                }
                SCPaginationItem {
                    SCPaginationNext(action: {})
                }
            }
        }
    }
}

#Preview("Pagination · windowed and RTL") {
    @Previewable @State var page = 25

    SCPreview {
        VStack(spacing: 20) {
            SCPagination(current: $page, total: 50)
            SCDirectionProvider(.rtl) {
                SCPagination(
                    current: $page,
                    total: 50,
                    previousText: "السابق",
                    nextText: "التالي",
                    formatPage: { String($0) }
                )
            }
        }
    }
}
