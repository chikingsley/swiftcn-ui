// ============================================================
// DatePicker.swift — swiftcn-ui
// Depends on: Theme/ · Button.swift · Calendar.swift · Input.swift · Popover.swift
// ============================================================
import SwiftUI

// MARK: - Presets

/// A real, caller-owned shortcut that can be shown beside a date picker calendar.
/// The same type supports individual dates and date ranges.
public struct SCDatePickerPreset<Value>: Identifiable {
    public let id: String
    public let label: String
    public let value: Value

    public init(id: String? = nil, _ label: String, value: Value) {
        self.id = id ?? label
        self.label = label
        self.value = value
    }
}

// MARK: - Basic date picker

/// A preassembled Popover + Calendar date picker.
///
/// shadcn intentionally has no DatePicker root component. For a fully custom
/// composition, attach `.scPopover` to any trigger and place `SCCalendar`
/// inside it. `SCDatePicker` is the useful common-case composition over those
/// same public parts.
public struct SCDatePicker: View {
    @Environment(\.calendar) private var calendar
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    @Binding private var selection: Date?
    @State private var internalIsPresented: Bool

    private let externalIsPresented: Binding<Bool>?
    private let placeholder: String
    private let bounds: ClosedRange<Date>?
    private let disabled: ((Date) -> Bool)?
    private let month: Binding<Date>?
    private let configuration: SCCalendarConfiguration
    private let presets: [SCDatePickerPreset<Date>]
    private let dismissesOnSelection: Bool
    private let onOpenChange: ((Bool) -> Void)?
    private let onMonthChange: ((Date) -> Void)?
    private let onSelectionChange: ((Date?) -> Void)?

    public init(
        _ placeholder: String = "Pick a date",
        selection: Binding<Date?>,
        isPresented: Binding<Bool>? = nil,
        defaultPresented: Bool = false,
        in bounds: ClosedRange<Date>? = nil,
        disabled: ((Date) -> Bool)? = nil,
        month: Binding<Date>? = nil,
        configuration: SCCalendarConfiguration = .init(),
        presets: [SCDatePickerPreset<Date>] = [],
        dismissesOnSelection: Bool = true,
        onOpenChange: ((Bool) -> Void)? = nil,
        onMonthChange: ((Date) -> Void)? = nil,
        onSelectionChange: ((Date?) -> Void)? = nil
    ) {
        self.placeholder = placeholder
        self._selection = selection
        self.externalIsPresented = isPresented
        self._internalIsPresented = State(initialValue: defaultPresented)
        self.bounds = bounds
        self.disabled = disabled
        self.month = month
        self.configuration = configuration
        self.presets = presets
        self.dismissesOnSelection = dismissesOnSelection
        self.onOpenChange = onOpenChange
        self.onMonthChange = onMonthChange
        self.onSelectionChange = onSelectionChange
    }

    /// Date-of-birth convenience with month and year caption menus. It still
    /// uses the same Popover + Calendar engine as every other date picker.
    public init(
        dateOfBirth selection: Binding<Date?>,
        placeholder: String = "Select date",
        isPresented: Binding<Bool>? = nil,
        in bounds: ClosedRange<Date>? = nil,
        yearRange: ClosedRange<Int>? = nil,
        onSelectionChange: ((Date?) -> Void)? = nil
    ) {
        self.init(
            placeholder,
            selection: selection,
            isPresented: isPresented,
            in: bounds,
            configuration: .init(
                captionLayout: .dropdown,
                yearRange: yearRange,
                allowsDeselection: false
            ),
            onSelectionChange: onSelectionChange
        )
    }

    public var body: some View {
        Button {
            presented.wrappedValue.toggle()
        } label: {
            SCDatePickerTriggerLabel(
                text: selection.map(formattedDate) ?? placeholder,
                isEmpty: selection == nil,
                isPresented: presented.wrappedValue
            )
        }
        .buttonStyle(.plain)
        .scPopover(isPresented: presented) {
            SCDatePickerPanel(
                presets: presets,
                isPresetEnabled: { accepts($0.value) },
                selectPreset: selectPreset,
                calendarContent: {
                    SCCalendar(
                        selection: calendarSelection,
                        bounds: bounds,
                        disabled: disabled,
                        month: month,
                        configuration: configuration,
                        onMonthChange: onMonthChange
                    )
                }
            )
        }
        .opacity(isEnabled ? 1 : 0.5)
        .animation(.easeOut(duration: 0.15), value: presented.wrappedValue)
    }

