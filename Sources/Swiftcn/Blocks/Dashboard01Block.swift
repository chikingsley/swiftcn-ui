// ============================================================
// Dashboard01Block.swift — swiftcn-ui
// Depends on: Theme/, Components/ (Sidebar, Card, Chart, Badge,
//             Button, Tabs, ToggleGroup, Select, Table, DataTable,
//             Drawer, Input, Avatar, Separator, Toast, Typography)
//
// Port of shadcn's dashboard-01 block: an inset sidebar app shell
// (Quick Create, main/documents/secondary navigation, user menu),
// the site header, four section cards, the interactive visitors
// area chart, and the sections data table with row selection,
// column visibility, pagination, editable cells, a per-row detail
// drawer, and row reordering.
// ============================================================
import Charts
import SwiftUI

// The complete upstream dashboard fixture intentionally keeps this source over
// the default file-length threshold.
// swiftlint:disable file_length

// MARK: - Models

/// One row of the dashboard-01 sections table — the Swift equivalent of the
/// upstream zod `schema`.
public struct SCDashboard01Section: Identifiable, Hashable, Sendable {
    public var id: Int
    public var header: String
    public var type: String
    public var status: String
    public var target: String
    public var limit: String
    public var reviewer: String

    public init(
        id: Int,
        header: String,
        type: String,
        status: String,
        target: String,
        limit: String,
        reviewer: String
    ) {
        self.id = id
        self.header = header
        self.type = type
        self.status = status
        self.target = target
        self.limit = limit
        self.reviewer = reviewer
    }

    /// The upstream placeholder value marking an unassigned reviewer.
    public static let unassignedReviewer = "Assign reviewer"

    public var hasAssignedReviewer: Bool {
        reviewer != Self.unassignedReviewer
    }
}

// MARK: - Actions

public enum SCDashboard01UserAction: Hashable, Sendable {
    case account
    case billing
    case notifications
    case logOut
}

public enum SCDashboard01DocumentAction: Hashable, Sendable {
    case open
    case share
    case delete
}

public enum SCDashboard01SectionAction: Hashable, Sendable {
    case edit
    case copy
    case favorite
    case delete
}

/// Every caller-visible action the block can emit. Actions that also have a
/// sensible local effect (copy, delete, reorder, cell edits) perform it and
/// then notify.
public enum SCDashboard01Action: Hashable, Sendable {
    case home
    case quickCreate
    case inbox
    case selectNavigation(String)
    case selectDocument(String)
    case document(String, SCDashboard01DocumentAction)
    case moreDocuments
    case selectSecondary(String)
    case user(SCDashboard01UserAction)
    case addSection
    case section(Int, SCDashboard01SectionAction)
    case reorderSections([Int])
    case updateSection(SCDashboard01Section)
}

// MARK: - Block

/// A functional SwiftUI port of shadcn's `dashboard-01` application shell.
///
/// The sidebar (offcanvas, inset variant) carries the Quick Create control,
/// primary navigation, the Documents group with per-item actions, the
/// secondary navigation, and the user account menu. The detail pane stacks
/// the site header, four section summary cards, the interactive "Total
/// Visitors" area chart (90/30/7-day ranges), and the sections data table:
/// checkbox selection, hideable columns, pagination, inline target/limit
/// editing with save toasts, reviewer assignment, per-row actions with
/// reordering, and a detail drawer with an editable form.
///
/// Navigation selection is controlled or internal; every visible control
/// routes through the required `onAction` callback. Sections, chart points,
/// and the user identity default to the upstream demo data.
///
///     SCDashboard01Block { action in
///         handle(action)
///     }
public struct SCDashboard01Block: View {
    @Environment(\.theme) private var theme

    @State private var internalSelection: String
    @State private var sections: [SCDashboard01Section]
    @State private var tableController = SCDataTableController<SCDashboard01Section>()
    @State private var tab: Dashboard01Tab = .outline

    private let user: SCSidebarUser
    private let externalSelection: Binding<String>?
    private let onAction: (SCDashboard01Action) -> Void

    public init(
        sections: [SCDashboard01Section] = SCDashboard01Data.sections,
        user: SCSidebarUser = SCDashboard01Data.user,
        selection: Binding<String>? = nil,
        defaultSelection: String = "Dashboard",
        onAction: @escaping (SCDashboard01Action) -> Void
    ) {
        self._sections = State(initialValue: sections)
        self.user = user
        self.externalSelection = selection
        self._internalSelection = State(initialValue: defaultSelection)
        self.onAction = onAction
    }

    public var body: some View {
        SCSidebarLayout(collapsible: .offcanvas, variant: .inset, persistenceKey: nil) {
            SCSidebarHeader {
                brandButton
            }
            SCSidebarContent {
                navMainGroup
                documentsGroup
                navSecondaryGroup
            }
            SCSidebarFooter {
                Dashboard01UserMenu(user: user) { onAction(.user($0)) }
            }
        } detail: {
            VStack(spacing: 0) {
                siteHeader
                Rectangle().fill(theme.border).frame(height: 1)
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        sectionCards
                        Dashboard01VisitorsChart()
                        dataTableSection
                    }
                    .padding(16)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(theme.background)
        }
        .scToaster()
    }

    // MARK: Selection

    private var selection: String {
        externalSelection?.wrappedValue ?? internalSelection
    }

    private func navigate(to id: String) {
        if let externalSelection {
            externalSelection.wrappedValue = id
        } else {
            internalSelection = id
        }
        onAction(.selectNavigation(id))
    }

    // MARK: Sidebar

    private var brandButton: some View {
        SCSidebarMenuButton(
            isActive: false,
            accessibilityLabel: Text("Acme Inc."),
            collapsedTooltip: "Acme Inc.",
            action: { onAction(.home) },
            content: { _ in
                HStack(spacing: 8) {
                    Image(systemName: "circle.dotted.circle")
                        .font(.system(size: 18, weight: .semibold))
                    Text("Acme Inc.")
                        .font(.callout.weight(.semibold))
                }
            },
            trailing: { _ in EmptyView() }
        )
    }

    private var navMainGroup: some View {
        SCSidebarGroup {
            SCSidebarGroupContent {
                SCSidebarMenu {
                    SCSidebarMenuItem {
                        HStack(spacing: 8) {
                            Button {
                                onAction(.quickCreate)
                            } label: {
                                Label("Quick Create", systemImage: "plus.circle.fill")
                                    .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.sc(.default, size: .sm))
                            Button {
                                onAction(.inbox)
                            } label: {
                                Image(systemName: "envelope")
                            }
                            .buttonStyle(.sc(.outline, size: .iconSM))
                            .accessibilityLabel("Inbox")
                        }
                        .padding(.horizontal, 8)
                        .padding(.bottom, 4)
                    }
                }
                SCSidebarMenu {
                    ForEach(SCDashboard01Data.navMain, id: \.title) { item in
                        SCSidebarMenuItem {
                            SCSidebarMenuButton(
                                item.title,
                                systemImage: item.systemImage,
                                isActive: selection == item.title
                            ) {
                                navigate(to: item.title)
                            }
                        }
                    }
                }
            }
        }
    }

