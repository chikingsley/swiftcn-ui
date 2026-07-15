// ============================================================
// RadioGroup.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Configuration

/// The layout owned by an `SCRadioGroup` root.
public enum SCRadioGroupLayout: Hashable, Sendable {
    case vertical
    case horizontal
    case grid(columns: Int)
}

/// Placement of an item's arbitrary label relative to its radio indicator.
public enum SCRadioGroupItemLabelPosition: Hashable, Sendable {
    case leading
    case trailing
}

// MARK: - Shared state

private final class SCRadioGroupKeyboardCoordinator {
    private struct Entry {
        let id: UUID
        var value: AnyHashable
        var isDisabled: Bool
        var focus: () -> Void
    }

    private var entries: [Entry] = []

    func register(
        id: UUID,
        value: AnyHashable,
        isDisabled: Bool,
        focus: @escaping () -> Void
    ) {
        if let index = entries.firstIndex(where: { $0.id == id }) {
            entries[index].value = value
            entries[index].isDisabled = isDisabled
            entries[index].focus = focus
        } else {
            entries.append(Entry(id: id, value: value, isDisabled: isDisabled, focus: focus))
        }
    }

    func unregister(id: UUID) {
        entries.removeAll { $0.id == id }
    }

    func move(
        from value: AnyHashable,
        offset: Int,
        select: (AnyHashable) -> Void
    ) {
        guard !entries.isEmpty, offset != 0 else { return }
        let currentIndex = entries.firstIndex { $0.value == value } ?? (offset > 0 ? -1 : 0)
        for step in 1...entries.count {
            let candidate = currentIndex + offset * step
            let index = (candidate % entries.count + entries.count) % entries.count
            guard !entries[index].isDisabled else { continue }
            select(entries[index].value)
            entries[index].focus()
            return
        }
    }
}

private struct SCRadioGroupContext {
    var selectedValue: AnyHashable?
    var isDisabled = false
    var isReadOnly = false
    var isRequired = false
    var isInvalid = false
    var select: (AnyHashable) -> Void = { _ in }
    var register: (UUID, AnyHashable, Bool, @escaping () -> Void) -> Void = { _, _, _, _ in }
    var unregister: (UUID) -> Void = { _ in }
    var move: (AnyHashable, Int) -> Void = { _, _ in }
}

private struct SCRadioGroupContextKey: EnvironmentKey {
    static var defaultValue: SCRadioGroupContext? { nil }
}

extension EnvironmentValues {
    fileprivate var scRadioGroupContext: SCRadioGroupContext? {
        get { self[SCRadioGroupContextKey.self] }
        set { self[SCRadioGroupContextKey.self] = newValue }
    }
}

// MARK: - Root

