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

/// Describes one column of an `SCTable`: its header title, sizing, alignment,
/// optional sort comparator, and how to derive the cell text from a row.
///
///     SCTableColumn("Amount", alignment: .trailing,
///                   comparator: { $0.amount < $1.amount },
///                   value: { $0.amount.formatted(.currency(code: "USD")) })
public struct SCTableColumn<Row> {
    var title: String
    var width: SCTableColumnWidth
    var alignment: HorizontalAlignment
    var comparator: ((Row, Row) -> Bool)?
    var value: (Row) -> String

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
        width: SCTableColumnWidth = .flexible,
        alignment: HorizontalAlignment = .leading,
        comparator: ((Row, Row) -> Bool)? = nil,
        value: @escaping (Row) -> String
    ) {
        self.title = title
        self.width = width
        self.alignment = alignment
        self.comparator = comparator
        self.value = value
    }
}

// MARK: - Component

/// A themed data table — the swiftcn port of shadcn/ui's Table. Built as a
/// custom grid rather than SwiftUI's `Table` (which is iPad/Mac-only and not
/// themeable): a muted header row, hairline row separators, and hover/press
/// feedback.
///
/// Pass a `selection` binding to get a leading checkbox column with a
/// select-all header; tapping a row then toggles its selection. Columns with
/// a `comparator` are sortable from the header (sort state is internal).
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
    var caption: String?

    @State private var sort: (column: Int, ascending: Bool)?
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
        caption: String? = nil
    ) {
        self.rows = rows
        self.columns = columns
        self.selection = selection
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
            if column.comparator != nil {
                Button {
                    toggleSort(index)
                } label: {
                    HStack(spacing: 4) {
                        Text(column.title)
                        sortIndicator(index)
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityLabel(column.title)
                .accessibilityValue(sortDescription(index))
                .accessibilityHint("Sorts the table by this column")
            } else {
                Text(column.title)
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
        if let sort, sort.column == index {
            Image(systemName: sort.ascending ? "arrow.up" : "arrow.down")
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
        if selection != nil {
            Button {
                toggleSelection(row.id)
            } label: {
                rowCells(row, isSelected: isSelected)
            }
            .buttonStyle(SCTableRowButtonStyle(
                background: isSelected ? theme.muted : isHovered ? theme.muted.opacity(0.5) : .clear,
                pressed: theme.muted.opacity(isSelected ? 1 : 0.5)
            ))
            .onHover { updateHover($0, id: row.id) }
            .accessibilityAddTraits(isSelected ? .isSelected : [])
        } else {
            rowCells(row, isSelected: false)
                .background(isHovered ? theme.muted.opacity(0.5) : .clear)
                .onHover { updateHover($0, id: row.id) }
                .accessibilityElement(children: .combine)
        }
    }

    private func rowCells(_ row: Row, isSelected: Bool) -> some View {
        HStack(spacing: 0) {
            if selection != nil {
                checkbox(isOn: isSelected)
                    .frame(width: selectionColumnWidth)
            }
            ForEach(columns.indices, id: \.self) { index in
                let column = columns[index]
                Text(column.value(row))
                    .font(.footnote)
                    .foregroundStyle(theme.foreground)
                    .lineLimit(1)
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
        guard let sort, sort.column < columns.count,
              let comparator = columns[sort.column].comparator else { return rows }
        let ascending = rows.sorted(by: comparator)
        return sort.ascending ? ascending : Array(ascending.reversed())
    }

    private func toggleSort(_ index: Int) {
        if let current = sort, current.column == index {
            sort = current.ascending ? (column: index, ascending: false) : nil
        } else {
            sort = (column: index, ascending: true)
        }
    }

    private func sortDescription(_ index: Int) -> String {
        guard let sort, sort.column == index else { return "Not sorted" }
        return sort.ascending ? "Sorted ascending" : "Sorted descending"
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
            case .flexible:          total += 60
            case .fixed(let width):  total += width
            case .min(let width):    total += width
            }
        }
        return total
    }
}

// MARK: - Style

/// Press feedback for selectable table rows: swaps the row background while
/// pressed, no other chrome.
private struct SCTableRowButtonStyle: ButtonStyle {
    var background: Color
    var pressed: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? pressed : background)
    }
}

private extension View {
    /// Applies an `SCTableColumnWidth` as a frame: `.flexible` shares the
    /// remaining width, `.fixed` is exact, `.min` grows from a floor.
    @ViewBuilder
    func columnFrame(_ width: SCTableColumnWidth, alignment: HorizontalAlignment) -> some View {
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
