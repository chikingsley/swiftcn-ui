import Swiftcn
import SwiftUI

/// SCRadioGroup's typed controlled selection, every layout, item and root
/// disabled states, invalid state, and read-only behavior, with each selection
/// mirrored into visible text so UI tests can prove genuine binding flow.
struct RadioGroupValidationScene: View {
    private enum Density: String, Hashable {
        case comfortable
        case compact
        case guarded
        case spacious
    }

    @State private var verticalSelection = Density.comfortable
    @State private var horizontalSelection = Density.compact
    @State private var gridSelection = Density.spacious

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Vertical: \(verticalSelection.rawValue)")
                .accessibilityIdentifier("radiogroup-vertical-echo")
            Text("Horizontal: \(horizontalSelection.rawValue)")
                .accessibilityIdentifier("radiogroup-horizontal-echo")
            Text("Grid: \(gridSelection.rawValue)")
                .accessibilityIdentifier("radiogroup-grid-echo")

            SCRadioGroup(
                selection: $verticalSelection,
                accessibilityLabel: "Vertical density"
            ) {
                SCRadioGroupItem("Comfortable", value: Density.comfortable)
                    .accessibilityIdentifier("radiogroup-vertical-comfortable")
                SCRadioGroupItem("Compact", value: Density.compact)
                    .accessibilityIdentifier("radiogroup-vertical-compact")
                SCRadioGroupItem("Spacious", value: Density.spacious, isDisabled: true)
                    .accessibilityIdentifier("radiogroup-item-disabled")
                SCRadioGroupItem("Read-only item", value: Density.guarded, isReadOnly: true)
                    .accessibilityIdentifier("radiogroup-item-readonly")
            }
            .accessibilityIdentifier("radiogroup-vertical")

            SCRadioGroup(
                selection: $horizontalSelection,
                layout: .horizontal,
                isInvalid: true,
                accessibilityLabel: "Invalid horizontal density"
            ) {
                SCRadioGroupItem(
                    "Comfortable",
                    value: Density.comfortable,
                    isInvalid: true,
                    labelPosition: .leading
                )
                .accessibilityIdentifier("radiogroup-item-invalid")
                SCRadioGroupItem("Compact", value: Density.compact)
                    .accessibilityIdentifier("radiogroup-horizontal-compact")
            }
            .accessibilityIdentifier("radiogroup-horizontal-invalid")

            SCRadioGroup(
                selection: $gridSelection,
                layout: .grid(columns: 2),
                isReadOnly: true,
                accessibilityLabel: "Read-only grid density"
            ) {
                SCRadioGroupItem("Comfortable", value: Density.comfortable)
                    .accessibilityIdentifier("radiogroup-grid-comfortable")
                SCRadioGroupItem("Spacious", value: Density.spacious)
                    .accessibilityIdentifier("radiogroup-grid-spacious")
            }
            .accessibilityIdentifier("radiogroup-grid-readonly")

            SCRadioGroup(
                selection: .constant(Density.comfortable),
                isDisabled: true,
                accessibilityLabel: "Disabled density"
            ) {
                SCRadioGroupItem("Disabled root item", value: Density.comfortable)
                    .accessibilityIdentifier("radiogroup-root-disabled-item")
            }
            .accessibilityIdentifier("radiogroup-root-disabled")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
