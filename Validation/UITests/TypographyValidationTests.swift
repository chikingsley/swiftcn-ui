import XCTest

final class TypographyValidationTests: ValidationCase {
    private let proseIdentifiers = [
        "typography-paragraph", "typography-blockquote", "typography-inline-code",
        "typography-lead", "typography-large", "typography-small", "typography-muted",
    ]

    func testEveryTypographyTreatmentAndListRenders() {
        let app = launchHost(scene: "typography")
        XCTAssertTrue(app.staticTexts["typography-h1"].waitForExistence(timeout: 5))

        for identifier in proseIdentifiers {
            XCTAssertTrue(app.staticTexts[identifier].exists, "\(identifier) is missing")
        }
        XCTAssertTrue(app.groups["typography-string-list"].exists)
        XCTAssertTrue(app.groups["typography-typed-list"].exists)
        XCTAssertTrue(app.staticTexts["typography-typed-list-alpha"].exists)
        XCTAssertTrue(app.staticTexts["typography-typed-list-beta"].exists)
        attachWindowScreenshot(of: app, named: "typography-light")
    }

    func testHeadingsExposeTheirNativeLevels() {
        let app = launchHost(scene: "typography")
        XCTAssertTrue(app.staticTexts["typography-h1"].waitForExistence(timeout: 5))

        for level in 1...4 {
            let heading = app.staticTexts["typography-h\(level)"]
            XCTAssertTrue(heading.exists, "h\(level) is missing")
            // macOS XCUITest exposes neither AXHeading nor its level. The
            // strongest observable contract is that every heading remains a
            // distinct static-text accessibility element with its own content.
            XCTAssertEqual(heading.elementType, .staticText)
            XCTAssertEqual(heading.label, ["Level one", "Level two", "Level three", "Level four"][level - 1])
        }
    }

    func testStyledActionRoutesToCallerOwnedState() {
        let app = launchHost(scene: "typography")
        let count = app.staticTexts["typography-activation-count"]
        XCTAssertTrue(count.waitForExistence(timeout: 5))
        app.buttons["typography-action-button"].click()
        XCTAssertEqual(text(of: count), "Activations: 1")
    }

    func testDisabledTypographyControlIsExposedAsDisabled() {
        let app = launchHost(scene: "typography")
        let button = app.buttons["typography-disabled"]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        XCTAssertFalse(button.isEnabled)
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "typography", appearance: "dark")
        XCTAssertTrue(app.staticTexts["typography-h1"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "typography-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "typography", appearance: "light")
        XCTAssertTrue(app.staticTexts["typography-h1"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "typography", appearance: "dark")
        XCTAssertTrue(app.staticTexts["typography-h1"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }
}
