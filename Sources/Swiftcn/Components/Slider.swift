// ============================================================
// Slider.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Public model

public enum SCSliderCollisionBehavior: CaseIterable, Hashable, Sendable {
    /// The active thumb pushes adjacent thumbs while preserving their order.
    case push
    /// The active thumb trades places with thumbs it crosses.
    case swap
    /// The active thumb stops at its nearest neighbor.
    case none
}

public enum SCSliderThumbAlignment: CaseIterable, Hashable, Sendable {
    /// A thumb's edge aligns with the control edge at the minimum and maximum.
    case edge
    /// A thumb's center aligns with the control edge and may extend outside it.
    case center
}

public enum SCSliderChangeReason: Hashable, Sendable {
    case trackPress
    case drag
    case keyboard
    case accessibility
}

public struct SCSliderEvent: Hashable, Sendable {
    public let reason: SCSliderChangeReason
    public let activeThumbIndex: Int

    public init(reason: SCSliderChangeReason, activeThumbIndex: Int) {
        self.reason = reason
        self.activeThumbIndex = activeThumbIndex
    }
}

// MARK: - Component

/// A controlled or internally managed, single- or multi-thumb Slider.
///
/// One engine supplies scalar, range, multiple-thumb, horizontal, and vertical
/// forms. It preserves native accessibility through one adjustable control per
/// thumb while providing the themed shadcn track, indicator, and thumbs.
///
///     SCSlider(value: $volume)
///     SCSlider(values: $priceRange, in: 0...1_000, step: 10)
///     SCSlider(defaultValues: [10, 20, 70], in: 0...100, step: 10)
///     SCSlider(value: $level, orientation: .vertical)
public struct SCSlider: View {
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @FocusState private var focusedThumbIndex: Int?

    @State private var internalValues: [Double]
    @State private var activeThumbIndex: Int?
    @State private var dragInitialValues: [Double] = []
    @State private var dragDidMove = false

    private let externalValues: Binding<[Double]>?
    private let range: ClosedRange<Double>
    private let step: Double?
    private let largeStep: Double?
    private let minimumStepsBetweenValues: Int
    private let orientation: Axis
    private let collisionBehavior: SCSliderCollisionBehavior
    private let thumbAlignment: SCSliderThumbAlignment
    private let isDisabled: Bool
    private let disabledThumbs: Set<Int>
    private let thumbAccessibilityLabels: [String]
    private let trackHeight: CGFloat
    private let thumbSize: CGFloat
    private let valueFormatter: ((Double) -> String)?
    private let onValueChange: (([Double], SCSliderEvent) -> Void)?
    private let onValueCommitted: (([Double], SCSliderEvent) -> Void)?

    // MARK: Controlled values

    public init(
        values: Binding<[Double]>,
        in range: ClosedRange<Double> = 0...100,
        step: Double? = 1,
        largeStep: Double? = 10,
        minimumStepsBetweenValues: Int = 0,
        orientation: Axis = .horizontal,
        collisionBehavior: SCSliderCollisionBehavior = .push,
        thumbAlignment: SCSliderThumbAlignment = .edge,
        isDisabled: Bool = false,
        disabledThumbs: Set<Int> = [],
        thumbAccessibilityLabels: [String] = [],
        trackHeight: CGFloat = 6,
        thumbSize: CGFloat = 20,
        valueFormatter: ((Double) -> String)? = nil,
        onValueChange: (([Double], SCSliderEvent) -> Void)? = nil,
        onValueCommitted: (([Double], SCSliderEvent) -> Void)? = nil
    ) {
        self.init(
            externalValues: values,
            initialValues: values.wrappedValue,
            range: range,
            step: step,
            largeStep: largeStep,
            minimumStepsBetweenValues: minimumStepsBetweenValues,
            orientation: orientation,
            collisionBehavior: collisionBehavior,
            thumbAlignment: thumbAlignment,
            isDisabled: isDisabled,
            disabledThumbs: disabledThumbs,
            thumbAccessibilityLabels: thumbAccessibilityLabels,
            trackHeight: trackHeight,
            thumbSize: thumbSize,
            valueFormatter: valueFormatter,
            onValueChange: onValueChange,
            onValueCommitted: onValueCommitted
        )
    }