    private var documentsGroup: some View {
        SCSidebarExpandedOnly {
            SCSidebarGroup("Documents") {
                SCSidebarMenu {
                    ForEach(SCDashboard01Data.documents, id: \.title) { item in
                        SCSidebarMenuItem {
                            SCSidebarMenuButton(
                                item.title,
                                systemImage: item.systemImage,
                                isActive: selection == item.title
                            ) {
                                navigate(to: item.title)
                                onAction(.selectDocument(item.title))
                            }
                            documentMenu(item.title)
                        }
                    }
                    SCSidebarMenuButton("More", systemImage: "ellipsis") {
                        onAction(.moreDocuments)
                    }
                }
            }
        }
    }

    private func documentMenu(_ name: String) -> some View {
        Menu {
            Button {
                onAction(.document(name, .open))
            } label: {
                Label("Open", systemImage: "folder")
            }
            Button {
                onAction(.document(name, .share))
            } label: {
                Label("Share", systemImage: "arrowshape.turn.up.right")
            }
            Divider()
            Button(role: .destructive) {
                onAction(.document(name, .delete))
            } label: {
                Label("Delete", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.caption.weight(.semibold))
                .frame(width: 28, height: 28)
                .contentShape(Rectangle())
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .padding(.trailing, 4)
        .accessibilityLabel("Actions for \(name)")
    }

    private var navSecondaryGroup: some View {
        SCSidebarGroup {
            SCSidebarGroupContent {
                SCSidebarMenu {
                    ForEach(SCDashboard01Data.navSecondary, id: \.title) { item in
                        SCSidebarMenuItem {
                            SCSidebarMenuButton(
                                item.title,
                                systemImage: item.systemImage,
                                isActive: selection == item.title
                            ) {
                                navigate(to: item.title)
                                onAction(.selectSecondary(item.title))
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: Site header

    private var siteHeader: some View {
        HStack(spacing: 8) {
            SCSidebarTrigger()
            SCSeparator(.vertical).frame(height: 16)
            Text("Documents")
                .font(.callout.weight(.medium))
            Spacer()
            Link(destination: SCDashboard01Data.gitHubURL) {
                Text("GitHub")
            }
            .buttonStyle(.sc(.ghost, size: .sm))
        }
        .padding(.horizontal, 16)
        .frame(height: 48)
    }

    // MARK: Section cards

    private var sectionCards: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 220), spacing: 16)],
            spacing: 16
        ) {
            ForEach(SCDashboard01Data.sectionCards, id: \.title) { card in
                Dashboard01SectionCard(card: card)
            }
        }
    }

    // MARK: Data table

    private var dataTableSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Spacer()
                SCDataTableViewOptions(controller: tableController, columns: tableColumns)
                Button {
                    onAction(.addSection)
                } label: {
                    Label("Add Section", systemImage: "plus")
                }
                .buttonStyle(.sc(.outline, size: .sm))
            }
            SCTabs(
                selection: $tab,
                variant: .segmented,
                tabs: [
                    SCTabItem(value: .outline, label: "Outline"),
                    SCTabItem(value: .pastPerformance, label: "Past Performance (3)"),
                    SCTabItem(value: .keyPersonnel, label: "Key Personnel (2)"),
                    SCTabItem(value: .focusDocuments, label: "Focus Documents"),
                ]
            ) { tab in
                switch tab {
                case .outline:
                    SCDataTable(
                        rows: sections,
                        columns: tableColumns,
                        controller: tableController,
                        selectionBehavior: .checkboxOnly,
                        showsToolbar: false
                    )
                case .pastPerformance, .keyPersonnel, .focusDocuments:
                    placeholderPanel
                }
            }
        }
    }

    private var placeholderPanel: some View {
        RoundedRectangle(cornerRadius: theme.radius, style: .continuous)
            .strokeBorder(theme.border, style: StrokeStyle(lineWidth: 1, dash: [4, 4]))
            .aspectRatio(16 / 9, contentMode: .fit)
            .frame(maxWidth: .infinity)
    }

    private var tableColumns: [SCTableColumn<SCDashboard01Section>] {
        [
            SCTableColumn(
                "Header",
                isHideable: false,
                comparator: { $0.header.localizedCompare($1.header) == .orderedAscending },
                searchValue: \.header,
                cell: { section in
                    Dashboard01SectionViewer(section: section) { updated in
                        apply(updated)
                    }
                }
            ),
            SCTableColumn("Section Type", id: "type", searchValue: \.type) { section in
                SCBadge(variant: .outline) {
                    Text(section.type)
                }
            },
            SCTableColumn(
                "Status",
                id: "status",
                comparator: { $0.status < $1.status },
                searchValue: \.status,
                cell: { section in
                    SCBadge(variant: .outline) {
                        HStack(spacing: 4) {
                            Image(systemName: section.status == "Done" ? "checkmark.circle.fill" : "circle.dotted")
                                .foregroundStyle(section.status == "Done" ? .green : theme.mutedForeground)
                            Text(section.status)
                        }
                    }
                }
            ),
            SCTableColumn("Target", id: "target", alignment: .trailing) { section in
                Dashboard01EditableCell(
                    label: "Target",
                    text: section.target
                ) { newValue in
                    var updated = section
                    updated.target = newValue
                    apply(updated, toast: true)
                }
            },
            SCTableColumn("Limit", id: "limit", alignment: .trailing) { section in
                Dashboard01EditableCell(
                    label: "Limit",
                    text: section.limit
                ) { newValue in
                    var updated = section
                    updated.limit = newValue
                    apply(updated, toast: true)
                }
            },
            SCTableColumn("Reviewer", id: "reviewer", searchValue: \.reviewer) { section in
                if section.hasAssignedReviewer {
                    Text(section.reviewer)
                } else {
                    SCSelect(
                        selection: reviewerBinding(for: section),
                        placeholder: SCDashboard01Section.unassignedReviewer,
                        options: SCDashboard01Data.tableReviewers
                    )
                }
            },
            SCTableColumn(
                id: "actions",
                accessibilityLabel: "Actions",
                width: .fixed(44),
                isHideable: false,
                header: { Text("") },
                cell: { section in
                    sectionMenu(section)
                }
            ),
        ]
    }

    private func sectionMenu(_ section: SCDashboard01Section) -> some View {
        Menu {
            Button {
                onAction(.section(section.id, .edit))
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            Button {
                duplicate(section)
            } label: {
                Label("Make a copy", systemImage: "doc.on.doc")
            }
            Button {
                onAction(.section(section.id, .favorite))
            } label: {
                Label("Favorite", systemImage: "star")
            }
            Divider()
            Button {
                move(section, offset: -1)
            } label: {
                Label("Move up", systemImage: "arrow.up")
            }
            .disabled(sections.first?.id == section.id)
            Button {
                move(section, offset: 1)
            } label: {
                Label("Move down", systemImage: "arrow.down")
            }
            .disabled(sections.last?.id == section.id)
            Divider()
            Button(role: .destructive) {
                remove(section)
            } label: {
                Label("Delete", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.caption.weight(.semibold))
                .frame(width: 28, height: 28)
                .contentShape(Rectangle())
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .accessibilityLabel("Actions for \(section.header)")
    }

    // MARK: Row mutations

    private func apply(_ updated: SCDashboard01Section, toast: Bool = false) {
        guard let index = sections.firstIndex(where: { $0.id == updated.id }) else { return }
        sections[index] = updated
        onAction(.updateSection(updated))
        if toast {
            Dashboard01SaveToast.show(for: updated.header)
        }
    }

    private func duplicate(_ section: SCDashboard01Section) {
        guard let index = sections.firstIndex(where: { $0.id == section.id }) else { return }
        var copy = section
        copy.id = (sections.map(\.id).max() ?? 0) + 1
        sections.insert(copy, at: index + 1)
        onAction(.section(section.id, .copy))
    }

    private func move(_ section: SCDashboard01Section, offset: Int) {
        guard let index = sections.firstIndex(where: { $0.id == section.id }) else { return }
        let destination = index + offset
        guard sections.indices.contains(destination) else { return }
        sections.swapAt(index, destination)
        onAction(.reorderSections(sections.map(\.id)))
    }

    private func remove(_ section: SCDashboard01Section) {
        sections.removeAll { $0.id == section.id }
        onAction(.section(section.id, .delete))
    }

    private func reviewerBinding(for section: SCDashboard01Section) -> Binding<String?> {
        Binding(
            get: { section.hasAssignedReviewer ? section.reviewer : nil },
            set: { newValue in
                guard let newValue else { return }
                var updated = section
                updated.reviewer = newValue
                apply(updated)
            }
        )
    }
}

// MARK: - Tabs

private enum Dashboard01Tab: Hashable {
    case outline
    case pastPerformance
    case keyPersonnel
    case focusDocuments
}

// MARK: - Save toast

/// The sonner `toast.promise` analog used by inline cell saves and the
/// drawer form: a loading toast that resolves to "Done" after the simulated
/// save completes, via the shared `SCToastCenter`.
@MainActor
enum Dashboard01SaveToast {
    static func show(for header: String) {
        let loading = SCToast(title: "Saving \(header)", duration: .seconds(30))
        SCToastCenter.shared.show(loading)
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1))
            SCToastCenter.shared.dismiss(loading.id)
            SCToastCenter.shared.show(title: "Done")
        }
    }
}

// MARK: - Editable cell

/// The transparent right-aligned inline editor used by the Target and Limit
/// columns. Commits on submit, matching the upstream form `onSubmit`.
private struct Dashboard01EditableCell: View {
    let label: String
    let text: String
    let onCommit: (String) -> Void

