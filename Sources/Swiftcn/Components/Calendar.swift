// ============================================================
// Calendar.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Component

/// A month-view date grid — shadcn's Calendar (react-day-picker look) rebuilt
/// on Foundation's `Calendar`, so the week start, weekday symbols, and
/// numerals all follow the user's locale rather than assuming a Sunday-first
/// English calendar.
///
/// Two selection modes, chosen by initializer:
///
///     SCCalendar(selection: $date)                     // single date
///     SCCalendar(range: $stay)                         // date range
///     SCCalendar(selection: $date, bounds: today...max)
///     SCCalendar(selection: $date, disabled: { date in
///         Calendar.current.isDateInWeekend(date)       // custom disabling
///     })
///
/// Range interaction: the first tap sets the start, the second tap completes
/// the range (tapping a day before the start restarts from that day), and any
/// tap on a completed range starts a new one.
public struct SCCalendar: View {
    private enum Mode {
        case single(Binding<Date?>)
        case range(Binding<ClosedRange<Date>?>)
    }

    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.calendar) private var calendar

    private let mode: Mode
    private let bounds: ClosedRange<Date>?
    private let isDayDisabled: ((Date) -> Bool)?
    private let cellSize: CGFloat = 36

    /// Any instant inside the month currently shown.
    @State private var displayedMonth: Date
    /// Pending range start after the first tap in range mode.
    @State private var rangeAnchor: Date?

    /// Creates a calendar that selects a single date.
    ///
    /// - Parameters:
    ///   - selection: The selected day, written at the tapped day's midnight.
    ///   - bounds: Days outside this range are disabled, and months beyond it
    ///     cannot be shown.
    ///   - disabled: Return `true` to disable an individual day.
    public init(
        selection: Binding<Date?>,
        bounds: ClosedRange<Date>? = nil,
        disabled: ((Date) -> Bool)? = nil
    ) {
        self.mode = .single(selection)
        self.bounds = bounds
        self.isDayDisabled = disabled
        self._displayedMonth = State(
            initialValue: Self.initialMonth(for: selection.wrappedValue, bounds: bounds)
        )
    }

    /// Creates a calendar that selects a contiguous date range.
    ///
    /// - Parameters:
    ///   - range: The selected range. Stays `nil` until a second tap completes
    ///     the range; endpoints are the tapped days' midnights.
    ///   - bounds: Days outside this range are disabled, and months beyond it
    ///     cannot be shown.
    ///   - disabled: Return `true` to disable an individual day.
    public init(
        range: Binding<ClosedRange<Date>?>,
        bounds: ClosedRange<Date>? = nil,
        disabled: ((Date) -> Bool)? = nil
    ) {
        self.mode = .range(range)
        self.bounds = bounds
        self.isDayDisabled = disabled
        self._displayedMonth = State(
            initialValue: Self.initialMonth(for: range.wrappedValue?.lowerBound, bounds: bounds)
        )
    }

    public var body: some View {
        VStack(spacing: 8) {
            header
            weekdayHeader
            dayGrid
        }
        .frame(width: cellSize * 7)
        .fixedSize()
        .opacity(isEnabled ? 1 : 0.5)
    }

    // MARK: Header

    private var header: some View {
        ZStack {
            Text(monthStart, format: .dateTime.year().month(.wide))
                .font(.subheadline.weight(.medium))
                .foregroundStyle(theme.foreground)
                .id(monthStart)
                .transition(.opacity)

            HStack {
                navButton(systemImage: "chevron.left", step: -1, label: "Previous month")
                Spacer()
                navButton(systemImage: "chevron.right", step: 1, label: "Next month")
            }
        }
    }

    private func navButton(systemImage: String, step: Int, label: String) -> some View {
        Button {
            stepMonth(by: step)
        } label: {
            Image(systemName: systemImage)
        }
        .buttonStyle(SCCalendarNavButtonStyle())
        .disabled(!canStepMonth(by: step))
        .accessibilityLabel(label)
    }

    // MARK: Weekday header

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            ForEach(Array(orderedWeekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .font(.caption2)
                    .foregroundStyle(theme.mutedForeground)
                    .frame(width: cellSize)
            }
        }
    }

    /// Very-short weekday symbols rotated so the locale's first weekday
    /// (`calendar.firstWeekday`) comes first.
    private var orderedWeekdaySymbols: [String] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        let shift = (calendar.firstWeekday - 1) % symbols.count
        return Array(symbols[shift...] + symbols[..<shift])
    }

    // MARK: Day grid

    private var dayGrid: some View {
        LazyVGrid(
            columns: Array(repeating: GridItem(.fixed(cellSize), spacing: 0), count: 7),
            spacing: 4
        ) {
            ForEach(gridDates, id: \.self) { date in
                dayCell(for: date)
            }
        }
        .id(monthStart)
        .transition(.opacity)
    }

    @ViewBuilder
    private func dayCell(for date: Date) -> some View {
        if calendar.isDate(date, equalTo: monthStart, toGranularity: .month) {
            let disabled = isDisabled(date)
            SCCalendarDayCell(
                date: date,
                size: cellSize,
                isToday: calendar.isDateInToday(date),
                isSelected: isSelected(date),
                band: bandSegment(for: date)
            ) {
                select(date)
            }
            .disabled(disabled)
            .opacity(disabled ? 0.35 : 1)
        } else {
            // Adjacent-month filler — shown for grid continuity, not interactive.
            Text(date, format: .dateTime.day())
                .font(.footnote)
                .monospacedDigit()
                .foregroundStyle(theme.mutedForeground.opacity(0.5))
                .frame(width: cellSize, height: cellSize)
                .accessibilityHidden(true)
        }
    }

    // MARK: Month math

    private var monthStart: Date {
        calendar.dateInterval(of: .month, for: displayedMonth)?.start ?? displayedMonth
    }

    /// The visible dates: leading filler from the previous month, the whole
    /// displayed month, and trailing filler padding to a full week.
    private var gridDates: [Date] {
        let start = monthStart
        let leading = (calendar.component(.weekday, from: start) - calendar.firstWeekday + 7) % 7
        guard
            let dayCount = calendar.range(of: .day, in: .month, for: start)?.count,
            let gridStart = calendar.date(byAdding: .day, value: -leading, to: start)
        else { return [] }
        let total = ((leading + dayCount + 6) / 7) * 7
        return (0..<total).compactMap { calendar.date(byAdding: .day, value: $0, to: gridStart) }
    }

    private func stepMonth(by value: Int) {
        guard let target = calendar.date(byAdding: .month, value: value, to: monthStart) else { return }
        withAnimation(.snappy(duration: 0.2)) {
            displayedMonth = target
        }
    }

    private func canStepMonth(by value: Int) -> Bool {
        guard
            let target = calendar.date(byAdding: .month, value: value, to: monthStart),
            let interval = calendar.dateInterval(of: .month, for: target)
        else { return false }
        guard let bounds else { return true }
        // The target month must contain at least one in-bounds day.
        return interval.start <= bounds.upperBound && interval.end > bounds.lowerBound
    }

    private static func initialMonth(for date: Date?, bounds: ClosedRange<Date>?) -> Date {
        let base = date ?? Date()
        guard let bounds else { return base }
        return min(max(base, bounds.lowerBound), bounds.upperBound)
    }

    // MARK: Selection

    private var rangeSelection: ClosedRange<Date>? {
        if case .range(let binding) = mode { return binding.wrappedValue }
        return nil
    }

    private func isSelected(_ date: Date) -> Bool {
        switch mode {
        case .single(let binding):
            guard let selected = binding.wrappedValue else { return false }
            return calendar.isDate(date, inSameDayAs: selected)
        case .range(let binding):
            if let range = binding.wrappedValue {
                return calendar.isDate(date, inSameDayAs: range.lowerBound)
                    || calendar.isDate(date, inSameDayAs: range.upperBound)
            }
            if let anchor = rangeAnchor {
                return calendar.isDate(date, inSameDayAs: anchor)
            }
            return false
        }
    }

    private func bandSegment(for date: Date) -> SCCalendarDayCell.Band {
        guard let range = rangeSelection else { return .none }
        let isStart = calendar.isDate(date, inSameDayAs: range.lowerBound)
        let isEnd = calendar.isDate(date, inSameDayAs: range.upperBound)
        switch (isStart, isEnd) {
        case (true, true): return .none // single-day range — endpoint circle only
        case (true, false): return .start
        case (false, true): return .end
        case (false, false):
            return date > range.lowerBound && date < range.upperBound ? .middle : .none
        }
    }

    private func select(_ date: Date) {
        switch mode {
        case .single(let binding):
            binding.wrappedValue = date
        case .range(let binding):
            if binding.wrappedValue != nil {
                // Tapping a completed range starts a new one.
                binding.wrappedValue = nil
                rangeAnchor = date
            } else if let anchor = rangeAnchor {
                if calendar.compare(date, to: anchor, toGranularity: .day) == .orderedAscending {
                    // Earlier than the pending start — restart from here.
                    rangeAnchor = date
                } else {
                    binding.wrappedValue = min(anchor, date)...max(anchor, date)
                    rangeAnchor = nil
                }
            } else {
                rangeAnchor = date
            }
        }
    }

    private func isDisabled(_ date: Date) -> Bool {
        if let bounds {
            if calendar.compare(date, to: bounds.lowerBound, toGranularity: .day) == .orderedAscending {
                return true
            }
            if calendar.compare(date, to: bounds.upperBound, toGranularity: .day) == .orderedDescending {
                return true
            }
        }
        return isDayDisabled?(date) ?? false
    }
}

