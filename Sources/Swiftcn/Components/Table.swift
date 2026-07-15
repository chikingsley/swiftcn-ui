// ============================================================
// Table.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Column

/// How an `SCTableColumn` claims horizontal space.
public enum SCTableColumnWidth: Equatable, Sendable {
    /// Shares the remaining width equally with the other flexible columns.
    case flexible
    /// Exactly this many points wide.
    case fixed(CGFloat)
    /// At least this many points wide, growing like `.flexible`.
    case min(CGFloat)
}

/// Whether selection changes only from the checkbox or from the whole row.
public enum SCTableSelectionBehavior: Hashable, Sendable {
    /// Keeps controls inside cells independent. Best for data tables.
    case checkboxOnly
    /// Clicking otherwise-empty row space also toggles selection.
    case row
}

/// Public, bindable table sort state.
public struct SCTableSort: Equatable, Sendable {
    public enum Order: Equatable, Sendable {
        case ascending
        case descending
    }

    public var columnID: String
    public var order: Order

    public init(columnID: String, order: Order) {
        self.columnID = columnID
        self.order = order
    }
}

/// Describes one column of an `SCTable`: its header title, sizing, alignment,
/// optional sort comparator, and how to derive the cell text from a row.
///
///     SCTableColumn("Amount", alignment: .trailing,
///                   comparator: { $0.amount < $1.amount },
///                   value: { $0.amount.formatted(.currency(code: "USD")) })
public struct SCTableColumn<Row> {
    var id: String
    var accessibilityLabel: String
    var width: SCTableColumnWidth
    var alignment: HorizontalAlignment
    var comparator: ((Row, Row) -> Bool)?
    var searchText: ((Row) -> String)?
    var isHideable: Bool
    var usesCustomSortControl: Bool
    var header: AnyView
    var cell: (Row) -> AnyView

    public var columnID: String { id }
    public var title: String { accessibilityLabel }
    public var canSort: Bool { comparator != nil }
    public var canHide: Bool { isHideable }

    /// - Parameters:
    ///   - title: The header title.
    ///   - width: How the column claims horizontal space (default `.flexible`).
    ///   - alignment: Horizontal alignment of the header and cells.
    ///   - comparator: Ascending sort predicate. Providing one makes the
    ///     column sortable — tapping the header cycles ascending →
    ///     descending → unsorted.
    ///   - value: Maps a row to the cell text.
    public init(
        _ title: String,
        id: String? = nil,
        width: SCTableColumnWidth = .flexible,
        alignment: HorizontalAlignment = .leading,
        isHideable: Bool = true,
        comparator: ((Row, Row) -> Bool)? = nil,
        value: @escaping (Row) -> String
    ) {
        self.id = id ?? title
        self.accessibilityLabel = title
        self.width = width
        self.alignment = alignment
        self.comparator = comparator
        self.searchText = value
        self.isHideable = isHideable
        self.usesCustomSortControl = false
        self.header = AnyView(Text(title))
        self.cell = { AnyView(Text(value($0))) }
    }

    /// Creates a column with arbitrary cell content such as badges, menus,
    /// buttons, avatars, progress views, or composed layouts.
    public init<Cell: View>(
        _ title: String,
        id: String? = nil,
        width: SCTableColumnWidth = .flexible,
        alignment: HorizontalAlignment = .leading,
        isHideable: Bool = true,
        comparator: ((Row, Row) -> Bool)? = nil,
        searchValue: ((Row) -> String)? = nil,
        @ViewBuilder cell: @escaping (Row) -> Cell
    ) {
        self.id = id ?? title
        self.accessibilityLabel = title
        self.width = width
        self.alignment = alignment
        self.comparator = comparator
        self.searchText = searchValue
        self.isHideable = isHideable
        self.usesCustomSortControl = false
        self.header = AnyView(Text(title))
        self.cell = { AnyView(cell($0)) }
    }

