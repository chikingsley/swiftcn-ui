import SwiftUI
import Swiftcn

private enum NativeSelectValidationFood: String, CaseIterable, Hashable {
    case none
    case apple
    case banana
    case blueberry
    case grapes
    case carrot
    case broccoli
}

/// Both SCNativeSelect sizes, controlled and internally managed selection,
/// grouped options via SCNativeSelectOptGroup, plus invalid and disabled
/// instances, each driving a caller-owned binding mirrored into a visible
/// value text, so UI tests can prove rendering, real Picker/NSPopUpButton
/// selection routing, and disabled/invalid semantics through the
/// accessibility tree.
struct NativeSelectValidationScene: View {
    @State private var changeCount = 0
    @State private var controlledFood = NativeSelectValidationFood.none
    @State private var smallFood = NativeSelectValidationFood.apple

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Changes: \(changeCount)")
                .accessibilityIdentifier("nativeselect-change-count")
            Text("Controlled: \(controlledFood.rawValue)")
                .accessibilityIdentifier("nativeselect-controlled-value")
            Text("Small: \(smallFood.rawValue)")
                .accessibilityIdentifier("nativeselect-small-value")

            SCNativeSelect(
                selection: $controlledFood,
                accessibilityLabel: "Food",
                onValueChange: { _ in changeCount += 1 }
            ) {
                SCNativeSelectOption("Select a food", value: NativeSelectValidationFood.none)
                SCNativeSelectOptGroup("Fruits") {
                    SCNativeSelectOption("Apple", value: NativeSelectValidationFood.apple)
                    SCNativeSelectOption("Banana", value: NativeSelectValidationFood.banana)
                    SCNativeSelectOption("Blueberry", value: NativeSelectValidationFood.blueberry)
                    SCNativeSelectOption("Grapes", value: NativeSelectValidationFood.grapes, isDisabled: true)
                }
                SCNativeSelectOptGroup("Vegetables") {
                    SCNativeSelectOption("Carrot", value: NativeSelectValidationFood.carrot)
                    SCNativeSelectOption("Broccoli", value: NativeSelectValidationFood.broccoli)
                }
            }
            .accessibilityIdentifier("nativeselect-controlled")
            .frame(width: 220)

            HStack(spacing: 12) {
                SCNativeSelect(
                    selection: $smallFood,
                    size: .sm,
                    accessibilityLabel: "Food (small)",
                    onValueChange: { _ in changeCount += 1 }
                ) {
                    ForEach(NativeSelectValidationFood.allCases, id: \.self) { food in
                        SCNativeSelectOption(food.rawValue.capitalized, value: food)
                    }
                }
                .accessibilityIdentifier("nativeselect-small")
                .frame(width: 160)

                SCNativeSelect(
                    defaultValue: NativeSelectValidationFood.none,
                    isInvalid: true,
                    accessibilityLabel: "Invalid food"
                ) {
                    SCNativeSelectOption("Error state", value: NativeSelectValidationFood.none)
                    SCNativeSelectOption("Apple", value: NativeSelectValidationFood.apple)
                }
                .accessibilityIdentifier("nativeselect-invalid")
                .frame(width: 160)

                SCNativeSelect(
                    defaultValue: NativeSelectValidationFood.none,
                    isDisabled: true,
                    accessibilityLabel: "Disabled food"
                ) {
                    SCNativeSelectOption("Disabled", value: NativeSelectValidationFood.none)
                }
                .accessibilityIdentifier("nativeselect-disabled")
                .frame(width: 160)
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