    private var presented: Binding<Bool> {
        Binding {
            externalIsPresented?.wrappedValue ?? internalIsPresented
        } set: { newValue in
            let oldValue = externalIsPresented?.wrappedValue ?? internalIsPresented
            guard oldValue != newValue else { return }
            if let externalIsPresented {
                externalIsPresented.wrappedValue = newValue
            } else {
                internalIsPresented = newValue
            }
            onOpenChange?(newValue)
        }
    }

    private var calendarSelection: Binding<Date?> {
        Binding {
            selection
        } set: { newValue in
            selection = newValue
            onSelectionChange?(newValue)
            if dismissesOnSelection {
                presented.wrappedValue = false
            }
        }
    }

    private func selectPreset(_ preset: SCDatePickerPreset<Date>) {
        guard accepts(preset.value) else { return }
        let normalized = calendar.startOfDay(for: preset.value)
        selection = normalized
        onSelectionChange?(normalized)
        presented.wrappedValue = false
    }

    private func accepts(_ date: Date) -> Bool {
        if let bounds {
            let precedesBounds =
                calendar.compare(date, to: bounds.lowerBound, toGranularity: .day)
                == .orderedAscending
            if precedesBounds {
                return false
            }
            let followsBounds =
                calendar.compare(date, to: bounds.upperBound, toGranularity: .day)
                == .orderedDescending
            if followsBounds {
                return false
            }
        }
        return disabled?(date) != true
    }

    private func formattedDate(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .omitted)
    }
}

// MARK: - Range picker

/// A two-click date-range picker composed from the same Popover and Calendar.
public struct SCDateRangePicker: View {
    @Environment(\.calendar) private var calendar
    @Environment(\.isEnabled) private var isEnabled

    @Binding private var selection: ClosedRange<Date>?
    @State private var internalIsPresented: Bool

    private let externalIsPresented: Binding<Bool>?
    private let placeholder: String
    private let bounds: ClosedRange<Date>?
    private let disabled: ((Date) -> Bool)?
    private let month: Binding<Date>?
    private let configuration: SCCalendarConfiguration
    private let presets: [SCDatePickerPreset<ClosedRange<Date>>]
    private let dismissesOnSelection: Bool
    private let onOpenChange: ((Bool) -> Void)?
    private let onMonthChange: ((Date) -> Void)?
    private let onSelectionChange: ((ClosedRange<Date>?) -> Void)?

    public init(
        _ placeholder: String = "Pick a date range",
        selection: Binding<ClosedRange<Date>?>,
        isPresented: Binding<Bool>? = nil,
        defaultPresented: Bool = false,
        in bounds: ClosedRange<Date>? = nil,
        disabled: ((Date) -> Bool)? = nil,
        month: Binding<Date>? = nil,
        configuration: SCCalendarConfiguration = .init(numberOfMonths: 2),
        presets: [SCDatePickerPreset<ClosedRange<Date>>] = [],
        dismissesOnSelection: Bool = true,
        onOpenChange: ((Bool) -> Void)? = nil,
        onMonthChange: ((Date) -> Void)? = nil,
        onSelectionChange: ((ClosedRange<Date>?) -> Void)? = nil
    ) {
        self.placeholder = placeholder
        self._selection = selection
        self.externalIsPresented = isPresented
        self._internalIsPresented = State(initialValue: defaultPresented)
        self.bounds = bounds
        self.disabled = disabled
        self.month = month
        self.configuration = configuration
        self.presets = presets
        self.dismissesOnSelection = dismissesOnSelection
        self.onOpenChange = onOpenChange
        self.onMonthChange = onMonthChange
        self.onSelectionChange = onSelectionChange
    }