    @State private var draft: String

    init(label: String, text: String, onCommit: @escaping (String) -> Void) {
        self.label = label
        self.text = text
        self.onCommit = onCommit
        self._draft = State(initialValue: text)
    }

    var body: some View {
        TextField(label, text: $draft)
            .textFieldStyle(.plain)
            .multilineTextAlignment(.trailing)
            .frame(width: 64)
            .onSubmit { onCommit(draft) }
            .accessibilityLabel(label)
    }
}

// MARK: - User menu

/// dashboard-01's `nav-user`: the footer account menu with the identity
/// header and Account / Billing / Notifications / Log out actions.
private struct Dashboard01UserMenu: View {
    @Environment(\.theme) private var theme
    @Environment(\.scSidebarIconRail) private var iconRail

    let user: SCSidebarUser
    let onAction: (SCDashboard01UserAction) -> Void

    var body: some View {
        Menu {
            Section {
                Button {
                    onAction(.account)
                } label: {
                    Label("Account", systemImage: "person.circle")
                }
                Button {
                    onAction(.billing)
                } label: {
                    Label("Billing", systemImage: "creditcard")
                }
                Button {
                    onAction(.notifications)
                } label: {
                    Label("Notifications", systemImage: "bell")
                }
            } header: {
                Text("\(user.name) · \(user.email)")
            }
            Divider()
            Button(role: .destructive) {
                onAction(.logOut)
            } label: {
                Label("Log out", systemImage: "rectangle.portrait.and.arrow.right")
            }
        } label: {
            HStack(spacing: 8) {
                SCAvatar(url: user.avatarURL, fallback: user.fallback, size: .sm)
                if !iconRail {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(user.name).font(.subheadline.weight(.medium))
                        Text(user.email)
                            .font(.caption2)
                            .foregroundStyle(theme.sidebarForeground.opacity(0.6))
                    }
                    .lineLimit(1)
                    Spacer(minLength: 0)
                    Image(systemName: "ellipsis")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(theme.sidebarForeground.opacity(0.6))
                }
            }
            .padding(.horizontal, iconRail ? 0 : 8)
            .frame(maxWidth: .infinity, alignment: iconRail ? .center : .leading)
            .frame(height: 44)
            .contentShape(RoundedRectangle(cornerRadius: theme.radius - 2, style: .continuous))
        }
        .menuStyle(.button)
        .buttonStyle(.plain)
        .menuIndicator(.hidden)
        .accessibilityLabel("User menu")
        .accessibilityValue(user.name)
    }
}

// MARK: - Section cards

private struct Dashboard01SectionCard: View {
    @Environment(\.theme) private var theme

    let card: SCDashboard01Data.SectionCard

    var body: some View {
        SCCard {
            SCCardHeader {
                SCCardDescription(card.title)
                SCCardTitle {
                    Text(card.value)
                        .font(.title2.weight(.semibold))
                        .monospacedDigit()
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                SCCardAction {
                    SCBadge(variant: .outline) {
                        HStack(spacing: 4) {
                            Image(
                                systemName: card.trendingUp
                                    ? "chart.line.uptrend.xyaxis"
                                    : "chart.line.downtrend.xyaxis"
                            )
                            Text(card.delta)
                        }
                    }
                }
            }
            SCCardFooter {
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Text(card.footerTitle)
                            .font(.footnote.weight(.medium))
                        Image(systemName: card.trendingUp ? "chart.line.uptrend.xyaxis" : "chart.line.downtrend.xyaxis")
                            .font(.footnote)
                    }
                    .lineLimit(1)
                    Text(card.footerDetail)
                        .font(.footnote)
                        .foregroundStyle(theme.mutedForeground)
                }
            }
        }
    }
}

