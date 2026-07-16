import Swiftcn
import SwiftUI

/// SCCheckbox in mixed, boolean, unlabeled, invalid, and disabled forms plus
/// the SCCheckboxStyle native Toggle, with every caller-owned binding mirrored
/// into visible value texts, so UI tests can prove rendering, tri-state
/// resolution, activation routing, and disabled semantics.
struct CheckboxValidationScene: View {
    @State private var changeCount = 0
    @State private var mixedState: SCCheckboxState = .mixed
    @State private var basicIsChecked = false
    @State private var styledIsOn = false

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Changes: \(changeCount)")
                .accessibilityIdentifier("checkbox-change-count")
            Text("Mixed: \(name(of: mixedState))")
                .accessibilityIdentifier("checkbox-mixed-value")
            Text("Basic: \(basicIsChecked ? "checked" : "unchecked")")
                .accessibilityIdentifier("checkbox-basic-value")
            Text("Styled: \(styledIsOn ? "on" : "off")")
                .accessibilityIdentifier("checkbox-styled-value")

            SCCheckbox(state: $mixedState) {
                Text("Select all rows")
            }
            .accessibilityIdentifier("checkbox-mixed")

            SCCheckbox(isChecked: $basicIsChecked) {
                Text("Accept terms and conditions")
            }
            .accessibilityIdentifier("checkbox-basic")

            HStack(spacing: 8) {
                SCCheckbox(state: .constant(.checked))
                    .accessibilityLabel("Row selection")
                    .accessibilityIdentifier("checkbox-unlabeled")
                Text("Composed field label")
                    .font(.subheadline)
            }

            SCCheckbox(state: .constant(.unchecked), isInvalid: true) {
                Text("Invalid choice")
            }
            .accessibilityIdentifier("checkbox-invalid")

            SCCheckbox(state: .constant(.checked)) {
                Text("Disabled checked")
            }
            .disabled(true)
            .accessibilityIdentifier("checkbox-disabled")

            Toggle("Receive marketing emails", isOn: $styledIsOn)
                .toggleStyle(.scCheckbox)
                .accessibilityIdentifier("checkbox-styled")
        }
        .onChange(of: mixedState) { changeCount += 1 }
        .onChange(of: basicIsChecked) { changeCount += 1 }
        .onChange(of: styledIsOn) { changeCount += 1 }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func name(of state: SCCheckboxState) -> String {
        switch state {
        case .unchecked: "unchecked"
        case .checked: "checked"
        case .mixed: "mixed"
        }
    }
}
