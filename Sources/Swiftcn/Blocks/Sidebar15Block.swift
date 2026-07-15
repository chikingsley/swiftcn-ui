// ============================================================
// Sidebar15Block.swift — swiftcn-ui
// Depends on: Sidebar10Block, Sidebar12Block, Breadcrumb, Separator
// ============================================================
import SwiftUI

public struct SCSidebar15Data: Sendable {
    public var left: SCSidebar10Data
    public var right: SCSidebar12Data
    public var pageTitle: String

    public init(
        left: SCSidebar10Data,
        right: SCSidebar12Data,
        pageTitle: String
    ) {
        self.left = left
        self.right = right
        self.pageTitle = pageTitle
    }

    public static let sidebar15 = SCSidebar15Data(
        left: .sidebar10,
        right: .sidebar12,
        pageTitle: "Project Management & Task Tracking"
    )
}

public enum SCSidebar15Action: Hashable, Sendable {
    case left(SCSidebar10Action)
    case right(SCSidebar12Action)
}

/// A dual-sidebar workspace composed from the complete sidebar-10 navigation
/// system and sidebar-12 calendar system. Every stateful subsystem remains
/// controllable, and the center document is always supplied by the caller.
public struct SCSidebar15Block<Detail: View>: View {
    private let data: SCSidebar15Data
    private let activeTeamID: Binding<String>?
    private let selection: Binding<String>?
    private let expandedWorkspaceIDs: Binding<Set<String>>?
    private let selectedDate: Binding<Date?>?
    private let month: Binding<Date>?
    private let selectedCalendarIDs: Binding<Set<String>>?
    private let expandedCalendarGroupIDs: Binding<Set<String>>?
    private let leftPersistenceKey: String?
    private let onAction: (SCSidebar15Action) -> Void
    private let detail: (String, Date?, Set<String>) -> Detail

    public init(
        data: SCSidebar15Data = .sidebar15,
        activeTeamID: Binding<String>? = nil,
        selection: Binding<String>? = nil,
        expandedWorkspaceIDs: Binding<Set<String>>? = nil,
        selectedDate: Binding<Date?>? = nil,
        month: Binding<Date>? = nil,
        selectedCalendarIDs: Binding<Set<String>>? = nil,
        expandedCalendarGroupIDs: Binding<Set<String>>? = nil,
        leftPersistenceKey: String? = "sc.sidebar15.left.open",
        onAction: @escaping (SCSidebar15Action) -> Void,
        @ViewBuilder detail:
            @escaping (
                _ selection: String,
                _ selectedDate: Date?,
                _ selectedCalendarIDs: Set<String>
            ) -> Detail
    ) {
        self.data = data
        self.activeTeamID = activeTeamID
        self.selection = selection
        self.expandedWorkspaceIDs = expandedWorkspaceIDs
        self.selectedDate = selectedDate
        self.month = month
        self.selectedCalendarIDs = selectedCalendarIDs
        self.expandedCalendarGroupIDs = expandedCalendarGroupIDs
        self.leftPersistenceKey = leftPersistenceKey
        self.onAction = onAction
        self.detail = detail
    }

    public init(
        data: SCSidebar15Data = .sidebar15,
        activeTeamID: Binding<String>? = nil,
        selection: Binding<String>? = nil,
        expandedWorkspaceIDs: Binding<Set<String>>? = nil,
        selectedDate: Binding<Date?>? = nil,
        month: Binding<Date>? = nil,
        selectedCalendarIDs: Binding<Set<String>>? = nil,
        expandedCalendarGroupIDs: Binding<Set<String>>? = nil,
        leftPersistenceKey: String? = "sc.sidebar15.left.open",
        onAction: @escaping (SCSidebar15Action) -> Void,
        @ViewBuilder detail: @escaping () -> Detail
    ) {
        self.init(
            data: data,
            activeTeamID: activeTeamID,
            selection: selection,
            expandedWorkspaceIDs: expandedWorkspaceIDs,
            selectedDate: selectedDate,
            month: month,
            selectedCalendarIDs: selectedCalendarIDs,
            expandedCalendarGroupIDs: expandedCalendarGroupIDs,
            leftPersistenceKey: leftPersistenceKey,
            onAction: onAction,
            detail: { _, _, _ in detail() }
        )
    }

    public var body: some View {
        SCSidebar12Block(
            data: data.right,
            selectedDate: selectedDate,
            month: month,
            selectedCalendarIDs: selectedCalendarIDs,
            expandedGroupIDs: expandedCalendarGroupIDs,
            collapsible: .none,
            side: .trailing,
            showsDetailHeader: false,
            persistenceKey: nil,
            onAction: { onAction(.right($0)) },
            detail: { date, calendarIDs in
                leftWorkspace(selectedDate: date, selectedCalendarIDs: calendarIDs)
            }
        )
    }

    private func leftWorkspace(
        selectedDate: Date?,
        selectedCalendarIDs: Set<String>
    ) -> some View {
        SCSidebar10Block(
            data: data.left,
            activeTeamID: activeTeamID,
            selection: selection,
            expandedWorkspaceIDs: expandedWorkspaceIDs,
            persistenceKey: leftPersistenceKey,
            onAction: { onAction(.left($0)) },
            header: { _ in centerHeader },
            detail: { selection in
                detail(selection, selectedDate, selectedCalendarIDs)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        )
    }

    private var centerHeader: some View {
        HStack(spacing: 12) {
            SCSidebarTrigger()
            SCSeparator(.vertical, isDecorative: true)
                .frame(height: 16)
            SCBreadcrumb {
                SCBreadcrumbList {
                    SCBreadcrumbItem {
                        SCBreadcrumbPage(data.pageTitle)
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 12)
        .frame(height: 56)
    }
}

// MARK: - Previews

#Preview("Sidebar block · sidebar-15") {
    @Previewable @State var lastAction = "Use either sidebar."

    SCPreview {
        SCSidebar15Block(
            leftPersistenceKey: nil,
            onAction: { lastAction = String(describing: $0) },
            detail: { selection, selectedDate, calendarIDs in
                VStack(alignment: .leading, spacing: 12) {
                    Text(selection).scH2()
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
        .frame(width: 1300, height: 760)
    }
}
