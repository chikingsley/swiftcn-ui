import XCTest

final class TableValidationTests: ValidationCase {
    func testTypedTableRendersEveryColumnAndRow() {
        let app = launchHost(scene: "table")
        let table = app.descendants(matching: .any)["table-typed"]
        XCTAssertTrue(table.waitForExistence(timeout: 5))

        for id in ["INV001", "INV002", "INV003"] {
            XCTAssertEqual(
                table.staticTexts.matching(NSPredicate(format: "value == %@", id)).count,
                1,
                "\(id) row is missing"
            )
        }
        XCTAssertTrue(table.staticTexts["Invoice"].exists)
        XCTAssertTrue(table.staticTexts["Status"].exists)
        XCTAssertTrue(table.staticTexts["Method"].exists)
        XCTAssertTrue(table.buttons["Amount"].exists, "sortable Amount header must render as a button")
        XCTAssertTrue(
            table.staticTexts.matching(NSPredicate(format: "value == 'A list of your recent invoices.'"))
                .firstMatch.exists
        )
        attachWindowScreenshot(of: app, named: "table-light")
    }

    func testColumnHeaderClickCyclesSortAndReordersRows() {
        let app = launchHost(scene: "table")
        let table = app.descendants(matching: .any)["table-typed"]
        let amountHeader = table.buttons["Amount"]
        XCTAssertTrue(amountHeader.waitForExistence(timeout: 5))
        XCTAssertEqual(amountHeader.value as? String, "Not sorted")
        XCTAssertEqual(text(of: app.staticTexts["table-sort-echo"]), "Sort: none")

        amountHeader.click()
        XCTAssertEqual(amountHeader.value as? String, "Sorted ascending")
        XCTAssertEqual(text(of: app.staticTexts["table-sort-echo"]), "Sort: Amount ascending")
        assertRowOrder(["INV002", "INV001", "INV003"], in: table)

        amountHeader.click()
        XCTAssertEqual(amountHeader.value as? String, "Sorted descending")
        XCTAssertEqual(text(of: app.staticTexts["table-sort-echo"]), "Sort: Amount descending")
        assertRowOrder(["INV003", "INV001", "INV002"], in: table)

        amountHeader.click()
        XCTAssertEqual(amountHeader.value as? String, "Not sorted")
        XCTAssertEqual(text(of: app.staticTexts["table-sort-echo"]), "Sort: none")
        assertRowOrder(["INV001", "INV002", "INV003"], in: table)
    }

    func testCheckboxSelectionAndSelectAllRouteIntoCallerOwnedBinding() {
        let app = launchHost(scene: "table")
        let table = app.descendants(matching: .any)["table-typed"]
        let selectAll = table.buttons["Select all rows"]
        XCTAssertTrue(selectAll.waitForExistence(timeout: 5))
        XCTAssertEqual(selectAll.value as? String, "Not selected")

        selectAll.click()
        XCTAssertEqual(selectAll.value as? String, "Selected")
        XCTAssertEqual(
            text(of: app.staticTexts["table-selection-echo"]),
            "Selected: INV001, INV002, INV003"
        )

        // Every row now reads "Deselect row"; the first in document order is INV001.
        table.buttons.matching(NSPredicate(format: "label == 'Deselect row'")).element(boundBy: 0).click()
        XCTAssertEqual(text(of: app.staticTexts["table-selection-echo"]), "Selected: INV002, INV003")
        XCTAssertEqual(selectAll.value as? String, "Partially selected")
    }

    func testRowTapWithRowSelectionBehaviorRoutesBothSelectionAndCallback() {
        let app = launchHost(scene: "tablerowtap")
        let table = app.descendants(matching: .any)["table-row-tap"]
        let methodCell = table.staticTexts.matching(NSPredicate(format: "value == 'PayPal'")).firstMatch
        XCTAssertTrue(methodCell.waitForExistence(timeout: 5))

        methodCell.click()
        XCTAssertEqual(text(of: app.staticTexts["table-last-tapped-echo"]), "Last tapped: INV002")
        XCTAssertEqual(text(of: app.staticTexts["table-row-tap-count"]), "Row-tap activations: 1")
        XCTAssertEqual(text(of: app.staticTexts["table-row-tap-selection-echo"]), "Row-tap selected: INV002")

        methodCell.click()
        XCTAssertEqual(text(of: app.staticTexts["table-row-tap-count"]), "Row-tap activations: 2")
        XCTAssertEqual(text(of: app.staticTexts["table-row-tap-selection-echo"]), "Row-tap selected: ")
    }

    func testDisabledTableDisablesItsControls() {
        let app = launchHost(scene: "table")
        let table = app.descendants(matching: .any)["table-disabled"]
        XCTAssertTrue(table.waitForExistence(timeout: 5))
        XCTAssertFalse(table.buttons["Select all rows"].isEnabled)
        XCTAssertFalse(table.buttons["Amount"].isEnabled)
    }

    func testPrimitiveCompositionRendersAndRoutesRowActivation() {
        let app = launchHost(scene: "tableprimitive")
        let primitive = app.descendants(matching: .any)["table-primitive"]
        XCTAssertTrue(primitive.waitForExistence(timeout: 5))
        XCTAssertTrue(primitive.staticTexts["Invoice"].exists)
        XCTAssertTrue(primitive.staticTexts["Status"].exists)
        XCTAssertEqual(
            text(of: app.descendants(matching: .any)["table-primitive-caption"]),
            "Primitive composition."
        )
        XCTAssertTrue(
            primitive.staticTexts.matching(NSPredicate(format: "value == '3 invoices'")).firstMatch.exists,
            "footer row must render"
        )

        let row = app.descendants(matching: .any)["table-primitive-row-INV002"]
        XCTAssertTrue(row.exists)
        row.click()
        XCTAssertEqual(text(of: app.staticTexts["table-primitive-activated-echo"]), "Primitive activated: INV002")
        XCTAssertEqual(text(of: app.staticTexts["table-primitive-activation-count"]), "Primitive activations: 1")
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "table", appearance: "dark")
        XCTAssertTrue(app.descendants(matching: .any)["table-typed"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "table-dark")
    }

    // The sampler flags the 13px muted header and caption texts:
    // mutedForeground on the table surface computes to 7.72:1 (light) —
    // clearing WCAG AA text (4.5:1). Identifier-less, so matched by "".
    private var mutedTextContrastFindings: [KnownAuditFinding] {
        [KnownAuditFinding(descriptionContains: "Contrast", identifier: "")]
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "table", appearance: "light")
        XCTAssertTrue(app.descendants(matching: .any)["table-typed"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app, tolerating: mutedTextContrastFindings)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "table", appearance: "dark")
        XCTAssertTrue(app.descendants(matching: .any)["table-typed"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app, tolerating: mutedTextContrastFindings)
    }

    /// Reads each id's row cell vertical position to prove the table actually
    /// re-laid out rows in the given order, not just that internal sort state
    /// changed.
    private func assertRowOrder(
        _ ids: [String],
        in table: XCUIElement,
        file: StaticString = #filePath,
        line: UInt = #line
    ) {
        let positions = ids.map { id in
            table.staticTexts.matching(NSPredicate(format: "value == %@", id)).firstMatch.frame.minY
        }
        XCTAssertEqual(
            positions, positions.sorted(), "rows are not laid out in order \(ids)", file: file, line: line
        )
    }
}
