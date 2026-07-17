import SwiftUI
import Swiftcn

/// A real `SCDataTableController` driving search, sort, checkbox/select-all,
/// hideable columns, custom row-action menus, pagination, and page-size
/// controls, plus a disabled instance, so UI tests can prove the reusable
/// data-table composition genuinely routes into caller-owned Observable
/// state rather than only rendering it.
struct DataTableValidationScene: View {
    @State private var controller = SCDataTableController<Payment>(pageSize: 3)
    @State private var disabledController = SCDataTableController<Payment>(pageSize: 3)
    @State private var lastCopiedEmail = "none"
    @State private var copyCount = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Compact echo block: the two stacked tables only fit the window
            // (XCUITest cannot click below it) with the echoes tight.
            VStack(alignment: .leading, spacing: 4) {
                echoes
            }

            SCDataTable(
                rows: Self.payments,
                columns: columns,
                controller: controller,
                caption: "Recent payments."
            ) {
                Text("No results.")
                    .accessibilityIdentifier("datatable-empty")
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("datatable-primary")

            SCDataTable(
                rows: Self.payments,
                columns: columns,
                controller: disabledController,
                showsPagination: false
            )
            .disabled(true)
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("datatable-disabled")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    @ViewBuilder
    private var echoes: some View {
        Text("Query: \(controller.query)")
            .accessibilityIdentifier("datatable-query-echo")
        Text("Sort: \(sortDescription)")
            .accessibilityIdentifier("datatable-sort-echo")
        Text("Selected: \(controller.selectedRowIDs.sorted().joined(separator: ", "))")
            .accessibilityIdentifier("datatable-selection-echo")
        Text("Hidden columns: \(controller.hiddenColumnIDs.sorted().joined(separator: ", "))")
            .accessibilityIdentifier("datatable-hidden-columns-echo")
        Text("Page index: \(controller.pageIndex)")
            .accessibilityIdentifier("datatable-pageindex-echo")
        Text("Page size: \(controller.pageSize)")
            .accessibilityIdentifier("datatable-pagesize-echo")
        Text("Last copied: \(lastCopiedEmail)")
            .accessibilityIdentifier("datatable-copy-last-echo")
        Text("Copy activations: \(copyCount)")
            .accessibilityIdentifier("datatable-copy-count-echo")
    }

    private var sortDescription: String {
        guard let sort = controller.sort else { return "none" }
        return "\(sort.columnID) \(sort.order == .ascending ? "ascending" : "descending")"
    }

    private var columns: [SCTableColumn<Payment>] {
        [
            SCTableColumn("Status", width: .min(90)) { $0.status },
            SCTableColumn(
                "Email",
                comparator: { $0.email < $1.email },
                value: { $0.email }
            ),
            SCTableColumn(
                "Amount",
                alignment: .trailing,
                comparator: { $0.amount < $1.amount },
                value: { $0.amount.formatted(.currency(code: "USD").precision(.fractionLength(2))) }
            ),
            SCTableColumn(
                "Actions",
                width: .fixed(90),
                isHideable: false,
                searchValue: nil
            ) { row in
                Menu {
                    Button("Copy payment ID") {
                        lastCopiedEmail = row.email
                        copyCount += 1
                    }
                    Button("View details") {}
                } label: {
                    Image(systemName: "ellipsis")
                }
                .menuStyle(.borderlessButton)
                .accessibilityLabel("Row actions for \(row.email)")
            },
        ]
    }

    struct Payment: Identifiable {
        let id: String
        let status: String
        let email: String
        let amount: Double
    }

    /// Six deterministic rows across exactly two pages of three (`pageSize:
    /// 3`) so pagination, cross-page selection, and sort reordering are all
    /// exercised without any random or clock-dependent data.
    private static let payments: [Payment] = [
        Payment(id: "1", status: "Success", email: "ken99@example.com", amount: 316),
        Payment(id: "2", status: "Success", email: "abe45@example.com", amount: 242),
        Payment(id: "3", status: "Processing", email: "monserrat44@example.com", amount: 837),
        Payment(id: "4", status: "Failed", email: "carmella@example.com", amount: 721),
        Payment(id: "5", status: "Success", email: "diego22@example.com", amount: 145),
        Payment(id: "6", status: "Processing", email: "brandt91@example.com", amount: 500),
    ]
}
