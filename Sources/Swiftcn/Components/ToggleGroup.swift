// ============================================================
// ToggleGroup.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Item

/// One cell of an `SCToggleGroup`: a value plus a text and/or icon label.
public struct SCToggleGroupItem<Value: Hashable>: Identifiable {
    public let value: Value
    let label: String?
    let systemImage: String?

    public var id: Value { value }

    public init(value: Value, label: String) {
        self.value = value
        self.label = label
        self.systemImage = nil
    }

    public init(value: Value, systemImage: String) {
        self.value = value
        self.label = nil
        self.systemImage = systemImage
    }

    public init(value: Value, label: String, systemImage: String) {
        self.value = value
        self.label = label
        self.systemImage = systemImage
    }
}

// MARK: - Component

/// A horizontal set of toggle buttons sharing one bordered container —
/// shadcn's ToggleGroup (outline look). Supports single-select via
/// `Binding<Value?>` and multi-select via `Binding<Set<Value>>`.
/// Item values must be unique.
///
///     SCToggleGroup(selection: $alignment, items: [
///         .init(value: Alignment.left, systemImage: "text.alignleft"),
///         .init(value: Alignment.center, systemImage: "text.aligncenter"),
///         .init(value: Alignment.right, systemImage: "text.alignright"),
///     ])
///
///     SCToggleGroup(selection: $styles, items: [   // Set<String> binding
///         .init(value: "bold", systemImage: "bold"),
///         .init(value: "italic", systemImage: "italic"),
///     ])
public struct SCToggleGroup<Value: Hashable>: View {
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    private enum Mode {
        case single(Binding<Value?>)
        case multiple(Binding<Set<Value>>)
    }

    private let mode: Mode
    private let items: [SCToggleGroupItem<Value>]

    private let cellHeight: CGFloat = 36

    /// Single-select: tapping the selected item deselects it.
    public init(selection: Binding<Value?>, items: [SCToggleGroupItem<Value>]) {
        self.mode = .single(selection)
        self.items = items
    }

    /// Multi-select: each item toggles independently.
    public init(selection: Binding<Set<Value>>, items: [SCToggleGroupItem<Value>]) {
        self.mode = .multiple(selection)
        self.items = items
    }

    public var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                if index > 0 {
                    Rectangle()
                        .fill(theme.border)
                        .frame(width: 1)
                }
                cell(for: item)
            }
        }
        .frame(height: cellHeight)
        .fixedSize(horizontal: true, vertical: false)
        .clipShape(shape)
        .overlay(shape.strokeBorder(theme.border, lineWidth: 1))
        .opacity(isEnabled ? 1 : 0.5)
    }

    // MARK: Cells

    private func cell(for item: SCToggleGroupItem<Value>) -> some View {
        let selected = isSelected(item.value)
        return Button {
            toggle(item.value)
        } label: {
            HStack(spacing: 6) {
                if let systemImage = item.systemImage {
                    Image(systemName: systemImage)
                }
                if let label = item.label {
                    Text(label)
                }
            }
            .font(.subheadline.weight(.medium))
            .lineLimit(1)
            .padding(.horizontal, 12)
            .frame(minWidth: cellHeight, maxHeight: .infinity)
            .background(selected ? theme.accent : .clear)
            .foregroundStyle(selected ? theme.accentForeground : theme.foreground)
            .contentShape(Rectangle())
            .animation(.easeOut(duration: 0.12), value: selected)
        }
        .buttonStyle(SCToggleGroupCellPressStyle())
        .accessibilityAddTraits(selected ? [.isSelected] : [])
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.radius, style: .continuous)
    }

    // MARK: Selection

    private func isSelected(_ value: Value) -> Bool {
        switch mode {
        case .single(let selection):   selection.wrappedValue == value
        case .multiple(let selection): selection.wrappedValue.contains(value)
        }
    }

    private func toggle(_ value: Value) {
        switch mode {
        case .single(let selection):
            selection.wrappedValue = selection.wrappedValue == value ? nil : value
        case .multiple(let selection):
            if selection.wrappedValue.contains(value) {
                selection.wrappedValue.remove(value)
            } else {
                selection.wrappedValue.insert(value)
            }
        }
    }
}

// MARK: - Inner button style

/// Pressed feedback for toggle-group cells.
private struct SCToggleGroupCellPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.7 : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Previews

#Preview("ToggleGroup · single") {
    @Previewable @State var alignment: String? = "left"
    SCPreview {
        SCToggleGroup(selection: $alignment, items: [
            .init(value: "left", systemImage: "text.alignleft"),
            .init(value: "center", systemImage: "text.aligncenter"),
            .init(value: "right", systemImage: "text.alignright"),
        ])
    }
}

#Preview("ToggleGroup · multiple") {
    @Previewable @State var styles: Set<String> = ["bold"]
    SCPreview {
        SCToggleGroup(selection: $styles, items: [
            .init(value: "bold", systemImage: "bold"),
            .init(value: "italic", systemImage: "italic"),
            .init(value: "underline", systemImage: "underline"),
        ])
    }
}

#Preview("ToggleGroup · labels & disabled") {
    @Previewable @State var period: String? = "week"
    SCPreview {
        VStack(spacing: 16) {
            SCToggleGroup(selection: $period, items: [
                .init(value: "day", label: "Day"),
                .init(value: "week", label: "Week"),
                .init(value: "month", label: "Month"),
            ])
            SCToggleGroup(selection: $period, items: [
                .init(value: "day", label: "Day"),
                .init(value: "week", label: "Week"),
            ])
            .disabled(true)
        }
    }
}