    public var body: some View {
        Button {
            presented.wrappedValue.toggle()
        } label: {
            SCDatePickerTriggerLabel(
                text: selection.map(formattedRange) ?? placeholder,
                isEmpty: selection == nil,
                isPresented: presented.wrappedValue
            )
        }
        .buttonStyle(.plain)
        .scPopover(isPresented: presented) {
            SCDatePickerPanel(
                presets: presets,
                isPresetEnabled: { accepts($0.value) },
                selectPreset: selectPreset,
                calendarContent: {
                    SCCalendar(
                        range: calendarSelection,
                        bounds: bounds,
                        disabled: disabled,
                        month: month,
                        configuration: configuration,
                        onMonthChange: onMonthChange
                    )
                }
            )
        }
        .opacity(isEnabled ? 1 : 0.5)
        .animation(.easeOut(duration: 0.15), value: presented.wrappedValue)
    }

    private var presented: Binding<Bool> {
        Binding {
            externalIsPresented?.wrappedValue ?? internalIsPresented
        } set: { newValue in
            let oldValue = externalIsPresented?.wrappedValue ?? internalIsPresented
            guard oldValue != newValue else { return }
            if let externalIsPresented {
                externalIsPresented.wrappedValue = newValue
            } else {
                internalIsPresented = newValue
            }
            onOpenChange?(newValue)
        }
    }

    private var calendarSelection: Binding<ClosedRange<Date>?> {
        Binding {
            selection
        } set: { newValue in
            selection = newValue
            onSelectionChange?(newValue)
            if dismissesOnSelection, newValue != nil {
                presented.wrappedValue = false
            }
        }
    }

    private func selectPreset(_ preset: SCDatePickerPreset<ClosedRange<Date>>) {
        guard accepts(preset.value) else { return }
        let normalized =
            calendar.startOfDay(for: preset.value.lowerBound)...calendar.startOfDay(for: preset.value.upperBound)
        selection = normalized
        onSelectionChange?(normalized)
        presented.wrappedValue = false
    }

    private func accepts(_ range: ClosedRange<Date>) -> Bool {
        if let bounds {
            let precedesBounds =
                calendar.compare(range.lowerBound, to: bounds.lowerBound, toGranularity: .day)
                == .orderedAscending
            if precedesBounds {
                return false
            }
            let followsBounds =
                calendar.compare(range.upperBound, to: bounds.upperBound, toGranularity: .day)
                == .orderedDescending
            if followsBounds {
                return false
            }
        }
        guard let disabled else { return true }
        var date = calendar.startOfDay(for: range.lowerBound)
        let end = calendar.startOfDay(for: range.upperBound)
        while date <= end {
            if disabled(date) { return false }
            guard let next = calendar.date(byAdding: .day, value: 1, to: date) else {
                return false
            }
            date = next
        }
        return true
    }

    private func formattedRange(_ range: ClosedRange<Date>) -> String {
        let start = range.lowerBound.formatted(date: .abbreviated, time: .omitted)
        let end = range.upperBound.formatted(date: .abbreviated, time: .omitted)
        return "\(start) – \(end)"
    }
}

// MARK: - Text input picker

/// A date text field with a real calendar action. Supply `parser` to accept
/// application-specific or natural-language input; the default parser uses a
/// localized medium date formatter.
public struct SCDateInputPicker: View {
    @Environment(\.calendar) private var calendar
    @Environment(\.locale) private var locale
    @Environment(\.theme) private var theme
    @Environment(\.timeZone) private var timeZone

    @Binding private var selection: Date?
    @State private var text: String
    @State private var internalIsPresented: Bool
    @State private var isInvalid = false
    @State private var textOwnedSelection: Date?

    private let externalIsPresented: Binding<Bool>?
    private let placeholder: String
    private let bounds: ClosedRange<Date>?
    private let disabled: ((Date) -> Bool)?
    private let configuration: SCCalendarConfiguration
    private let presets: [SCDatePickerPreset<Date>]
    private let parser: ((String) -> Date?)?
    private let formatter: ((Date) -> String)?
    private let parsesWhileTyping: Bool
    private let showsParsedDate: Bool
    private let invalidMessage: String
    private let onSelectionChange: ((Date?) -> Void)?
    private let onParseFailure: ((String) -> Void)?

