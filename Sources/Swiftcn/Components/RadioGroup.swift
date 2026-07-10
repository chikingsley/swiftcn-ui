// ============================================================
// RadioGroup.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Selection plumbing

/// Type-erased selection contract an `SCRadioGroup` hands to its `SCRadio`
/// children through the environment, so radios can live anywhere inside the
/// group's content without generic coupling.
struct SCRadioSelection {
    var isSelected: (AnyHashable) -> Bool
    var select: (AnyHashable) -> Void
}

private struct SCRadioSelectionKey: EnvironmentKey {
    static let defaultValue: SCRadioSelection? = nil
}

extension EnvironmentValues {
    var scRadioSelection: SCRadioSelection? {
        get { self[SCRadioSelectionKey.self] }
        set { self[SCRadioSelectionKey.self] = newValue }
    }
}

// MARK: - Component

/// A set of mutually exclusive options. The group owns the selection binding
/// and provides it to the `SCRadio` rows declared in its content; tapping a
/// row writes its value back to the binding.
///
///     SCRadioGroup(selection: $density) {
///         SCRadio("Default", value: Density.default)
///         SCRadio("Comfortable", value: Density.comfortable)
///         SCRadio("Compact", value: Density.compact)
///     }
public struct SCRadioGroup<Value: Hashable, Content: View>: View {
    @Binding private var selection: Value
    private let content: Content

    public init(selection: Binding<Value>, @ViewBuilder content: () -> Content) {
        self._selection = selection
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            content
        }
        .environment(\.scRadioSelection, SCRadioSelection(
            isSelected: { $0 == AnyHashable(selection) },
            select: { newValue in
                guard let value = newValue.base as? Value else { return }
                selection = value
            }
        ))
    }
}

// MARK: - Subcomponents

/// A single option row inside an `SCRadioGroup`. Selecting it is handled by a
/// native `Button`, so tap targets, keyboard access, and accessibility stay
/// native; the selected row additionally exposes the `isSelected` trait.
///
///     SCRadio("Comfortable", value: Density.comfortable)
public struct SCRadio<Value: Hashable>: View {
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.scRadioSelection) private var group

    private let label: String
    private let value: Value

    public init(_ label: String, value: Value) {
        self.label = label
        self.value = value
    }

    private var isSelected: Bool {
        group?.isSelected(AnyHashable(value)) ?? false
    }

    public var body: some View {
        Button {
            group?.select(AnyHashable(value))
        } label: {
            HStack(spacing: 8) {
                indicator
                Text(label)
                    .font(.subheadline)
                    .foregroundStyle(theme.foreground)
            }
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? [.isSelected] : [])
        .opacity(isEnabled ? 1 : 0.5)
    }

    private var indicator: some View {
        ZStack {
            Circle()
                .strokeBorder(isSelected ? theme.primary : theme.input, lineWidth: 1.5)
            if isSelected {
                Circle()
                    .fill(theme.primary)
                    .frame(width: 10, height: 10)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(width: 20, height: 20)
        .animation(.spring(response: 0.2, dampingFraction: 0.75), value: isSelected)
    }
}

// MARK: - Previews

#Preview("RadioGroup") {
    @Previewable @State var density = "comfortable"
    SCPreview {
        SCRadioGroup(selection: $density) {
            SCRadio("Default", value: "default")
            SCRadio("Comfortable", value: "comfortable")
            SCRadio("Compact", value: "compact")
        }
    }
}

#Preview("RadioGroup · disabled") {
    @Previewable @State var plan = "free"
    SCPreview {
        SCRadioGroup(selection: $plan) {
            SCRadio("Free", value: "free")
            SCRadio("Pro", value: "pro")
            SCRadio("Enterprise", value: "enterprise")
                .disabled(true)
        }
    }
}
