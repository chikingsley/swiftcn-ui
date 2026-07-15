// ============================================================
// Sidebar12Block.swift — swiftcn-ui
// Depends on: SidebarBlock, Calendar, Breadcrumb, Separator
// ============================================================
import SwiftUI

public struct SCSidebar12CalendarItem: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String

    public init(id: String, name: String) {
        self.id = id
        self.name = name
    }
}

public struct SCSidebar12CalendarGroup: Identifiable, Hashable, Sendable {
    public let id: String
    public let name: String
    public let items: [SCSidebar12CalendarItem]

    public init(id: String, name: String, items: [SCSidebar12CalendarItem]) {
        self.id = id
        self.name = name
        self.items = items
    }
}

public struct SCSidebar12Data: Sendable {
    public var user: SCSidebarUser
    public var calendars: [SCSidebar12CalendarGroup]
    public var defaultMonth: Date
    public var defaultSelectedCalendarIDs: Set<String>
    public var initiallyExpandedGroupIDs: Set<String>

    public init(
        user: SCSidebarUser,
        calendars: [SCSidebar12CalendarGroup],
        defaultMonth: Date,
        defaultSelectedCalendarIDs: Set<String> = [],
        initiallyExpandedGroupIDs: Set<String> = []
    ) {
        self.user = user
        self.calendars = calendars
        self.defaultMonth = defaultMonth
        self.defaultSelectedCalendarIDs = defaultSelectedCalendarIDs
        self.initiallyExpandedGroupIDs = initiallyExpandedGroupIDs
    }

    public static let sidebar12 = SCSidebar12Data(
        user: SCSidebarUser(
            name: "shadcn",
            email: "m@example.com",
            fallback: "CN"
        ),
        calendars: [
            SCSidebar12CalendarGroup(
                id: "my-calendars",
                name: "My Calendars",
                items: [
                    SCSidebar12CalendarItem(id: "personal", name: "Personal"),
                    SCSidebar12CalendarItem(id: "work", name: "Work"),
                    SCSidebar12CalendarItem(id: "family", name: "Family"),
                ]
            ),
            SCSidebar12CalendarGroup(
                id: "favorites",
                name: "Favorites",
                items: [
                    SCSidebar12CalendarItem(id: "holidays", name: "Holidays"),
                    SCSidebar12CalendarItem(id: "birthdays", name: "Birthdays"),
                ]
            ),
            SCSidebar12CalendarGroup(
                id: "other",
                name: "Other",
                items: [
                    SCSidebar12CalendarItem(id: "travel", name: "Travel"),
                    SCSidebar12CalendarItem(id: "reminders", name: "Reminders"),
                    SCSidebar12CalendarItem(id: "deadlines", name: "Deadlines"),
                ]
            ),
        ],
        defaultMonth: Date(timeIntervalSince1970: 1_727_740_800),
        defaultSelectedCalendarIDs: [
            "personal", "work", "holidays", "birthdays", "travel", "reminders",
        ],
        initiallyExpandedGroupIDs: ["my-calendars"]
    )
}

public enum SCSidebar12Action: Hashable, Sendable {
    case user(SCSidebarUserAction)
    case selectDate(Date?)
    case changeMonth(Date)
    case setCalendarEnabled(String, Bool)
    case setGroupExpanded(String, Bool)
    case createCalendar
}

/// A functional calendar workspace matching shadcn's `sidebar-12` composition.
/// Date, month, enabled-calendar, and disclosure state can all be caller-owned.
public struct SCSidebar12Block<Detail: View>: View {
    @Environment(\.theme) private var theme

    @State private var internalSelectedDate: Date?
    @State private var internalMonth: Date
    @State private var internalSelectedCalendarIDs: Set<String>
    @State private var internalExpandedGroupIDs: Set<String>

    private let data: SCSidebar12Data
    private let externalSelectedDate: Binding<Date?>?
    private let externalMonth: Binding<Date>?
    private let externalSelectedCalendarIDs: Binding<Set<String>>?
    private let externalExpandedGroupIDs: Binding<Set<String>>?
    private let collapsible: SCSidebarCollapsible
    private let side: SCSidebarSide
    private let showsDetailHeader: Bool
    private let persistenceKey: String?
    private let onAction: (SCSidebar12Action) -> Void
    private let detail: (Date?, Set<String>) -> Detail