    /// Scalar convenience over the same multi-thumb engine.
    public init(
        value: Binding<Double>,
        in range: ClosedRange<Double> = 0...1,
        step: Double? = nil,
        largeStep: Double? = nil,
        orientation: Axis = .horizontal,
        thumbAlignment: SCSliderThumbAlignment = .edge,
        isDisabled: Bool = false,
        accessibilityLabel: String = "Value",
        trackHeight: CGFloat = 6,
        thumbSize: CGFloat = 20,
        valueFormatter: ((Double) -> String)? = nil,
        onValueChange: ((Double, SCSliderEvent) -> Void)? = nil,
        onValueCommitted: ((Double, SCSliderEvent) -> Void)? = nil
    ) {
        let values = Binding<[Double]>(
            get: { [value.wrappedValue] },
            set: { newValues in
                if let first = newValues.first { value.wrappedValue = first }
            }
        )
        let arrayOnChange = onValueChange.map { callback in
            { (values: [Double], event: SCSliderEvent) in
                if let first = values.first { callback(first, event) }
            }
        }
        let arrayOnCommitted = onValueCommitted.map { callback in
            { (values: [Double], event: SCSliderEvent) in
                if let first = values.first { callback(first, event) }
            }
        }
        self.init(
            externalValues: values,
            initialValues: values.wrappedValue,
            range: range,
            step: step,
            largeStep: largeStep,
            minimumStepsBetweenValues: 0,
            orientation: orientation,
            collisionBehavior: .push,
            thumbAlignment: thumbAlignment,
            isDisabled: isDisabled,
            disabledThumbs: [],
            thumbAccessibilityLabels: [accessibilityLabel],
            trackHeight: trackHeight,
            thumbSize: thumbSize,
            valueFormatter: valueFormatter,
            onValueChange: arrayOnChange,
            onValueCommitted: arrayOnCommitted
        )
    }

    // MARK: Internally managed values

    public init(
        defaultValues: [Double],
        in range: ClosedRange<Double> = 0...100,
        step: Double? = 1,
        largeStep: Double? = 10,
        minimumStepsBetweenValues: Int = 0,
        orientation: Axis = .horizontal,
        collisionBehavior: SCSliderCollisionBehavior = .push,
        thumbAlignment: SCSliderThumbAlignment = .edge,
        isDisabled: Bool = false,
        disabledThumbs: Set<Int> = [],
        thumbAccessibilityLabels: [String] = [],
        trackHeight: CGFloat = 6,
        thumbSize: CGFloat = 20,
        valueFormatter: ((Double) -> String)? = nil,
        onValueChange: (([Double], SCSliderEvent) -> Void)? = nil,
        onValueCommitted: (([Double], SCSliderEvent) -> Void)? = nil
    ) {
        self.init(
            externalValues: nil,
            initialValues: defaultValues,
            range: range,
            step: step,
            largeStep: largeStep,
            minimumStepsBetweenValues: minimumStepsBetweenValues,
            orientation: orientation,
            collisionBehavior: collisionBehavior,
            thumbAlignment: thumbAlignment,
            isDisabled: isDisabled,
            disabledThumbs: disabledThumbs,
            thumbAccessibilityLabels: thumbAccessibilityLabels,
            trackHeight: trackHeight,
            thumbSize: thumbSize,
            valueFormatter: valueFormatter,
            onValueChange: onValueChange,
            onValueCommitted: onValueCommitted
        )
    }

    public init(
        defaultValue: Double,
        in range: ClosedRange<Double> = 0...100,
        step: Double? = 1,
        largeStep: Double? = 10,
        orientation: Axis = .horizontal,
        thumbAlignment: SCSliderThumbAlignment = .edge,
        isDisabled: Bool = false,
        accessibilityLabel: String = "Value",
        trackHeight: CGFloat = 6,
        thumbSize: CGFloat = 20,
        valueFormatter: ((Double) -> String)? = nil,
        onValueChange: ((Double, SCSliderEvent) -> Void)? = nil,
        onValueCommitted: ((Double, SCSliderEvent) -> Void)? = nil
    ) {
        let arrayOnChange = onValueChange.map { callback in
            { (values: [Double], event: SCSliderEvent) in
                if let first = values.first { callback(first, event) }
            }
        }
        let arrayOnCommitted = onValueCommitted.map { callback in
            { (values: [Double], event: SCSliderEvent) in
                if let first = values.first { callback(first, event) }
            }
        }
        self.init(
            externalValues: nil,
            initialValues: [defaultValue],
            range: range,
            step: step,
            largeStep: largeStep,
            minimumStepsBetweenValues: 0,
            orientation: orientation,
            collisionBehavior: .push,
            thumbAlignment: thumbAlignment,
            isDisabled: isDisabled,
            disabledThumbs: [],
            thumbAccessibilityLabels: [accessibilityLabel],
            trackHeight: trackHeight,
            thumbSize: thumbSize,
            valueFormatter: valueFormatter,
            onValueChange: arrayOnChange,
            onValueCommitted: arrayOnCommitted
        )
    }

