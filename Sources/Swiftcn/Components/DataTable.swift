// ============================================================
// DataTable.swift — swiftcn-ui
// Depends on: Table.swift, Button.swift, Theme/
// ============================================================
import Observation
import SwiftUI

/// Caller-owned state for a reusable data-table composition.
@Observable
public final class SCDataTableController<Row: Identifiable> {
    public var query: String {
        didSet {
            if query != oldValue { pageIndex = 0 }
        }
    }

    public var sort: SCTableSort? {
        didSet {
            if sort != oldValue { pageIndex = 0 }
        }
    }

    public var selectedRowIDs: Set<Row.ID>
    public var hiddenColumnIDs: Set<String>
    public var pageIndex: Int
    public var pageSize: Int {
        didSet {
            if pageSize < 1 { pageSize = 1 }
            if pageSize != oldValue { pageIndex = 0 }
        }
    }

    public init(
        query: String = "",
        sort: SCTableSort? = nil,
        selectedRowIDs: Set<Row.ID> = [],
        hiddenColumnIDs: Set<String> = [],
        pageIndex: Int = 0,
        pageSize: Int = 10
    ) {
        self.query = query
        self.sort = sort
        self.selectedRowIDs = selectedRowIDs
        self.hiddenColumnIDs = hiddenColumnIDs
        self.pageIndex = max(0, pageIndex)
        self.pageSize = max(1, pageSize)
    }

    public func isColumnVisible(_ columnID: String) -> Bool {
        !hiddenColumnIDs.contains(columnID)
    }

    public func setColumn(_ columnID: String, isVisible: Bool) {
        if isVisible {
            hiddenColumnIDs.remove(columnID)
        } else {
            hiddenColumnIDs.insert(columnID)
        }
    }

    public func pageCount(totalRows: Int) -> Int {
        max(1, Int(ceil(Double(totalRows) / Double(pageSize))))
    }

    public func canGoBackward(totalRows: Int) -> Bool {
        totalRows > 0 && pageIndex > 0
    }

    public func canGoForward(totalRows: Int) -> Bool {
        totalRows > 0 && pageIndex + 1 < pageCount(totalRows: totalRows)
    }

    public func goToFirstPage() {
        pageIndex = 0
    }

    public func goToPreviousPage(totalRows: Int) {
        guard canGoBackward(totalRows: totalRows) else { return }
        pageIndex -= 1
    }

    public func goToNextPage(totalRows: Int) {
        guard canGoForward(totalRows: totalRows) else { return }
        pageIndex += 1
    }

    public func goToLastPage(totalRows: Int) {
        pageIndex = pageCount(totalRows: totalRows) - 1
    }

    public func clampPage(totalRows: Int) {
        pageIndex = min(max(0, pageIndex), pageCount(totalRows: totalRows) - 1)
    }
}

/// A toolbar row for caller-composed filters, actions, and view options.
public struct SCDataTableToolbar<Content: View>: View {
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        HStack(spacing: 8) { content }
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

/// A controlled global-filter field for a data-table controller.
public struct SCDataTableSearchField<Row: Identifiable>: View {
    @Environment(\.theme) private var theme
    private let controller: SCDataTableController<Row>
    private let placeholder: String

    public init(
        controller: SCDataTableController<Row>,
        placeholder: String = "Filter rows…"
    ) {
        self.controller = controller
        self.placeholder = placeholder
    }

    public var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(theme.mutedForeground)
                .accessibilityHidden(true)
            TextField(placeholder, text: queryBinding)
                .textFieldStyle(.plain)
            if !controller.query.isEmpty {
                Button {
                    controller.query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(theme.mutedForeground)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear filter")
            }
        }
        .font(.subheadline)
        .padding(.horizontal, 10)
        .frame(width: 240, height: 36)
        .background(theme.background, in: shape)
        .overlay { shape.strokeBorder(theme.input) }
    }

    private var queryBinding: Binding<String> {
        Binding(
            get: { controller.query },
            set: { controller.query = $0 }
        )
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.radius, style: .continuous)
    }
}

/// A native menu that controls every hideable column.
public struct SCDataTableViewOptions<Row: Identifiable>: View {
    private let controller: SCDataTableController<Row>
    private let columns: [SCTableColumn<Row>]

