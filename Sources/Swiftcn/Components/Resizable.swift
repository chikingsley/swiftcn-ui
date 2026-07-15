// ============================================================
// Resizable.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

#if os(macOS)
    import AppKit
#endif

// MARK: - Layout value

/// Panel sizes keyed by stable panel IDs. Values are fractions from zero to one.
public struct SCResizableLayout: Equatable {
    public var sizes: [String: CGFloat]

    public init(_ sizes: [String: CGFloat] = [:]) {
        self.sizes = sizes
    }

    public subscript(_ panelID: String) -> CGFloat? {
        get { sizes[panelID] }
        set { sizes[panelID] = newValue }
    }
}

// MARK: - Builder plumbing

private struct SCResizablePanelDefinition {
    let id: String
    let defaultSize: CGFloat?
    let minimumSize: CGFloat
    let maximumSize: CGFloat
    let isCollapsible: Bool
    let collapsedSize: CGFloat
    let onResize: ((CGFloat) -> Void)?
    let content: AnyView
}

private struct SCResizableHandleDefinition {
    let id: UUID
    let withHandle: Bool
    let isDisabled: Bool
    let keyboardStep: CGFloat
    let resetsOnDoubleClick: Bool
    let accessibilityLabel: String
}

private enum SCResizableElement {
    case panel(SCResizablePanelDefinition)
    case handle(SCResizableHandleDefinition)

    var identity: String {
        switch self {
        case .panel(let panel): "panel-\(panel.id)"
        case .handle(let handle): "handle-\(handle.id.uuidString)"
        }
    }
}

/// The opaque result produced by `SCResizableGroupBuilder`.
public struct SCResizableGroupContent {
    fileprivate var elements: [SCResizableElement]

    fileprivate init(elements: [SCResizableElement] = []) {
        self.elements = elements
    }
}

/// Builds a static sequence of Panels and Handles for a resizable group.
@resultBuilder
public enum SCResizableGroupBuilder {
    public static func buildExpression<Content: View>(
        _ panel: SCResizablePanel<Content>
    ) -> SCResizableGroupContent {
        SCResizableGroupContent(elements: [.panel(panel.definition)])
    }

    public static func buildExpression(
        _ handle: SCResizableHandle
    ) -> SCResizableGroupContent {
        SCResizableGroupContent(elements: [.handle(handle.definition)])
    }

    public static func buildBlock(
        _ components: SCResizableGroupContent...
    ) -> SCResizableGroupContent {
        SCResizableGroupContent(elements: components.flatMap(\.elements))
    }

    public static func buildOptional(
        _ component: SCResizableGroupContent?
    ) -> SCResizableGroupContent {
        component ?? SCResizableGroupContent()
    }

    public static func buildEither(
        first component: SCResizableGroupContent
    ) -> SCResizableGroupContent {
        component
    }

    public static func buildEither(
        second component: SCResizableGroupContent
    ) -> SCResizableGroupContent {
        component
    }

    public static func buildArray(
        _ components: [SCResizableGroupContent]
    ) -> SCResizableGroupContent {
        SCResizableGroupContent(elements: components.flatMap(\.elements))
    }

    public static func buildLimitedAvailability(
        _ component: SCResizableGroupContent
    ) -> SCResizableGroupContent {
        component
    }
}

// MARK: - Panel and Handle definitions

/// Declares one arbitrary-content panel inside an `SCResizablePanelGroup`.
public struct SCResizablePanel<Content: View> {
    fileprivate let definition: SCResizablePanelDefinition

    public init(
        id: String = UUID().uuidString,
        defaultSize: CGFloat? = nil,
        minimumSize: CGFloat = 0,
        maximumSize: CGFloat = 1,
        isCollapsible: Bool = false,
        collapsedSize: CGFloat = 0,
        onResize: ((CGFloat) -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        let minimum = min(max(minimumSize, 0), 1)
        let maximum = min(max(maximumSize, minimum), 1)
        self.definition = SCResizablePanelDefinition(
            id: id,
            defaultSize: defaultSize.map { min(max($0, 0), 1) },
            minimumSize: minimum,
            maximumSize: maximum,
            isCollapsible: isCollapsible,
            collapsedSize: min(max(collapsedSize, 0), minimum),
            onResize: onResize,
            content: AnyView(content())
        )
    }
}

/// Declares a real draggable, keyboard-adjustable separator between Panels.
public struct SCResizableHandle {
    fileprivate let definition: SCResizableHandleDefinition