    public init(
        data: SCSidebar12Data = .sidebar12,
        selectedDate: Binding<Date?>? = nil,
        month: Binding<Date>? = nil,
        selectedCalendarIDs: Binding<Set<String>>? = nil,
        expandedGroupIDs: Binding<Set<String>>? = nil,
        collapsible: SCSidebarCollapsible = .offcanvas,
        side: SCSidebarSide = .leading,
        showsDetailHeader: Bool = true,
        persistenceKey: String? = "sc.sidebar12.open",
        onAction: @escaping (SCSidebar12Action) -> Void,
        @ViewBuilder detail:
            @escaping (
                _ selectedDate: Date?,
                _ selectedCalendarIDs: Set<String>
            ) -> Detail
    ) {
        self.data = data
        self.externalSelectedDate = selectedDate
        self.externalMonth = month
        self.externalSelectedCalendarIDs = selectedCalendarIDs
        self.externalExpandedGroupIDs = expandedGroupIDs
        self.collapsible = collapsible
        self.side = side
        self.showsDetailHeader = showsDetailHeader
        self.persistenceKey = persistenceKey
        self.onAction = onAction
        self.detail = detail
        _internalSelectedDate = State(initialValue: selectedDate?.wrappedValue)
        _internalMonth = State(initialValue: month?.wrappedValue ?? data.defaultMonth)
        _internalSelectedCalendarIDs = State(
            initialValue: selectedCalendarIDs?.wrappedValue ?? data.defaultSelectedCalendarIDs
        )
        _internalExpandedGroupIDs = State(
            initialValue: expandedGroupIDs?.wrappedValue ?? data.initiallyExpandedGroupIDs
        )
    }

    public init(
        data: SCSidebar12Data = .sidebar12,
        selectedDate: Binding<Date?>? = nil,
        month: Binding<Date>? = nil,
        selectedCalendarIDs: Binding<Set<String>>? = nil,
        expandedGroupIDs: Binding<Set<String>>? = nil,
        collapsible: SCSidebarCollapsible = .offcanvas,
        side: SCSidebarSide = .leading,
        showsDetailHeader: Bool = true,
        persistenceKey: String? = "sc.sidebar12.open",
        onAction: @escaping (SCSidebar12Action) -> Void,
        @ViewBuilder detail: @escaping () -> Detail
    ) {
        self.init(
            data: data,
            selectedDate: selectedDate,
            month: month,
            selectedCalendarIDs: selectedCalendarIDs,
            expandedGroupIDs: expandedGroupIDs,
            collapsible: collapsible,
            side: side,
            showsDetailHeader: showsDetailHeader,
            persistenceKey: persistenceKey,
            onAction: onAction,
            detail: { _, _ in detail() }
        )
    }

    public var body: some View {
        SCSidebarLayout(
            collapsible: collapsible,
            side: side,
            persistenceKey: persistenceKey
        ) {
            SCSidebarHeader {
                SCSidebarUserMenu(user: data.user) { onAction(.user($0)) }
            }
            .frame(height: 64)
            .overlay(alignment: .bottom) {
                Rectangle()
                    .fill(theme.sidebarBorder)
                    .frame(height: 1)
                    .accessibilityHidden(true)
            }
            SCSidebarContent {
                datePicker
                SCSidebarSeparator(isDecorative: true)
                calendars
            }
            SCSidebarFooter {
                SCSidebarMenu {
                    SCSidebarMenuItem {
                        SCSidebarMenuButton(
                            "New Calendar",
                            systemImage: "plus",
                            action: { onAction(.createCalendar) }
                        )
                    }
                }
            }
        } detail: {
            VStack(spacing: 0) {
                if showsDetailHeader {
                    topBar
                    Rectangle()
                        .fill(theme.border)
                        .frame(height: 1)
                        .accessibilityHidden(true)
                }
                detail(selectedDateValue, selectedCalendarIDsValue)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.background)
        }
    }

    private var selectedDateValue: Date? {
        externalSelectedDate?.wrappedValue ?? internalSelectedDate
    }

    private var monthValue: Date {
        externalMonth?.wrappedValue ?? internalMonth
    }

    private var selectedCalendarIDsValue: Set<String> {
        externalSelectedCalendarIDs?.wrappedValue ?? internalSelectedCalendarIDs
    }

    private var expandedGroupIDsValue: Set<String> {
        externalExpandedGroupIDs?.wrappedValue ?? internalExpandedGroupIDs
    }

    private var selectedDateBinding: Binding<Date?> {
        Binding(
            get: { selectedDateValue },
            set: { value in
                if let externalSelectedDate {
                    externalSelectedDate.wrappedValue = value
                } else {
                    internalSelectedDate = value
                }
                onAction(.selectDate(value))
            }
        )
    }

    private var monthBinding: Binding<Date> {
        Binding(
            get: { monthValue },
            set: { value in
                if let externalMonth {
                    externalMonth.wrappedValue = value
                } else {
                    internalMonth = value
                }
            }
        )
    }