// MARK: - Interactive visitors chart

private enum Dashboard01TimeRange: Hashable, CaseIterable {
    case last3Months
    case last30Days
    case last7Days

    var label: String {
        switch self {
        case .last3Months: "Last 3 months"
        case .last30Days: "Last 30 days"
        case .last7Days: "Last 7 days"
        }
    }

    var days: Int {
        switch self {
        case .last3Months: 90
        case .last30Days: 30
        case .last7Days: 7
        }
    }
}

/// dashboard-01's `chart-area-interactive`: the "Total Visitors" card with a
/// stacked, gradient-filled desktop/mobile area chart, a time-range control
/// (toggle group where it fits, select otherwise), and a dot-indicator
/// tooltip driven by chart x-selection.
private struct Dashboard01VisitorsChart: View {
    @Environment(\.theme) private var theme
    #if os(iOS)
        @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif

    @State private var timeRange: Dashboard01TimeRange = .last3Months
    @State private var chartSelection: Date?

    var body: some View {
        card
            .onAppear {
                #if os(iOS)
                    // Upstream defaults mobile to the 7-day range.
                    if horizontalSizeClass == .compact {
                        timeRange = .last7Days
                    }
                #endif
            }
    }

    private var card: some View {
        SCCard {
            SCCardHeader {
                SCCardTitle("Total Visitors")
                SCCardDescription("Total for the last 3 months")
                SCCardAction {
                    ViewThatFits(in: .horizontal) {
                        SCToggleGroup(
                            selection: toggleBinding,
                            items: Dashboard01TimeRange.allCases.map {
                                SCToggleGroupItem(value: $0, label: $0.label)
                            }
                        )
                        SCSelect(
                            selection: selectBinding,
                            placeholder: Dashboard01TimeRange.last3Months.label,
                            options: Dashboard01TimeRange.allCases.map {
                                SCSelectOption(value: $0, label: $0.label)
                            }
                        )
                    }
                }
            }
            SCCardContent {
                SCChartContainer(
                    configuration: configuration,
                    aspectRatio: nil,
                    accessibilityLabel: "Total visitors area chart"
                ) {
                    chart
                }
                .frame(height: 250)
            }
        }
    }

    private var configuration: SCChartConfiguration {
        SCChartConfiguration([
            SCChartSeriesConfiguration(key: "desktop", label: "Desktop", color: theme.primary),
            SCChartSeriesConfiguration(key: "mobile", label: "Mobile", color: theme.primary.opacity(0.6)),
        ])
    }

    private var filtered: [SCDashboard01Data.VisitorPoint] {
        let start =
            Calendar(identifier: .gregorian).date(
                byAdding: .day,
                value: -timeRange.days,
                to: SCDashboard01Data.visitorsReferenceDate
            ) ?? .distantPast
        return SCDashboard01Data.visitors.filter { $0.date >= start }
    }

    private var chart: some View {
        Chart {
            ForEach(filtered) { point in
                AreaMark(
                    x: .value("Date", point.date),
                    y: .value("Visitors", point.mobile),
                    series: .value("Series", "Mobile"),
                    stacking: .standard
                )
                .foregroundStyle(gradient(peakOpacity: 0.8))
                .interpolationMethod(.catmullRom)

                AreaMark(
                    x: .value("Date", point.date),
                    y: .value("Visitors", point.desktop),
                    series: .value("Series", "Desktop"),
                    stacking: .standard
                )
                .foregroundStyle(gradient(peakOpacity: 1.0))
                .interpolationMethod(.catmullRom)
            }
        }
        .chartXAxis {
            AxisMarks(values: .automatic(desiredCount: 6)) { _ in
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
            }
        }
        .chartYAxis {
            AxisMarks { _ in
                AxisGridLine()
            }
        }
        .scChartTooltip(selection: $chartSelection) { (date: Date) in
            if let point = nearestPoint(to: date) {
                SCChartTooltipContent(payload: payload(for: point), indicator: .dot) {
                    Text(point.date, format: .dateTime.month(.abbreviated).day())
                }
            }
        }
    }

    private func gradient(peakOpacity: Double) -> LinearGradient {
        LinearGradient(
            stops: [
                .init(color: theme.primary.opacity(peakOpacity), location: 0.05),
                .init(color: theme.primary.opacity(0.1), location: 0.95),
            ],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    private func nearestPoint(to date: Date) -> SCDashboard01Data.VisitorPoint? {
        filtered.min {
            abs($0.date.timeIntervalSince(date)) < abs($1.date.timeIntervalSince(date))
        }
    }

    private func payload(for point: SCDashboard01Data.VisitorPoint) -> [SCChartTooltipPayload] {
        [
            SCChartTooltipPayload(
                key: "desktop",
                configurationKey: "desktop",
                fallbackName: "Desktop",
                value: .number(point.desktop)
            ),
            SCChartTooltipPayload(
                key: "mobile",
                configurationKey: "mobile",
                fallbackName: "Mobile",
                value: .number(point.mobile)
            ),
        ]
    }

    private var toggleBinding: Binding<Dashboard01TimeRange?> {
        Binding(
            get: { timeRange },
            set: { newValue in
                if let newValue {
                    timeRange = newValue
                }
            }
        )
    }

    private var selectBinding: Binding<Dashboard01TimeRange?> {
        toggleBinding
    }
}

// MARK: - Section detail drawer

/// dashboard-01's `TableCellViewer`: the header cell opens a detail drawer
/// (trailing edge on macOS, bottom on compact iPad) with the six-month mini
/// chart, descriptive copy, and an editable form whose Submit saves back to
/// the table with the save toast.
private struct Dashboard01SectionViewer: View {
    @Environment(\.theme) private var theme

    let section: SCDashboard01Section
    let onSubmit: (SCDashboard01Section) -> Void

    var body: some View {
        SCDrawer(
            defaultPresented: false,
            showSwipeHandle: drawerDirection == .down,
            swipeDirection: drawerDirection,
            panelSize: drawerDirection == .down ? nil : 380,
            trigger: {
                Text(section.header)
                    .multilineTextAlignment(.leading)
            },
            overlay: { SCDrawerOverlay() },
            content: {
                Dashboard01SectionForm(section: section, onSubmit: onSubmit)
            }
        )
        .buttonStyle(.sc(.link, size: .sm))
    }

    private var drawerDirection: SCDrawerSwipeDirection {
        #if os(iOS)
            return .down
        #else
            return .right
        #endif
    }
}

private struct Dashboard01SectionForm: View {
    @Environment(\.theme) private var theme
    @Environment(\.scDismissDrawer) private var dismissDrawer

    let onSubmit: (SCDashboard01Section) -> Void

    @State private var draft: SCDashboard01Section

    init(section: SCDashboard01Section, onSubmit: @escaping (SCDashboard01Section) -> Void) {
        self.onSubmit = onSubmit
        self._draft = State(initialValue: section)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            VStack(alignment: .leading, spacing: 4) {
                Text(draft.header)
                    .font(.headline)
                Text("Showing total visitors for the last 6 months")
                    .font(.footnote)
                    .foregroundStyle(theme.mutedForeground)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    #if os(macOS)
                        miniChart
                        SCSeparator()
                        trendCopy
                        SCSeparator()
                    #endif
                    form
                }
                .padding(.horizontal, 16)
            }

            VStack(spacing: 8) {
                Button {
                    onSubmit(draft)
                    Dashboard01SaveToast.show(for: draft.header)
                    dismissDrawer()
                } label: {
                    Text("Submit").frame(maxWidth: .infinity)
                }
                .buttonStyle(.sc(.default))
                SCDrawerClose("Done")
            }
            .padding(16)
        }
    }

