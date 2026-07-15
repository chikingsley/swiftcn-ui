// ============================================================
// Calendar.swift — swiftcn-ui
// Depends on: Theme/, Button.swift
// ============================================================
import SwiftUI

// MARK: - Configuration

public enum SCCalendarCaptionLayout: CaseIterable, Sendable {
    case label
    case dropdown
    case dropdownMonths
    case dropdownYears
}

/// Layout and interaction options shared by every calendar selection mode.
public struct SCCalendarConfiguration: Sendable {
    public var defaultMonth: Date?
    public var showOutsideDays: Bool
    public var fixedWeeks: Bool
    public var showWeekNumber: Bool
    public var numberOfMonths: Int
    public var captionLayout: SCCalendarCaptionLayout
    public var navigationButtonVariant: SCButtonVariant
    public var cellSize: CGFloat
    public var yearRange: ClosedRange<Int>?
    public var allowsDeselection: Bool

    public init(
        defaultMonth: Date? = nil,
        showOutsideDays: Bool = true,
        fixedWeeks: Bool = false,
        showWeekNumber: Bool = false,
        numberOfMonths: Int = 1,
        captionLayout: SCCalendarCaptionLayout = .label,
        navigationButtonVariant: SCButtonVariant = .ghost,
        cellSize: CGFloat = 36,
        yearRange: ClosedRange<Int>? = nil,
        allowsDeselection: Bool = true
    ) {
        self.defaultMonth = defaultMonth
        self.showOutsideDays = showOutsideDays
        self.fixedWeeks = fixedWeeks
        self.showWeekNumber = showWeekNumber
        self.numberOfMonths = max(numberOfMonths, 1)
        self.captionLayout = captionLayout
        self.navigationButtonVariant = navigationButtonVariant
        self.cellSize = max(cellSize, 24)
        self.yearRange = yearRange
        self.allowsDeselection = allowsDeselection
    }
}

/// Public state supplied to custom day content and `SCCalendarDayButton`.
public struct SCCalendarDayState: Sendable, Equatable {
    public var isOutside: Bool
    public var isToday: Bool
    public var isSelected: Bool
    public var isRangeStart: Bool
    public var isRangeMiddle: Bool
    public var isRangeEnd: Bool
    public var isDisabled: Bool

    public init(
        isOutside: Bool = false,
        isToday: Bool = false,
        isSelected: Bool = false,
        isRangeStart: Bool = false,
        isRangeMiddle: Bool = false,
        isRangeEnd: Bool = false,
        isDisabled: Bool = false
    ) {
        self.isOutside = isOutside
        self.isToday = isToday
        self.isSelected = isSelected
        self.isRangeStart = isRangeStart
        self.isRangeMiddle = isRangeMiddle
        self.isRangeEnd = isRangeEnd
        self.isDisabled = isDisabled
    }
}

// MARK: - Calendar

/// A localized, composable month calendar with single, multiple, and range selection.
public struct SCCalendar<DayContent: View>: View {
    private enum Mode {
        case single(Binding<Date?>)
        case multiple(Binding<Set<Date>>)
        case range(Binding<ClosedRange<Date>?>)
    }