    /// Creates a column with fully custom header and cell content.
    public init<Header: View, Cell: View>(
        id: String,
        accessibilityLabel: String,
        width: SCTableColumnWidth = .flexible,
        alignment: HorizontalAlignment = .leading,
        isHideable: Bool = true,
        comparator: ((Row, Row) -> Bool)? = nil,
        searchValue: ((Row) -> String)? = nil,
        usesCustomSortControl: Bool = false,
        @ViewBuilder header: () -> Header,
        @ViewBuilder cell: @escaping (Row) -> Cell
    ) {
        self.id = id
        self.accessibilityLabel = accessibilityLabel
        self.width = width
        self.alignment = alignment
        self.comparator = comparator
        self.searchText = searchValue
        self.isHideable = isHideable
        self.usesCustomSortControl = usesCustomSortControl
        self.header = AnyView(header())
        self.cell = { AnyView(cell($0)) }
    }
}

// MARK: - Primitive composition

private enum SCTableSectionRole: Hashable {
    case header
    case body
    case footer
}

private struct SCTableSectionRoleKey: EnvironmentKey {
    static let defaultValue = SCTableSectionRole.body
}

extension EnvironmentValues {
    fileprivate var scTableSectionRole: SCTableSectionRole {
        get { self[SCTableSectionRoleKey.self] }
        set { self[SCTableSectionRoleKey.self] = newValue }
    }
}

/// The composable table root documented by shadcn/ui.
///
/// `SCTableRoot` keeps its rows at least as wide as the viewport and adds
/// horizontal overflow only when `minimumWidth` requires it. Compose it from
/// `SCTableHeader`, `SCTableBody`, optional `SCTableFooter`, rows, heads, and
/// cells. A caption is a separate builder because SwiftUI cannot hoist an
/// arbitrary child out of the scrolling table the way HTML lays out a
/// `<caption>` element.
public struct SCTableRoot<Content: View, Caption: View>: View {
    var minimumWidth: CGFloat
    var content: Content
    var caption: Caption

    public init(
        minimumWidth: CGFloat = 0,
        @ViewBuilder content: () -> Content,
        @ViewBuilder caption: () -> Caption
    ) {
        self.minimumWidth = max(0, minimumWidth)
        self.content = content()
        self.caption = caption()
    }

    public var body: some View {
        VStack(spacing: 12) {
            ScrollView(.horizontal) {
                VStack(spacing: 0) {
                    content
                }
                .frame(minWidth: minimumWidth, alignment: .leading)
                .containerRelativeFrame(.horizontal, alignment: .leading) { length, _ in
                    max(length, minimumWidth)
                }
            }
            .scrollIndicators(.hidden)

            caption
        }
    }
}

extension SCTableRoot where Caption == EmptyView {
    public init(
        minimumWidth: CGFloat = 0,
        @ViewBuilder content: () -> Content
    ) {
        self.init(minimumWidth: minimumWidth, content: content) {
            EmptyView()
        }
    }
}

/// Groups one or more header rows.
public struct SCTableHeader<Content: View>: View {
    var content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: 0) {
            content
        }
        .environment(\.scTableSectionRole, .header)
    }
}

/// Groups the table's data rows.
public struct SCTableBody<Content: View>: View {
    var content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: 0) {
            content
        }
        .environment(\.scTableSectionRole, .body)
    }
}

/// Groups summary rows and applies the muted footer treatment.
public struct SCTableFooter<Content: View>: View {
    @Environment(\.theme) private var theme

    var content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        VStack(spacing: 0) {
            content
        }
        .fontWeight(.medium)
        .background(theme.muted.opacity(0.5))
        .overlay(alignment: .top) {
            Rectangle()
                .fill(theme.border)
                .frame(height: 1)
        }
        .environment(\.scTableSectionRole, .footer)
    }
}

/// A composable table row. Supply `onActivate` for an actionable row; rich
/// controls inside cells remain independently interactive.
public struct SCTableRow<Content: View>: View {
    @Environment(\.theme) private var theme
    @Environment(\.scTableSectionRole) private var sectionRole

    var isSelected: Bool
    var isExpanded: Bool
    var onActivate: (() -> Void)?
    var content: Content

    @State private var isHovered = false

    public init(
        isSelected: Bool = false,
        isExpanded: Bool = false,
        onActivate: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.isSelected = isSelected
        self.isExpanded = isExpanded
        self.onActivate = onActivate
        self.content = content()
    }