    public init(
        withHandle: Bool = false,
        isDisabled: Bool = false,
        keyboardStep: CGFloat = 0.02,
        resetsOnDoubleClick: Bool = true,
        accessibilityLabel: String = "Resize panels"
    ) {
        self.definition = SCResizableHandleDefinition(
            id: UUID(),
            withHandle: withHandle,
            isDisabled: isDisabled,
            keyboardStep: min(max(keyboardStep, 0.001), 1),
            resetsOnDoubleClick: resetsOnDoubleClick,
            accessibilityLabel: accessibilityLabel
        )
    }
}

// MARK: - Panel Group

/// Owns the layout, constraints, and interaction of composed Panels and Handles.
public struct SCResizablePanelGroup: View {
    private let orientation: Axis
    private let externalLayout: Binding<SCResizableLayout>?
    private let initialLayout: SCResizableLayout
    private let elements: [SCResizableElement]
    private let onLayoutChange: ((SCResizableLayout) -> Void)?
    private let handleThickness: CGFloat
    private let dragTargetThickness: CGFloat

    @State private var internalLayout: SCResizableLayout
    @State private var dragBases: [UUID: SCResizableLayout] = [:]
    @State private var activeHandles: Set<UUID> = []

    /// Creates an internally managed group.
    public init(
        _ orientation: Axis = .horizontal,
        defaultLayout: SCResizableLayout = SCResizableLayout(),
        handleThickness: CGFloat = 1,
        dragTargetThickness: CGFloat = 11,
        onLayoutChange: ((SCResizableLayout) -> Void)? = nil,
        @SCResizableGroupBuilder content: () -> SCResizableGroupContent
    ) {
        let elements = content().elements
        let resolved = Self.resolvedLayout(for: elements, proposed: defaultLayout)
        self.orientation = orientation
        self.externalLayout = nil
        self.initialLayout = resolved
        self.elements = elements
        self.onLayoutChange = onLayoutChange
        self.handleThickness = max(handleThickness, 1)
        self.dragTargetThickness = max(dragTargetThickness, handleThickness, 1)
        self._internalLayout = State(initialValue: resolved)
    }

    /// Creates a caller-controlled group.
    public init(
        _ orientation: Axis = .horizontal,
        layout: Binding<SCResizableLayout>,
        handleThickness: CGFloat = 1,
        dragTargetThickness: CGFloat = 11,
        onLayoutChange: ((SCResizableLayout) -> Void)? = nil,
        @SCResizableGroupBuilder content: () -> SCResizableGroupContent
    ) {
        let elements = content().elements
        let resolved = Self.resolvedLayout(for: elements, proposed: layout.wrappedValue)
        self.orientation = orientation
        self.externalLayout = layout
        self.initialLayout = resolved
        self.elements = elements
        self.onLayoutChange = onLayoutChange
        self.handleThickness = max(handleThickness, 1)
        self.dragTargetThickness = max(dragTargetThickness, handleThickness, 1)
        self._internalLayout = State(initialValue: resolved)
    }

    public var body: some View {
        GeometryReader { geometry in
            let totalLength = orientation == .horizontal ? geometry.size.width : geometry.size.height
            let handleCount = elements.reduce(into: 0) { count, element in
                if case .handle = element { count += 1 }
            }
            let availableLength = max(totalLength - CGFloat(handleCount) * handleThickness, 0)
            let stack =
                orientation == .horizontal
                ? AnyLayout(HStackLayout(spacing: 0))
                : AnyLayout(VStackLayout(spacing: 0))

            stack {
                ForEach(Array(elements.enumerated()), id: \.element.identity) { index, element in
                    elementView(element, index: index, availableLength: availableLength)
                }
            }
        }
        .onAppear {
            notifyPanels(layout)
        }
    }

    @ViewBuilder
    private func elementView(
        _ element: SCResizableElement,
        index: Int,
        availableLength: CGFloat
    ) -> some View {
        switch element {
        case .panel(let panel):
            panel.content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .frame(
                    width: orientation == .horizontal
                        ? availableLength * (layout[panel.id] ?? 0) : nil,
                    height: orientation == .vertical
                        ? availableLength * (layout[panel.id] ?? 0) : nil
                )
                .clipped()
        case .handle(let handle):
            SCResizableHandleView(
                orientation: orientation,
                withHandle: handle.withHandle,
                isDisabled: handle.isDisabled,
                isActive: activeHandles.contains(handle.id),
                visibleThickness: handleThickness,
                targetThickness: dragTargetThickness,
                accessibilityLabel: handle.accessibilityLabel,
                accessibilityValue: handleValue(at: index),
                onDragBegan: { beginDrag(handle: handle) },
                onDragChanged: { translation in
                    resize(
                        at: index,
                        handle: handle,
                        delta: availableLength > 0 ? translation / availableLength : 0
                    )
                },
                onDragEnded: { endDrag(handle: handle) },
                onAdjust: { direction in
                    adjust(at: index, by: direction * handle.keyboardStep)
                },
                onReset: handle.resetsOnDoubleClick ? reset : nil
            )
            .zIndex(1)
        }
    }

