import SwiftUI
import Swiftcn

/// Every `SCCalendar` selection mode (single/multiple/range), multi-month
/// display, bounds-driven disabled dates, a controlled month binding, the
/// dropdown caption layout, custom day content, and a disabled instance, all
/// fixed to July 2024 so weekday-dependent assertions (which day is a
/// weekend, which day is mid-month) never depend on the run date.
///
/// The instances are split across four scene keys (`calendar`,
/// `calendarrange`, `calendarextras`, `calendarmisc`) because a month grid is
/// ~330pt tall and macOS XCUITest cannot interact with content outside the
/// host window. Each calendar is wrapped in `.accessibilityElement(children:
/// .contain)` so its identifier names one container element instead of
/// propagating onto every descendant day cell.
struct CalendarValidationScene: View {
    enum Part {
        case selection
        case range
        case extras
        case misc
    }

    let part: Part

    @State private var singleDate: Date?
    @State private var multipleDates: Set<Date> = []
    @State private var range: ClosedRange<Date>?
    @State private var disabledDatesSelection: Date?
    @State private var controlledMonth = CalendarValidationScene.date(2024, 7, 15)
    @State private var disabledInstanceSelection: Date?

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            switch part {
            case .selection: selectionPart
            case .range: rangePart
            case .extras: extrasPart
            case .misc: miscPart
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var selectionPart: some View {
        Group {
            Text("Single: \(singleDate.map(Self.format) ?? "none")")
                .accessibilityIdentifier("calendar-single-echo")
            Text("Multiple: \(multipleDates.sorted().map(Self.format).joined(separator: ", "))")
                .accessibilityIdentifier("calendar-multiple-echo")

            HStack(spacing: 20) {
                SCCalendar(
                    selection: $singleDate,
                    configuration: .init(defaultMonth: Self.fixedMonth)
                )
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("calendar-single")

                SCCalendar(
                    selections: $multipleDates,
                    configuration: .init(defaultMonth: Self.fixedMonth)
                )
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("calendar-multiple")
            }
        }
    }

    private var rangePart: some View {
        Group {
            Text("Range: \(range.map { "\(Self.format($0.lowerBound)) to \(Self.format($0.upperBound))" } ?? "none")")
                .accessibilityIdentifier("calendar-range-echo")

            SCCalendar(
                range: $range,
                configuration: .init(defaultMonth: Self.fixedMonth, numberOfMonths: 2)
            )
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("calendar-range")
        }
    }

    private var extrasPart: some View {
        Group {
            Text("Disabled-dates selection: \(disabledDatesSelection.map(Self.format) ?? "none")")
                .accessibilityIdentifier("calendar-disabled-dates-echo")
            Text("Controlled month: \(Self.formatMonth(controlledMonth))")
                .accessibilityIdentifier("calendar-controlled-month-echo")

            HStack(spacing: 20) {
                SCCalendar(
                    selection: $disabledDatesSelection,
                    disabled: { Calendar.current.isDateInWeekend($0) },
                    configuration: .init(defaultMonth: Self.fixedMonth)
                )
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("calendar-disabled-dates")

                VStack(alignment: .leading, spacing: 8) {
                    Button("Jump to January 2025") {
                        controlledMonth = Self.date(2025, 1, 1)
                    }
                    .buttonStyle(.sc(.outline, size: .sm))
                    .accessibilityIdentifier("calendar-jump-button")

                    SCCalendar(
                        selection: .constant(nil),
                        month: $controlledMonth,
                        configuration: .init(defaultMonth: Self.fixedMonth)
                    )
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("calendar-controlled-month")
                }
            }
        }
    }

    private var miscPart: some View {
        Group {
            Text("Disabled-instance selection: \(disabledInstanceSelection.map(Self.format) ?? "none")")
                .accessibilityIdentifier("calendar-disabled-echo")

            HStack(alignment: .top, spacing: 20) {
                SCCalendar(
                    selection: .constant(nil),
                    configuration: .init(defaultMonth: Self.fixedMonth, captionLayout: .dropdown)
                )
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("calendar-dropdown")

                SCCalendar(
                    selection: .constant(nil),
                    configuration: .init(defaultMonth: Self.fixedMonth)
                ) { date, state in
                    VStack(spacing: 1) {
                        Text(date, format: .dateTime.day())
                        if !state.isOutside {
                            Text(Calendar.current.isDateInWeekend(date) ? "$120" : "$100")
                                .font(.system(size: 8))
                        }
                    }
                }
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("calendar-custom-day")

                SCCalendar(
                    selection: $disabledInstanceSelection,
                    configuration: .init(defaultMonth: Self.fixedMonth)
                )
                .disabled(true)
                .accessibilityElement(children: .contain)
                .accessibilityIdentifier("calendar-disabled")
            }
        }
    }

    private static let fixedMonth = date(2024, 7, 15)

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

    private static func formatMonth(_ date: Date) -> String {
        date.formatted(.dateTime.year().month(.wide))
    }
}
