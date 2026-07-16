import XCTest

final class SpinnerValidationTests: ValidationCase {
    private struct SpinnerExpectation {
        let identifier: String
        let label: String
        let side: CGFloat
        let lineWidth: CGFloat
    }

    func testEverySizeAppearanceAndLabelRendersAtStableGeometry() {
        let app = launchHost(scene: "spinner")
        let expected = [
            SpinnerExpectation(identifier: "spinner-compact", label: "Loading compact", side: 14, lineWidth: 1.5),
            SpinnerExpectation(identifier: "spinner-default", label: "Loading default", side: 16, lineWidth: 1.5),
            SpinnerExpectation(identifier: "spinner-large", label: "Loading large", side: 32, lineWidth: 3),
            SpinnerExpectation(
                identifier: "spinner-custom-stroke",
                label: "Loading custom stroke",
                side: 24,
                lineWidth: 4
            ),
            SpinnerExpectation(identifier: "spinner-appearance", label: "Loading accented", side: 24, lineWidth: 1.5),
        ]

        for spinner in expected {
            let element = app.activityIndicators[spinner.identifier]
            XCTAssertTrue(element.waitForExistence(timeout: 5), "\(spinner.identifier) is missing")
            XCTAssertEqual(element.label, spinner.label)
            // AX samples the rotating trimmed arc's painted bounds rather than
            // its fixed SwiftUI frame. Rotation changes that bounding box by at
            // most one stroke width; 0.25 points covers subpixel AX rounding.
            let paintedBoundsAccuracy = spinner.lineWidth + 0.25
            XCTAssertEqual(element.frame.width, spinner.side, accuracy: paintedBoundsAccuracy)
            XCTAssertEqual(element.frame.height, spinner.side, accuracy: paintedBoundsAccuracy)
        }
        attachWindowScreenshot(of: app, named: "spinner-light")
    }

    func testAppearanceConfigurationRoutesFromCallerOwnedState() {
        let app = launchHost(scene: "spinner")
        let echo = app.staticTexts["spinner-appearance-echo"]
        XCTAssertTrue(echo.waitForExistence(timeout: 5))
        XCTAssertEqual(text(of: echo), "Appearance: secondary")
        app.buttons["spinner-appearance-toggle"].click()
        XCTAssertEqual(text(of: echo), "Appearance: accent")
        XCTAssertTrue(app.activityIndicators["spinner-appearance"].exists)
    }

    func testDisabledSpinnerIsExposedAsDisabled() {
        let app = launchHost(scene: "spinner")
        let spinner = app.activityIndicators["spinner-disabled"]
        XCTAssertTrue(spinner.waitForExistence(timeout: 5))
        XCTAssertFalse(spinner.isEnabled)
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "spinner", appearance: "dark")
        XCTAssertTrue(app.activityIndicators["spinner-default"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "spinner-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "spinner", appearance: "light")
        XCTAssertTrue(app.activityIndicators["spinner-default"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "spinner", appearance: "dark")
        XCTAssertTrue(app.activityIndicators["spinner-default"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }

}