    private var miniChart: some View {
        Chart {
            ForEach(SCDashboard01Data.monthlyVisitors, id: \.month) { point in
                AreaMark(
                    x: .value("Month", point.month),
                    y: .value("Visitors", point.mobile),
                    series: .value("Series", "Mobile"),
                    stacking: .standard
                )
                .foregroundStyle(theme.primary.opacity(0.6))
                .interpolationMethod(.catmullRom)

                AreaMark(
                    x: .value("Month", point.month),
                    y: .value("Visitors", point.desktop),
                    series: .value("Series", "Desktop"),
                    stacking: .standard
                )
                .foregroundStyle(theme.primary.opacity(0.4))
                .interpolationMethod(.catmullRom)
            }
        }
        .chartXAxis(.hidden)
        .chartYAxis {
            AxisMarks { _ in
                AxisGridLine()
            }
        }
        .scChartStyle()
        .frame(height: 160)
    }

    private var trendCopy: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Text("Trending up by 5.2% this month")
                    .font(.footnote.weight(.medium))
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.footnote)
            }
            Text(
                "Showing total visitors for the last 6 months. "
                    + "This is sample copy to test a wrapping, multiline layout."
            )
            .font(.footnote)
            .foregroundStyle(theme.mutedForeground)
        }
    }

    private var form: some View {
        VStack(alignment: .leading, spacing: 12) {
            SCField("Header") {
                SCInput("Header", value: $draft.header)
            }
            HStack(alignment: .top, spacing: 12) {
                SCField("Type") {
                    SCSelect(
                        selection: optionalBinding($draft.type),
                        placeholder: "Select a type",
                        options: SCDashboard01Data.sectionTypes
                    )
                }
                SCField("Status") {
                    SCSelect(
                        selection: optionalBinding($draft.status),
                        placeholder: "Select a status",
                        options: SCDashboard01Data.sectionStatuses
                    )
                }
            }
            HStack(alignment: .top, spacing: 12) {
                SCField("Target") {
                    SCInput("Target", value: $draft.target)
                }
                SCField("Limit") {
                    SCInput("Limit", value: $draft.limit)
                }
            }
            SCField("Reviewer") {
                SCSelect(
                    selection: optionalBinding($draft.reviewer),
                    placeholder: "Select a reviewer",
                    options: SCDashboard01Data.drawerReviewers
                )
            }
        }
    }

    private func optionalBinding(_ source: Binding<String>) -> Binding<String?> {
        Binding(
            get: { source.wrappedValue },
            set: { newValue in
                if let newValue {
                    source.wrappedValue = newValue
                }
            }
        )
    }
}

// MARK: - Demo data

/// The upstream dashboard-01 demo content: the user identity, navigation
/// structure, section-card copy, the 68-row sections table (`data.json`),
/// and the visitors chart series.
public enum SCDashboard01Data {
    public struct NavItem: Sendable {
        public let title: String
        public let systemImage: String

        public init(title: String, systemImage: String) {
            self.title = title
            self.systemImage = systemImage
        }
    }

    public struct SectionCard: Sendable {
        public let title: String
        public let value: String
        public let delta: String
        public let trendingUp: Bool
        public let footerTitle: String
        public let footerDetail: String
    }

    public struct VisitorPoint: Identifiable, Sendable {
        public let date: Date
        public let desktop: Double
        public let mobile: Double

        public var id: Date { date }

        init(_ dateString: String, _ desktop: Double, _ mobile: Double) {
            let parts = dateString.split(separator: "-").compactMap { Int($0) }
            var components = DateComponents()
            components.year = !parts.isEmpty ? parts[0] : nil
            components.month = parts.count > 1 ? parts[1] : nil
            components.day = parts.count > 2 ? parts[2] : nil
            self.date = Calendar(identifier: .gregorian).date(from: components) ?? .distantPast
            self.desktop = desktop
            self.mobile = mobile
        }
    }

    public static let user = SCSidebarUser(name: "shadcn", email: "m@example.com", fallback: "CN")

    public static var gitHubURL: URL {
        guard
            let url = URL(
                string: "https://github.com/shadcn-ui/ui/tree/main/apps/v4/app/(examples)/dashboard"
            )
        else {
            preconditionFailure("The dashboard source URL literal must remain valid.")
        }
        return url
    }

    public static let navMain: [NavItem] = [
        NavItem(title: "Dashboard", systemImage: "square.grid.2x2"),
        NavItem(title: "Lifecycle", systemImage: "list.bullet.rectangle"),
        NavItem(title: "Analytics", systemImage: "chart.bar"),
        NavItem(title: "Projects", systemImage: "folder"),
        NavItem(title: "Team", systemImage: "person.2"),
    ]

    public static let documents: [NavItem] = [
        NavItem(title: "Data Library", systemImage: "cylinder.split.1x2"),
        NavItem(title: "Reports", systemImage: "doc.text.below.ecg"),
        NavItem(title: "Word Assistant", systemImage: "doc.richtext"),
    ]

    public static let navSecondary: [NavItem] = [
        NavItem(title: "Settings", systemImage: "gearshape"),
        NavItem(title: "Get Help", systemImage: "questionmark.circle"),
        NavItem(title: "Search", systemImage: "magnifyingglass"),
    ]

    public static let sectionCards: [SectionCard] = [
        SectionCard(
            title: "Total Revenue",
            value: "$1,250.00",
            delta: "+12.5%",
            trendingUp: true,
            footerTitle: "Trending up this month",
            footerDetail: "Visitors for the last 6 months"
        ),
        SectionCard(
            title: "New Customers",
            value: "1,234",
            delta: "-20%",
            trendingUp: false,
            footerTitle: "Down 20% this period",
            footerDetail: "Acquisition needs attention"
        ),
        SectionCard(
            title: "Active Accounts",
            value: "45,678",
            delta: "+12.5%",
            trendingUp: true,
            footerTitle: "Strong user retention",
            footerDetail: "Engagement exceed targets"
        ),
        SectionCard(
            title: "Growth Rate",
            value: "4.5%",
            delta: "+4.5%",
            trendingUp: true,
            footerTitle: "Steady performance increase",
            footerDetail: "Meets growth projections"
        ),
    ]