    public init(
        _ placeholder: String = "Select date",
        selection: Binding<Date?>,
        isPresented: Binding<Bool>? = nil,
        defaultPresented: Bool = false,
        in bounds: ClosedRange<Date>? = nil,
        disabled: ((Date) -> Bool)? = nil,
        configuration: SCCalendarConfiguration = .init(),
        presets: [SCDatePickerPreset<Date>] = [],
        parser: ((String) -> Date?)? = nil,
        formatter: ((Date) -> String)? = nil,
        parsesWhileTyping: Bool = false,
        showsParsedDate: Bool = false,
        invalidMessage: String = "Enter a valid date.",
        onSelectionChange: ((Date?) -> Void)? = nil,
        onParseFailure: ((String) -> Void)? = nil
    ) {
        self.placeholder = placeholder
        self._selection = selection
        self.externalIsPresented = isPresented
        self._internalIsPresented = State(initialValue: defaultPresented)
        self._text = State(initialValue: "")
        self.bounds = bounds
        self.disabled = disabled
        self.configuration = configuration
        self.presets = presets
        self.parser = parser
        self.formatter = formatter
        self.parsesWhileTyping = parsesWhileTyping
        self.showsParsedDate = showsParsedDate
        self.invalidMessage = invalidMessage
        self.onSelectionChange = onSelectionChange
        self.onParseFailure = onParseFailure
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            SCInput(placeholder, text: $text) {
                Button {
                    presented.wrappedValue.toggle()
                } label: {
                    Image(systemName: "calendar")
                        .frame(width: 28, height: 28)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Open calendar")
                .scPopover(isPresented: presented) {
                    SCDatePickerPanel(
                        presets: presets,
                        isPresetEnabled: { accepts($0.value) },
                        selectPreset: selectPreset,
                        calendarContent: {
                            SCCalendar(
                                selection: calendarSelection,
                                bounds: bounds,
                                disabled: disabled,
                                configuration: configuration
                            )
                        }
                    )
                }
            }
            .environment(\.scFieldInvalid, isInvalid)
            .onSubmit(commitText)

            if isInvalid {
                Text(invalidMessage)
                    .font(.caption)
                    .foregroundStyle(theme.destructive)
                    .accessibilityLabel("Error: \(invalidMessage)")
            } else if showsParsedDate, let selection {
                Text("Selected \(displayText(for: selection))")
                    .font(.caption)
                    .foregroundStyle(theme.mutedForeground)
            }
        }
        .onAppear(perform: synchronizeText)
        .onChange(of: selection) { _, newValue in
            if newValue == textOwnedSelection {
                textOwnedSelection = nil
            } else {
                synchronizeText()
            }
        }
        .onChange(of: text) { _, newValue in
            isInvalid = false
            guard parsesWhileTyping else { return }
            parseWhileTyping(newValue)
        }
    }

    private var presented: Binding<Bool> {
        Binding {
            externalIsPresented?.wrappedValue ?? internalIsPresented
        } set: { newValue in
            if let externalIsPresented {
                externalIsPresented.wrappedValue = newValue
            } else {
                internalIsPresented = newValue
            }
        }
    }

    private var calendarSelection: Binding<Date?> {
        Binding {
            selection
        } set: { newValue in
            applySelection(newValue, preservingText: false)
            presented.wrappedValue = false
        }
    }

    private func selectPreset(_ preset: SCDatePickerPreset<Date>) {
        applySelection(preset.value, preservingText: false)
        presented.wrappedValue = false
    }

    private func commitText() {
        let candidate = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !candidate.isEmpty else {
            applySelection(nil, preservingText: false)
            return
        }
        guard let parsed = parse(candidate), accepts(parsed) else {
            isInvalid = true
            onParseFailure?(candidate)
            return
        }
        applySelection(parsed, preservingText: false)
    }

    private func parseWhileTyping(_ candidate: String) {
        let candidate = candidate.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !candidate.isEmpty else {
            applySelection(nil, preservingText: true)
            return
        }
        guard let parsed = parse(candidate), accepts(parsed) else { return }
        applySelection(parsed, preservingText: true)
    }