    @ViewBuilder
    public var body: some View {
        if let onActivate {
            row
                .onTapGesture(perform: onActivate)
                .accessibilityAction(named: "Activate row", onActivate)
        } else {
            row
        }
    }

    private var row: some View {
        HStack(spacing: 0) {
            content
        }
        .background(background)
        .contentShape(Rectangle())
        .overlay(alignment: .bottom) {
            if sectionRole != .footer {
                Rectangle()
                    .fill(theme.border)
                    .frame(height: 1)
            }
        }
        .onHover { isHovered = $0 }
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var background: Color {
        if sectionRole == .footer {
            return .clear
        }
        if isSelected || isExpanded || (isHovered && onActivate != nil) {
            return theme.muted.opacity(0.5)
        }
        return .clear
    }
}

/// A header cell with the official muted, medium-weight treatment.
public struct SCTableHead<Content: View>: View {
    @Environment(\.theme) private var theme

    var width: SCTableColumnWidth
    var alignment: HorizontalAlignment
    var content: Content

    public init(
        width: SCTableColumnWidth = .flexible,
        alignment: HorizontalAlignment = .leading,
        @ViewBuilder content: () -> Content
    ) {
        self.width = width
        self.alignment = alignment
        self.content = content()
    }

    public var body: some View {
        content
            .font(.caption.weight(.medium))
            .foregroundStyle(theme.mutedForeground)
            .lineLimit(1)
            .padding(.horizontal, 8)
            .frame(minHeight: 40)
            .columnFrame(width, alignment: alignment)
            .accessibilityAddTraits(.isHeader)
    }
}

/// A data or footer cell. Arbitrary SwiftUI content, including controls and
/// menus, can be supplied by the caller.
public struct SCTableCell<Content: View>: View {
    @Environment(\.theme) private var theme

    var width: SCTableColumnWidth
    var alignment: HorizontalAlignment
    var content: Content

    public init(
        width: SCTableColumnWidth = .flexible,
        alignment: HorizontalAlignment = .leading,
        @ViewBuilder content: () -> Content
    ) {
        self.width = width
        self.alignment = alignment
        self.content = content()
    }

    public var body: some View {
        content
            .font(.footnote)
            .foregroundStyle(theme.foreground)
            .padding(.horizontal, 8)
            .frame(minHeight: 48)
            .columnFrame(width, alignment: alignment)
    }
}

/// The table caption. Pass this through `SCTableRoot`'s `caption` builder.
public struct SCTableCaption<Content: View>: View {
    @Environment(\.theme) private var theme

    var content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .font(.caption)
            .foregroundStyle(theme.mutedForeground)
            .frame(maxWidth: .infinity)
            .multilineTextAlignment(.center)
    }
}

// MARK: - Typed convenience

/// A themed data table — the swiftcn port of shadcn/ui's Table. Built as a
/// custom grid rather than SwiftUI's `Table` (which is iPad/Mac-only and not
/// themeable): a muted header row, hairline row separators, and hover/press
/// feedback.
///
/// Pass a `selection` binding to get a leading checkbox column with a
/// select-all header. Checkbox-only selection is the default so interactive
/// cell content remains independent; opt into row selection explicitly.
/// Columns with a `comparator` are sortable from the header, with either
/// internal state or a caller-owned `SCTableSort` binding.
///
/// Layout: the table always sits inside a horizontal `ScrollView` whose
/// content is pinned — via `containerRelativeFrame` — to at least the sum of
/// `.fixed`/`.min` column widths (flexible columns count a 60pt floor). It
/// therefore fills the full available width when it fits and scrolls
/// sideways only when it can't.
///
///     SCTable(
///         rows: invoices,
///         columns: [
///             SCTableColumn("Invoice") { $0.id },
///             SCTableColumn("Status") { $0.status },
///             SCTableColumn("Amount", alignment: .trailing,
///                           comparator: { $0.amount < $1.amount },
///                           value: { $0.amount.formatted(.currency(code: "USD")) })
///         ],
///         caption: "A list of your recent invoices."
///     )
public struct SCTable<Row: Identifiable>: View {
    @Environment(\.theme) private var theme