    public init(
        controller: SCDataTableController<Row>,
        columns: [SCTableColumn<Row>]
    ) {
        self.controller = controller
        self.columns = columns
    }

    public var body: some View {
        Menu {
            ForEach(hideableColumns, id: \.columnID) { column in
                Toggle(
                    column.title,
                    isOn: Binding(
                        get: { controller.isColumnVisible(column.columnID) },
                        set: { controller.setColumn(column.columnID, isVisible: $0) }
                    )
                )
            }
        } label: {
            Label("Columns", systemImage: "slider.horizontal.3")
        }
        .buttonStyle(.sc(.outline, size: .sm))
        .disabled(hideableColumns.isEmpty)
    }

    private var hideableColumns: [SCTableColumn<Row>] {
        columns.filter(\.canHide)
    }
}

/// A sortable/hideable header for use in an `SCTableColumn` custom header slot.
public struct SCDataTableColumnHeader<Row: Identifiable, HeaderLabel: View>: View {
    private let controller: SCDataTableController<Row>
    private let columnID: String
    private let canSort: Bool
    private let canHide: Bool
    private let label: HeaderLabel

    public init(
        controller: SCDataTableController<Row>,
        columnID: String,
        canSort: Bool = true,
        canHide: Bool = true,
        @ViewBuilder label: () -> HeaderLabel
    ) {
        self.controller = controller
        self.columnID = columnID
        self.canSort = canSort
        self.canHide = canHide
        self.label = label()
    }

    public var body: some View {
        if canSort || canHide {
            Menu {
                if canSort {
                    Button {
                        controller.sort = SCTableSort(columnID: columnID, order: .ascending)
                    } label: {
                        Label("Ascending", systemImage: "arrow.up")
                    }
                    Button {
                        controller.sort = SCTableSort(columnID: columnID, order: .descending)
                    } label: {
                        Label("Descending", systemImage: "arrow.down")
                    }
                    Button {
                        controller.sort = nil
                    } label: {
                        Label("Clear sort", systemImage: "arrow.up.arrow.down")
                    }
                }
                if canSort, canHide { Divider() }
                if canHide {
                    Button {
                        controller.setColumn(columnID, isVisible: false)
                    } label: {
                        Label("Hide", systemImage: "eye.slash")
                    }
                }
            } label: {
                HStack(spacing: 4) {
                    label
                    sortIndicator
                }
            }
            .buttonStyle(.plain)
        } else {
            label
        }
    }

    @ViewBuilder
    private var sortIndicator: some View {
        if let sort = controller.sort, sort.columnID == columnID {
            Image(systemName: sort.order == .ascending ? "arrow.up" : "arrow.down")
        } else if canSort {
            Image(systemName: "arrow.up.arrow.down").opacity(0.5)
        }
    }
}

/// Selection summary, rows-per-page control, and first/previous/next/last actions.
public struct SCDataTablePagination<Row: Identifiable>: View {
    @Environment(\.theme) private var theme
    private let controller: SCDataTableController<Row>
    private let filteredRowCount: Int
    private let selectedFilteredRowCount: Int
    private let pageSizes: [Int]

    public init(
        controller: SCDataTableController<Row>,
        filteredRowCount: Int,
        selectedFilteredRowCount: Int,
        pageSizes: [Int] = [10, 20, 25, 30, 40, 50]
    ) {
        self.controller = controller
        self.filteredRowCount = filteredRowCount
        self.selectedFilteredRowCount = selectedFilteredRowCount
        self.pageSizes = Array(Set(pageSizes.filter { $0 > 0 } + [controller.pageSize])).sorted()
    }

