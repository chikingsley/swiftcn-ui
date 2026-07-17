import XCTest

final class BubbleValidationTests: ValidationCase {
    private let variants = ["default", "secondary", "muted", "tinted", "outline", "ghost", "destructive"]

    func testEveryVariantAlignmentGroupAndCustomColorsRenders() {
        let app = launchHost(scene: "bubble", height: 700)
        XCTAssertTrue(app.staticTexts["bubble-activation-count"].waitForExistence(timeout: 5))

        for variant in variants {
            XCTAssertTrue(
                app.groups["bubble-variant-\(variant)"].exists,
                "variant \(variant) is missing"
            )
        }
        XCTAssertTrue(app.groups["bubble-align-start"].exists)
        XCTAssertTrue(app.groups["bubble-align-end"].exists)

        let group = app.groups["bubble-group"]
        XCTAssertTrue(group.exists)
        XCTAssertTrue(group.groups["bubble-group-item-1"].exists)
        XCTAssertTrue(group.groups["bubble-group-item-2"].exists)

        XCTAssertTrue(app.groups["bubble-custom-colors"].exists)
        attachWindowScreenshot(of: app, named: "bubble-light")
    }

    func testReactionsOverlayExposesItsAccessibilityLabel() {
        let app = launchHost(scene: "bubble", height: 700)
        let bubble = app.groups["bubble-with-reactions"]
        XCTAssertTrue(bubble.waitForExistence(timeout: 5))
        XCTAssertTrue(
            bubble.descendants(matching: .any)["Reactions: thumbs up"].exists,
            "reactions capsule must expose its combined accessibility label"
        )
    }

    func testRealButtonContentRoutesIntoCallerOwnedState() {
        let app = launchHost(scene: "bubble", height: 700)
        let button = app.buttons["bubble-button-content"]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        button.click()
        XCTAssertEqual(text(of: app.staticTexts["bubble-last-activated"]), "Last: button-content")
        XCTAssertEqual(text(of: app.staticTexts["bubble-activation-count"]), "Activations: 1")
    }

    func testRealLinkContentRoutesThroughOpenURL() {
        let app = launchHost(scene: "bubble", height: 700)
        let link = app.links["bubble-link-content"]
        XCTAssertTrue(link.waitForExistence(timeout: 5))
        link.click()
        XCTAssertEqual(text(of: app.staticTexts["bubble-last-activated"]), "Last: link-content")
    }

    func testDisabledBubbleStyledButtonIsExposedAsDisabled() {
        let app = launchHost(scene: "bubble", height: 700)
        let button = app.buttons["bubble-disabled"]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        XCTAssertFalse(button.isEnabled)
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "bubble", appearance: "dark", height: 700)
        XCTAssertTrue(app.staticTexts["bubble-activation-count"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "bubble-dark")
    }

    // The destructive variant matches upstream (destructive text on a 10%
    // destructive tint), which computes to 3.99:1 in light mode — genuinely
    // below WCAG AA text (4.5:1); dark computes 5.35:1 and passes. Recorded
    // in the ledger as an upstream-inherited deviation pending a theme-level
    // decision (the Alert precedent removed its tint for the same numbers).
    // Identifier-less, so matched by "".
    private var destructiveTintContrastFindings: [KnownAuditFinding] {
        [KnownAuditFinding(descriptionContains: "Contrast", identifier: "")]
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "bubble", appearance: "light", height: 700)
        XCTAssertTrue(app.staticTexts["bubble-activation-count"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app, tolerating: destructiveTintContrastFindings)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "bubble", appearance: "dark", height: 700)
        XCTAssertTrue(app.staticTexts["bubble-activation-count"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app, tolerating: destructiveTintContrastFindings)
    }
}