    var rows: [Row]
    var columns: [SCTableColumn<Row>]
    var selection: Binding<Set<Row.ID>>?
    var selectionBehavior: SCTableSelectionBehavior
    var externalSort: Binding<SCTableSort?>?
    var onRowTap: ((Row) -> Void)?
    var caption: String?

    @State private var internalSort: SCTableSort?
    @State private var hoveredID: Row.ID?

    private let selectionColumnWidth: CGFloat = 36

    /// - Parameters:
    ///   - rows: The data to display, one element per row.
    ///   - columns: The column definitions, in display order.
    ///   - selection: Optional binding of selected row IDs. When present, a
    ///     leading checkbox column (with select-all header) is shown and rows
    ///     become tappable.
    ///   - caption: Optional caption rendered under the table.
    public init(
        rows: [Row],
        columns: [SCTableColumn<Row>],
        selection: Binding<Set<Row.ID>>? = nil,
        selectionBehavior: SCTableSelectionBehavior = .checkboxOnly,
        sort: Binding<SCTableSort?>? = nil,
        onRowTap: ((Row) -> Void)? = nil,
        caption: String? = nil
    ) {
        self.rows = rows
        self.columns = columns
        self.selection = selection
        self.selectionBehavior = selectionBehavior
        self.externalSort = sort
        self.onRowTap = onRowTap
        self.caption = caption
    }

    public var body: some View {
        VStack(spacing: 12) {
            ScrollView(.horizontal) {
                table
                    .containerRelativeFrame(.horizontal, alignment: .leading) { length, _ in
                        max(length, minimumTableWidth)
                    }
            }
            .scrollIndicators(.hidden)
            if let caption {
                Text(caption)
                    .font(.caption)
                    .foregroundStyle(theme.mutedForeground)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            }
        }
    }

    private var table: some View {
        let displayed = displayedRows
        return VStack(spacing: 0) {
            headerRow
            hairline
            ForEach(Array(displayed.enumerated()), id: \.element.id) { index, row in
                bodyRow(row)
                if index < displayed.count - 1 {
                    hairline
                }
            }
        }
    }

    // MARK: Header

    private var headerRow: some View {
        HStack(spacing: 0) {
            if selection != nil {
                selectAllCell
            }
            ForEach(columns.indices, id: \.self) { index in
                headerCell(index)
            }
        }
        .frame(minHeight: 40)
    }

