// ============================================================
// Checkbox.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Style

/// Checkbox appearance for native SwiftUI `Toggle`s — a square check control
/// in place of the platform switch. The toggle primitive is kept underneath
/// (wrapped in a `Button`), so tap targets, keyboard access, and the on/off
/// `accessibilityValue` all stay native; this supplies the style layer only.
///
///     Toggle("Accept terms and conditions", isOn: $accepted)
///         .toggleStyle(.scCheckbox)
public struct SCCheckboxStyle: ToggleStyle {
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack(spacing: 8) {
                box(isOn: configuration.isOn)
                configuration.label
                    .font(.subheadline)
                    .foregroundStyle(theme.foreground)
            }
        }
        .buttonStyle(.plain)
        .opacity(isEnabled ? 1 : 0.5)
    }

    private func box(isOn: Bool) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .fill(isOn ? theme.primary : theme.background)
            RoundedRectangle(cornerRadius: 6, style: .continuous)
                .strokeBorder(theme.input, lineWidth: 1.5)
                .opacity(isOn ? 0 : 1)
            if isOn {
                Image(systemName: "checkmark")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(theme.primaryForeground)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .frame(width: 20, height: 20)
        .animation(.spring(response: 0.2, dampingFraction: 0.75), value: isOn)
    }
}

public extension ToggleStyle where Self == SCCheckboxStyle {
    /// `Toggle("Accept terms", isOn: $accepted).toggleStyle(.scCheckbox)`
    static var scCheckbox: SCCheckboxStyle { SCCheckboxStyle() }
}

// MARK: - Previews

#Preview("Checkbox") {
    @Previewable @State var accepted = true
    @Previewable @State var marketing = false
    SCPreview {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Accept terms and conditions", isOn: $accepted)
                .toggleStyle(.scCheckbox)
            Toggle("Receive marketing emails", isOn: $marketing)
                .toggleStyle(.scCheckbox)
        }
    }
}

#Preview("Checkbox · disabled") {
    SCPreview {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Disabled unchecked", isOn: .constant(false))
                .toggleStyle(.scCheckbox)
                .disabled(true)
            Toggle("Disabled checked", isOn: .constant(true))
                .toggleStyle(.scCheckbox)
                .disabled(true)
        }
    }
}