    private var layout: SCResizableLayout {
        Self.resolvedLayout(
            for: elements,
            proposed: externalLayout?.wrappedValue ?? internalLayout
        )
    }

    private func beginDrag(handle: SCResizableHandleDefinition) {
        dragBases[handle.id] = layout
        activeHandles.insert(handle.id)
    }

    private func resize(
        at handleIndex: Int,
        handle: SCResizableHandleDefinition,
        delta: CGFloat
    ) {
        let base = dragBases[handle.id] ?? layout
        guard let pair = adjacentPanels(to: handleIndex) else { return }
        applyResize(pair: pair, proposedLeading: (base[pair.leading.id] ?? 0) + delta, base: base)
    }

    private func endDrag(handle: SCResizableHandleDefinition) {
        dragBases[handle.id] = nil
        activeHandles.remove(handle.id)
    }

    private func adjust(at handleIndex: Int, by delta: CGFloat) {
        guard let pair = adjacentPanels(to: handleIndex) else { return }
        let current = layout
        applyResize(
            pair: pair,
            proposedLeading: (current[pair.leading.id] ?? 0) + delta,
            base: current
        )
    }

    private func applyResize(
        pair: (leading: SCResizablePanelDefinition, trailing: SCResizablePanelDefinition),
        proposedLeading: CGFloat,
        base: SCResizableLayout
    ) {
        let leadingSize = base[pair.leading.id] ?? 0
        let trailingSize = base[pair.trailing.id] ?? 0
        let pairTotal = leadingSize + trailingSize
        guard pairTotal > 0 else { return }

        var proposal = proposedLeading
        var leadingMinimum = pair.leading.minimumSize
        var trailingMinimum = pair.trailing.minimumSize

        if pair.leading.isCollapsible, proposal < pair.leading.minimumSize {
            proposal = pair.leading.collapsedSize
            leadingMinimum = pair.leading.collapsedSize
        }
        let trailingWouldCollapse =
            pair.trailing.isCollapsible
            && pairTotal - proposal < pair.trailing.minimumSize
        if trailingWouldCollapse {
            proposal = pairTotal - pair.trailing.collapsedSize
            trailingMinimum = pair.trailing.collapsedSize
        }

        let lowerBound = max(leadingMinimum, pairTotal - pair.trailing.maximumSize)
        let upperBound = min(pair.leading.maximumSize, pairTotal - trailingMinimum)
        guard lowerBound <= upperBound else { return }

        let nextLeading = min(max(proposal, lowerBound), upperBound)
        let nextTrailing = pairTotal - nextLeading
        var next = base
        next[pair.leading.id] = nextLeading
        next[pair.trailing.id] = nextTrailing
        setLayout(next)
    }

    private func reset() {
        setLayout(initialLayout)
    }

    private func setLayout(_ nextLayout: SCResizableLayout) {
        if let externalLayout {
            externalLayout.wrappedValue = nextLayout
        } else {
            internalLayout = nextLayout
        }
        onLayoutChange?(nextLayout)
        notifyPanels(nextLayout)
    }

    private func notifyPanels(_ layout: SCResizableLayout) {
        for case .panel(let panel) in elements {
            panel.onResize?(layout[panel.id] ?? 0)
        }
    }

    private func adjacentPanels(
        to handleIndex: Int
    ) -> (leading: SCResizablePanelDefinition, trailing: SCResizablePanelDefinition)? {
        let leading = elements[..<handleIndex].reversed().compactMap { element in
            if case .panel(let panel) = element { return panel }
            return nil
        }.first
        let trailing = elements[(handleIndex + 1)...].compactMap { element in
            if case .panel(let panel) = element { return panel }
            return nil
        }.first
        guard let leading, let trailing else { return nil }
        return (leading, trailing)
    }

    private func handleValue(at index: Int) -> String {
        guard let pair = adjacentPanels(to: index) else { return "Unavailable" }
        return "\(Int(((layout[pair.leading.id] ?? 0) * 100).rounded())) percent"
    }

