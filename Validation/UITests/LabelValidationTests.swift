import XCTest

final class LabelValidationTests: ValidationCase {
    private let labelIdentifiers = [
        "label-arbitrary-required", "label-paired-label", "label-vertical-trailing-label",
        "label-horizontal-leading-label", "label-horizontal-trailing-label", "label-disabled",
    ]

    func testEveryContentStateOrientationAndPlacementRenders() {
        let app = launchHost(scene: "label")
        XCTAssertTrue(element("label-arbitrary-required", in: app).waitForExistence(timeout: 5))

        for identifier in labelIdentifiers {
            XCTAssertTrue(element(identifier, in: app).exists, "\(identifier) is missing")
        }
        XCTAssertTrue(app.buttons["label-vertical-trailing-control"].exists)
        XCTAssertTrue(app.buttons["label-horizontal-leading-control"].exists)
        XCTAssertTrue(app.buttons["label-horizontal-trailing-control"].exists)
        attachWindowScreenshot(of: app, named: "label-light")
    }

    func testArbitraryLabelRoutesActivationIntoCallerState() {
        let app = launchHost(scene: "label")
        let label = element("label-arbitrary-required", in: app)
        XCTAssertTrue(label.waitForExistence(timeout: 5))
        label.click()
        XCTAssertEqual(text(of: app.staticTexts["label-activation-count"]), "Activations: 1")
        XCTAssertTrue(label.label.contains("Required"))
    }

    func testLabelledPairLabelsControlAndForwardsFocus() {
        let app = launchHost(scene: "label")
        let field = app.textFields["label-paired-control"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        let label = element("label-paired-label", in: app)
        XCTAssertTrue(label.label.contains("Account name"))

        // macOS XCUITest does not copy an AXTitleUIElement relationship into
        // XCUIElement.label. Typing without clicking the field proves the
        // native label activation forwarded focus to the paired control.
        label.click()
        field.typeText("Ada")
        XCTAssertEqual(text(of: app.staticTexts["label-account-echo"]), "Account: Ada")
    }

    func testDisabledLabelFollowsDisabledEnvironment() {
        let app = launchHost(scene: "label")
        let label = element("label-disabled", in: app)
        XCTAssertTrue(label.waitForExistence(timeout: 5))
        XCTAssertFalse(label.isEnabled)
        XCTAssertEqual(text(of: app.staticTexts["label-activation-count"]), "Activations: 0")
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "label", appearance: "dark")
        XCTAssertTrue(element("label-arbitrary-required", in: app).waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "label-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "label", appearance: "light")
        XCTAssertTrue(element("label-arbitrary-required", in: app).waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "label", appearance: "dark")
        XCTAssertTrue(element("label-arbitrary-required", in: app).waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }

    private func element(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any).matching(identifier: identifier).firstMatch
    }
}