    private init(
        externalValues: Binding<[Double]>?,
        initialValues: [Double],
        range: ClosedRange<Double>,
        step: Double?,
        largeStep: Double?,
        minimumStepsBetweenValues: Int,
        orientation: Axis,
        collisionBehavior: SCSliderCollisionBehavior,
        thumbAlignment: SCSliderThumbAlignment,
        isDisabled: Bool,
        disabledThumbs: Set<Int>,
        thumbAccessibilityLabels: [String],
        trackHeight: CGFloat,
        thumbSize: CGFloat,
        valueFormatter: ((Double) -> String)?,
        onValueChange: (([Double], SCSliderEvent) -> Void)?,
        onValueCommitted: (([Double], SCSliderEvent) -> Void)?
    ) {
        self.externalValues = externalValues
        self._internalValues = State(initialValue: initialValues)
        self.range = range
        self.step = step.flatMap { $0 > 0 ? $0 : nil }
        self.largeStep = largeStep.flatMap { $0 > 0 ? $0 : nil }
        self.minimumStepsBetweenValues = max(minimumStepsBetweenValues, 0)
        self.orientation = orientation
        self.collisionBehavior = collisionBehavior
        self.thumbAlignment = thumbAlignment
        self.isDisabled = isDisabled
        self.disabledThumbs = disabledThumbs
        self.thumbAccessibilityLabels = thumbAccessibilityLabels
        self.trackHeight = max(trackHeight, 1)
        self.thumbSize = max(thumbSize, 12)
        self.valueFormatter = valueFormatter
        self.onValueChange = onValueChange
        self.onValueCommitted = onValueCommitted
    }

    // MARK: View

    public var body: some View {
        GeometryReader { geometry in
            sliderBody(in: geometry.size)
        }
        .frame(
            width: orientation == .vertical ? thumbSize : nil,
            height: orientation == .horizontal ? thumbSize : nil
        )
        .opacity(canInteract ? 1 : 0.5)
        .accessibilityRepresentation { accessibilitySliders }
    }

    private func sliderBody(in size: CGSize) -> some View {
        let values = displayValues
        return ZStack {
            track(in: size)
            indicator(for: values, in: size)
            ForEach(values.indices, id: \.self) { index in
                thumb(at: index, value: values[index], in: size)
            }
        }
        .contentShape(Rectangle())
        .gesture(sliderGesture(in: size))
    }

    private func track(in size: CGSize) -> some View {
        Capsule()
            .fill(theme.secondary)
            .frame(
                width: orientation == .horizontal ? size.width : trackHeight,
                height: orientation == .horizontal ? trackHeight : size.height
            )
            .position(x: size.width / 2, y: size.height / 2)
            .accessibilityHidden(true)
    }

    @ViewBuilder
    private func indicator(for values: [Double], in size: CGSize) -> some View {
        let lowerValue = values.count == 1 ? range.lowerBound : (values.first ?? range.lowerBound)
        let upperValue = values.last ?? range.lowerBound
        let lowerPosition = axisPosition(for: lowerValue, in: size)
        let upperPosition = axisPosition(for: upperValue, in: size)

        if orientation == .horizontal {
            Capsule()
                .fill(theme.primary)
                .frame(width: max(upperPosition - lowerPosition, 0), height: trackHeight)
                .position(x: (lowerPosition + upperPosition) / 2, y: size.height / 2)
                .accessibilityHidden(true)
        } else {
            Capsule()
                .fill(theme.primary)
                .frame(width: trackHeight, height: max(lowerPosition - upperPosition, 0))
                .position(x: size.width / 2, y: (lowerPosition + upperPosition) / 2)
                .accessibilityHidden(true)
        }
    }

