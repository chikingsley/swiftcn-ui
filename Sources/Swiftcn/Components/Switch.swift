// ============================================================
// Switch.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Style

/// shadcn's switch appearance for native SwiftUI `Toggle`s: a compact themed
/// capsule track with a sliding thumb, label leading and control trailing —
/// the same layout as the platform toggle. The toggle primitive is kept
/// underneath (wrapped in a `Button`), so tap targets, keyboard access, and
/// the on/off `accessibilityValue` all stay native; this supplies the style
/// layer only.
///
///     Toggle("Airplane Mode", isOn: $airplaneMode)
///         .toggleStyle(.scSwitch)
public struct SCSwitchStyle: ToggleStyle {
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        Button {
            configuration.isOn.toggle()
        } label: {
            HStack {
                configuration.label
                    .font(.subheadline)
                    .foregroundStyle(theme.foreground)
                Spacer()
                track(isOn: configuration.isOn)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .opacity(isEnabled ? 1 : 0.5)
    }

    private func track(isOn: Bool) -> some View {
        ZStack {
            Capsule()
                .fill(isOn ? theme.primary : theme.input)
            Circle()
                .fill(theme.background)
                .frame(width: 22, height: 22)
                .shadow(color: theme.foreground.opacity(0.12), radius: 1, x: 0, y: 1)
                .offset(x: isOn ? 9 : -9)
        }
        .frame(width: 44, height: 26)
        .animation(.spring(response: 0.25, dampingFraction: 0.85), value: isOn)
    }
}

public extension ToggleStyle where Self == SCSwitchStyle {
    /// `Toggle("Airplane Mode", isOn: $airplaneMode).toggleStyle(.scSwitch)`
    static var scSwitch: SCSwitchStyle { SCSwitchStyle() }
}

// MARK: - Previews

#Preview("Switch") {
    @Previewable @State var airplaneMode = true
    @Previewable @State var wifi = false
    SCPreview {
        VStack(spacing: 12) {
            Toggle("Airplane Mode", isOn: $airplaneMode)
                .toggleStyle(.scSwitch)
            Toggle("Wi-Fi", isOn: $wifi)
                .toggleStyle(.scSwitch)
        }
    }
}

#Preview("Switch · disabled") {
    SCPreview {
        VStack(spacing: 12) {
            Toggle("Disabled off", isOn: .constant(false))
                .toggleStyle(.scSwitch)
                .disabled(true)
            Toggle("Disabled on", isOn: .constant(true))
                .toggleStyle(.scSwitch)
                .disabled(true)
        }
    }
}