    private func applySelection(_ newValue: Date?, preservingText: Bool) {
        let normalized = newValue.map(calendar.startOfDay(for:))
        textOwnedSelection = preservingText ? normalized : nil
        selection = normalized
        isInvalid = false
        if !preservingText { synchronizeText() }
        onSelectionChange?(normalized)
    }

    private func accepts(_ date: Date) -> Bool {
        if let bounds, !bounds.contains(date) { return false }
        return disabled?(date) != true
    }

    private func parse(_ candidate: String) -> Date? {
        parser?(candidate) ?? dateFormatter.date(from: candidate)
    }

    private func synchronizeText() {
        text = selection.map(displayText(for:)) ?? ""
    }

    private func displayText(for date: Date) -> String {
        formatter?(date) ?? dateFormatter.string(from: date)
    }

    private var dateFormatter: DateFormatter {
        let result = DateFormatter()
        result.calendar = calendar
        result.locale = locale
        result.timeZone = timeZone
        result.dateStyle = .medium
        result.timeStyle = .none
        result.isLenient = false
        return result
    }
}

/// Natural-language convenience over `SCDateInputPicker`. Parsing remains
/// caller-owned so applications can choose their parser and locale policy.
public struct SCNaturalLanguageDatePicker: View {
    @Binding private var selection: Date?
    private let placeholder: String
    private let parser: (String) -> Date?
    private let formatter: ((Date) -> String)?
    private let onSelectionChange: ((Date?) -> Void)?

    public init(
        _ placeholder: String = "Select date",
        selection: Binding<Date?>,
        parser: @escaping (String) -> Date?,
        formatter: ((Date) -> String)? = nil,
        onSelectionChange: ((Date?) -> Void)? = nil
    ) {
        self.placeholder = placeholder
        self._selection = selection
        self.parser = parser
        self.formatter = formatter
        self.onSelectionChange = onSelectionChange
    }

    public var body: some View {
        SCDateInputPicker(
            placeholder,
            selection: $selection,
            parser: parser,
            formatter: formatter,
            parsesWhileTyping: true,
            showsParsedDate: true,
            onSelectionChange: onSelectionChange
        )
    }
}

// MARK: - Date and time picker

/// A calendar date and native time control backed by one optional `Date`.
public struct SCDateTimePicker: View {
    @Environment(\.calendar) private var calendar
    @Environment(\.theme) private var theme

    @Binding private var selection: Date?
    private let externalIsPresented: Binding<Bool>?
    private let placeholder: String
    private let timeLabel: String
    private let bounds: ClosedRange<Date>?
    private let configuration: SCCalendarConfiguration
    private let presets: [SCDatePickerPreset<Date>]
    private let defaultTime: Date
    private let onSelectionChange: ((Date?) -> Void)?

    public init(
        _ placeholder: String = "Select date",
        timeLabel: String = "Time",
        selection: Binding<Date?>,
        isPresented: Binding<Bool>? = nil,
        in bounds: ClosedRange<Date>? = nil,
        configuration: SCCalendarConfiguration = .init(),
        presets: [SCDatePickerPreset<Date>] = [],
        defaultTime: Date = Date(),
        onSelectionChange: ((Date?) -> Void)? = nil
    ) {
        self.placeholder = placeholder
        self.timeLabel = timeLabel
        self._selection = selection
        self.externalIsPresented = isPresented
        self.bounds = bounds
        self.configuration = configuration
        self.presets = presets
        self.defaultTime = defaultTime
        self.onSelectionChange = onSelectionChange
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            SCDatePicker(
                placeholder,
                selection: dateSelection,
                isPresented: externalIsPresented,
                in: bounds,
                configuration: configuration,
                presets: presets,
                onSelectionChange: { _ in onSelectionChange?(selection) }
            )

            HStack(spacing: 12) {
                Text(timeLabel)
                    .font(.subheadline)
                    .foregroundStyle(theme.foreground)
                Spacer(minLength: 12)
                DatePicker("", selection: timeSelection, displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .datePickerStyle(.compact)
                    .disabled(selection == nil)
                    .accessibilityLabel(timeLabel)
            }
        }
    }

