// ============================================================
// NativeSelect.swift — swiftcn-ui
// Depends on: Field.swift · Theme/
// ============================================================
import SwiftUI

// MARK: - Size

public enum SCNativeSelectSize: CaseIterable, Equatable, Hashable, Sendable {
    case `default`
    case sm
}

// MARK: - Root

/// A typed native single-selection control. Picker owns the popup, disclosure
/// indicator, focus, keyboard and touch selection, disabled options, platform
/// appearance, dismissal, and accessibility.
public struct SCNativeSelect<Value: Hashable, Content: View>: View {
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var environmentIsEnabled
    @Environment(\.scFieldInvalid) private var fieldIsInvalid
    @FocusState private var isFocused: Bool

    @State private var internalSelection: Value
    private let externalSelection: Binding<Value>?
    private let size: SCNativeSelectSize
    private let explicitIsInvalid: Bool?
    private let isDisabled: Bool
    private let accessibilityLabel: String
    private let onValueChange: ((Value) -> Void)?
    private let content: Content

    /// Creates a caller-controlled native select.
    public init(
        selection: Binding<Value>,
        size: SCNativeSelectSize = .default,
        isInvalid: Bool? = nil,
        isDisabled: Bool = false,
        accessibilityLabel: String = "Options",
        onValueChange: ((Value) -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self._internalSelection = State(initialValue: selection.wrappedValue)
        self.externalSelection = selection
        self.size = size
        self.explicitIsInvalid = isInvalid
        self.isDisabled = isDisabled
        self.accessibilityLabel = accessibilityLabel
        self.onValueChange = onValueChange
        self.content = content()
    }

    /// Creates an internally managed native select with an explicit initial
    /// value, mirroring an uncontrolled HTML select's defaultValue.
    public init(
        defaultValue: Value,
        size: SCNativeSelectSize = .default,
        isInvalid: Bool? = nil,
        isDisabled: Bool = false,
        accessibilityLabel: String = "Options",
        onValueChange: ((Value) -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self._internalSelection = State(initialValue: defaultValue)
        self.externalSelection = nil
        self.size = size
        self.explicitIsInvalid = isInvalid
        self.isDisabled = isDisabled
        self.accessibilityLabel = accessibilityLabel
        self.onValueChange = onValueChange
        self.content = content()
    }

    public var body: some View {
        Picker(accessibilityLabel, selection: selection) {
            content
        }
        .labelsHidden()
        .pickerStyle(.menu)
        .controlSize(size == .sm ? .small : .regular)
        .focused($isFocused)
        .padding(.horizontal, 4)
        .frame(minHeight: size == .sm ? 32 : 36)
        .background(theme.background, in: shape)
        .overlay { border }
        .overlay { focusRing }
        .contentShape(shape)
        .disabled(isDisabled)
        .opacity(isActuallyEnabled ? 1 : 0.5)
        .accessibilityLabel(Text(accessibilityLabel))
        .onChange(of: selection.wrappedValue) { _, value in
            onValueChange?(value)
        }
    }

    private var selection: Binding<Value> {
        externalSelection ?? $internalSelection
    }

    private var resolvedIsInvalid: Bool {
        explicitIsInvalid ?? fieldIsInvalid
    }

    private var isActuallyEnabled: Bool {
        environmentIsEnabled && !isDisabled
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: max(theme.radius - 2, 4), style: .continuous)
    }

    private var border: some View {
        shape.strokeBorder(resolvedIsInvalid ? theme.destructive : theme.input)
    }

    @ViewBuilder
    private var focusRing: some View {
        if isFocused {
            shape.strokeBorder(
                resolvedIsInvalid ? theme.destructive.opacity(0.3) : theme.ring.opacity(0.5),
                lineWidth: 3
            )
        }
    }
}

// MARK: - Option

/// One tagged, optionally disabled choice in SCNativeSelect.
public struct SCNativeSelectOption<Value: Hashable, Content: View>: View {
    private let value: Value
    private let isDisabled: Bool
    private let content: Content

    public init(
        value: Value,
        isDisabled: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.value = value
        self.isDisabled = isDisabled
        self.content = content()
    }

    public var body: some View {
        content
            .tag(value)
            .disabled(isDisabled)
    }
}

extension SCNativeSelectOption where Content == Text {
    public init(
        _ title: String,
        value: Value,
        isDisabled: Bool = false
    ) {
        self.init(value: value, isDisabled: isDisabled) {
            Text(title)
        }
    }
}

// MARK: - Option group

/// A native grouped set of options with an arbitrary Section heading.
public struct SCNativeSelectOptGroup<Label: View, Content: View>: View {
    private let label: Label
    private let content: Content

    public init(
        @ViewBuilder label: () -> Label,
        @ViewBuilder content: () -> Content
    ) {
        self.label = label()
        self.content = content()
    }

    public var body: some View {
        Section {
            content
        } header: {
            label
        }
    }
}

extension SCNativeSelectOptGroup where Label == Text {
    public init(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) {
        self.init(label: { Text(title) }, content: content)
    }
}

// MARK: - Previews

private enum SCNativeSelectPreviewFood: String, CaseIterable, Hashable {
    case none
    case apple
    case banana
    case blueberry
    case grapes
    case carrot
    case broccoli
}

#Preview("Native Select · complete") {
    @Previewable @State var food = SCNativeSelectPreviewFood.none

    SCPreview {
        VStack(alignment: .leading, spacing: 16) {
            SCField("Food", description: "Select a food.") {
                SCNativeSelect(
                    selection: $food,
                    accessibilityLabel: "Food"
                ) {
                    SCNativeSelectOption("Select a food", value: SCNativeSelectPreviewFood.none)
                    SCNativeSelectOptGroup("Fruits") {
                        SCNativeSelectOption("Apple", value: SCNativeSelectPreviewFood.apple)
                        SCNativeSelectOption("Banana", value: SCNativeSelectPreviewFood.banana)
                        SCNativeSelectOption("Blueberry", value: SCNativeSelectPreviewFood.blueberry)
                        SCNativeSelectOption(
                            "Grapes",
                            value: SCNativeSelectPreviewFood.grapes,
                            isDisabled: true
                        )
                    }
                    SCNativeSelectOptGroup("Vegetables") {
                        SCNativeSelectOption("Carrot", value: SCNativeSelectPreviewFood.carrot)
                        SCNativeSelectOption("Broccoli", value: SCNativeSelectPreviewFood.broccoli)
                    }
                }
            }

            HStack(spacing: 12) {
                SCNativeSelect(defaultValue: SCNativeSelectPreviewFood.apple, size: .sm) {
                    ForEach(SCNativeSelectPreviewFood.allCases, id: \.self) { value in
                        SCNativeSelectOption(value.rawValue.capitalized, value: value)
                    }
                }
                SCNativeSelect(
                    defaultValue: SCNativeSelectPreviewFood.none,
                    isInvalid: true
                ) {
                    SCNativeSelectOption("Error state", value: SCNativeSelectPreviewFood.none)
                    SCNativeSelectOption("Apple", value: SCNativeSelectPreviewFood.apple)
                }
                SCNativeSelect(
                    defaultValue: SCNativeSelectPreviewFood.none,
                    isDisabled: true
                ) {
                    SCNativeSelectOption("Disabled", value: SCNativeSelectPreviewFood.none)
                }
            }
        }
    }
}
