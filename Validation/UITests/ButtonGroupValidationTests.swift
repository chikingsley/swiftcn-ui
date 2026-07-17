import XCTest

final class ButtonGroupValidationTests: ValidationCase {
    func testEditingActionsGroupRendersAndRoutesRealActions() {
        let app = launchHost(scene: "buttongroup")
        let count = app.staticTexts["buttongroup-edit-action-count"]
        XCTAssertTrue(count.waitForExistence(timeout: 5))

        app.buttons["buttongroup-copy"].click()
        XCTAssertEqual(text(of: app.staticTexts["buttongroup-last-edit-action"]), "Last edit action: Copy")
        app.buttons["buttongroup-paste"].click()
        XCTAssertEqual(text(of: app.staticTexts["buttongroup-last-edit-action"]), "Last edit action: Paste")
        XCTAssertEqual(text(of: count), "Edit actions: 2")

        let disabled = app.buttons["buttongroup-archive-disabled"]
        XCTAssertTrue(disabled.exists)
        XCTAssertFalse(disabled.isEnabled)
    }

    func testGroupExposesItsAccessibilityLabel() {
        let app = launchHost(scene: "buttongroup")
        let group = app.groups["buttongroup-edit-actions"]
        XCTAssertTrue(group.waitForExistence(timeout: 5))
        XCTAssertEqual(group.label, "Editing actions")
        XCTAssertEqual(app.groups["buttongroup-vertical"].label, "Counter")
    }

    func testMixedContentGroupRoutesTypedTextSelectionAndButtonIntoCallerState() {
        let app = launchHost(scene: "buttongroup")
        let input = app.textFields["buttongroup-input"]
        XCTAssertTrue(input.waitForExistence(timeout: 5))
        input.click()
        input.typeText("512")

        let select = app.popUpButtons["buttongroup-select"]
        XCTAssertTrue(select.exists, "native select addon is missing")
        select.click()
        app.menuItems["percent"].click()
        XCTAssertEqual(text(of: app.staticTexts["buttongroup-unit-echo"]), "Unit: percent")

        app.buttons["buttongroup-apply"].click()
        XCTAssertEqual(
            text(of: app.staticTexts["buttongroup-applied-size"]),
            "Applied size: 512 percent",
            "Apply must read the input group's real, currently-selected values"
        )
    }

    func testVerticalGroupRoutesIncrementAndDecrement() {
        let app = launchHost(scene: "buttongroup")
        let counter = app.staticTexts["buttongroup-counter"]
        XCTAssertTrue(counter.waitForExistence(timeout: 5))

        app.buttons["buttongroup-vertical-increment"].click()
        app.buttons["buttongroup-vertical-increment"].click()
        XCTAssertEqual(text(of: counter), "Counter: 2")
        app.buttons["buttongroup-vertical-decrement"].click()
        XCTAssertEqual(text(of: counter), "Counter: 1")
    }

    func testArrayConvenienceGroupRendersRealButtonsAndRoutesActions() {
        let app = launchHost(scene: "buttongroup")
        let group = app.groups["buttongroup-array"]
        XCTAssertTrue(group.waitForExistence(timeout: 5))

        // SCButtonGroupItem's array convenience API renders real native
        // buttons in declaration order but has no per-item
        // accessibilityIdentifier hook, so positional lookup within the
        // group is the strongest available handle (minus, then plus).
        let buttons = group.buttons
        XCTAssertEqual(buttons.count, 2)
        buttons.element(boundBy: 1).click()
        XCTAssertEqual(text(of: app.staticTexts["buttongroup-array-counter"]), "Array counter: 1")
        buttons.element(boundBy: 0).click()
        XCTAssertEqual(text(of: app.staticTexts["buttongroup-array-counter"]), "Array counter: 0")
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "buttongroup", appearance: "dark")
        XCTAssertTrue(app.buttons["buttongroup-copy"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "buttongroup-dark")
    }

    func testLightAppearanceRenders() {
        let app = launchHost(scene: "buttongroup", appearance: "light")
        XCTAssertTrue(app.buttons["buttongroup-copy"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "buttongroup-light")
    }

    // The group's embedded select renders through `Picker(.menu)`, which
    // surfaces as an AXPopUpButton whose activation is menu-open; Apple's
    // `.action` audit flags it as missing a click action even though the
    // Select/NativeSelect suites prove the identical control clickable.
    // Framework false positive; every other dimension still runs.
    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "buttongroup", appearance: "light")
        XCTAssertTrue(app.buttons["buttongroup-copy"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app, excluding: .action)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "buttongroup", appearance: "dark")
        XCTAssertTrue(app.buttons["buttongroup-copy"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app, excluding: .action)
    }
}
