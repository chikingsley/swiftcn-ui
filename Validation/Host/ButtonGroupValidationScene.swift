import SwiftUI
import Swiftcn

/// Horizontal and vertical orientations, mixed buttons/text-input/native
/// select addons, separators, the array convenience initializer, and a
/// disabled control, each wired to caller-owned state mirrored into visible
/// echoes, so UI tests can prove rendering, real action routing across
/// heterogeneous children, and disabled semantics through the accessibility
/// tree.
struct ButtonGroupValidationScene: View {
    private enum Unit: String, CaseIterable, Hashable {
        case items
        case percent
    }

    @State private var editActionCount = 0
    @State private var lastEditAction = "none"
    @State private var gpuSize = ""
    @State private var appliedSize = "none"
    @State private var unit = Unit.items
    @State private var counter = 0
    @State private var arrayCounter = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Edit actions: \(editActionCount)")
                .accessibilityIdentifier("buttongroup-edit-action-count")
            Text("Last edit action: \(lastEditAction)")
                .accessibilityIdentifier("buttongroup-last-edit-action")
            Text("Applied size: \(appliedSize)")
                .accessibilityIdentifier("buttongroup-applied-size")
            Text("Unit: \(unit.rawValue)")
                .accessibilityIdentifier("buttongroup-unit-echo")
            Text("Counter: \(counter)")
                .accessibilityIdentifier("buttongroup-counter")
            Text("Array counter: \(arrayCounter)")
                .accessibilityIdentifier("buttongroup-array-counter")

            SCButtonGroup(accessibilityLabel: "Editing actions") {
                Button("Copy") {
                    editActionCount += 1
                    lastEditAction = "Copy"
                }
                .buttonStyle(.sc(.outline))
                .accessibilityIdentifier("buttongroup-copy")

                SCButtonGroupSeparator()

                Button("Paste") {
                    editActionCount += 1
                    lastEditAction = "Paste"
                }
                .buttonStyle(.sc(.outline))
                .accessibilityIdentifier("buttongroup-paste")

                SCButtonGroupSeparator()

                Button("Archive") {
                    editActionCount += 1
                    lastEditAction = "Archive"
                }
                .buttonStyle(.sc(.outline))
                .disabled(true)
                .accessibilityIdentifier("buttongroup-archive-disabled")
            }
            .accessibilityIdentifier("buttongroup-edit-actions")

            SCButtonGroup {
                SCButtonGroupText("GPU size")
                TextField("Value", text: $gpuSize)
                    .textFieldStyle(.roundedBorder)
                    .accessibilityIdentifier("buttongroup-input")
                SCNativeSelect(selection: $unit, accessibilityLabel: "Unit") {
                    ForEach(Unit.allCases, id: \.self) { value in
                        SCNativeSelectOption(value.rawValue, value: value)
                    }
                }
                .accessibilityIdentifier("buttongroup-select")
                Button("Apply") {
                    appliedSize = "\(gpuSize) \(unit.rawValue)"
                }
                .buttonStyle(.sc(.outline))
                .accessibilityIdentifier("buttongroup-apply")
            }
            .accessibilityIdentifier("buttongroup-mixed")

            HStack(alignment: .top, spacing: 16) {
                SCButtonGroup(orientation: .vertical, accessibilityLabel: "Counter") {
                    Button {
                        counter += 1
                    } label: {
                        Image(systemName: "plus")
                    }
                    .buttonStyle(.sc(.outline, size: .icon))
                    .accessibilityIdentifier("buttongroup-vertical-increment")

                    Button {
                        counter -= 1
                    } label: {
                        Image(systemName: "minus")
                    }
                    .buttonStyle(.sc(.outline, size: .icon))
                    .accessibilityIdentifier("buttongroup-vertical-decrement")
                }
                .accessibilityIdentifier("buttongroup-vertical")

                SCButtonGroup(
                    size: .sm,
                    accessibilityLabel: "Array counter actions",
                    items: [
                        .init(systemImage: "minus") { arrayCounter -= 1 },
                        .init(systemImage: "plus") { arrayCounter += 1 },
                    ]
                )
                .accessibilityIdentifier("buttongroup-array")
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
