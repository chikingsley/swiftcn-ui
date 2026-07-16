import XCTest

final class CheckboxValidationTests: ValidationCase {
    func testMixedStateResolvesToCheckedThenTogglesNormally() {
        let app = launchHost(scene: "checkbox")
        let mixed = app.checkBoxes["checkbox-mixed"]
        XCTAssertTrue(mixed.waitForExistence(timeout: 5))
        XCTAssertEqual(text(of: app.staticTexts["checkbox-mixed-value"]), "Mixed: mixed")

        // Activating a mixed checkbox resolves it to checked (the native
        // convention), and a second activation unchecks it.
        mixed.click()
        XCTAssertEqual(text(of: app.staticTexts["checkbox-mixed-value"]), "Mixed: checked")
        mixed.click()
        XCTAssertEqual(text(of: app.staticTexts["checkbox-mixed-value"]), "Mixed: unchecked")
        XCTAssertEqual(text(of: app.staticTexts["checkbox-change-count"]), "Changes: 2")
    }

    func testBooleanCheckboxAndStyledToggleRouteChanges() {
        let app = launchHost(scene: "checkbox")
        let basic = app.checkBoxes["checkbox-basic"]
        XCTAssertTrue(basic.waitForExistence(timeout: 5))
        XCTAssertEqual(basic.value as? Int, 0)
        basic.click()
        XCTAssertEqual(basic.value as? Int, 1)
        XCTAssertEqual(text(of: app.staticTexts["checkbox-basic-value"]), "Basic: checked")

        let styled = app.checkBoxes["checkbox-styled"]
        XCTAssertTrue(styled.exists, "SCCheckboxStyle toggle is missing")
        styled.click()
        XCTAssertEqual(text(of: app.staticTexts["checkbox-styled-value"]), "Styled: on")
        styled.click()
        XCTAssertEqual(text(of: app.staticTexts["checkbox-styled-value"]), "Styled: off")

        XCTAssertEqual(text(of: app.staticTexts["checkbox-change-count"]), "Changes: 3")
        attachWindowScreenshot(of: app, named: "checkbox-light")
    }

    func testUnlabeledAndInvalidFormsRenderWithLabels() {
        let app = launchHost(scene: "checkbox")
        let unlabeled = app.checkBoxes["checkbox-unlabeled"]
        XCTAssertTrue(unlabeled.waitForExistence(timeout: 5))
        XCTAssertEqual(unlabeled.label, "Row selection")
        XCTAssertEqual(unlabeled.value as? Int, 1)

        let invalid = app.checkBoxes["checkbox-invalid"]
        XCTAssertTrue(invalid.exists, "invalid checkbox is missing")
        XCTAssertEqual(invalid.label, "Invalid choice")
    }

    func testDisabledCheckboxIsExposedAsDisabled() {
        let app = launchHost(scene: "checkbox")
        let disabled = app.checkBoxes["checkbox-disabled"]
        XCTAssertTrue(disabled.waitForExistence(timeout: 5))
        XCTAssertFalse(disabled.isEnabled)
        XCTAssertEqual(disabled.value as? Int, 1)
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "checkbox", appearance: "dark")
        XCTAssertTrue(app.checkBoxes["checkbox-mixed"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "checkbox-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "checkbox", appearance: "light")
        XCTAssertTrue(app.checkBoxes["checkbox-mixed"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "checkbox", appearance: "dark")
        XCTAssertTrue(app.checkBoxes["checkbox-mixed"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }
}