// MARK: - Day cell

/// One tappable day in the grid, drawing the today/selected/in-range layers.
private struct SCCalendarDayCell: View {
    @Environment(\.theme) private var theme

    /// Where the day sits in a completed range's `theme.secondary` band.
    enum Band {
        case none, start, middle, end
    }

    let date: Date
    let size: CGFloat
    let isToday: Bool
    let isSelected: Bool
    let band: Band
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(date, format: .dateTime.day())
                .font(.footnote)
                .monospacedDigit()
                .frame(width: size, height: size)
                .background { backgroundLayer }
                .foregroundStyle(foreground)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(date.formatted(date: .complete, time: .omitted))
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var backgroundLayer: some View {
        ZStack {
            bandShape
            if isSelected {
                Circle().fill(theme.primary)
            } else if isToday {
                Circle().fill(theme.accent)
            }
        }
    }

    @ViewBuilder private var bandShape: some View {
        switch band {
        case .none:
            EmptyView()
        case .start:
            UnevenRoundedRectangle(
                cornerRadii: .init(topLeading: size / 2, bottomLeading: size / 2),
                style: .continuous
            )
            .fill(theme.secondary)
        case .middle:
            Rectangle().fill(theme.secondary)
        case .end:
            UnevenRoundedRectangle(
                cornerRadii: .init(bottomTrailing: size / 2, topTrailing: size / 2),
                style: .continuous
            )
            .fill(theme.secondary)
        }
    }

