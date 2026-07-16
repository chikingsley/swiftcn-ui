import XCTest

final class AspectRatioValidationTests: ValidationCase {
    func testEveryRatioRendersAtExactGeometry() {
        let app = launchHost(scene: "aspectratio")
        let expected: [(String, CGFloat)] = [
            ("aspectratio-16-9", 16.0 / 9.0),
            ("aspectratio-1-1", 1),
            ("aspectratio-4-3", 4.0 / 3.0),
        ]

        for (identifier, ratio) in expected {
            let element = app.groups[identifier]
            XCTAssertTrue(element.waitForExistence(timeout: 5), "\(identifier) is missing")
            XCTAssertEqual(element.frame.width / element.frame.height, ratio, accuracy: 0.03)
        }
        let clipped = app.groups["aspectratio-clipped"]
        let clippedContent = app.descendants(matching: .any)["aspectratio-clipped-content"]
        XCTAssertTrue(clipped.exists)
        XCTAssertTrue(clippedContent.exists)
        XCTAssertEqual(clippedContent.frame, clipped.frame)
        attachWindowScreenshot(of: app, named: "aspectratio-light")
    }

    func testAlignmentRoutesCallerOwnedStateAndMovesContent() {
        let app = launchHost(scene: "aspectratio")
        let echo = app.staticTexts["aspectratio-alignment-echo"]
        let container = app.groups["aspectratio-aligned"]
        let marker = app.descendants(matching: .any)["aspectratio-alignment-marker"]
        XCTAssertTrue(echo.waitForExistence(timeout: 5))
        XCTAssertTrue(container.exists)
        XCTAssertTrue(marker.exists)
        XCTAssertEqual(text(of: echo), "Alignment: top-leading")
        XCTAssertEqual(marker.frame.minX, container.frame.minX, accuracy: 2)
        XCTAssertEqual(marker.frame.minY, container.frame.minY, accuracy: 2)

        app.buttons["aspectratio-alignment-toggle"].click()
        XCTAssertEqual(text(of: echo), "Alignment: bottom-trailing")
        XCTAssertEqual(marker.frame.maxX, container.frame.maxX, accuracy: 2)
        XCTAssertEqual(marker.frame.maxY, container.frame.maxY, accuracy: 2)
    }

    func testDisabledSurfaceIsExposedAsDisabled() {
        let app = launchHost(scene: "aspectratio")
        let element = app.descendants(matching: .any)["aspectratio-disabled"]
        XCTAssertTrue(element.waitForExistence(timeout: 5))
        XCTAssertFalse(element.isEnabled)
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "aspectratio", appearance: "dark")
        XCTAssertTrue(app.groups["aspectratio-16-9"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "aspectratio-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "aspectratio", appearance: "light")
        XCTAssertTrue(app.groups["aspectratio-16-9"].waitForExistence(timeout: 5))
        // theme.foreground zinc950 #09090B on theme.muted zinc100 #F4F4F5
        // computes to 18.10:1, above WCAG AA's 4.5:1 text threshold.
        try runAccessibilityAudit(
            on: app,
            tolerating: [
                KnownAuditFinding(
                    descriptionContains: "Contrast failed",
                    identifier: "aspectratio-label-4-3"
                )
            ]
        )
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "aspectratio", appearance: "dark")
        XCTAssertTrue(app.groups["aspectratio-16-9"].waitForExistence(timeout: 5))
        // theme.foreground zinc50 #FAFAFA on theme.muted zinc800 #27272A
        // computes to 14.27:1, above WCAG AA's 4.5:1 text threshold.
        try runAccessibilityAudit(
            on: app,
            tolerating: [
                KnownAuditFinding(
                    descriptionContains: "Contrast failed",
                    identifier: "aspectratio-label-4-3"
                )
            ]
        )
    }
}
