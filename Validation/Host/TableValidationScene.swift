import SwiftUI
import Swiftcn

/// The typed `SCTable` convenience wired to caller-owned selection and sort
/// bindings (plus a combined row-tap/row-selection instance and a disabled
/// instance), and the primitive `SCTableRoot` composition wired to per-row
/// activation, so UI tests can prove real column sorting, checkbox and
/// row-tap selection, row activation, and disabled semantics through the
/// accessibility tree.
struct TableValidationScene: View {
    @State private var selection: Set<String> = []
    @State private var sort: SCTableSort?
    @State private var rowTapSelection: Set<String> = []
    @State private var lastTappedRowID = "none"
    @State private var rowTapCount = 0
    @State private var primitiveActivatedID = "none"
    @State private var primitiveActivationCount = 0

    enum Part {
        case typed
        case rowTap
        case primitive
    }

    let part: Part

    // A full SCTable with seven rows is ~260pt tall, so the instances are
    // split across three scene keys (`table`, `tablerowtap`,
    // `tableprimitive`) to keep every element inside the clickable window.
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            switch part {
            case .typed: typedPart
            case .rowTap: rowTapPart
            case .primitive: primitivePart
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    @ViewBuilder
    private var typedPart: some View {
        Text("Selected: \(selection.sorted().joined(separator: ", "))")
            .accessibilityIdentifier("table-selection-echo")
        Text("Sort: \(sortDescription)")
            .accessibilityIdentifier("table-sort-echo")

        SCTable(
            rows: TableValidationScene.invoices,
            columns: TableValidationScene.columns,
            selection: $selection,
            sort: $sort,
            caption: "A list of your recent invoices."
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("table-typed")

        SCTable(
            rows: TableValidationScene.invoices,
            columns: TableValidationScene.columns,
            selection: .constant([])
        )
        .disabled(true)
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("table-disabled")
    }

    @ViewBuilder
    private var rowTapPart: some View {
        Text("Row-tap selected: \(rowTapSelection.sorted().joined(separator: ", "))")
            .accessibilityIdentifier("table-row-tap-selection-echo")
        Text("Last tapped: \(lastTappedRowID)")
            .accessibilityIdentifier("table-last-tapped-echo")
        Text("Row-tap activations: \(rowTapCount)")
            .accessibilityIdentifier("table-row-tap-count")

        SCTable(
            rows: TableValidationScene.invoices,
            columns: TableValidationScene.columns,
            selection: $rowTapSelection,
            selectionBehavior: .row,
            onRowTap: { row in
                lastTappedRowID = row.id
                rowTapCount += 1
            }
        )
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("table-row-tap")
    }

    @ViewBuilder
    private var primitivePart: some View {
        Text("Primitive activated: \(primitiveActivatedID)")
            .accessibilityIdentifier("table-primitive-activated-echo")
        Text("Primitive activations: \(primitiveActivationCount)")
            .accessibilityIdentifier("table-primitive-activation-count")

        primitiveComposition
    }

    private var sortDescription: String {
        guard let sort else { return "none" }
        return "\(sort.columnID) \(sort.order == .ascending ? "ascending" : "descending")"
    }

    private var primitiveComposition: some View {
        SCTableRoot(minimumWidth: 320) {
            SCTableHeader {
                SCTableRow {
                    SCTableHead(width: .fixed(90)) { Text("Invoice") }
                    SCTableHead { Text("Status") }
                }
            }
            SCTableBody {
                ForEach(TableValidationScene.invoices) { invoice in
                    SCTableRow(onActivate: {
                        primitiveActivatedID = invoice.id
                        primitiveActivationCount += 1
                    }) {
                        SCTableCell(width: .fixed(90)) { Text(invoice.id) }
                        SCTableCell { Text(invoice.status) }
                    }
                    .accessibilityElement(children: .contain)
                    .accessibilityIdentifier("table-primitive-row-\(invoice.id)")
                }
            }
            SCTableFooter {
                SCTableRow {
                    SCTableCell(width: .fixed(90)) { Text("Total") }
                    SCTableCell { Text("\(TableValidationScene.invoices.count) invoices") }
                }
                .accessibilityIdentifier("table-primitive-footer-row")
            }
        } caption: {
            SCTableCaption { Text("Primitive composition.") }
                .accessibilityIdentifier("table-primitive-caption")
        }
        .accessibilityElement(children: .contain)
        .accessibilityIdentifier("table-primitive")
    }

    private struct Invoice: Identifiable {
        let id: String
        let status: String
        let method: String
        let amount: Double
    }

    private static let invoices: [Invoice] = [
        Invoice(id: "INV001", status: "Paid", method: "Credit Card", amount: 250),
        Invoice(id: "INV002", status: "Pending", method: "PayPal", amount: 150),
        Invoice(id: "INV003", status: "Unpaid", method: "Bank Transfer", amount: 350),
    ]

    private static let columns: [SCTableColumn<Invoice>] = [
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