    private static func resolvedLayout(
        for elements: [SCResizableElement],
        proposed: SCResizableLayout
    ) -> SCResizableLayout {
        let panels = elements.compactMap { element -> SCResizablePanelDefinition? in
            if case .panel(let panel) = element { return panel }
            return nil
        }
        guard !panels.isEmpty else { return SCResizableLayout() }

        let specifiedTotal = panels.reduce(CGFloat.zero) { total, panel in
            total + max(proposed[panel.id] ?? panel.defaultSize ?? 0, 0)
        }
        let unspecified = panels.filter {
            proposed[$0.id] == nil && $0.defaultSize == nil
        }
        let remaining = max(1 - specifiedTotal, 0)
        let fallback = unspecified.isEmpty ? 0 : remaining / CGFloat(unspecified.count)

        var sizes: [String: CGFloat] = [:]
        for panel in panels {
            let raw = proposed[panel.id] ?? panel.defaultSize ?? fallback
            sizes[panel.id] = min(max(raw, panel.minimumSize), panel.maximumSize)
        }

        distributeDifference(1 - sizes.values.reduce(0, +), panels: panels, sizes: &sizes)
        return SCResizableLayout(sizes)
    }

    private static func distributeDifference(
        _ initialDifference: CGFloat,
        panels: [SCResizablePanelDefinition],
        sizes: inout [String: CGFloat]
    ) {
        var difference = initialDifference
        var remainingPanels = panels

        while abs(difference) > 0.0001, !remainingPanels.isEmpty {
            let share = difference / CGFloat(remainingPanels.count)
            var consumed: CGFloat = 0
            var nextPanels: [SCResizablePanelDefinition] = []

            for panel in remainingPanels {
                let current = sizes[panel.id] ?? 0
                let proposed = current + share
                let clamped = min(max(proposed, panel.minimumSize), panel.maximumSize)
                sizes[panel.id] = clamped
                consumed += clamped - current

                let hasCapacity =
                    difference > 0
                    ? clamped < panel.maximumSize
                    : clamped > panel.minimumSize
                if hasCapacity { nextPanels.append(panel) }
            }

            guard abs(consumed) > 0.0001 else { break }
            difference -= consumed
            remainingPanels = nextPanels
        }
    }
}

// MARK: - Interactive Handle

private struct SCResizableHandleView: View {
    @Environment(\.theme) private var theme
    @FocusState private var isFocused: Bool

    let orientation: Axis
    let withHandle: Bool
    let isDisabled: Bool
    let isActive: Bool
    let visibleThickness: CGFloat
    let targetThickness: CGFloat
    let accessibilityLabel: String
    let accessibilityValue: String
    let onDragBegan: () -> Void
    let onDragChanged: (CGFloat) -> Void
    let onDragEnded: () -> Void
    let onAdjust: (CGFloat) -> Void
    let onReset: (() -> Void)?

    @State private var isDragging = false

    var body: some View {
        Rectangle()
            .fill(isActive || isFocused ? theme.ring : theme.border)
            .frame(
                width: orientation == .horizontal ? visibleThickness : nil,
                height: orientation == .vertical ? visibleThickness : nil
            )
            .overlay { grip }
            .overlay { interactionTarget }
    }