    @Environment(\.calendar) private var calendar
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.theme) private var theme

    @FocusState private var focusedDate: Date?
    @State private var localMonth: Date
    @State private var rangeAnchor: Date?

    private let mode: Mode
    private let bounds: ClosedRange<Date>?
    private let isDayDisabled: ((Date) -> Bool)?
    private let controlledMonth: Binding<Date>?
    private let configuration: SCCalendarConfiguration
    private let onMonthChange: ((Date) -> Void)?
    private let dayContent: (Date, SCCalendarDayState) -> DayContent

    private init(
        mode: Mode,
        initialSelection: Date?,
        bounds: ClosedRange<Date>?,
        disabled: ((Date) -> Bool)?,
        month: Binding<Date>?,
        configuration: SCCalendarConfiguration,
        onMonthChange: ((Date) -> Void)?,
        dayContent: @escaping (Date, SCCalendarDayState) -> DayContent
    ) {
        self.mode = mode
        self.bounds = bounds
        self.isDayDisabled = disabled
        self.controlledMonth = month
        self.configuration = configuration
        self.onMonthChange = onMonthChange
        self.dayContent = dayContent

        let proposed = month?.wrappedValue ?? configuration.defaultMonth ?? initialSelection ?? Date()
        self._localMonth = State(initialValue: Self.clamped(proposed, to: bounds))
    }

    public init(
        selection: Binding<Date?>,
        bounds: ClosedRange<Date>? = nil,
        disabled: ((Date) -> Bool)? = nil,
        month: Binding<Date>? = nil,
        configuration: SCCalendarConfiguration = .init(),
        onMonthChange: ((Date) -> Void)? = nil,
        @ViewBuilder dayContent: @escaping (Date, SCCalendarDayState) -> DayContent
    ) {
        self.init(
            mode: .single(selection),
            initialSelection: selection.wrappedValue,
            bounds: bounds,
            disabled: disabled,
            month: month,
            configuration: configuration,
            onMonthChange: onMonthChange,
            dayContent: dayContent
        )
    }

    public init(
        selections: Binding<Set<Date>>,
        bounds: ClosedRange<Date>? = nil,
        disabled: ((Date) -> Bool)? = nil,
        month: Binding<Date>? = nil,
        configuration: SCCalendarConfiguration = .init(),
        onMonthChange: ((Date) -> Void)? = nil,
        @ViewBuilder dayContent: @escaping (Date, SCCalendarDayState) -> DayContent
    ) {
        self.init(
            mode: .multiple(selections),
            initialSelection: selections.wrappedValue.min(),
            bounds: bounds,
            disabled: disabled,
            month: month,
            configuration: configuration,
            onMonthChange: onMonthChange,
            dayContent: dayContent
        )
    }

    public init(
        range: Binding<ClosedRange<Date>?>,
        bounds: ClosedRange<Date>? = nil,
        disabled: ((Date) -> Bool)? = nil,
        month: Binding<Date>? = nil,
        configuration: SCCalendarConfiguration = .init(),
        onMonthChange: ((Date) -> Void)? = nil,
        @ViewBuilder dayContent: @escaping (Date, SCCalendarDayState) -> DayContent
    ) {
        self.init(
            mode: .range(range),
            initialSelection: range.wrappedValue?.lowerBound,
            bounds: bounds,
            disabled: disabled,
            month: month,
            configuration: configuration,
            onMonthChange: onMonthChange,
            dayContent: dayContent
        )
    }

    public var body: some View {
        keyboardEnabledContent
            .fixedSize()
            .opacity(isEnabled ? 1 : 0.5)
            .environment(\.layoutDirection, layoutDirection)
    }

    @ViewBuilder
    private var keyboardEnabledContent: some View {
        #if os(macOS)
            months
                .onMoveCommand(perform: moveFocus)
        #else
            months
        #endif
    }

    private var months: some View {
        HStack(alignment: .top, spacing: 16) {
            ForEach(0..<configuration.numberOfMonths, id: \.self) { index in
                if let month = calendar.date(
                    byAdding: .month,
                    value: index,
                    to: firstVisibleMonth
                ) {
                    monthView(month, index: index)
                }
            }
        }
    }

    private func monthView(_ month: Date, index: Int) -> some View {
        VStack(spacing: 8) {
            monthHeader(month, index: index)
            weekdayHeader
            weekRows(for: month)
        }
        .frame(width: configuration.cellSize * CGFloat(configuration.showWeekNumber ? 8 : 7))
    }

    // MARK: Caption and navigation

    private func monthHeader(_ month: Date, index: Int) -> some View {
        ZStack {
            caption(for: month, index: index)
            HStack {
                if index == 0 {
                    navigationButton(step: -1, label: "Previous month")
                }
                Spacer()
                if index == configuration.numberOfMonths - 1 {
                    navigationButton(step: 1, label: "Next month")
                }
            }
        }
        .frame(height: configuration.cellSize)
    }

    @ViewBuilder
    private func caption(for month: Date, index: Int) -> some View {
        switch configuration.captionLayout {
        case .label:
            Text(month, format: .dateTime.year().month(.wide))
                .font(.subheadline.weight(.medium))
        case .dropdown:
            HStack(spacing: 6) {
                monthPicker(for: month, index: index)
                yearPicker(for: month, index: index)
            }
        case .dropdownMonths:
            HStack(spacing: 6) {
                monthPicker(for: month, index: index)
                Text(month, format: .dateTime.year())
            }
        case .dropdownYears:
            HStack(spacing: 6) {
                Text(month, format: .dateTime.month(.abbreviated))
                yearPicker(for: month, index: index)
            }
        }
    }

    private func monthPicker(for month: Date, index: Int) -> some View {
        Picker(
            "Month",
            selection: Binding(
                get: { calendar.component(.month, from: month) },
                set: { setCaptionMonth($0, current: month, visibleIndex: index) }
            )
        ) {
            ForEach(1...12, id: \.self) { value in
                Text(calendar.shortMonthSymbols[value - 1]).tag(value)
            }
        }
        .labelsHidden()
        .pickerStyle(.menu)
        .fixedSize()
    }

    private func yearPicker(for month: Date, index: Int) -> some View {
        Picker(
            "Year",
            selection: Binding(
                get: { calendar.component(.year, from: month) },
                set: { setCaptionYear($0, current: month, visibleIndex: index) }
            )
        ) {
            ForEach(yearRange, id: \.self) { year in
                Text(String(year)).tag(year)
            }
        }
        .labelsHidden()
        .pickerStyle(.menu)
        .fixedSize()
    }

    private var yearRange: ClosedRange<Int> {
        if let configured = configuration.yearRange { return configured }
        if let bounds {
            let lower = calendar.component(.year, from: bounds.lowerBound)
            let upper = calendar.component(.year, from: bounds.upperBound)
            return lower...upper
        }
        let current = calendar.component(.year, from: Date())
        return (current - 100)...(current + 100)
    }

    private func navigationButton(step: Int, label: String) -> some View {
        Button {
            stepMonth(by: step)
        } label: {
            Image(systemName: step < 0 ? "chevron.backward" : "chevron.forward")
        }
        .buttonStyle(.sc(configuration.navigationButtonVariant, size: .icon))
        .disabled(!canStepMonth(by: step))
        .accessibilityLabel(Text(label))
    }

    // MARK: Grid

    private var weekdayHeader: some View {
        HStack(spacing: 0) {
            if configuration.showWeekNumber {
                Text("#")
                    .accessibilityLabel(Text("Week"))
                    .frame(width: configuration.cellSize)
            }
            ForEach(Array(orderedWeekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .frame(width: configuration.cellSize)
            }
        }
        .font(.caption2)
        .foregroundStyle(theme.mutedForeground)
    }

    private var orderedWeekdaySymbols: [String] {
        let symbols = calendar.veryShortStandaloneWeekdaySymbols
        guard !symbols.isEmpty else { return [] }
        let shift = (calendar.firstWeekday - 1) % symbols.count
        return Array(symbols[shift...] + symbols[..<shift])
    }

    private func weekRows(for month: Date) -> some View {
        let weeks = gridDates(for: month).chunked(into: 7)
        return VStack(spacing: 4) {
            ForEach(Array(weeks.enumerated()), id: \.offset) { _, week in
                HStack(spacing: 0) {
                    if configuration.showWeekNumber, let first = week.first {
                        Text(String(calendar.component(.weekOfYear, from: first)))
                            .font(.caption2)
                            .foregroundStyle(theme.mutedForeground)
                            .frame(width: configuration.cellSize, height: configuration.cellSize)
                            .accessibilityLabel(
                                Text("Week \(calendar.component(.weekOfYear, from: first))")
                            )
                    }
                    ForEach(week, id: \.self) { date in
                        dayCell(for: date, displayedMonth: month)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private func dayCell(for date: Date, displayedMonth: Date) -> some View {
        let outside = !calendar.isDate(date, equalTo: displayedMonth, toGranularity: .month)
        if outside && !configuration.showOutsideDays {
            Color.clear
                .frame(width: configuration.cellSize, height: configuration.cellSize)
                .accessibilityHidden(true)
        } else {
            let state = dayState(for: date, isOutside: outside)
            SCCalendarDayButton(
                date: date,
                state: state,
                size: configuration.cellSize,
                focusedDate: $focusedDate
            ) {
                select(date, outside: outside)
            } content: {
                dayContent(date, state)
            }
        }
    }

    private func gridDates(for month: Date) -> [Date] {
        let start = monthStart(month)
        let leading = (calendar.component(.weekday, from: start) - calendar.firstWeekday + 7) % 7
        guard
            let dayCount = calendar.range(of: .day, in: .month, for: start)?.count,
            let gridStart = calendar.date(byAdding: .day, value: -leading, to: start)
        else { return [] }
        let naturalCount = ((leading + dayCount + 6) / 7) * 7
        let total = configuration.fixedWeeks ? 42 : naturalCount
        return (0..<total).compactMap {
            calendar.date(byAdding: .day, value: $0, to: gridStart)
        }
    }

    // MARK: State and selection

    private func dayState(for date: Date, isOutside: Bool) -> SCCalendarDayState {
        let range = rangeSelection
        let rangeStart = range.map { sameDay(date, $0.lowerBound) } ?? false
        let rangeEnd = range.map { sameDay(date, $0.upperBound) } ?? false
        let rangeMiddle =
            range.map {
                date > calendar.startOfDay(for: $0.lowerBound)
                    && date < calendar.startOfDay(for: $0.upperBound)
            } ?? false
        return SCCalendarDayState(
            isOutside: isOutside,
            isToday: calendar.isDateInToday(date),
            isSelected: isSelected(date),
            isRangeStart: rangeStart,
            isRangeMiddle: rangeMiddle,
            isRangeEnd: rangeEnd,
            isDisabled: isDisabled(date)
        )
    }

    private var rangeSelection: ClosedRange<Date>? {
        if case .range(let binding) = mode { return binding.wrappedValue }
        return nil
    }

    private func isSelected(_ date: Date) -> Bool {
        switch mode {
        case .single(let binding):
            return binding.wrappedValue.map { sameDay(date, $0) } ?? false
        case .multiple(let binding):
            return binding.wrappedValue.contains { sameDay(date, $0) }
        case .range(let binding):
            if let range = binding.wrappedValue {
                return sameDay(date, range.lowerBound) || sameDay(date, range.upperBound)
            }
            return rangeAnchor.map { sameDay(date, $0) } ?? false
        }
    }

    private func select(_ date: Date, outside: Bool) {
        let date = calendar.startOfDay(for: date)
        guard !isDisabled(date) else { return }

        switch mode {
        case .single(let binding):
            if configuration.allowsDeselection, binding.wrappedValue.map({ sameDay($0, date) }) == true {
                binding.wrappedValue = nil
            } else {
                binding.wrappedValue = date
            }
        case .multiple(let binding):
            if let stored = binding.wrappedValue.first(where: { sameDay($0, date) }) {
                binding.wrappedValue.remove(stored)
            } else {
                binding.wrappedValue.insert(date)
            }
        case .range(let binding):
            if binding.wrappedValue != nil {
                binding.wrappedValue = nil
                rangeAnchor = date
            } else if let anchor = rangeAnchor {
                binding.wrappedValue = min(anchor, date)...max(anchor, date)
                rangeAnchor = nil
            } else {
                rangeAnchor = date
            }
        }

        focusedDate = date
        if outside { setFirstVisibleMonth(date) }
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

    private func sameDay(_ lhs: Date, _ rhs: Date) -> Bool {
        calendar.isDate(lhs, inSameDayAs: rhs)
    }

    // MARK: Month ownership

    private var firstVisibleMonth: Date {
        monthStart(controlledMonth?.wrappedValue ?? localMonth)
    }

    private func monthStart(_ date: Date) -> Date {
        calendar.dateInterval(of: .month, for: date)?.start ?? date
    }

    private func stepMonth(by value: Int) {
        guard let target = calendar.date(byAdding: .month, value: value, to: firstVisibleMonth) else {
            return
        }
        setFirstVisibleMonth(target)
    }

    private func canStepMonth(by value: Int) -> Bool {
        guard let target = calendar.date(byAdding: .month, value: value, to: firstVisibleMonth) else {
            return false
        }
        guard let bounds else { return true }
        let lastOffset = configuration.numberOfMonths - 1
        let lastMonth = calendar.date(byAdding: .month, value: lastOffset, to: target) ?? target
        guard
            let firstInterval = calendar.dateInterval(of: .month, for: target),
            let lastInterval = calendar.dateInterval(of: .month, for: lastMonth)
        else { return false }
        return firstInterval.start <= bounds.upperBound && lastInterval.end > bounds.lowerBound
    }

    private func setFirstVisibleMonth(_ date: Date) {
        let value = monthStart(Self.clamped(date, to: bounds))
        withAnimation(.snappy(duration: 0.2)) {
            localMonth = value
            controlledMonth?.wrappedValue = value
        }
        onMonthChange?(value)
    }

    private func setCaptionMonth(_ value: Int, current: Date, visibleIndex: Int) {
        var components = calendar.dateComponents([.year], from: current)
        components.month = value
        components.day = 1
        guard let target = calendar.date(from: components) else { return }
        setVisibleMonth(target, at: visibleIndex)
    }

    private func setCaptionYear(_ value: Int, current: Date, visibleIndex: Int) {
        var components = calendar.dateComponents([.month], from: current)
        components.year = value
        components.day = 1
        guard let target = calendar.date(from: components) else { return }
        setVisibleMonth(target, at: visibleIndex)
    }

    private func setVisibleMonth(_ date: Date, at index: Int) {
        let target = calendar.date(byAdding: .month, value: -index, to: date) ?? date
        setFirstVisibleMonth(target)
    }

    private static func clamped(_ date: Date, to bounds: ClosedRange<Date>?) -> Date {
        guard let bounds else { return date }
        return min(max(date, bounds.lowerBound), bounds.upperBound)
    }

    // MARK: Keyboard focus

    #if os(macOS)
        private func moveFocus(_ direction: MoveCommandDirection) {
            let offset: Int
            switch direction {
            case .left: offset = layoutDirection == .leftToRight ? -1 : 1
            case .right: offset = layoutDirection == .leftToRight ? 1 : -1
            case .up: offset = -7
            case .down: offset = 7
            default: return
            }

            var candidate = focusedDate ?? firstSelectedDate ?? Date()
            for _ in 0..<366 {
                guard let next = calendar.date(byAdding: .day, value: offset, to: candidate) else {
                    return
                }
                candidate = calendar.startOfDay(for: next)
                if !isDisabled(candidate) { break }
            }
            focusedDate = candidate

            let finalMonth = monthStart(candidate)
            let visibleMonths = (0..<configuration.numberOfMonths).compactMap {
                calendar.date(byAdding: .month, value: $0, to: firstVisibleMonth)
            }
            if !visibleMonths.contains(where: { monthStart($0) == finalMonth }) {
                setFirstVisibleMonth(finalMonth)
            }
        }
    #endif

    private var firstSelectedDate: Date? {
        switch mode {
        case .single(let binding): return binding.wrappedValue
        case .multiple(let binding): return binding.wrappedValue.min()
        case .range(let binding): return binding.wrappedValue?.lowerBound ?? rangeAnchor
        }
    }
}

// MARK: - Default day content

extension SCCalendar where DayContent == Text {
    public init(
        selection: Binding<Date?>,
        bounds: ClosedRange<Date>? = nil,
        disabled: ((Date) -> Bool)? = nil,
        month: Binding<Date>? = nil,
        configuration: SCCalendarConfiguration = .init(),
        onMonthChange: ((Date) -> Void)? = nil
    ) {
        self.init(
            selection: selection,
            bounds: bounds,
            disabled: disabled,
            month: month,
            configuration: configuration,
            onMonthChange: onMonthChange
        ) { date, _ in
            Text(date, format: .dateTime.day())
        }
    }

    public init(
        selections: Binding<Set<Date>>,
        bounds: ClosedRange<Date>? = nil,
        disabled: ((Date) -> Bool)? = nil,
        month: Binding<Date>? = nil,
        configuration: SCCalendarConfiguration = .init(),
        onMonthChange: ((Date) -> Void)? = nil
    ) {
        self.init(
            selections: selections,
            bounds: bounds,
            disabled: disabled,
            month: month,
            configuration: configuration,
            onMonthChange: onMonthChange
        ) { date, _ in
            Text(date, format: .dateTime.day())
        }
    }

    public init(
        range: Binding<ClosedRange<Date>?>,
        bounds: ClosedRange<Date>? = nil,
        disabled: ((Date) -> Bool)? = nil,
        month: Binding<Date>? = nil,
        configuration: SCCalendarConfiguration = .init(),
        onMonthChange: ((Date) -> Void)? = nil
    ) {
        self.init(
            range: range,
            bounds: bounds,
            disabled: disabled,
            month: month,
            configuration: configuration,
            onMonthChange: onMonthChange
        ) { date, _ in
            Text(date, format: .dateTime.day())
        }
    }
}

// MARK: - Day button

/// A reusable calendar day button that accepts arbitrary day content.
public struct SCCalendarDayButton<Content: View>: View {
    @Environment(\.theme) private var theme

    private let date: Date
    private let state: SCCalendarDayState
    private let size: CGFloat
    private let focusedDate: FocusState<Date?>.Binding?
    private let action: () -> Void
    private let content: Content

    public init(
        date: Date,
        state: SCCalendarDayState,
        size: CGFloat = 36,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.date = date
        self.state = state
        self.size = size
        self.focusedDate = nil
        self.action = action
        self.content = content()
    }

    fileprivate init(
        date: Date,
        state: SCCalendarDayState,
        size: CGFloat,
        focusedDate: FocusState<Date?>.Binding,
        action: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.date = date
        self.state = state
        self.size = size
        self.focusedDate = focusedDate
        self.action = action
        self.content = content()
    }

    public var body: some View {
        Group {
            if let focusedDate {
                button.focused(focusedDate, equals: date)
            } else {
                button
            }
        }
    }

    private var button: some View {
        Button(action: action) {
            VStack(spacing: 1) {
                content
            }
            .font(.footnote)
            .monospacedDigit()
            .frame(width: size, height: size)
            .background { backgroundLayer }
            .foregroundStyle(foreground)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(state.isDisabled)
        .opacity(state.isDisabled ? 0.35 : 1)
        .accessibilityLabel(Text(date.formatted(date: .complete, time: .omitted)))
        .accessibilityAddTraits(state.isSelected ? .isSelected : [])
    }

    private var backgroundLayer: some View {
        ZStack {
            rangeBand
            if state.isSelected || state.isRangeStart || state.isRangeEnd {
                RoundedRectangle(cornerRadius: theme.radius, style: .continuous)
                    .fill(theme.primary)
            } else if state.isToday {
                RoundedRectangle(cornerRadius: theme.radius, style: .continuous)
                    .fill(theme.muted)
            }
        }
    }

    @ViewBuilder
    private var rangeBand: some View {
        if state.isRangeMiddle {
            Rectangle().fill(theme.muted)
        } else if state.isRangeStart, !state.isRangeEnd {
            UnevenRoundedRectangle(
                cornerRadii: .init(
                    topLeading: theme.radius,
                    bottomLeading: theme.radius
                ),
                style: .continuous
            )
            .fill(theme.muted)
        } else if state.isRangeEnd, !state.isRangeStart {
            UnevenRoundedRectangle(
                cornerRadii: .init(
                    bottomTrailing: theme.radius,
                    topTrailing: theme.radius
                ),
                style: .continuous
            )
            .fill(theme.muted)
        }
    }

    private var foreground: Color {
        if state.isSelected || state.isRangeStart || state.isRangeEnd {
            return theme.primaryForeground
        }
        if state.isOutside { return theme.mutedForeground }
        return theme.foreground
    }
}

extension Array {
    fileprivate func chunked(into size: Int) -> [[Element]] {
        guard size > 0 else { return [] }
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}

// MARK: - Previews

#Preview("Calendar · modes") {
    @Previewable @State var date: Date? = Date()
    @Previewable @State var dates: Set<Date> = []
    @Previewable @State var range: ClosedRange<Date>?

    SCPreview {
        HStack(alignment: .top, spacing: 20) {
            SCCalendar(
                selection: $date,
                configuration: .init(captionLayout: .dropdown)
            )
            SCCalendar(selections: $dates)
            SCCalendar(range: $range)
        }
    }
}

#Preview("Calendar · multi-month custom days") {
    @Previewable @State var range: ClosedRange<Date>?

    SCPreview {
        SCCalendar(
            range: $range,
            configuration: .init(
                fixedWeeks: true,
                showWeekNumber: true,
                numberOfMonths: 2
            )
        ) { date, state in
            VStack(spacing: 1) {
                Text(date, format: .dateTime.day())
                if !state.isOutside {
                    Text(Calendar.current.isDateInWeekend(date) ? "$120" : "$100")
                        .font(.system(size: 8))
                }
            }
        }
    }
}