    static let sectionTypes: [SCSelectOption<String>] = [
        "Table of Contents", "Executive Summary", "Technical Approach", "Design",
        "Capabilities", "Focus Documents", "Narrative", "Cover Page",
    ].map { SCSelectOption(value: $0, label: $0) }

    static let sectionStatuses: [SCSelectOption<String>] = [
        "Done", "In Progress", "Not Started",
    ].map { SCSelectOption(value: $0, label: $0) }

    static let tableReviewers: [SCSelectOption<String>] = [
        "Eddie Lake", "Jamik Tashpulatov",
    ].map { SCSelectOption(value: $0, label: $0) }

    static let drawerReviewers: [SCSelectOption<String>] = [
        "Eddie Lake", "Jamik Tashpulatov", "Emily Whalen",
    ].map { SCSelectOption(value: $0, label: $0) }

    // These exact one-line fixtures mirror upstream data.json and are easier to
    // compare when their records are not reformatted across several lines.
    // swiftlint:disable large_tuple
    static let monthlyVisitors: [(month: String, desktop: Double, mobile: Double)] = [
        ("January", 186, 80), ("February", 305, 200), ("March", 237, 120),
        ("April", 73, 190), ("May", 209, 130), ("June", 214, 140),
    ]

    /// Upstream filters relative to the newest chart date, 2024-06-30.
    public static let visitorsReferenceDate: Date = {
        var components = DateComponents()
        components.year = 2024
        components.month = 6
        components.day = 30
        return Calendar(identifier: .gregorian).date(from: components) ?? .distantPast
    }()