    private var datePicker: some View {
        SCSidebarGroup {
            SCSidebarGroupContent {
                SCCalendar(
                    selection: selectedDateBinding,
                    month: monthBinding,
                    configuration: SCCalendarConfiguration(
                        defaultMonth: data.defaultMonth,
                        cellSize: 33
                    ),
                    onMonthChange: { onAction(.changeMonth($0)) }
                )
                .frame(maxWidth: .infinity)
            }
        }
    }

    private var calendars: some View {
        ForEach(Array(data.calendars.enumerated()), id: \.element.id) { index, group in
            calendarGroup(group)
            if index < data.calendars.count - 1 {
                SCSidebarSeparator(isDecorative: true)
            }
        }
    }

    private func calendarGroup(_ group: SCSidebar12CalendarGroup) -> some View {
        SCSidebarGroup {
            SCSidebarGroupLabel {
                Button {
                    toggleGroup(group.id)
                } label: {
                    HStack(spacing: 8) {
                        Text(group.name)
                        Spacer(minLength: 0)
                        Image(systemName: "chevron.right")
                            .font(.caption2.weight(.semibold))
                            .rotationEffect(
                                .degrees(expandedGroupIDsValue.contains(group.id) ? 90 : 0)
                            )
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityValue(
                    expandedGroupIDsValue.contains(group.id) ? "Expanded" : "Collapsed"
                )
            }
            if expandedGroupIDsValue.contains(group.id) {
                SCSidebarGroupContent {
                    SCSidebarMenu {
                        ForEach(group.items) { item in
                            calendarRow(item)
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private func calendarRow(_ item: SCSidebar12CalendarItem) -> some View {
        let isSelected = selectedCalendarIDsValue.contains(item.id)
        return SCSidebarMenuItem {
            SCSidebarMenuButton(
                accessibilityLabel: Text(item.name),
                action: { setCalendar(item.id, enabled: !isSelected) },
                content: { _ in
                    HStack(spacing: 8) {
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                            .fill(isSelected ? theme.sidebarPrimary : .clear)
                            .frame(width: 16, height: 16)
                            .overlay {
                                RoundedRectangle(cornerRadius: 3, style: .continuous)
                                    .strokeBorder(
                                        isSelected
                                            ? theme.sidebarPrimary
                                            : theme.sidebarBorder
                                    )
                                if isSelected {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10, weight: .bold))
                                        .foregroundStyle(theme.sidebarPrimaryForeground)
                                }
                            }
                        Text(item.name)
                            .font(.subheadline.weight(.medium))
                            .lineLimit(1)
                    }
                }
            )
            .accessibilityValue(isSelected ? "Enabled" : "Disabled")
        }
    }

    private var topBar: some View {
        HStack(spacing: 12) {
            SCSidebarTrigger()
            SCSeparator(.vertical, isDecorative: true)
                .frame(height: 16)
            SCBreadcrumb {
                SCBreadcrumbList {
                    SCBreadcrumbItem {
                        SCBreadcrumbPage {
                            Text(monthValue, format: .dateTime.month(.wide).year())
                        }
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 16)
        .frame(height: 64)
    }

    private func toggleGroup(_ id: String) {
        var updated = expandedGroupIDsValue
        let willExpand = !updated.contains(id)
        if willExpand {
            updated.insert(id)
        } else {
            updated.remove(id)
        }
        if let externalExpandedGroupIDs {
            externalExpandedGroupIDs.wrappedValue = updated
        } else {
            internalExpandedGroupIDs = updated
        }
        onAction(.setGroupExpanded(id, willExpand))
    }

    private func setCalendar(_ id: String, enabled: Bool) {
        var updated = selectedCalendarIDsValue
        if enabled {
            updated.insert(id)
        } else {
            updated.remove(id)
        }
        if let externalSelectedCalendarIDs {
            externalSelectedCalendarIDs.wrappedValue = updated
        } else {
            internalSelectedCalendarIDs = updated
        }
        onAction(.setCalendarEnabled(id, enabled))
    }
}

// MARK: - Previews

#Preview("Sidebar block · sidebar-12") {
    @Previewable @State var lastAction = "Choose a date or calendar."

    SCPreview {
        SCSidebar12Block(
            persistenceKey: nil,
            onAction: { lastAction = String(describing: $0) },
            detail: { selectedDate, calendarIDs in
                VStack(alignment: .leading, spacing: 12) {
                    Text("Calendar").scH2()
                    Text(
                        selectedDate.map { $0.formatted(date: .long, time: .omitted) }
                            ?? "No date selected"
                    )
                    Text("\(calendarIDs.count) calendars enabled").scMuted()
                    Text(lastAction).scMuted()
                    Spacer()
                }
                .padding(24)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        )
        .frame(width: 1000, height: 700)
    }
}
