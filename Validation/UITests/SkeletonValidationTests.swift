import XCTest

final class SkeletonValidationTests: ValidationCase {
    private let skeletonIdentifiers = [
        "skeleton-pulse", "skeleton-shimmer", "skeleton-static", "skeleton-circle",
    ]

    func testSkeletonsRenderWithoutEnteringTheAccessibilityTree() {
        let app = launchHost(scene: "skeleton")
        XCTAssertTrue(app.staticTexts["skeleton-loading-state"].waitForExistence(timeout: 5))

        for identifier in skeletonIdentifiers {
            XCTAssertEqual(
                app.descendants(matching: .any).matching(identifier: identifier).count,
                0,
                "\(identifier) must be hidden from accessibility"
            )
        }
        attachWindowScreenshot(of: app, named: "skeleton-light")
    }

    func testSkeletonModifierHidesContentUntilLoadingEnds() {
        let app = launchHost(scene: "skeleton")
        let loadingState = app.staticTexts["skeleton-loading-state"]
        XCTAssertTrue(loadingState.waitForExistence(timeout: 5))
        XCTAssertEqual(text(of: loadingState), "Loading: true")

        let title = app.staticTexts["skeleton-content-title"]
        let description = app.staticTexts["skeleton-content-description"]
        XCTAssertFalse(title.exists, "redacted content must be hidden from accessibility")
        XCTAssertFalse(description.exists, "redacted content must be hidden from accessibility")

        app.buttons["skeleton-toggle"].click()
        XCTAssertEqual(text(of: loadingState), "Loading: false")
        XCTAssertTrue(title.exists, "content must be re-exposed once loading ends")
        XCTAssertEqual(text(of: title), "Sync complete")
        XCTAssertEqual(text(of: description), "All 128 files are up to date.")

        app.buttons["skeleton-toggle"].click()
        XCTAssertEqual(text(of: loadingState), "Loading: true")
        XCTAssertFalse(title.exists, "content must hide again when loading restarts")
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "skeleton", appearance: "dark")
        XCTAssertTrue(app.staticTexts["skeleton-loading-state"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "skeleton-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "skeleton", appearance: "light")
        XCTAssertTrue(app.staticTexts["skeleton-loading-state"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "skeleton", appearance: "dark")
        XCTAssertTrue(app.staticTexts["skeleton-loading-state"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }
}
