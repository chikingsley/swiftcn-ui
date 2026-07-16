import SwiftUI
import Swiftcn

/// SCSlider's controlled scalar and range bindings, continuous and stepped
/// values, and disabled state, with values mirrored into visible text so UI
/// tests can prove adjustable accessibility actions reach caller-owned state.
struct SliderValidationScene: View {
    @State private var scalarValue = 40.0
    @State private var continuousValue = 0.25
    @State private var rangeValues = [20.0, 80.0]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Scalar: \(scalarValue.formatted(.number.precision(.fractionLength(0))))")
                .accessibilityIdentifier("slider-scalar-echo")
            Text(
                "Range: \(rangeValues[0].formatted(.number.precision(.fractionLength(0))))–"
                    + "\(rangeValues[1].formatted(.number.precision(.fractionLength(0))))"
            )
            .accessibilityIdentifier("slider-range-echo")

            SCSlider(
                value: $scalarValue,
                in: 0...100,
                step: 10,
                accessibilityLabel: "Scalar value"
            )
            .accessibilityIdentifier("slider-scalar")
            .frame(width: 320)

            SCSlider(
                value: $continuousValue,
                in: 0...1,
                accessibilityLabel: "Continuous value"
            )
            .accessibilityIdentifier("slider-continuous")
            .frame(width: 320)

            SCSlider(
                values: $rangeValues,
                in: 0...100,
                step: 5,
                minimumStepsBetweenValues: 2,
                thumbAccessibilityLabels: ["Range minimum", "Range maximum"]
            )
            .accessibilityIdentifier("slider-range")
            .frame(width: 320)

            SCSlider(
                defaultValue: 50,
                in: 0...100,
                step: 10,
                isDisabled: true,
                accessibilityLabel: "Disabled value"
            )
            .accessibilityIdentifier("slider-disabled")
            .frame(width: 320)
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
