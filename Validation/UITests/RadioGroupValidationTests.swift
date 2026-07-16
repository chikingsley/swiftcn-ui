import XCTest

final class RadioGroupValidationTests: ValidationCase {
    private let itemIdentifiers = [
        "radiogroup-vertical-comfortable", "radiogroup-vertical-compact",
        "radiogroup-item-disabled", "radiogroup-item-readonly", "radiogroup-item-invalid",
        "radiogroup-horizontal-compact", "radiogroup-grid-comfortable",
        "radiogroup-grid-spacious", "radiogroup-root-disabled-item",
    ]

    func testEveryLayoutAndStateRenders() {
        let app = launchHost(scene: "radiogroup")
        XCTAssertTrue(app.buttons["radiogroup-vertical-comfortable"].waitForExistence(timeout: 5))

        for identifier in itemIdentifiers {
            XCTAssertTrue(app.buttons[identifier].exists, "\(identifier) is missing")
        }
        XCTAssertEqual(app.buttons["radiogroup-horizontal-compact"].value as? String, "Selected")
        attachWindowScreenshot(of: app, named: "radiogroup-light")
    }

    func testTypedSelectionRoutesIntoCallerOwnedBinding() {
        let app = launchHost(scene: "radiogroup")
        let compact = app.buttons["radiogroup-vertical-compact"]
        XCTAssertTrue(compact.waitForExistence(timeout: 5))
        compact.click()
        XCTAssertEqual(text(of: app.staticTexts["radiogroup-vertical-echo"]), "Vertical: compact")
        XCTAssertEqual(compact.value as? String, "Selected")
    }

    func testReadOnlyItemDoesNotMutateSelection() {
        let app = launchHost(scene: "radiogroup")
        let item = app.buttons["radiogroup-grid-comfortable"]
        XCTAssertTrue(item.waitForExistence(timeout: 5))
        item.click()
        XCTAssertEqual(text(of: app.staticTexts["radiogroup-grid-echo"]), "Grid: spacious")
    }

    func testPerItemAndRootDisabledStatesAreExposed() {
        let app = launchHost(scene: "radiogroup")
        let itemDisabled = app.buttons["radiogroup-item-disabled"]
        let rootDisabled = app.buttons["radiogroup-root-disabled-item"]
        XCTAssertTrue(itemDisabled.waitForExistence(timeout: 5))
        XCTAssertFalse(itemDisabled.isEnabled)
        XCTAssertFalse(rootDisabled.isEnabled)
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "radiogroup", appearance: "dark")
        XCTAssertTrue(app.buttons["radiogroup-vertical-comfortable"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "radiogroup-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "radiogroup", appearance: "light")
        XCTAssertTrue(app.buttons["radiogroup-vertical-comfortable"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "radiogroup", appearance: "dark")
        XCTAssertTrue(app.buttons["radiogroup-vertical-comfortable"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }
}