    private func thumb(at index: Int, value: Double, in size: CGSize) -> some View {
        let position = axisPosition(for: value, in: size)
        return Circle()
            .fill(theme.background)
            .overlay(Circle().strokeBorder(theme.primary, lineWidth: 1.5))
            .overlay {
                if focusedThumbIndex == index {
                    Circle()
                        .stroke(theme.ring, lineWidth: 2)
                        .padding(-3)
                }
            }
            .shadow(color: theme.foreground.opacity(0.12), radius: 2, x: 0, y: 1)
            .frame(width: thumbSize, height: thumbSize)
            .position(
                x: orientation == .horizontal ? position : size.width / 2,
                y: orientation == .horizontal ? size.height / 2 : position
            )
            .opacity(disabledThumbs.contains(index) ? 0.5 : 1)
            .focusable(canInteract && !disabledThumbs.contains(index))
            .focused($focusedThumbIndex, equals: index)
            .onKeyPress(keys: sliderKeys) { keyPress in
                handleKeyPress(keyPress, thumbIndex: index)
            }
            .accessibilityHidden(true)
    }

    // MARK: Pointer interaction

    private func sliderGesture(in size: CGSize) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { drag in
                guard canInteract else { return }
                let proposedValue = value(at: drag.location, in: size)
                let currentValues = displayValues

                if activeThumbIndex == nil {
                    guard let nearest = nearestEnabledThumb(to: proposedValue, values: currentValues)
                    else { return }
                    activeThumbIndex = nearest
                    focusedThumbIndex = nearest
                    dragInitialValues = currentValues
                    dragDidMove = false
                }

                guard let activeThumbIndex else { return }
                dragDidMove = dragDidMove || drag.translation != .zero
                let reason: SCSliderChangeReason = dragDidMove ? .drag : .trackPress
                self.activeThumbIndex = setThumbValue(
                    proposedValue,
                    at: activeThumbIndex,
                    reason: reason,
                    commit: false
                )
            }
            .onEnded { _ in
                guard let activeThumbIndex else { return }
                let currentValues = displayValues
                if currentValues != dragInitialValues {
                    onValueCommitted?(
                        currentValues,
                        SCSliderEvent(
                            reason: dragDidMove ? .drag : .trackPress,
                            activeThumbIndex: activeThumbIndex
                        )
                    )
                }
                self.activeThumbIndex = nil
                dragInitialValues = []
                dragDidMove = false
            }
    }

    private func nearestEnabledThumb(to proposedValue: Double, values: [Double]) -> Int? {
        values.indices
            .filter { !disabledThumbs.contains($0) }
            .min { abs(values[$0] - proposedValue) < abs(values[$1] - proposedValue) }
    }

    // MARK: Keyboard interaction

    private var sliderKeys: Set<KeyEquivalent> {
        [.leftArrow, .rightArrow, .upArrow, .downArrow, .home, .end, .pageUp, .pageDown]
    }

    private func handleKeyPress(_ keyPress: KeyPress, thumbIndex: Int) -> KeyPress.Result {
        guard canInteract, !disabledThumbs.contains(thumbIndex) else { return .ignored }
        let currentValue = displayValues[thumbIndex]
        let ordinaryStep = step ?? max((range.upperBound - range.lowerBound) / 100, 0.000_001)
        let acceleratedStep = resolvedLargeStep
        let usesLargeStep = keyPress.modifiers.contains(.shift)

        let proposedValue: Double
        switch keyPress.key {
        case .leftArrow, .downArrow:
            proposedValue = currentValue - (usesLargeStep ? acceleratedStep : ordinaryStep)
        case .rightArrow, .upArrow:
            proposedValue = currentValue + (usesLargeStep ? acceleratedStep : ordinaryStep)
        case .pageDown:
            proposedValue = currentValue - acceleratedStep
        case .pageUp:
            proposedValue = currentValue + acceleratedStep
        case .home:
            proposedValue = range.lowerBound
        case .end:
            proposedValue = range.upperBound
        default:
            return .ignored
        }

        focusedThumbIndex = setThumbValue(
            proposedValue,
            at: thumbIndex,
            reason: .keyboard,
            commit: true
        )
        return .handled
    }

    // MARK: Accessibility

    @ViewBuilder
    private var accessibilitySliders: some View {
        VStack {
            ForEach(displayValues.indices, id: \.self) { index in
                if let step {
                    Slider(value: accessibilityBinding(for: index), in: range, step: step)
                        .disabled(!canInteract || disabledThumbs.contains(index))
                        .accessibilityLabel(thumbLabel(at: index, count: displayValues.count))
                        .accessibilityValue(formattedValue(displayValues[index]))
                } else {
                    Slider(value: accessibilityBinding(for: index), in: range)
                        .disabled(!canInteract || disabledThumbs.contains(index))
                        .accessibilityLabel(thumbLabel(at: index, count: displayValues.count))
                        .accessibilityValue(formattedValue(displayValues[index]))
                }
            }
        }
    }

    private func accessibilityBinding(for index: Int) -> Binding<Double> {
        Binding(
            get: {
                let values = displayValues
                return values.indices.contains(index) ? values[index] : range.lowerBound
            },
            set: { newValue in
                _ = setThumbValue(
                    newValue,
                    at: index,
                    reason: .accessibility,
                    commit: true
                )
            }
        )
    }

    private func thumbLabel(at index: Int, count: Int) -> Text {
        if thumbAccessibilityLabels.indices.contains(index) {
            return Text(thumbAccessibilityLabels[index])
        }
        if count == 1 { return Text("Value") }
        if count == 2 { return Text(index == 0 ? "Minimum value" : "Maximum value") }
        return Text("Value \(index + 1)")
    }

    private func formattedValue(_ value: Double) -> Text {
        if let valueFormatter { return Text(valueFormatter(value)) }
        return Text(value.formatted(.number.precision(.fractionLength(0...3))))
    }

    // MARK: Value engine

    private var canInteract: Bool {
        isEnabled && !isDisabled
    }

    private var valuesBinding: Binding<[Double]> {
        if let externalValues {
            externalValues
        } else {
            $internalValues
        }
    }

    private var displayValues: [Double] {
        sanitized(valuesBinding.wrappedValue)
    }

    private var resolvedLargeStep: Double {
        if let largeStep { return largeStep }
        if let step { return step * 10 }
        return max((range.upperBound - range.lowerBound) / 10, 0.000_001)
    }

    private func setThumbValue(
        _ proposedValue: Double,
        at index: Int,
        reason: SCSliderChangeReason,
        commit: Bool
    ) -> Int {
        let currentValues = displayValues
        guard currentValues.indices.contains(index), !disabledThumbs.contains(index) else {
            return index
        }

        let update = updatedValues(currentValues, moving: index, to: proposedValue)
        guard update.values != currentValues else { return update.activeIndex }

        valuesBinding.wrappedValue = update.values
        let event = SCSliderEvent(reason: reason, activeThumbIndex: update.activeIndex)
        onValueChange?(update.values, event)
        if commit { onValueCommitted?(update.values, event) }
        return update.activeIndex
    }

    private func updatedValues(
        _ currentValues: [Double],
        moving index: Int,
        to proposedValue: Double
    ) -> (values: [Double], activeIndex: Int) {
        var values = currentValues
        let proposedValue = snappedAndClamped(proposedValue)
        let gap = effectiveMinimumGap(for: values.count)

        switch collisionBehavior {
        case .none:
            let lower = index > 0 ? values[index - 1] + gap : range.lowerBound
            let upper = index + 1 < values.count ? values[index + 1] - gap : range.upperBound
            values[index] = min(max(proposedValue, lower), upper)
            return (values, index)

        case .push:
            let lower = range.lowerBound + gap * Double(index)
            let upper = range.upperBound - gap * Double(values.count - index - 1)
            values[index] = min(max(proposedValue, lower), upper)
            if index > 0 {
                for neighbor in stride(from: index - 1, through: 0, by: -1) {
                    values[neighbor] = min(values[neighbor], values[neighbor + 1] - gap)
                }
            }
            if index + 1 < values.count {
                for neighbor in (index + 1)..<values.count {
                    values[neighbor] = max(values[neighbor], values[neighbor - 1] + gap)
                }
            }
            return (values, index)

        case .swap:
            var tagged = values.enumerated().map { (original: $0.offset, value: $0.element) }
            tagged[index].value = proposedValue
            tagged.sort {
                $0.value == $1.value ? $0.original < $1.original : $0.value < $1.value
            }
            values = sanitized(tagged.map(\.value))
            let activeIndex = tagged.firstIndex { $0.original == index } ?? index
            return (values, activeIndex)
        }
    }

    private func sanitized(_ rawValues: [Double]) -> [Double] {
        var values = (rawValues.isEmpty ? [range.lowerBound] : rawValues)
            .map(snappedAndClamped)
            .sorted()
        let gap = effectiveMinimumGap(for: values.count)
        guard values.count > 1, gap > 0 else { return values }

        for index in 1..<values.count {
            values[index] = max(values[index], values[index - 1] + gap)
        }
        if let overflow = values.last.map({ $0 - range.upperBound }), overflow > 0 {
            for index in values.indices { values[index] -= overflow }
        }
        for index in stride(from: values.count - 2, through: 0, by: -1) {
            values[index] = min(values[index], values[index + 1] - gap)
        }
        return values.map { min(max($0, range.lowerBound), range.upperBound) }
    }

    private func effectiveMinimumGap(for count: Int) -> Double {
        guard count > 1, let step else { return 0 }
        let requested = step * Double(minimumStepsBetweenValues)
        let capacity = (range.upperBound - range.lowerBound) / Double(count - 1)
        return min(requested, capacity)
    }

    private func snappedAndClamped(_ value: Double) -> Double {
        var value = min(max(value, range.lowerBound), range.upperBound)
        if let step {
            value = range.lowerBound + (((value - range.lowerBound) / step).rounded() * step)
        }
        return min(max(value, range.lowerBound), range.upperBound)
    }

    // MARK: Geometry

    private func fraction(of value: Double) -> CGFloat {
        let span = range.upperBound - range.lowerBound
        guard span > 0 else { return 0 }
        return CGFloat(min(max((value - range.lowerBound) / span, 0), 1))
    }

    private func axisPosition(for value: Double, in size: CGSize) -> CGFloat {
        let length = orientation == .horizontal ? size.width : size.height
        let inset = thumbAlignment == .edge ? thumbSize / 2 : 0
        let usableLength = max(length - inset * 2, 0)
        let increasingPosition = inset + fraction(of: value) * usableLength
        return orientation == .horizontal ? increasingPosition : length - increasingPosition
    }

    private func value(at location: CGPoint, in size: CGSize) -> Double {
        let length = orientation == .horizontal ? size.width : size.height
        let coordinate = orientation == .horizontal ? location.x : size.height - location.y
        let inset = thumbAlignment == .edge ? thumbSize / 2 : 0
        let usableLength = max(length - inset * 2, 1)
        let fraction = min(max((coordinate - inset) / usableLength, 0), 1)
        return range.lowerBound + Double(fraction) * (range.upperBound - range.lowerBound)
    }
}

// MARK: - Previews

#Preview("Slider · scalar and range") {
    @Previewable @State var value = 50.0
    @Previewable @State var range = [25.0, 75.0]

    SCPreview {
        VStack(spacing: 24) {
            SCSlider(value: $value, in: 0...100, step: 1, accessibilityLabel: "Volume")
            SCSlider(
                values: $range,
                in: 0...100,
                step: 5,
                thumbAccessibilityLabels: ["Minimum price", "Maximum price"]
            )
        }
        .frame(maxWidth: 320)
    }
}

#Preview("Slider · multiple and vertical") {
    SCPreview {
        HStack(spacing: 32) {
            SCSlider(
                defaultValues: [10, 20, 70],
                in: 0...100,
                step: 10,
                collisionBehavior: .swap
            )
            .frame(width: 280)

            SCSlider(
                defaultValue: 50,
                in: 0...100,
                orientation: .vertical,
                accessibilityLabel: "Level"
            )
            .frame(height: 160)
        }
    }
}

#Preview("Slider · disabled") {
    SCPreview {
        SCSlider(defaultValue: 50, isDisabled: true)
            .frame(maxWidth: 280)
    }
}
