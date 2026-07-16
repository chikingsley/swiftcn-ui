import XCTest

final class ProgressValidationTests: ValidationCase {
    private let identifiers = [
        "progress-empty", "progress-determinate", "progress-complete",
        "progress-indeterminate", "progress-custom", "progress-disabled",
    ]

    func testEveryProgressStateAndCompositionRendersWithNativeSemantics() {
        let app = launchHost(scene: "progress")
        XCTAssertTrue(app.progressIndicators["progress-empty"].waitForExistence(timeout: 5))

        for identifier in identifiers where identifier != "progress-indeterminate" {
            XCTAssertTrue(app.progressIndicators[identifier].exists, "\(identifier) is missing")
        }
        let indeterminate = app.activityIndicators["progress-indeterminate"]
        XCTAssertTrue(indeterminate.exists, "progress-indeterminate is missing")
        XCTAssertEqual(indeterminate.label, "Indeterminate progress")
        XCTAssertEqual(numericValue(of: app.progressIndicators["progress-empty"]), 0)
        XCTAssertEqual(numericValue(of: app.progressIndicators["progress-complete"]), 1)
        XCTAssertEqual(app.progressIndicators["progress-custom"].label, "Custom progress")
        XCTAssertEqual(numericValue(of: app.progressIndicators["progress-custom"]), 0.6)
        attachWindowScreenshot(of: app, named: "progress-light")
    }

    func testCallerOwnedValueUpdateReachesEchoAndProgressAccessibilityValue() {
        let app = launchHost(scene: "progress")
        let progress = app.progressIndicators["progress-determinate"]
        XCTAssertTrue(progress.waitForExistence(timeout: 5))
        XCTAssertEqual(progress.label, "Upload progress")
        XCTAssertEqual(numericValue(of: progress), 0.25)

        app.buttons["progress-advance"].click()
        XCTAssertEqual(text(of: app.staticTexts["progress-value-echo"]), "Upload: 50")
        XCTAssertEqual(numericValue(of: progress), 0.5)
    }

    func testDisabledProgressIsExposedAsDisabled() {
        let app = launchHost(scene: "progress")
        let progress = app.progressIndicators["progress-disabled"]
        XCTAssertTrue(progress.waitForExistence(timeout: 5))
        XCTAssertFalse(progress.isEnabled)
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "progress", appearance: "dark")
        XCTAssertTrue(app.progressIndicators["progress-determinate"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "progress-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "progress", appearance: "light")
        XCTAssertTrue(app.progressIndicators["progress-determinate"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "progress", appearance: "dark")
        XCTAssertTrue(app.progressIndicators["progress-determinate"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }

    private func numericValue(of element: XCUIElement) -> Double? {
        (element.value as? NSNumber)?.doubleValue
    }
}
