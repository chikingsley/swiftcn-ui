import Swiftcn
import SwiftUI

/// Both SCSwitch sizes plus the SCSwitchStyle native Toggle, an invalid
/// switch, and a disabled switch, each driving caller-owned bindings that are
/// mirrored into visible value texts, so UI tests can prove rendering, toggle
/// routing, and disabled semantics through the accessibility tree.
struct SwitchValidationScene: View {
    @State private var changeCount = 0
    @State private var defaultIsOn = false
    @State private var smallIsOn = false
    @State private var styledIsOn = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Changes: \(changeCount)")
                .accessibilityIdentifier("switch-change-count")
            Text("Default: \(defaultIsOn ? "on" : "off")")
                .accessibilityIdentifier("switch-default-value")
            Text("Small: \(smallIsOn ? "on" : "off")")
                .accessibilityIdentifier("switch-small-value")
            Text("Styled: \(styledIsOn ? "on" : "off")")
                .accessibilityIdentifier("switch-styled-value")

            HStack(spacing: 24) {
                SCSwitch("Default switch", isOn: $defaultIsOn)
                    .accessibilityIdentifier("switch-default")
                SCSwitch("Small switch", isOn: $smallIsOn, size: .small)
                    .accessibilityIdentifier("switch-small")
            }

            Toggle("Airplane Mode", isOn: $styledIsOn)
                .toggleStyle(.scSwitch)
                .accessibilityIdentifier("switch-styled")
                .frame(width: 260)

            SCSwitch("Invalid switch", isOn: .constant(false), isInvalid: .invalid)
                .accessibilityIdentifier("switch-invalid")

            SCSwitch("Disabled switch", isOn: .constant(true), isDisabled: true)
                .accessibilityIdentifier("switch-disabled")
        }
        .onChange(of: defaultIsOn) { changeCount += 1 }
        .onChange(of: smallIsOn) { changeCount += 1 }
        .onChange(of: styledIsOn) { changeCount += 1 }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