/// Provides shared typed selection to a composed set of radio items.
public struct SCRadioGroup<Value: Hashable, Content: View>: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.scFieldInvalid) private var fieldIsInvalid
    @State private var internalSelection: Value?
    @State private var keyboard = SCRadioGroupKeyboardCoordinator()

    private enum Selection {
        case required(Binding<Value>)
        case optional(Binding<Value?>)
        case internalState
    }

    private let selection: Selection
    private let layout: SCRadioGroupLayout
    private let spacing: CGFloat
    private let isDisabled: Bool
    private let isReadOnly: Bool
    private let isRequired: Bool
    private let isInvalid: Bool
    private let accessibilityLabel: String
    private let onValueChange: ((Value) -> Void)?
    private let content: Content

    /// Creates a controlled radio group whose selection is always non-optional.
    public init(
        selection: Binding<Value>,
        layout: SCRadioGroupLayout = .vertical,
        spacing: CGFloat = 10,
        isDisabled: Bool = false,
        isReadOnly: Bool = false,
        isRequired: Bool = false,
        isInvalid: Bool = false,
        accessibilityLabel: String = "Radio group",
        onValueChange: ((Value) -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.selection = .required(selection)
        self._internalSelection = State(initialValue: selection.wrappedValue)
        self.layout = layout
        self.spacing = max(spacing, 0)
        self.isDisabled = isDisabled
        self.isReadOnly = isReadOnly
        self.isRequired = isRequired
        self.isInvalid = isInvalid
        self.accessibilityLabel = accessibilityLabel
        self.onValueChange = onValueChange
        self.content = content()
    }

    /// Creates a controlled group that may initially have no selected item.
    public init(
        selection: Binding<Value?>,
        layout: SCRadioGroupLayout = .vertical,
        spacing: CGFloat = 10,
        isDisabled: Bool = false,
        isReadOnly: Bool = false,
        isRequired: Bool = false,
        isInvalid: Bool = false,
        accessibilityLabel: String = "Radio group",
        onValueChange: ((Value) -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.selection = .optional(selection)
        self._internalSelection = State(initialValue: selection.wrappedValue)
        self.layout = layout
        self.spacing = max(spacing, 0)
        self.isDisabled = isDisabled
        self.isReadOnly = isReadOnly
        self.isRequired = isRequired
        self.isInvalid = isInvalid
        self.accessibilityLabel = accessibilityLabel
        self.onValueChange = onValueChange
        self.content = content()
    }

    /// Creates an internally managed radio group with an optional default.
    public init(
        defaultValue: Value? = nil,
        layout: SCRadioGroupLayout = .vertical,
        spacing: CGFloat = 10,
        isDisabled: Bool = false,
        isReadOnly: Bool = false,
        isRequired: Bool = false,
        isInvalid: Bool = false,
        accessibilityLabel: String = "Radio group",
        onValueChange: ((Value) -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.selection = .internalState
        self._internalSelection = State(initialValue: defaultValue)
        self.layout = layout
        self.spacing = max(spacing, 0)
        self.isDisabled = isDisabled
        self.isReadOnly = isReadOnly
        self.isRequired = isRequired
        self.isInvalid = isInvalid
        self.accessibilityLabel = accessibilityLabel
        self.onValueChange = onValueChange
        self.content = content()
    }

    public var body: some View {
        laidOutContent
            .environment(\.scRadioGroupContext, context)
            .disabled(isDisabled)
            .accessibilityElement(children: .contain)
            .accessibilityLabel(accessibilityLabel)
            .accessibilityHint(accessibilityHint)
    }

    @ViewBuilder
    private var laidOutContent: some View {
        switch layout {
        case .vertical:
            VStack(alignment: .leading, spacing: spacing) { content }
        case .horizontal:
            HStack(alignment: .center, spacing: spacing) { content }
        case .grid(let columnCount):
            LazyVGrid(
                columns: Array(
                    repeating: GridItem(.flexible(), spacing: spacing),
                    count: max(columnCount, 1)
                ),
                alignment: .leading,
                spacing: spacing
            ) {
                content
            }
        }
    }

    private var selectedValue: Value? {
        switch selection {
        case .required(let binding): binding.wrappedValue
        case .optional(let binding): binding.wrappedValue
        case .internalState: internalSelection
        }
    }

    private var context: SCRadioGroupContext {
        SCRadioGroupContext(
            selectedValue: selectedValue.map(AnyHashable.init),
            isDisabled: isDisabled,
            isReadOnly: isReadOnly,
            isRequired: isRequired,
            isInvalid: isInvalid || fieldIsInvalid,
            select: select,
            register: { id, value, isDisabled, focus in
                keyboard.register(id: id, value: value, isDisabled: isDisabled, focus: focus)
            },
            unregister: { id in
                keyboard.unregister(id: id)
            },
            move: { value, offset in
                keyboard.move(from: value, offset: offset, select: select)
            }
        )
    }

    private var accessibilityHint: String {
        if isReadOnly { return "Read only" }
        if isRequired, selectedValue == nil { return "Selection required" }
        if isInvalid || fieldIsInvalid { return "Invalid selection" }
        return ""
    }

    private func select(_ erasedValue: AnyHashable) {
        guard
            isEnabled,
            !isDisabled,
            !isReadOnly,
            let value = erasedValue.base as? Value,
            value != selectedValue
        else { return }

        switch selection {
        case .required(let binding): binding.wrappedValue = value
        case .optional(let binding): binding.wrappedValue = value
        case .internalState: internalSelection = value
        }
        onValueChange?(value)
    }
}

// MARK: - Item

/// A real native Button radio item with an arbitrary label and typed value.
public struct SCRadioGroupItem<Value: Hashable, Label: View>: View {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.scFieldInvalid) private var fieldIsInvalid
    @Environment(\.scRadioGroupContext) private var group
    @Environment(\.theme) private var theme
    @FocusState private var isFocused: Bool
    @State private var registrationID = UUID()

    private let value: Value
    private let isDisabled: Bool
    private let isReadOnly: Bool
    private let isRequired: Bool
    private let isInvalid: Bool
    private let labelPosition: SCRadioGroupItemLabelPosition
    private let label: Label

    public init(
        value: Value,
        isDisabled: Bool = false,
        isReadOnly: Bool = false,
        isRequired: Bool = false,
        isInvalid: Bool = false,
        labelPosition: SCRadioGroupItemLabelPosition = .trailing,
        @ViewBuilder label: () -> Label
    ) {
        self.value = value
        self.isDisabled = isDisabled
        self.isReadOnly = isReadOnly
        self.isRequired = isRequired
        self.isInvalid = isInvalid
        self.labelPosition = labelPosition
        self.label = label()
    }

    public var body: some View {
        Button {
            guard !effectiveReadOnly else { return }
            group?.select(AnyHashable(value))
        } label: {
            HStack(alignment: .center, spacing: 8) {
                if labelPosition == .leading {
                    label
                    indicator
                } else {
                    indicator
                    label
                }
            }
            .frame(minHeight: minimumTargetHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(effectiveDisabled || group == nil)
        .focused($isFocused)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityValue(isSelected ? "Selected" : "Not selected")
        .accessibilityHint(accessibilityHint)
        .onKeyPress(.upArrow) { move(-1) }
        .onKeyPress(.downArrow) { move(1) }
        .onKeyPress(.leftArrow) {
            move(layoutDirection == .leftToRight ? -1 : 1)
        }
        .onKeyPress(.rightArrow) {
            move(layoutDirection == .leftToRight ? 1 : -1)
        }
        .onAppear { register() }
        .onChange(of: effectiveDisabled) { _, _ in register() }
        .onDisappear { group?.unregister(registrationID) }
    }

    private var isSelected: Bool {
        group?.selectedValue == AnyHashable(value)
    }

    private var effectiveDisabled: Bool {
        !isEnabled || isDisabled || group?.isDisabled == true
    }

    private var effectiveReadOnly: Bool {
        isReadOnly || group?.isReadOnly == true
    }

    private var effectiveRequired: Bool {
        isRequired || group?.isRequired == true
    }

    private var effectiveInvalid: Bool {
        isInvalid || fieldIsInvalid || group?.isInvalid == true
    }

    private var indicator: some View {
        ZStack {
            Circle()
                .strokeBorder(indicatorBorder, lineWidth: 1.5)
            if isSelected {
                Circle()
                    .fill(theme.primary)
                    .frame(width: 10, height: 10)
                    .transition(reduceMotion ? .identity : .scale.combined(with: .opacity))
            }
        }
        .frame(width: 20, height: 20)
        .overlay {
            if isFocused {
                Circle()
                    .stroke(theme.ring, lineWidth: 2)
                    .padding(-3)
            }
        }
        .animation(
            reduceMotion ? nil : .spring(response: 0.2, dampingFraction: 0.75),
            value: isSelected
        )
    }

    private var indicatorBorder: Color {
        if effectiveInvalid { return theme.destructive }
        return isSelected ? theme.primary : theme.input
    }

    private var accessibilityHint: String {
        if effectiveReadOnly { return "Read only" }
        if effectiveRequired, group?.selectedValue == nil { return "Selection required" }
        if effectiveInvalid { return "Invalid selection" }
        return ""
    }

    private var minimumTargetHeight: CGFloat {
        #if os(iOS)
            44
        #else
            28
        #endif
    }

    private func register() {
        group?.register(
            registrationID,
            AnyHashable(value),
            effectiveDisabled || effectiveReadOnly
        ) {
            isFocused = true
        }
    }

    private func move(_ offset: Int) -> KeyPress.Result {
        guard !effectiveDisabled, !effectiveReadOnly, let group else { return .ignored }
        group.move(AnyHashable(value), offset)
        return .handled
    }
}

extension SCRadioGroupItem where Label == Text {
    /// A text-label convenience using the same radio item engine.
    public init(
        _ label: String,
        value: Value,
        isDisabled: Bool = false,
        isReadOnly: Bool = false,
        isRequired: Bool = false,
        isInvalid: Bool = false,
        labelPosition: SCRadioGroupItemLabelPosition = .trailing
    ) {
        self.init(
            value: value,
            isDisabled: isDisabled,
            isReadOnly: isReadOnly,
            isRequired: isRequired,
            isInvalid: isInvalid,
            labelPosition: labelPosition
        ) {
            Text(label)
        }
    }
}

extension SCRadioGroupItem where Label == EmptyView {
    /// An indicator-only item for composition beside `SCFieldLabel` content.
    public init(
        value: Value,
        isDisabled: Bool = false,
        isReadOnly: Bool = false,
        isRequired: Bool = false,
        isInvalid: Bool = false
    ) {
        self.init(
            value: value,
            isDisabled: isDisabled,
            isReadOnly: isReadOnly,
            isRequired: isRequired,
            isInvalid: isInvalid
        ) {
            EmptyView()
        }
    }
}

/// Supported shorthand for a text-labeled `SCRadioGroupItem`.
public typealias SCRadio<Value: Hashable> = SCRadioGroupItem<Value, Text>

// MARK: - Previews

#Preview("Radio Group · controlled") {
    @Previewable @State var density = "comfortable"

    SCPreview {
        SCRadioGroup(
            selection: $density,
            accessibilityLabel: "Interface density"
        ) {
            SCRadioGroupItem("Default", value: "default")
            SCRadioGroupItem("Comfortable", value: "comfortable")
            SCRadioGroupItem("Compact", value: "compact")
        }
    }
}

#Preview("Radio Group · descriptions and grid") {
    SCPreview {
        SCRadioGroup(
            defaultValue: "plus",
            layout: .grid(columns: 2),
            accessibilityLabel: "Plan"
        ) {
            SCRadioGroupItem(value: "plus") {
                VStack(alignment: .leading) {
                    Text("Plus").fontWeight(.medium)
                    Text("For individuals and small teams").font(.caption)
                }
            }
            SCRadioGroupItem(value: "pro") {
                VStack(alignment: .leading) {
                    Text("Pro").fontWeight(.medium)
                    Text("For growing businesses").font(.caption)
                }
            }
            SCRadioGroupItem("Enterprise", value: "enterprise", isDisabled: true)
            SCRadioGroupItem("Custom", value: "custom", isInvalid: true)
        }
    }
}