    private var dateSelection: Binding<Date?> {
        Binding {
            selection
        } set: { newDate in
            guard let newDate else {
                selection = nil
                return
            }
            selection = merging(day: newDate, time: selection ?? defaultTime)
        }
    }

    private var timeSelection: Binding<Date> {
        Binding {
            selection ?? defaultTime
        } set: { newTime in
            guard let selectedDay = selection else { return }
            selection = merging(day: selectedDay, time: newTime)
            onSelectionChange?(selection)
        }
    }

    private func merging(day: Date, time: Date) -> Date {
        let dayParts = calendar.dateComponents([.era, .year, .month, .day], from: day)
        let timeParts = calendar.dateComponents([.hour, .minute, .second], from: time)
        var result = DateComponents()
        result.era = dayParts.era
        result.year = dayParts.year
        result.month = dayParts.month
        result.day = dayParts.day
        result.hour = timeParts.hour
        result.minute = timeParts.minute
        result.second = timeParts.second
        return calendar.date(from: result) ?? day
    }
}

// MARK: - Shared composition

private struct SCDatePickerPanel<Value, CalendarContent: View>: View {
    let presets: [SCDatePickerPreset<Value>]
    let isPresetEnabled: (SCDatePickerPreset<Value>) -> Bool
    let selectPreset: (SCDatePickerPreset<Value>) -> Void
    @ViewBuilder let calendarContent: CalendarContent

    init(
        presets: [SCDatePickerPreset<Value>],
        isPresetEnabled: @escaping (SCDatePickerPreset<Value>) -> Bool = { _ in true },
        selectPreset: @escaping (SCDatePickerPreset<Value>) -> Void,
        @ViewBuilder calendarContent: () -> CalendarContent
    ) {
        self.presets = presets
        self.isPresetEnabled = isPresetEnabled
        self.selectPreset = selectPreset
        self.calendarContent = calendarContent()
    }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if !presets.isEmpty {
                VStack(alignment: .leading, spacing: 2) {
                    ForEach(presets) { preset in
                        Button(preset.label) {
                            selectPreset(preset)
                        }
                        .buttonStyle(SCButtonStyle(variant: .ghost, size: .sm))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .disabled(!isPresetEnabled(preset))
                    }
                }
                .frame(minWidth: 112)

                Divider()
            }

            calendarContent
        }
    }
}

private struct SCDatePickerTriggerLabel: View {
    @Environment(\.theme) private var theme

    let text: String
    let isEmpty: Bool
    let isPresented: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "calendar")
                .foregroundStyle(theme.mutedForeground)
            Text(text)
                .foregroundStyle(isEmpty ? theme.mutedForeground : theme.foreground)
            Spacer(minLength: 0)
        }
        .font(.subheadline)
        .lineLimit(1)
        .padding(.horizontal, 12)
        .frame(height: 40)
        .background(theme.background, in: shape)
        .overlay(
            shape.strokeBorder(
                isPresented ? theme.ring : theme.input,
                lineWidth: isPresented ? 1.5 : 1
            )
        )
        .contentShape(shape)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.radius, style: .continuous)
    }
}

// MARK: - Previews

#Preview("DatePicker · basic and birth") {
    @Previewable @State var date: Date?
    @Previewable @State var birthday: Date?
    SCPreview {
        VStack(spacing: 12) {
            SCDatePicker(selection: $date)
            SCDatePicker(dateOfBirth: $birthday)
        }
    }
    .frame(height: 520)
}

#Preview("DatePicker · range and presets") {
    @Previewable @State var range: ClosedRange<Date>?
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    let nextWeek = calendar.date(byAdding: .day, value: 7, to: today) ?? today
    SCPreview {
        SCDateRangePicker(
            selection: $range,
            presets: [.init("Next 7 days", value: today...nextWeek)]
        )
    }
    .frame(height: 520)
}

#Preview("DatePicker · input and time") {
    @Previewable @State var inputDate: Date?
    @Previewable @State var dateTime: Date?
    SCPreview {
        VStack(spacing: 16) {
            SCDateInputPicker(selection: $inputDate)
            SCDateTimePicker(selection: $dateTime)
        }
    }
    .frame(height: 520)
}