    private var foreground: Color {
        if isSelected {
            theme.primaryForeground
        } else if isToday {
            theme.accentForeground
        } else if band == .middle {
            theme.secondaryForeground
        } else {
            theme.foreground
        }
    }
}

// MARK: - Nav button style

/// Ghost icon-button chrome for the month-stepping chevrons.
private struct SCCalendarNavButtonStyle: ButtonStyle {
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.footnote.weight(.medium))
            .frame(width: 36, height: 36)
            .background(configuration.isPressed ? theme.accent : .clear, in: shape)
            .foregroundStyle(theme.foreground)
            .contentShape(shape)
            .opacity(isEnabled ? 1 : 0.35)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.radius, style: .continuous)
    }
}

// MARK: - Previews

#Preview("Calendar · single") {
    @Previewable @State var date: Date? = Date()
    SCPreview {
        SCCalendar(selection: $date)
    }
}

#Preview("Calendar · range") {
    @Previewable @State var range: ClosedRange<Date>? = nil
    SCPreview {
        VStack(spacing: 12) {
            SCCalendar(range: $range)
            Text(
                range.map {
                    "\($0.lowerBound.formatted(date: .abbreviated, time: .omitted)) – \($0.upperBound.formatted(date: .abbreviated, time: .omitted))"
                } ?? "No range selected"
            )
            .font(.caption)
            .foregroundStyle(Theme.default.mutedForeground)
        }
    }
}

#Preview("Calendar · bounds & disabled days") {
    @Previewable @State var date: Date? = nil
    let today = Calendar.current.startOfDay(for: Date())
    let limit = Calendar.current.date(byAdding: .month, value: 2, to: today) ?? today
    SCPreview {
        SCCalendar(
            selection: $date,
            bounds: today...limit,
            disabled: { Calendar.current.isDateInWeekend($0) }
        )
    }
}

#Preview("Calendar · disabled") {
    @Previewable @State var date: Date? = Date()
    SCPreview {
        SCCalendar(selection: $date)
            .disabled(true)
    }
}
