import XCTest

final class AlertValidationTests: ValidationCase {
    func testDefaultVariantRendersTitleAndDescriptionSlots() {
        let app = launchHost(scene: "alert")
        let alert = app.groups["alert-default"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))

        // The convenience initializer's slots carry no identifiers; macOS
        // static text exposes the string through AXValue.
        let title = alert.staticTexts.matching(
            NSPredicate(format: "value == %@", "Heads up!")
        )
        XCTAssertEqual(title.count, 1, "default alert title is missing")
        let description = alert.staticTexts.matching(
            NSPredicate(
                format: "value == %@", "You can add components to your app using the CLI.")
        )
        XCTAssertEqual(description.count, 1, "default alert description is missing")
        attachWindowScreenshot(of: app, named: "alert-light")
    }

    func testDestructiveVariantRendersComposedSlots() {
        let app = launchHost(scene: "alert")
        let alert = app.groups["alert-destructive"]
        XCTAssertTrue(alert.waitForExistence(timeout: 5))

        let title = app.staticTexts["alert-destructive-title"]
        XCTAssertTrue(title.exists, "destructive alert title is missing")
        XCTAssertEqual(text(of: title), "Payment failed")

        let description = app.staticTexts["alert-destructive-description"]
        XCTAssertTrue(description.exists, "destructive alert description is missing")
        XCTAssertEqual(text(of: description), "Choose another payment method and try again.")
    }

    func testAlertActionButtonOwnsActivation() {
        let app = launchHost(scene: "alert")
        let button = app.buttons["alert-action-button"]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        button.click()
        button.click()
        XCTAssertEqual(text(of: app.staticTexts["alert-activation-count"]), "Activations: 2")
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "alert", appearance: "dark")
        XCTAssertTrue(app.groups["alert-default"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "alert-dark")
    }

    // Both audits must pass with no tolerations: the destructive variant
    // is untinted (theme.background, Alert.swift:63-68) and the
    // description uses full-strength destructive, so the title measures
    // red-600 #E7000B on white = 4.77:1 light and red-400 #FF6467 on
    // zinc-950 = 6.55:1 dark (WCAG AA needs 4.5:1).
    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "alert", appearance: "light")
        XCTAssertTrue(app.groups["alert-default"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "alert", appearance: "dark")
        XCTAssertTrue(app.groups["alert-default"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }
}