    /// The 68 demo rows of the upstream `data.json`.
    public static let sections: [SCDashboard01Section] = [
        SCDashboard01Section(
            id: 1, header: "Cover page", type: "Cover page", status: "In Process", target: "18", limit: "5",
            reviewer: "Eddie Lake"),
        SCDashboard01Section(
            id: 2, header: "Table of contents", type: "Table of contents", status: "Done", target: "29", limit: "24",
            reviewer: "Eddie Lake"),
        SCDashboard01Section(
            id: 3, header: "Executive summary", type: "Narrative", status: "Done", target: "10", limit: "13",
            reviewer: "Eddie Lake"),
        SCDashboard01Section(
            id: 4, header: "Technical approach", type: "Narrative", status: "Done", target: "27", limit: "23",
            reviewer: "Jamik Tashpulatov"),
        SCDashboard01Section(
            id: 5, header: "Design", type: "Narrative", status: "In Process", target: "2", limit: "16",
            reviewer: "Jamik Tashpulatov"),
        SCDashboard01Section(
            id: 6, header: "Capabilities", type: "Narrative", status: "In Process", target: "20", limit: "8",
            reviewer: "Jamik Tashpulatov"),
        SCDashboard01Section(
            id: 7, header: "Integration with existing systems", type: "Narrative", status: "In Process", target: "19",
            limit: "21", reviewer: "Jamik Tashpulatov"),
        SCDashboard01Section(
            id: 8, header: "Innovation and Advantages", type: "Narrative", status: "Done", target: "25", limit: "26",
            reviewer: "Assign reviewer"),
        SCDashboard01Section(
            id: 9, header: "Overview of EMR's Innovative Solutions", type: "Technical content", status: "Done",
            target: "7", limit: "23", reviewer: "Assign reviewer"),
        SCDashboard01Section(
            id: 10, header: "Advanced Algorithms and Machine Learning", type: "Narrative", status: "Done", target: "30",
            limit: "28", reviewer: "Assign reviewer"),
        SCDashboard01Section(
            id: 11, header: "Adaptive Communication Protocols", type: "Narrative", status: "Done", target: "9",
            limit: "31", reviewer: "Assign reviewer"),
        SCDashboard01Section(
            id: 12, header: "Advantages Over Current Technologies", type: "Narrative", status: "Done", target: "12",
            limit: "0", reviewer: "Assign reviewer"),
        SCDashboard01Section(
            id: 13, header: "Past Performance", type: "Narrative", status: "Done", target: "22", limit: "33",
            reviewer: "Assign reviewer"),
        SCDashboard01Section(
            id: 14, header: "Customer Feedback and Satisfaction Levels", type: "Narrative", status: "Done",
            target: "15", limit: "34", reviewer: "Assign reviewer"),
        SCDashboard01Section(
            id: 15, header: "Implementation Challenges and Solutions", type: "Narrative", status: "Done", target: "3",
            limit: "35", reviewer: "Assign reviewer"),
        SCDashboard01Section(
            id: 16, header: "Security Measures and Data Protection Policies", type: "Narrative", status: "In Process",
            target: "6", limit: "36", reviewer: "Assign reviewer"),
        SCDashboard01Section(
            id: 17, header: "Scalability and Future Proofing", type: "Narrative", status: "Done", target: "4",
            limit: "37", reviewer: "Assign reviewer"),
        SCDashboard01Section(
            id: 18, header: "Cost-Benefit Analysis", type: "Plain language", status: "Done", target: "14", limit: "38",
            reviewer: "Assign reviewer"),
        SCDashboard01Section(
            id: 19, header: "User Training and Onboarding Experience", type: "Narrative", status: "Done", target: "17",
            limit: "39", reviewer: "Assign reviewer"),
        SCDashboard01Section(
            id: 20, header: "Future Development Roadmap", type: "Narrative", status: "Done", target: "11", limit: "40",
            reviewer: "Assign reviewer"),
        SCDashboard01Section(
            id: 21, header: "System Architecture Overview", type: "Technical content", status: "In Process",
            target: "24", limit: "18", reviewer: "Maya Johnson"),
        SCDashboard01Section(
            id: 22, header: "Risk Management Plan", type: "Narrative", status: "Done", target: "15", limit: "22",
            reviewer: "Carlos Rodriguez"),
        SCDashboard01Section(
            id: 23, header: "Compliance Documentation", type: "Legal", status: "In Process", target: "31", limit: "27",
            reviewer: "Sarah Chen"),
        SCDashboard01Section(
            id: 24, header: "API Documentation", type: "Technical content", status: "Done", target: "8", limit: "12",
            reviewer: "Raj Patel"),
        SCDashboard01Section(
            id: 25, header: "User Interface Mockups", type: "Visual", status: "In Process", target: "19", limit: "25",
            reviewer: "Leila Ahmadi"),
        SCDashboard01Section(
            id: 26, header: "Database Schema", type: "Technical content", status: "Done", target: "22", limit: "20",
            reviewer: "Thomas Wilson"),
        SCDashboard01Section(
            id: 27, header: "Testing Methodology", type: "Technical content", status: "In Process", target: "17",
            limit: "14", reviewer: "Assign reviewer"),
        SCDashboard01Section(
            id: 28, header: "Deployment Strategy", type: "Narrative", status: "Done", target: "26", limit: "30",
            reviewer: "Eddie Lake"),
        SCDashboard01Section(
            id: 29, header: "Budget Breakdown", type: "Financial", status: "In Process", target: "13", limit: "16",
            reviewer: "Jamik Tashpulatov"),
        SCDashboard01Section(
            id: 30, header: "Market Analysis", type: "Research", status: "Done", target: "29", limit: "32",
            reviewer: "Sophia Martinez"),
        SCDashboard01Section(
            id: 31, header: "Competitor Comparison", type: "Research", status: "In Process", target: "21", limit: "19",
            reviewer: "Assign reviewer"),
        SCDashboard01Section(
            id: 32, header: "Maintenance Plan", type: "Technical content", status: "Done", target: "16", limit: "23",
            reviewer: "Alex Thompson"),
        SCDashboard01Section(
            id: 33, header: "User Personas", type: "Research", status: "In Process", target: "27", limit: "24",
            reviewer: "Nina Patel"),
        SCDashboard01Section(
            id: 34, header: "Accessibility Compliance", type: "Legal", status: "Done", target: "18", limit: "21",
            reviewer: "Assign reviewer"),
        SCDashboard01Section(
            id: 35, header: "Performance Metrics", type: "Technical content", status: "In Process", target: "23",
            limit: "26", reviewer: "David Kim"),
        SCDashboard01Section(
            id: 36, header: "Disaster Recovery Plan", type: "Technical content", status: "Done", target: "14",
            limit: "17", reviewer: "Jamik Tashpulatov"),
        SCDashboard01Section(
            id: 37, header: "Third-party Integrations", type: "Technical content", status: "In Process", target: "25",
            limit: "28", reviewer: "Eddie Lake"),
        SCDashboard01Section(
            id: 38, header: "User Feedback Summary", type: "Research", status: "Done", target: "20", limit: "15",
            reviewer: "Assign reviewer"),
        SCDashboard01Section(
            id: 39, header: "Localization Strategy", type: "Narrative", status: "In Process", target: "12", limit: "19",
            reviewer: "Maria Garcia"),
        SCDashboard01Section(
            id: 40, header: "Mobile Compatibility", type: "Technical content", status: "Done", target: "28",
            limit: "31", reviewer: "James Wilson"),
        SCDashboard01Section(
            id: 41, header: "Data Migration Plan", type: "Technical content", status: "In Process", target: "19",
            limit: "22", reviewer: "Assign reviewer"),
        SCDashboard01Section(
            id: 42, header: "Quality Assurance Protocols", type: "Technical content", status: "Done", target: "30",
            limit: "33", reviewer: "Priya Singh"),
        SCDashboard01Section(
            id: 43, header: "Stakeholder Analysis", type: "Research", status: "In Process", target: "11", limit: "14",
            reviewer: "Eddie Lake"),
        SCDashboard01Section(
            id: 44, header: "Environmental Impact Assessment", type: "Research", status: "Done", target: "24",
            limit: "27", reviewer: "Assign reviewer"),
        SCDashboard01Section(
            id: 45, header: "Intellectual Property Rights", type: "Legal", status: "In Process", target: "17",
            limit: "20", reviewer: "Sarah Johnson"),
        SCDashboard01Section(
            id: 46, header: "Customer Support Framework", type: "Narrative", status: "Done", target: "22", limit: "25",
            reviewer: "Jamik Tashpulatov"),
        SCDashboard01Section(
            id: 47, header: "Version Control Strategy", type: "Technical content", status: "In Process", target: "15",
            limit: "18", reviewer: "Assign reviewer"),
        SCDashboard01Section(
            id: 48, header: "Continuous Integration Pipeline", type: "Technical content", status: "Done", target: "26",
            limit: "29", reviewer: "Michael Chen"),
        SCDashboard01Section(
            id: 49, header: "Regulatory Compliance", type: "Legal", status: "In Process", target: "13", limit: "16",
            reviewer: "Assign reviewer"),
        SCDashboard01Section(
            id: 50, header: "User Authentication System", type: "Technical content", status: "Done", target: "28",
            limit: "31", reviewer: "Eddie Lake"),
        SCDashboard01Section(
            id: 51, header: "Data Analytics Framework", type: "Technical content", status: "In Process", target: "21",
            limit: "24", reviewer: "Jamik Tashpulatov"),
        SCDashboard01Section(
            id: 52, header: "Cloud Infrastructure", type: "Technical content", status: "Done", target: "16",
            limit: "19", reviewer: "Assign reviewer"),
        SCDashboard01Section(
            id: 53, header: "Network Security Measures", type: "Technical content", status: "In Process", target: "29",
            limit: "32", reviewer: "Lisa Wong"),
        SCDashboard01Section(
            id: 54, header: "Project Timeline", type: "Planning", status: "Done", target: "14", limit: "17",
            reviewer: "Eddie Lake"),
        SCDashboard01Section(
            id: 55, header: "Resource Allocation", type: "Planning", status: "In Process", target: "27", limit: "30",
            reviewer: "Assign reviewer"),
        SCDashboard01Section(
            id: 56, header: "Team Structure and Roles", type: "Planning", status: "Done", target: "20", limit: "23",
            reviewer: "Jamik Tashpulatov"),
        SCDashboard01Section(
            id: 57, header: "Communication Protocols", type: "Planning", status: "In Process", target: "15",
            limit: "18", reviewer: "Assign reviewer"),
        SCDashboard01Section(
            id: 58, header: "Success Metrics", type: "Planning", status: "Done", target: "30", limit: "33",
            reviewer: "Eddie Lake"),
        SCDashboard01Section(
            id: 59, header: "Internationalization Support", type: "Technical content", status: "In Process",
            target: "23", limit: "26", reviewer: "Jamik Tashpulatov"),
        SCDashboard01Section(
            id: 60, header: "Backup and Recovery Procedures", type: "Technical content", status: "Done", target: "18",
            limit: "21", reviewer: "Assign reviewer"),
        SCDashboard01Section(
            id: 61, header: "Monitoring and Alerting System", type: "Technical content", status: "In Process",
            target: "25", limit: "28", reviewer: "Daniel Park"),
        SCDashboard01Section(
            id: 62, header: "Code Review Guidelines", type: "Technical content", status: "Done", target: "12",
            limit: "15", reviewer: "Eddie Lake"),
        SCDashboard01Section(
            id: 63, header: "Documentation Standards", type: "Technical content", status: "In Process", target: "27",
            limit: "30", reviewer: "Jamik Tashpulatov"),
        SCDashboard01Section(
            id: 64, header: "Release Management Process", type: "Planning", status: "Done", target: "22", limit: "25",
            reviewer: "Assign reviewer"),
        SCDashboard01Section(
            id: 65, header: "Feature Prioritization Matrix", type: "Planning", status: "In Process", target: "19",
            limit: "22", reviewer: "Emma Davis"),
        SCDashboard01Section(
            id: 66, header: "Technical Debt Assessment", type: "Technical content", status: "Done", target: "24",
            limit: "27", reviewer: "Eddie Lake"),
        SCDashboard01Section(
            id: 67, header: "Capacity Planning", type: "Planning", status: "In Process", target: "21", limit: "24",
            reviewer: "Jamik Tashpulatov"),
        SCDashboard01Section(
            id: 68, header: "Service Level Agreements", type: "Legal", status: "Done", target: "26", limit: "29",
            reviewer: "Assign reviewer"),
    ]
    // swiftlint:enable large_tuple

