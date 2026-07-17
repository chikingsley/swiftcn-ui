import SwiftUI
import Swiftcn

/// Every SCSelect trigger size, single/multiple selection mode, rich
/// composition (groups, labels, separators, disabled items), plus invalid and
/// disabled instances, each driving caller-owned bindings that are mirrored
/// into visible value texts, so UI tests can prove rendering, native Menu
/// selection routing, and disabled/invalid semantics through the
/// accessibility tree.
struct SelectValidationScene: View {
    @State private var singleChangeCount = 0
    @State private var multipleChangeCount = 0
    @State private var arrayValue: String?
    @State private var smallValue: String?
    @State private var multipleValue: Set<String> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Single changes: \(singleChangeCount)")
                .accessibilityIdentifier("select-single-change-count")
            Text("Multiple changes: \(multipleChangeCount)")
                .accessibilityIdentifier("select-multiple-change-count")
            Text("Array value: \(arrayValue ?? "none")")
                .accessibilityIdentifier("select-array-value")
            Text("Small value: \(smallValue ?? "none")")
                .accessibilityIdentifier("select-small-value")
            Text("Multiple value: \(multipleValue.sorted().joined(separator: ", "))")
                .accessibilityIdentifier("select-multiple-value")

            HStack(spacing: 12) {
                SCSelect(
                    selection: $arrayValue,
                    placeholder: "Select a fruit",
                    accessibilityLabel: "Fruit (array)",
                    onValueChange: { _ in singleChangeCount += 1 },
                    options: ["Apple", "Banana", "Blueberry"]
                )
                .accessibilityIdentifier("select-array")

                SCSelect(
                    selection: $smallValue,
                    isRequired: true,
                    accessibilityLabel: "Fruit (small)",
                    onValueChange: { _ in singleChangeCount += 1 }
                ) {
                    SCSelectTrigger(size: .sm) { state in
                        SCSelectValue(state, placeholder: "Small select")
                    }
                    SCSelectContent {
                        SCSelectGroup("Fruits") {
                            SCSelectItem("Apple", value: "Apple")
                            SCSelectItem("Banana", value: "Banana")
                        }
                        SCSelectSeparator()
                        SCSelectGroup("Other") {
                            SCSelectItem("Grapes", value: "Grapes", isDisabled: true)
                            SCSelectItem("Pineapple", value: "Pineapple")
                        }
                    }
                }
                .accessibilityIdentifier("select-small")
            }

            SCSelect(
                selection: $multipleValue,
                accessibilityLabel: "Fruits (multiple)",
                onValuesChange: { _ in multipleChangeCount += 1 }
            ) {
                SCSelectTrigger(expandsHorizontally: true) { state in
                    SCSelectValue(state, placeholder: "Select fruits")
                }
                SCSelectContent {
                    SCSelectGroup {
                        SCSelectItem("Apple", value: "Apple")
                        SCSelectItem("Banana", value: "Banana")
                        SCSelectItem("Blueberry", value: "Blueberry")
                    }
                }
            }
            .accessibilityIdentifier("select-multiple")

            HStack(spacing: 12) {
                SCSelect(
                    defaultValue: "Apple",
                    isInvalid: true,
                    accessibilityLabel: "Invalid fruit",
                    options: ["Apple", "Banana"]
                )
                .accessibilityIdentifier("select-invalid")

                SCSelect(
                    defaultValue: "Apple",
                    isDisabled: true,
                    accessibilityLabel: "Disabled fruit",
                    options: ["Apple", "Banana"]
                )
                .accessibilityIdentifier("select-disabled")
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