    public var body: some View {
        HStack(spacing: 16) {
            Text("\(selectedFilteredRowCount) of \(filteredRowCount) row(s) selected.")
                .font(.footnote)
                .foregroundStyle(theme.mutedForeground)
            Spacer(minLength: 8)
            HStack(spacing: 8) {
                Text("Rows per page").font(.footnote.weight(.medium))
                Menu {
                    ForEach(pageSizes, id: \.self) { size in
                        Button("\(size)") { controller.pageSize = size }
                    }
                } label: {
                    Text("\(controller.pageSize)")
                        .frame(minWidth: 28)
                }
                .buttonStyle(.sc(.outline, size: .sm))
            }
            Text(
                "Page \(controller.pageIndex + 1) of \(controller.pageCount(totalRows: filteredRowCount))"
            )
            .font(.footnote.weight(.medium))
            .monospacedDigit()
            HStack(spacing: 6) {
                pageButton("backward.end", label: "First page") {
                    controller.goToFirstPage()
                }
                .disabled(!controller.canGoBackward(totalRows: filteredRowCount))
                pageButton("chevron.backward", label: "Previous page") {
                    controller.goToPreviousPage(totalRows: filteredRowCount)
                }
                .disabled(!controller.canGoBackward(totalRows: filteredRowCount))
                pageButton("chevron.forward", label: "Next page") {
                    controller.goToNextPage(totalRows: filteredRowCount)
                }
                .disabled(!controller.canGoForward(totalRows: filteredRowCount))
                pageButton("forward.end", label: "Last page") {
                    controller.goToLastPage(totalRows: filteredRowCount)
                }
                .disabled(!controller.canGoForward(totalRows: filteredRowCount))
            }
        }
    }

    private func pageButton(
        _ systemImage: String,
        label: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            Image(systemName: systemImage)
        }
        .buttonStyle(.sc(.outline, size: .iconSM))
        .accessibilityLabel(label)
    }
}

/// A reusable typed data table assembled from `SCTable` and headless controller state.
public struct SCDataTable<Row: Identifiable>: View {
    @Environment(\.theme) private var theme

    private let rows: [Row]
    private let columns: [SCTableColumn<Row>]
    private let controller: SCDataTableController<Row>
    private let selectionBehavior: SCTableSelectionBehavior
    private let onRowTap: ((Row) -> Void)?
    private let caption: String?
    private let showsToolbar: Bool
    private let showsPagination: Bool
    private let pageSizes: [Int]
    private let filter: ((Row, String) -> Bool)?
    private let emptyContent: AnyView

    public init(
        rows: [Row],
        columns: [SCTableColumn<Row>],
        controller: SCDataTableController<Row>,
        selectionBehavior: SCTableSelectionBehavior = .checkboxOnly,
        onRowTap: ((Row) -> Void)? = nil,
        caption: String? = nil,
        showsToolbar: Bool = true,
        showsPagination: Bool = true,
        pageSizes: [Int] = [10, 20, 25, 30, 40, 50],
        filter: ((Row, String) -> Bool)? = nil
    ) {
        self.rows = rows
        self.columns = columns
        self.controller = controller
        self.selectionBehavior = selectionBehavior
        self.onRowTap = onRowTap
        self.caption = caption
        self.showsToolbar = showsToolbar
        self.showsPagination = showsPagination
        self.pageSizes = pageSizes
        self.filter = filter
        self.emptyContent = AnyView(
            Text("No results.")
                .font(.subheadline)
                .foregroundStyle(Color.secondary)
        )
    }

    public init<Empty: View>(
        rows: [Row],
        columns: [SCTableColumn<Row>],
        controller: SCDataTableController<Row>,
        selectionBehavior: SCTableSelectionBehavior = .checkboxOnly,
        onRowTap: ((Row) -> Void)? = nil,
        caption: String? = nil,
        showsToolbar: Bool = true,
        showsPagination: Bool = true,
        pageSizes: [Int] = [10, 20, 25, 30, 40, 50],
        filter: ((Row, String) -> Bool)? = nil,
        @ViewBuilder empty: () -> Empty
    ) {
        self.rows = rows
        self.columns = columns
        self.controller = controller
        self.selectionBehavior = selectionBehavior
        self.onRowTap = onRowTap
        self.caption = caption
        self.showsToolbar = showsToolbar
        self.showsPagination = showsPagination
        self.pageSizes = pageSizes
        self.filter = filter
        self.emptyContent = AnyView(empty())
    }