    /// The daily desktop/mobile series behind the visitors chart.
    public static let visitors: [VisitorPoint] = [
        VisitorPoint("2024-04-01", 222, 150),
        VisitorPoint("2024-04-02", 97, 180),
        VisitorPoint("2024-04-03", 167, 120),
        VisitorPoint("2024-04-04", 242, 260),
        VisitorPoint("2024-04-05", 373, 290),
        VisitorPoint("2024-04-06", 301, 340),
        VisitorPoint("2024-04-07", 245, 180),
        VisitorPoint("2024-04-08", 409, 320),
        VisitorPoint("2024-04-09", 59, 110),
        VisitorPoint("2024-04-10", 261, 190),
        VisitorPoint("2024-04-11", 327, 350),
        VisitorPoint("2024-04-12", 292, 210),
        VisitorPoint("2024-04-13", 342, 380),
        VisitorPoint("2024-04-14", 137, 220),
        VisitorPoint("2024-04-15", 120, 170),
        VisitorPoint("2024-04-16", 138, 190),
        VisitorPoint("2024-04-17", 446, 360),
        VisitorPoint("2024-04-18", 364, 410),
        VisitorPoint("2024-04-19", 243, 180),
        VisitorPoint("2024-04-20", 89, 150),
        VisitorPoint("2024-04-21", 137, 200),
        VisitorPoint("2024-04-22", 224, 170),
        VisitorPoint("2024-04-23", 138, 230),
        VisitorPoint("2024-04-24", 387, 290),
        VisitorPoint("2024-04-25", 215, 250),
        VisitorPoint("2024-04-26", 75, 130),
        VisitorPoint("2024-04-27", 383, 420),
        VisitorPoint("2024-04-28", 122, 180),
        VisitorPoint("2024-04-29", 315, 240),
        VisitorPoint("2024-04-30", 454, 380),
        VisitorPoint("2024-05-01", 165, 220),
        VisitorPoint("2024-05-02", 293, 310),
        VisitorPoint("2024-05-03", 247, 190),
        VisitorPoint("2024-05-04", 385, 420),
        VisitorPoint("2024-05-05", 481, 390),
        VisitorPoint("2024-05-06", 498, 520),
        VisitorPoint("2024-05-07", 388, 300),
        VisitorPoint("2024-05-08", 149, 210),
        VisitorPoint("2024-05-09", 227, 180),
        VisitorPoint("2024-05-10", 293, 330),
        VisitorPoint("2024-05-11", 335, 270),
        VisitorPoint("2024-05-12", 197, 240),
        VisitorPoint("2024-05-13", 197, 160),
        VisitorPoint("2024-05-14", 448, 490),
        VisitorPoint("2024-05-15", 473, 380),
        VisitorPoint("2024-05-16", 338, 400),
        VisitorPoint("2024-05-17", 499, 420),
        VisitorPoint("2024-05-18", 315, 350),
        VisitorPoint("2024-05-19", 235, 180),
        VisitorPoint("2024-05-20", 177, 230),
        VisitorPoint("2024-05-21", 82, 140),
        VisitorPoint("2024-05-22", 81, 120),
        VisitorPoint("2024-05-23", 252, 290),
        VisitorPoint("2024-05-24", 294, 220),
        VisitorPoint("2024-05-25", 201, 250),
        VisitorPoint("2024-05-26", 213, 170),
        VisitorPoint("2024-05-27", 420, 460),
        VisitorPoint("2024-05-28", 233, 190),
        VisitorPoint("2024-05-29", 78, 130),
        VisitorPoint("2024-05-30", 340, 280),
        VisitorPoint("2024-05-31", 178, 230),
        VisitorPoint("2024-06-01", 178, 200),
        VisitorPoint("2024-06-02", 470, 410),
        VisitorPoint("2024-06-03", 103, 160),
        VisitorPoint("2024-06-04", 439, 380),
        VisitorPoint("2024-06-05", 88, 140),
        VisitorPoint("2024-06-06", 294, 250),
        VisitorPoint("2024-06-07", 323, 370),
        VisitorPoint("2024-06-08", 385, 320),
        VisitorPoint("2024-06-09", 438, 480),
        VisitorPoint("2024-06-10", 155, 200),
        VisitorPoint("2024-06-11", 92, 150),
        VisitorPoint("2024-06-12", 492, 420),
        VisitorPoint("2024-06-13", 81, 130),
        VisitorPoint("2024-06-14", 426, 380),
        VisitorPoint("2024-06-15", 307, 350),
        VisitorPoint("2024-06-16", 371, 310),
        VisitorPoint("2024-06-17", 475, 520),
        VisitorPoint("2024-06-18", 107, 170),
        VisitorPoint("2024-06-19", 341, 290),
        VisitorPoint("2024-06-20", 408, 450),
        VisitorPoint("2024-06-21", 169, 210),
        VisitorPoint("2024-06-22", 317, 270),
        VisitorPoint("2024-06-23", 480, 530),
        VisitorPoint("2024-06-24", 132, 180),
        VisitorPoint("2024-06-25", 141, 190),
        VisitorPoint("2024-06-26", 434, 380),
        VisitorPoint("2024-06-27", 448, 490),
        VisitorPoint("2024-06-28", 149, 200),
        VisitorPoint("2024-06-29", 103, 160),
        VisitorPoint("2024-06-30", 446, 400),
    ]
}

// MARK: - Previews

#Preview("Dashboard01 · full block") {
    @Previewable @State var lastAction = "Use any dashboard control."

    SCPreview {
        VStack(spacing: 8) {
            SCDashboard01Block { lastAction = String(describing: $0) }
                .frame(width: 1100, height: 760)
            Text(lastAction).scMuted()
        }
    }
}

#Preview("Dashboard01 · controlled selection") {
    @Previewable @State var selection = "Analytics"

    SCPreview {
        VStack(spacing: 8) {
            SCDashboard01Block(selection: $selection) { _ in }
                .frame(width: 1100, height: 700)
            Text("Selected: \(selection)").scMuted()
        }
    }
}
