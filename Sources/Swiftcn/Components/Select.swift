// ============================================================
// Select.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Option

/// One entry in an `SCSelect`: the value it writes to the selection binding
/// and the label shown for it.
public struct SCSelectOption<Value: Hashable>: Identifiable {
    public let value: Value
    public let label: String

    public var id: Value { value }

    public init(value: Value, label: String) {
        self.value = value
        self.label = label
    }
}

// MARK: - Component

/// A dropdown for choosing one value from a list, triggered from a control
/// styled like an input field.
///
/// Built on the native `Menu` primitive, so presentation, dismissal,
/// positioning, and accessibility stay native. Accepted limitation: the open
/// list itself is system-styled — theme tokens style the trigger, not the
/// platform menu. The selected option shows a checkmark in the menu.
///
///     SCSelect(selection: $fruit,
///              placeholder: "Select a fruit",
///              options: ["Apple", "Banana", "Blueberry"])
///
///     SCSelect(selection: $timezone, options: [
///         SCSelectOption(value: TimeZone(identifier: "GMT")!, label: "GMT"),
///         SCSelectOption(value: TimeZone(identifier: "EST")!, label: "Eastern"),
///     ])
public struct SCSelect<Value: Hashable>: View {
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    @Binding private var selection: Value?
    private let placeholder: String
    private let options: [SCSelectOption<Value>]

    public init(
        selection: Binding<Value?>,
        placeholder: String = "Select…",
        options: [SCSelectOption<Value>]
    ) {
        self._selection = selection
        self.placeholder = placeholder
        self.options = options
    }

    public var body: some View {
        Menu {
            ForEach(options) { option in
                Button {
                    selection = option.value
                } label: {
                    if option.value == selection {
                        Label(option.label, systemImage: "checkmark")
                    } else {
                        Text(option.label)
                    }
                }
            }
        } label: {
            trigger
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .opacity(isEnabled ? 1 : 0.5)
    }

    private var selectedLabel: String? {
        options.first { $0.value == selection }?.label
    }

    private var trigger: some View {
        HStack(spacing: 8) {
            Text(selectedLabel ?? placeholder)
                .font(.subheadline)
                .foregroundStyle(selectedLabel == nil ? theme.mutedForeground : theme.foreground)
                .lineLimit(1)
            Spacer(minLength: 8)
            Image(systemName: "chevron.up.chevron.down")
                .font(.caption)
                .foregroundStyle(theme.mutedForeground)
        }
        .padding(.horizontal, 12)
        .frame(height: 40)
        .frame(maxWidth: .infinity)
        .background(theme.background, in: shape)
        .overlay(shape.strokeBorder(theme.input))
        .contentShape(shape)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.radius, style: .continuous)
    }
}

public extension SCSelect where Value == String {
    /// Convenience for plain string choices — each string is both value and
    /// label.
    ///
    ///     SCSelect(selection: $fruit, options: ["Apple", "Banana"])
    init(
        selection: Binding<String?>,
        placeholder: String = "Select…",
        options: [String]
    ) {
        self.init(
            selection: selection,
            placeholder: placeholder,
            options: options.map { SCSelectOption(value: $0, label: $0) }
        )
    }
}

// MARK: - Previews

#Preview("Select") {
    @Previewable @State var fruit: String? = nil
    SCPreview {
        VStack(spacing: 12) {
            SCSelect(
                selection: $fruit,
                placeholder: "Select a fruit",
                options: ["Apple", "Banana", "Blueberry", "Grapes", "Pineapple"]
            )
            Text("Selected: \(fruit ?? "none")")
                .font(.caption)
                .foregroundStyle(Theme.default.mutedForeground)
        }
    }
}

#Preview("Select · states") {
    @Previewable @State var picked: String? = "Dark"
    SCPreview {
        VStack(spacing: 12) {
            SCSelect(
                selection: $picked,
                placeholder: "Theme",
                options: ["Light", "Dark", "System"]
            )
            SCSelect(
                selection: .constant(String?.none),
                placeholder: "Disabled",
                options: ["One", "Two"]
            )
            .disabled(true)
        }
    }
}
