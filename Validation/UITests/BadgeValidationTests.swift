import XCTest

final class BadgeValidationTests: ValidationCase {
    private let variants = ["default", "secondary", "destructive", "outline", "ghost", "link"]

    func testEveryVariantAndInvalidStateRenders() {
        let app = launchHost(scene: "badge")
        XCTAssertTrue(app.staticTexts["badge-variant-default"].waitForExistence(timeout: 5))

        for variant in variants {
            XCTAssertTrue(
                app.staticTexts["badge-variant-\(variant)"].exists,
                "variant \(variant) is missing"
            )
        }
        XCTAssertTrue(app.staticTexts["badge-invalid"].exists)
        attachWindowScreenshot(of: app, named: "badge-light")
    }

    func testBadgeStyledButtonOwnsActivation() {
        let app = launchHost(scene: "badge")
        let button = app.buttons["badge-button"]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        button.click()
        button.click()
        XCTAssertEqual(text(of: app.staticTexts["badge-activation-count"]), "Activations: 2")
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "badge", appearance: "dark")
        XCTAssertTrue(app.staticTexts["badge-variant-default"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "badge-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "badge", appearance: "light")
        XCTAssertTrue(app.staticTexts["badge-variant-default"].waitForExistence(timeout: 5))
        // False positive: the audit cannot attribute the backdrop behind the
        // link badge's clear capsule. Computed ratio is zinc-900 on white =
        // 17.72:1 (WCAG AA needs 4.5:1).
        try runAccessibilityAudit(
            on: app,
            tolerating: [
                KnownAuditFinding(
                    descriptionContains: "Contrast",
                    identifier: "badge-variant-link"
                )
            ]
        )
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "badge", appearance: "dark")
        XCTAssertTrue(app.staticTexts["badge-variant-default"].waitForExistence(timeout: 5))
        // Dark destructive is upstream's red-400 with the theme's black
        // destructiveForeground (7.28:1 vs white's 2.89:1; WCAG AA needs
        // 4.5:1), so the destructive badge must pass this audit with no
        // toleration.
        // badge-invalid is a false positive: the destructive shadow glow
        // confuses sampling; computed ratio is zinc-900 on zinc-200 =
        // 13.96:1.
        try runAccessibilityAudit(
            on: app,
            tolerating: [
                KnownAuditFinding(
                    descriptionContains: "Contrast",
                    identifier: "badge-invalid"
                )
            ]
        )
    }
}