    private func headerCell(_ index: Int) -> some View {
        let column = columns[index]
        return Group {
            if column.comparator != nil, !column.usesCustomSortControl {
                Button {
                    toggleSort(index)
                } label: {
                    HStack(spacing: 4) {
                        column.header
                        sortIndicator(index)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(column.accessibilityLabel)
                .accessibilityValue(sortDescription(index))
                .accessibilityHint("Sorts the table by this column")
            } else {
                column.header
            }
        }
        .font(.caption.weight(.medium))
        .foregroundStyle(theme.mutedForeground)
        .lineLimit(1)
        .padding(.horizontal, 8)
        .columnFrame(column.width, alignment: column.alignment)
    }

    @ViewBuilder
    private func sortIndicator(_ index: Int) -> some View {
        if let sort = currentSort, sort.columnID == columns[index].id {
            Image(systemName: sort.order == .ascending ? "arrow.up" : "arrow.down")
                .font(.caption2.weight(.semibold))
        } else {
            Image(systemName: "arrow.up.arrow.down")
                .font(.caption2.weight(.semibold))
                .opacity(0.5)
        }
    }

    private var selectAllCell: some View {
        Button {
            toggleSelectAll()
        } label: {
            checkbox(isOn: allRowsSelected, isMixed: someRowsSelected && !allRowsSelected)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .frame(width: selectionColumnWidth)
        .accessibilityLabel("Select all rows")
        .accessibilityValue(
            allRowsSelected ? "Selected" : someRowsSelected ? "Partially selected" : "Not selected"
        )
    }

    // MARK: Body rows

    @ViewBuilder
    private func bodyRow(_ row: Row) -> some View {
        let isSelected = isSelected(row.id)
        let isHovered = hoveredID == row.id
        let background = isSelected ? theme.muted : isHovered ? theme.muted.opacity(0.5) : .clear
        if selectionBehavior == .row || onRowTap != nil {
            rowCells(row, isSelected: isSelected)
                .background(background)
                .contentShape(Rectangle())
                .onTapGesture { rowTapped(row) }
                .onHover { updateHover($0, id: row.id) }
                .accessibilityAddTraits(isSelected ? .isSelected : [])
                .accessibilityAction(named: "Activate row") { rowTapped(row) }
        } else {
            rowCells(row, isSelected: isSelected)
                .background(background)
                .onHover { updateHover($0, id: row.id) }
                .accessibilityAddTraits(isSelected ? .isSelected : [])
        }
    }

    private func rowCells(_ row: Row, isSelected: Bool) -> some View {
        HStack(spacing: 0) {
            if selection != nil {
                Button {
                    toggleSelection(row.id)
                } label: {
                    checkbox(isOn: isSelected)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .frame(width: selectionColumnWidth)
                .accessibilityLabel(isSelected ? "Deselect row" : "Select row")
            }
            ForEach(columns.indices, id: \.self) { index in
                let column = columns[index]
                column.cell(row)
                    .font(.footnote)
                    .foregroundStyle(theme.foreground)
                    .padding(.horizontal, 8)
                    .columnFrame(column.width, alignment: column.alignment)
            }
        }
        .frame(minHeight: 48)
        .contentShape(Rectangle())
    }

    private var hairline: some View {
        Rectangle()
            .fill(theme.border)
            .frame(height: 1)
    }

    // MARK: Checkbox visual

    /// A 16pt check box drawn locally (same visual language as `SCCheckboxStyle`,
    /// but the table row — not the box — is the tap target).
    private func checkbox(isOn: Bool, isMixed: Bool = false) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .fill(isOn || isMixed ? theme.primary : theme.background)
            RoundedRectangle(cornerRadius: 4, style: .continuous)
                .strokeBorder(theme.input, lineWidth: 1)
                .opacity(isOn || isMixed ? 0 : 1)
            if isOn || isMixed {
                Image(systemName: isMixed ? "minus" : "checkmark")
                    .font(.caption2.weight(.bold))
                    .imageScale(.small)
                    .foregroundStyle(theme.primaryForeground)
            }
        }
        .frame(width: 16, height: 16)
    }

    // MARK: Sorting

    private var displayedRows: [Row] {
        guard
            let sort = currentSort,
            let column = columns.first(where: { $0.id == sort.columnID }),
            let comparator = column.comparator
        else { return rows }
        let ascending = rows.sorted(by: comparator)
        return sort.order == .ascending ? ascending : Array(ascending.reversed())
    }

    private func toggleSort(_ index: Int) {
        let columnID = columns[index].id
        if let current = currentSort, current.columnID == columnID {
            setSort(current.order == .ascending ? SCTableSort(columnID: columnID, order: .descending) : nil)
        } else {
            setSort(SCTableSort(columnID: columnID, order: .ascending))
        }
    }

    private func sortDescription(_ index: Int) -> String {
        guard let sort = currentSort, sort.columnID == columns[index].id else { return "Not sorted" }
        return sort.order == .ascending ? "Sorted ascending" : "Sorted descending"
    }

    private var currentSort: SCTableSort? {
        externalSort?.wrappedValue ?? internalSort
    }

    private func setSort(_ sort: SCTableSort?) {
        if let externalSort {
            externalSort.wrappedValue = sort
        } else {
            internalSort = sort
        }
    }

    // MARK: Selection

    private func isSelected(_ id: Row.ID) -> Bool {
        selection?.wrappedValue.contains(id) ?? false
    }

    private func toggleSelection(_ id: Row.ID) {
        guard let selection else { return }
        if selection.wrappedValue.contains(id) {
            selection.wrappedValue.remove(id)
        } else {
            selection.wrappedValue.insert(id)
        }
    }

    private func rowTapped(_ row: Row) {
        if selectionBehavior == .row {
            toggleSelection(row.id)
        }
        onRowTap?(row)
    }

    private var allRowsSelected: Bool {
        guard let selection, !rows.isEmpty else { return false }
        return rows.allSatisfy { selection.wrappedValue.contains($0.id) }
    }

    private var someRowsSelected: Bool {
        guard let selection else { return false }
        return rows.contains { selection.wrappedValue.contains($0.id) }
    }

    private func toggleSelectAll() {
        guard let selection else { return }
        selection.wrappedValue = allRowsSelected ? [] : Set(rows.map(\.id))
    }

    private func updateHover(_ hovering: Bool, id: Row.ID) {
        if hovering {
            hoveredID = id
        } else if hoveredID == id {
            hoveredID = nil
        }
    }

    // MARK: Layout

    /// The narrowest width the table content may be laid out at: the sum of
    /// `.fixed` and `.min` column widths, a 60pt floor per flexible column,
    /// and the checkbox column when selection is enabled.
    private var minimumTableWidth: CGFloat {
        var total: CGFloat = selection != nil ? selectionColumnWidth : 0
        for column in columns {
            switch column.width {
            case .flexible: total += 60
            case .fixed(let width): total += width
            case .min(let width): total += width
            }
        }
        return total
    }
}

extension View {
    /// Applies an `SCTableColumnWidth` as a frame: `.flexible` shares the
    /// remaining width, `.fixed` is exact, `.min` grows from a floor.
    @ViewBuilder
    fileprivate func columnFrame(_ width: SCTableColumnWidth, alignment: HorizontalAlignment) -> some View {
        let alignment = Alignment(horizontal: alignment, vertical: .center)
        switch width {
        case .flexible:
            frame(maxWidth: .infinity, alignment: alignment)
        case .fixed(let width):
            frame(width: width, alignment: alignment)
        case .min(let width):
            frame(minWidth: width, maxWidth: .infinity, alignment: alignment)
        }
    }
}

// MARK: - Previews

private struct PreviewInvoice: Identifiable {
    let id: String
    let status: String
    let method: String
    let amount: Double
}

private let previewInvoices: [PreviewInvoice] = [
    PreviewInvoice(id: "INV001", status: "Paid", method: "Credit Card", amount: 250),
    PreviewInvoice(id: "INV002", status: "Pending", method: "PayPal", amount: 150),
    PreviewInvoice(id: "INV003", status: "Unpaid", method: "Bank Transfer", amount: 350),
    PreviewInvoice(id: "INV004", status: "Paid", method: "Credit Card", amount: 450),
    PreviewInvoice(id: "INV005", status: "Paid", method: "PayPal", amount: 550),
]

private var previewColumns: [SCTableColumn<PreviewInvoice>] {
    [
        SCTableColumn("Invoice", width: .min(80)) { $0.id },
        SCTableColumn("Status") { $0.status },
        SCTableColumn("Method") { $0.method },
        SCTableColumn(
            "Amount",
            alignment: .trailing,
            comparator: { $0.amount < $1.amount },
            value: { $0.amount.formatted(.currency(code: "USD").precision(.fractionLength(2))) }
        ),
    ]
}

#Preview("Table") {
    SCPreview {
        SCTable(
            rows: previewInvoices,
            columns: previewColumns,
            caption: "A list of your recent invoices."
        )
    }
}

#Preview("Table · primitive composition") {
    SCPreview {
        SCTableRoot(minimumWidth: 420) {
            SCTableHeader {
                SCTableRow {
                    SCTableHead(width: .fixed(90)) { Text("Invoice") }
                    SCTableHead { Text("Status") }
                    SCTableHead { Text("Method") }
                    SCTableHead(alignment: .trailing) { Text("Amount") }
                }
            }
            SCTableBody {
                ForEach(previewInvoices) { invoice in
                    SCTableRow {
                        SCTableCell(width: .fixed(90)) { Text(invoice.id).fontWeight(.medium) }
                        SCTableCell { Text(invoice.status) }
                        SCTableCell { Text(invoice.method) }
                        SCTableCell(alignment: .trailing) {
                            Text(invoice.amount.formatted(.currency(code: "USD")))
                        }
                    }
                }
            }
        } caption: {
            SCTableCaption { Text("A list of your recent invoices.") }
        }
    }
}

#Preview("Table · selection") {
    @Previewable @State var selection: Set<String> = ["INV002"]
    SCPreview {
        SCTable(
            rows: previewInvoices,
            columns: previewColumns,
            selection: $selection
        )
    }
}