    public var body: some View {
        VStack(spacing: 12) {
            if showsToolbar {
                SCDataTableToolbar {
                    SCDataTableSearchField(controller: controller)
                    Spacer(minLength: 8)
                    SCDataTableViewOptions(controller: controller, columns: columns)
                }
            }
            SCTable(
                rows: pagedRows,
                columns: visibleColumns,
                selection: selectionBinding,
                selectionBehavior: selectionBehavior,
                sort: sortBinding,
                onRowTap: onRowTap,
                caption: caption
            )
            if pagedRows.isEmpty {
                emptyContent
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(theme.muted.opacity(0.25), in: emptyShape)
            }
            if showsPagination {
                SCDataTablePagination(
                    controller: controller,
                    filteredRowCount: filteredRows.count,
                    selectedFilteredRowCount: selectedFilteredRowCount,
                    pageSizes: pageSizes
                )
            }
        }
        .onAppear { controller.clampPage(totalRows: filteredRows.count) }
        .onChange(of: filteredRows.map(\.id)) { _, _ in
            controller.clampPage(totalRows: filteredRows.count)
        }
    }

    private var visibleColumns: [SCTableColumn<Row>] {
        columns.filter { controller.isColumnVisible($0.columnID) }
    }

    private var filteredRows: [Row] {
        let query = controller.query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return rows }
        if let filter { return rows.filter { filter($0, query) } }
        return rows.filter { row in
            columns.contains { column in
                column.searchText?(row).localizedCaseInsensitiveContains(query) == true
            }
        }
    }

    private var sortedRows: [Row] {
        guard
            let sort = controller.sort,
            let comparator = columns.first(where: { $0.columnID == sort.columnID })?.comparator
        else { return filteredRows }
        let ascending = filteredRows.sorted(by: comparator)
        return sort.order == .ascending ? ascending : Array(ascending.reversed())
    }

    private var pagedRows: [Row] {
        let start = min(controller.pageIndex * controller.pageSize, sortedRows.count)
        let end = min(start + controller.pageSize, sortedRows.count)
        return Array(sortedRows[start..<end])
    }

    private var selectedFilteredRowCount: Int {
        filteredRows.reduce(into: 0) { count, row in
            if controller.selectedRowIDs.contains(row.id) { count += 1 }
        }
    }

    private var selectionBinding: Binding<Set<Row.ID>> {
        Binding(
            get: { controller.selectedRowIDs },
            set: { controller.selectedRowIDs = $0 }
        )
    }

    private var sortBinding: Binding<SCTableSort?> {
        Binding(
            get: { controller.sort },
            set: { controller.sort = $0 }
        )
    }

    private var emptyShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.radius, style: .continuous)
    }
}

// MARK: - Previews

private struct SCDataTablePreviewPayment: Identifiable {
    let id: String
    let status: String
    let email: String
    let amount: Double
}

private let scDataTablePreviewRows = [
    SCDataTablePreviewPayment(id: "1", status: "Success", email: "ken99@example.com", amount: 316),
    SCDataTablePreviewPayment(id: "2", status: "Success", email: "abe45@example.com", amount: 242),
    SCDataTablePreviewPayment(id: "3", status: "Processing", email: "monserrat44@example.com", amount: 837),
    SCDataTablePreviewPayment(id: "4", status: "Failed", email: "carmella@example.com", amount: 721),
]

#Preview("Data table") {
    @Previewable @State var controller = SCDataTableController<SCDataTablePreviewPayment>(
        pageSize: 3
    )
    let columns: [SCTableColumn<SCDataTablePreviewPayment>] = [
        SCTableColumn("Status", width: .min(100)) { $0.status },
        SCTableColumn(
            "Email",
            comparator: { $0.email < $1.email },
            value: { $0.email }
        ),
        SCTableColumn(
            "Amount",
            alignment: .trailing,
            comparator: { $0.amount < $1.amount },
            value: { $0.amount.formatted(.currency(code: "USD")) }
        ),
        SCTableColumn(
            "Actions",
            width: .fixed(80),
            isHideable: false,
            searchValue: nil
        ) { _ in
            Menu {
                Button("Copy payment ID") {}
                Button("View details") {}
            } label: {
                Image(systemName: "ellipsis")
            }
            .menuStyle(.borderlessButton)
        },
    ]

    SCPreview {
        SCDataTable(
            rows: scDataTablePreviewRows,
            columns: columns,
            controller: controller
        )
    }
    .frame(width: 760, height: 420)
}
