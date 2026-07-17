import SwiftUI
import Swiftcn

private let comboboxFrameworkOptions: [SCComboboxOption<String>] = [
    SCComboboxOption(value: "next", label: "Next.js", group: "Popular"),
    SCComboboxOption(value: "sveltekit", label: "SvelteKit", group: "Popular"),
    SCComboboxOption(value: "nuxt", label: "Nuxt.js", group: "Other"),
    SCComboboxOption(value: "remix", label: "Remix", group: "Other", isDisabled: true),
    SCComboboxOption(value: "astro", label: "Astro", group: "Other"),
]

private let comboboxColorOptions = ["Red", "Green", "Blue"]

/// A searchable single-select combobox built from SCComboboxTrigger,
/// SCComboboxContent, SCComboboxInput, and SCComboboxCollection; a manually
/// composed multi-select combobox with removable chips (SCComboboxChips,
/// SCComboboxChip, SCComboboxList, SCComboboxGroup, SCComboboxItem); and a
/// disabled instance — all built directly on SCComboboxRoot, the same engine
/// the closed SCCombobox convenience composes internally — so UI tests can
/// prove presentation, search filtering, tap selection, chip removal, and
/// disabled semantics through the accessibility tree.
struct ComboboxValidationScene: View {
    @Environment(\.theme) private var theme

    @State private var frameworkChangeCount = 0
    @State private var frameworkOpenChangeCount = 0
    @State private var frameworkValue: String?
    @State private var frameworkPresented = false

    @State private var colorChangeCount = 0
    @State private var colorValue: Set<String> = ["Green"]
    @State private var colorPresented = false

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Framework changes: \(frameworkChangeCount)")
                .accessibilityIdentifier("combobox-framework-change-count")
            Text("Framework open changes: \(frameworkOpenChangeCount)")
                .accessibilityIdentifier("combobox-framework-open-change-count")
            Text("Framework value: \(frameworkValue ?? "none")")
                .accessibilityIdentifier("combobox-framework-value")
            Text("Color changes: \(colorChangeCount)")
                .accessibilityIdentifier("combobox-color-change-count")
            Text("Color value: \(colorValue.sorted().joined(separator: ", "))")
                .accessibilityIdentifier("combobox-color-value")

            frameworkCombobox
            colorCombobox
            disabledCombobox
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var frameworkCombobox: some View {
        SCComboboxRoot(
            selection: $frameworkValue,
            isPresented: $frameworkPresented,
            resetsQueryOnOpen: true,
            onOpenChange: { _ in frameworkOpenChangeCount += 1 },
            onValueChange: { _ in frameworkChangeCount += 1 },
            content: { snapshot in
                SCComboboxTrigger { _ in
                    Text(frameworkLabel(for: snapshot.selectedValues.first))
                }
                .accessibilityIdentifier("combobox-framework-trigger")
                .background {
                    SCComboboxContent(width: 240, alignment: .start) {
                        VStack(spacing: 0) {
                            SCComboboxInput(placeholder: "Search frameworks…", showsTrigger: false, isEmbedded: true)
                            SCComboboxCollection(
                                options: comboboxFrameworkOptions,
                                row: { option, isSelected, _, _ in
                                    HStack(spacing: 8) {
                                        Image(systemName: "checkmark")
                                            .opacity(isSelected ? 1 : 0)
                                        Text(option.label)
                                        Spacer(minLength: 8)
                                    }
                                    .accessibilityIdentifier("combobox-framework-option-\(option.value)")
                                },
                                groupHeader: { title in Text(title) },
                                empty: {
                                    Text("No results.")
                                        .accessibilityIdentifier("combobox-framework-empty")
                                }
                            )
                            .frame(height: 200)
                        }
                        // The popover surface: SCComboboxContent's portal panel is
                        // transparent by design, so a manual composition must paint
                        // the opaque popover background and border itself, exactly
                        // as the SCCombobox convenience does (ComboboxPicker's
                        // menuContent). Without it the panel shows through to the
                        // window content behind it.
                        .background(popoverShape.fill(theme.popover))
                        .overlay(popoverShape.strokeBorder(theme.border))
                    }
                }
            }
        )
    }

    private var colorCombobox: some View {
        SCComboboxRoot(
            selection: $colorValue,
            isPresented: $colorPresented,
            onValueChange: { _ in colorChangeCount += 1 },
            content: { _ in
                SCComboboxChips {
                    ForEach(Array(colorValue).sorted(), id: \.self) { color in
                        SCComboboxChip(value: color) {
                            Text(color)
                        }
                    }
                    SCComboboxChipsInput(placeholder: "Add color…")
                        .accessibilityIdentifier("combobox-color-input")
                }
                .background {
                    SCComboboxContent(width: 200, alignment: .start) {
                        SCComboboxList {
                            SCComboboxGroup {
                                SCComboboxLabel { Text("Colors") }
                                ForEach(comboboxColorOptions, id: \.self) { color in
                                    SCComboboxItem(value: color) { _ in
                                        Text(color)
                                    }
                                    .accessibilityIdentifier("combobox-color-option-\(color)")
                                }
                            }
                        }
                        // SCComboboxList is an intrinsically-unbounded ScrollView; in
                        // the SCOverlayPortal panel it collapses to a zero-hit-region
                        // frame unless given an explicit height, which leaves its
                        // option rows present in the tree but not clickable. Framing
                        // it makes the panel hittable (mirrors the framework list's
                        // explicit SCComboboxCollection height above).
                        .frame(width: 200, height: 168)
                        // Paint the opaque popover surface, as the SCCombobox
                        // convenience does; the portal panel is transparent by
                        // design and a manual composition owns its background.
                        .background(popoverShape.fill(theme.popover))
                        .overlay(popoverShape.strokeBorder(theme.border))
                    }
                }
            }
        )
    }

    private var disabledCombobox: some View {
        SCComboboxRoot(selection: .constant(nil as String?), isDisabled: true) { _ in
            SCComboboxTrigger { _ in
                Text("Disabled combobox")
            }
            .accessibilityIdentifier("combobox-disabled-trigger")
        }
    }

    private func frameworkLabel(for value: String?) -> String {
        comboboxFrameworkOptions.first { $0.value == value }?.label ?? "Select a framework"
    }

    private var popoverShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.radius, style: .continuous)
    }
}
