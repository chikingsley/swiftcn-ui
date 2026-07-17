import SwiftUI
import Swiftcn

/// Every bundled date-picker convenience — basic, range with presets,
/// date-of-birth dropdown captions, text input with a calendar action,
/// natural-language parsing, and combined date/time — each fixed to July
/// 2024 (or a pre-seeded 1990 birth date) for determinism, plus a disabled
/// instance, so UI tests can prove day selection, presets, typed input, and
/// natural-language parsing all route into caller-owned `Date?` bindings.
/// shadcn has no DatePicker root; every instance here composes the public
/// Popover and Calendar the same way a custom caller would.
struct DatePickerValidationScene: View {
    @State private var basicDate: Date?
    @State private var rangeSelection: ClosedRange<Date>?
    @State private var birthDate: Date? = DatePickerValidationScene.date(1990, 1, 15)
    @State private var inputDate: Date?
    @State private var nlDate: Date?
    @State private var dateTimeSelection: Date?
    @State private var disabledSelection: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            echoes

            SCDatePicker(
                "Pick a date",
                selection: $basicDate,
                configuration: .init(defaultMonth: Self.fixedMonth)
            )
            .accessibilityIdentifier("datepicker-basic-trigger")

            SCDateRangePicker(
                "Pick a date range",
                selection: $rangeSelection,
                configuration: .init(defaultMonth: Self.fixedMonth, numberOfMonths: 2),
                presets: [.init("This week", value: Self.fixedWeek)]
            )
            .accessibilityIdentifier("datepicker-range-trigger")

            SCDatePicker(dateOfBirth: $birthDate)
                .accessibilityIdentifier("datepicker-birth-trigger")

            SCDateInputPicker(
                selection: $inputDate,
                configuration: .init(defaultMonth: Self.fixedMonth)
            )
            .accessibilityIdentifier("datepicker-input")

            SCNaturalLanguageDatePicker(
                selection: $nlDate,
                parser: Self.parseNaturalLanguage
            )
            .accessibilityIdentifier("datepicker-nl")

            SCDateTimePicker(
                selection: $dateTimeSelection,
                configuration: .init(defaultMonth: Self.fixedMonth),
                defaultTime: Self.fixedMonth
            )
            .accessibilityIdentifier("datepicker-datetime")

            SCDatePicker(selection: $disabledSelection)
                .disabled(true)
                .accessibilityIdentifier("datepicker-disabled-trigger")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    @ViewBuilder
    private var echoes: some View {
        Text("Basic: \(basicDate.map(Self.format) ?? "none")")
            .accessibilityIdentifier("datepicker-basic-echo")
        Text(
            "Range: "
                + (rangeSelection.map { "\(Self.format($0.lowerBound)) to \(Self.format($0.upperBound))" } ?? "none")
        )
        .accessibilityIdentifier("datepicker-range-echo")
        Text("Birth: \(birthDate.map(Self.format) ?? "none")")
            .accessibilityIdentifier("datepicker-birth-echo")
        Text("Input: \(inputDate.map(Self.format) ?? "none")")
            .accessibilityIdentifier("datepicker-input-echo")
        Text("Natural language: \(nlDate.map(Self.format) ?? "none")")
            .accessibilityIdentifier("datepicker-nl-echo")
        Text("Date/time: \(dateTimeSelection.map(Self.formatDateTime) ?? "none")")
            .accessibilityIdentifier("datepicker-datetime-echo")
        Text("Disabled: \(disabledSelection.map(Self.format) ?? "none")")
            .accessibilityIdentifier("datepicker-disabled-echo")
    }

    private static let fixedMonth = date(2024, 7, 15)
    private static let fixedWeek = date(2024, 7, 8)...date(2024, 7, 14)

    private static func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components) ?? Date()
    }

    private static func format(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .omitted)
    }

    private static func formatDateTime(_ date: Date) -> String {
        date.formatted(date: .abbreviated, time: .shortened)
    }

    private static func parseNaturalLanguage(_ text: String) -> Date? {
        switch text.lowercased() {
        case "today": return fixedMonth
        case "tomorrow": return Calendar.current.date(byAdding: .day, value: 1, to: fixedMonth)
        default: return nil
        }
    }
}