    @ViewBuilder
    private var grip: some View {
        if withHandle {
            RoundedRectangle(cornerRadius: 3, style: .continuous)
                .fill(theme.background)
                .frame(
                    width: orientation == .horizontal ? 10 : 24,
                    height: orientation == .horizontal ? 24 : 10
                )
                .overlay {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 8, weight: .bold))
                        .rotationEffect(orientation == .horizontal ? .degrees(90) : .zero)
                        .foregroundStyle(theme.mutedForeground)
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .stroke(theme.border)
                }
        }
    }

    private var interactionTarget: some View {
        Color.clear
            .frame(
                width: orientation == .horizontal ? targetThickness : nil,
                height: orientation == .vertical ? targetThickness : nil
            )
            .contentShape(Rectangle())
            .focusable(!isDisabled)
            .focused($isFocused)
            .gesture(dragGesture)
            .onTapGesture(count: 2) {
                guard !isDisabled else { return }
                onReset?()
            }
            .onKeyPress(.leftArrow) {
                guard !isDisabled, orientation == .horizontal else { return .ignored }
                onAdjust(-1)
                return .handled
            }
            .onKeyPress(.rightArrow) {
                guard !isDisabled, orientation == .horizontal else { return .ignored }
                onAdjust(1)
                return .handled
            }
            .onKeyPress(.upArrow) {
                guard !isDisabled, orientation == .vertical else { return .ignored }
                onAdjust(-1)
                return .handled
            }
            .onKeyPress(.downArrow) {
                guard !isDisabled, orientation == .vertical else { return .ignored }
                onAdjust(1)
                return .handled
            }
            .resizeCursor(orientation)
            .accessibilityElement()
            .accessibilityLabel(accessibilityLabel)
            .accessibilityValue(accessibilityValue)
            .accessibilityAdjustableAction { direction in
                guard !isDisabled else { return }
                switch direction {
                case .increment: onAdjust(1)
                case .decrement: onAdjust(-1)
                @unknown default: break
                }
            }
    }

    private var dragGesture: some Gesture {
        DragGesture(minimumDistance: 1)
            .onChanged { value in
                guard !isDisabled else { return }
                if !isDragging {
                    isDragging = true
                    onDragBegan()
                }
                onDragChanged(
                    orientation == .horizontal
                        ? value.translation.width
                        : value.translation.height
                )
            }
            .onEnded { _ in
                guard isDragging else { return }
                isDragging = false
                onDragEnded()
            }
    }
}

// MARK: - Two-panel convenience

/// A two-panel convenience composed entirely from Panel Group, Panels, and Handle.
public struct SCResizableSplit<First: View, Second: View>: View {
    private let orientation: Axis
    private let initialFraction: CGFloat
    private let range: ClosedRange<CGFloat>
    private let first: First
    private let second: Second

    public init(
        _ orientation: Axis = .horizontal,
        fraction initialFraction: CGFloat = 0.5,
        range: ClosedRange<CGFloat> = 0.2...0.8,
        @ViewBuilder first: () -> First,
        @ViewBuilder second: () -> Second
    ) {
        let lowerBound = min(max(range.lowerBound, 0), 1)
        let upperBound = min(max(range.upperBound, lowerBound), 1)
        self.orientation = orientation
        self.range = lowerBound...upperBound
        self.initialFraction = min(max(initialFraction, lowerBound), upperBound)
        self.first = first()
        self.second = second()
    }

    public var body: some View {
        SCResizablePanelGroup(
            orientation,
            defaultLayout: SCResizableLayout([
                "first": initialFraction,
                "second": 1 - initialFraction,
            ])
        ) {
            SCResizablePanel(
                id: "first",
                minimumSize: range.lowerBound,
                maximumSize: range.upperBound
            ) {
                first
            }
            SCResizableHandle(withHandle: true)
            SCResizablePanel(
                id: "second",
                minimumSize: 1 - range.upperBound,
                maximumSize: 1 - range.lowerBound
            ) {
                second
            }
        }
    }
}

// MARK: - Cursor

extension View {
    @ViewBuilder
    fileprivate func resizeCursor(_ orientation: Axis) -> some View {
        #if os(macOS)
            onHover { hovering in
                if hovering {
                    (orientation == .horizontal ? NSCursor.resizeLeftRight : NSCursor.resizeUpDown)
                        .push()
                } else {
                    NSCursor.pop()
                }
            }
        #else
            self
        #endif
    }
}

// MARK: - Previews

private struct ResizablePreviewPane: View {
    @Environment(\.theme) private var theme
    let label: String

    var body: some View {
        RoundedRectangle(cornerRadius: theme.radius, style: .continuous)
            .fill(theme.muted)
            .overlay { Text(label).font(.footnote.weight(.medium)) }
            .padding(6)
    }
}

#Preview("Resizable · controlled and nested") {
    @Previewable @State var layout = SCResizableLayout(["left": 0.3, "right": 0.7])

    SCPreview {
        SCResizablePanelGroup(.horizontal, layout: $layout) {
            SCResizablePanel(id: "left", minimumSize: 0.2) {
                ResizablePreviewPane(label: "\(Int((layout["left"] ?? 0) * 100))%")
            }
            SCResizableHandle(withHandle: true)
            SCResizablePanel(id: "right", minimumSize: 0.3) {
                SCResizablePanelGroup(.vertical) {
                    SCResizablePanel(defaultSize: 0.25) {
                        ResizablePreviewPane(label: "Two")
                    }
                    SCResizableHandle()
                    SCResizablePanel(defaultSize: 0.75) {
                        ResizablePreviewPane(label: "Three")
                    }
                }
            }
        }
        .frame(height: 260)
    }
}
