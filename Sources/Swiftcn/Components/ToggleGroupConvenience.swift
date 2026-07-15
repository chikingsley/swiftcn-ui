// ============================================================
// ToggleGroupConvenience.swift — swiftcn-ui
// Supplemental source for: toggle-group
// ============================================================
import SwiftUI

// MARK: - Array conveniences

extension SCToggleGroup where Content == AnyView {
    /// Compatibility composition for the original connected outline API.
    public init(
        selection: Binding<Value?>,
        items: [SCToggleGroupItem<Value, AnyView>],
        variant: SCToggleVariant = .outline,
        size: SCToggleSize = .default,
        spacing: CGFloat = 0,
        orientation: SCToggleGroupOrientation = .horizontal,
        loopsFocus: Bool = true,
        isDisabled: Bool = false,
        accessibilityLabel: String = "Toggle group",
        onValueChange: ((Value?) -> Void)? = nil
    ) {
        self.init(
            selection: selection,
            variant: variant,
            size: size,
            spacing: spacing,
            orientation: orientation,
            loopsFocus: loopsFocus,
            isDisabled: isDisabled,
            accessibilityLabel: accessibilityLabel,
            onValueChange: onValueChange
        ) {
            AnyView(ForEach(items, id: \.value) { item in item })
        }
    }

    /// Compatibility composition for the original connected outline API.
    public init(
        selection: Binding<Set<Value>>,
        items: [SCToggleGroupItem<Value, AnyView>],
        variant: SCToggleVariant = .outline,
        size: SCToggleSize = .default,
        spacing: CGFloat = 0,
        orientation: SCToggleGroupOrientation = .horizontal,
        loopsFocus: Bool = true,
        isDisabled: Bool = false,
        accessibilityLabel: String = "Toggle group",
        onValueChange: ((Set<Value>) -> Void)? = nil
    ) {
        self.init(
            selection: selection,
            variant: variant,
            size: size,
            spacing: spacing,
            orientation: orientation,
            loopsFocus: loopsFocus,
            isDisabled: isDisabled,
            accessibilityLabel: accessibilityLabel,
            onValueChange: onValueChange
        ) {
            AnyView(ForEach(items, id: \.value) { item in item })
        }
    }
}

// MARK: - Previews

#Preview("ToggleGroup · composed single") {
    @Previewable @State var alignment: String? = "left"
    SCPreview {
        SCToggleGroup(selection: $alignment, variant: .outline, spacing: 0) {
            SCToggleGroupItem(value: "left", accessibilityLabel: "Align left") {
                Image(systemName: "text.alignleft")
            }
            SCToggleGroupItem(value: "center", accessibilityLabel: "Align center") {
                Image(systemName: "text.aligncenter")
            }
            SCToggleGroupItem(value: "right", accessibilityLabel: "Align right") {
                Image(systemName: "text.alignright")
            }
        }
    }
}

#Preview("ToggleGroup · multiple and vertical") {
    @Previewable @State var styles: Set<String> = ["bold"]
    SCPreview {
        SCToggleGroup(
            selection: $styles,
            size: .sm,
            orientation: .vertical,
            accessibilityLabel: "Text formatting"
        ) {
            SCToggleGroupItem(value: "bold") { Text("Bold") }
            SCToggleGroupItem(value: "italic") { Text("Italic") }
            SCToggleGroupItem(value: "underline", isDisabled: true) { Text("Underline") }
        }
    }
}

#Preview("ToggleGroup · compatibility array") {
    @Previewable @State var period: String? = "week"
    SCPreview {
        SCToggleGroup(
            selection: $period,
            items: [
                .init(value: "day", label: "Day"),
                .init(value: "week", label: "Week"),
                .init(value: "month", label: "Month", isDisabled: true),
            ]
        )
    }
}
