import Swiftcn
import SwiftUI

/// Typed single and multiple toggle groups cover controlled and internal
/// selection, both variants, every size, both axes, and root/item disabling.
struct ToggleGroupValidationScene: View {
    @State private var singleSelection: String? = "left"
    @State private var multipleSelection: Set<String> = ["bold"]
    @State private var singleCallback = "none"
    @State private var multipleCallback = "none"
    @State private var internalCallback = "none"

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Single: \(singleSelection ?? "none")")
                .accessibilityIdentifier("togglegroup-single-echo")
            Text("Single callback: \(singleCallback)")
                .accessibilityIdentifier("togglegroup-single-callback")
            Text("Multiple: \(names(multipleSelection))")
                .accessibilityIdentifier("togglegroup-multiple-echo")
            Text("Multiple callback: \(multipleCallback)")
                .accessibilityIdentifier("togglegroup-multiple-callback")
            Text("Internal callback: \(internalCallback)")
                .accessibilityIdentifier("togglegroup-internal-callback")

            SCToggleGroup(
                selection: $singleSelection,
                variant: .default,
                size: .default,
                accessibilityLabel: "Alignment",
                onValueChange: { singleCallback = $0 ?? "none" }
            ) {
                SCToggleGroupItem(value: "left", accessibilityLabel: "Align left") {
                    Text("Left")
                }
                .accessibilityIdentifier("togglegroup-single-left")
                SCToggleGroupItem(value: "center", accessibilityLabel: "Align center") {
                    Text("Center")
                }
                .accessibilityIdentifier("togglegroup-single-center")
                SCToggleGroupItem(value: "right", isDisabled: true, accessibilityLabel: "Align right") {
                    Text("Right")
                }
                .accessibilityIdentifier("togglegroup-disabled-item")
            }
            .accessibilityIdentifier("togglegroup-single-root")

            SCToggleGroup(
                selection: $multipleSelection,
                variant: .outline,
                size: .sm,
                spacing: 0,
                orientation: .vertical,
                accessibilityLabel: "Formatting",
                onValueChange: { multipleCallback = names($0) }
            ) {
                SCToggleGroupItem(value: "bold") { Text("Bold") }
                    .accessibilityIdentifier("togglegroup-multiple-bold")
                SCToggleGroupItem(value: "italic") { Text("Italic") }
                    .accessibilityIdentifier("togglegroup-multiple-italic")
            }
            .accessibilityIdentifier("togglegroup-multiple-root")

            SCToggleGroup(
                defaultValue: "week",
                variant: .outline,
                size: .lg,
                onValueChange: { internalCallback = $0 ?? "none" }
            ) {
                SCToggleGroupItem(value: "day") { Text("Day") }
                    .accessibilityIdentifier("togglegroup-internal-day")
                SCToggleGroupItem(value: "week") { Text("Week") }
                    .accessibilityIdentifier("togglegroup-internal-week")
            }

            SCToggleGroup(
                defaultValues: Set(["one"]),
                isDisabled: true,
                accessibilityLabel: "Disabled group"
            ) {
                SCToggleGroupItem(value: "one") { Text("One") }
                    .accessibilityIdentifier("togglegroup-disabled-root-item")
            }
            .accessibilityIdentifier("togglegroup-disabled-root")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private func names(_ values: Set<String>) -> String {
        values.isEmpty ? "none" : values.sorted().joined(separator: ",")
    }
}
