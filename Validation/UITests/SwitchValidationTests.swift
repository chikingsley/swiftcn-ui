import XCTest

final class SwitchValidationTests: ValidationCase {
    /// SCSwitch exposes its toggle through accessibilityRepresentation, and
    /// SwiftUI lays the represented Toggle's elements out at natural size
    /// from the real view's origin — wider than the actual 44x44 control —
    /// so element-frame clicks miss the real button. Click 10pt inside the
    /// synthetic label's leading edge, which is the real control's origin.
    private func clickSwitch(labeled label: String, in app: XCUIApplication) {
        let anchor = app.staticTexts.matching(
            NSPredicate(format: "value == %@", label)
        ).firstMatch
        anchor.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0.5))
            .withOffset(CGVector(dx: 10, dy: 0))
            .click()
    }

    func testBothSizesAndStyledToggleRenderAndRouteChanges() {
        let app = launchHost(scene: "switch")
        let count = app.staticTexts["switch-change-count"]
        XCTAssertTrue(count.waitForExistence(timeout: 5))

        XCTAssertTrue(app.switches["switch-default"].exists, "default switch is missing")
        clickSwitch(labeled: "Default switch", in: app)
        XCTAssertEqual(text(of: app.staticTexts["switch-default-value"]), "Default: on")
        clickSwitch(labeled: "Default switch", in: app)
        XCTAssertEqual(text(of: app.staticTexts["switch-default-value"]), "Default: off")

        XCTAssertTrue(app.switches["switch-small"].exists, "small switch is missing")
        clickSwitch(labeled: "Small switch", in: app)
        XCTAssertEqual(text(of: app.staticTexts["switch-small-value"]), "Small: on")

        let styledSwitch = app.switches["switch-styled"]
        XCTAssertTrue(styledSwitch.exists, "SCSwitchStyle toggle is missing")
        styledSwitch.click()
        XCTAssertEqual(text(of: app.staticTexts["switch-styled-value"]), "Styled: on")

        XCTAssertEqual(text(of: count), "Changes: 4")
        attachWindowScreenshot(of: app, named: "switch-light")
    }

    func testSwitchExposesToggleValueThroughAccessibility() {
        let app = launchHost(scene: "switch")
        let defaultSwitch = app.switches["switch-default"]
        XCTAssertTrue(defaultSwitch.waitForExistence(timeout: 5))
        XCTAssertEqual(defaultSwitch.value as? Int, 0)
        clickSwitch(labeled: "Default switch", in: app)
        XCTAssertEqual(defaultSwitch.value as? Int, 1)
    }

    func testInvalidSwitchRendersAndKeepsCallerOwnedBinding() {
        let app = launchHost(scene: "switch")
        let invalidSwitch = app.switches["switch-invalid"]
        XCTAssertTrue(invalidSwitch.waitForExistence(timeout: 5))
        // The invalid switch is bound to .constant(false): activating it must
        // not mutate anything, proving the binding is truly caller-owned.
        clickSwitch(labeled: "Invalid switch", in: app)
        XCTAssertEqual(invalidSwitch.value as? Int, 0)
        XCTAssertEqual(text(of: app.staticTexts["switch-change-count"]), "Changes: 0")
    }

    func testDisabledSwitchIsExposedAsDisabled() {
        let app = launchHost(scene: "switch")
        let disabledSwitch = app.switches["switch-disabled"]
        XCTAssertTrue(disabledSwitch.waitForExistence(timeout: 5))
        XCTAssertFalse(disabledSwitch.isEnabled)
        XCTAssertEqual(disabledSwitch.value as? Int, 1)
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "switch", appearance: "dark")
        XCTAssertTrue(app.switches["switch-default"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "switch-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "switch", appearance: "light")
        XCTAssertTrue(app.switches["switch-default"].waitForExistence(timeout: 5))
        // False positive: SwiftUI puts accessibilityRepresentation labels in
        // the tree without ever drawing them, so the audit samples the
        // pixels under the synthetic label frame — the off-state switch
        // track (zinc-200 on white = 1.27:1, a non-text element) — as if
        // they were text glyphs. No text is rendered there. Every rendered
        // text in this scene carries an identifier and passes on its own
        // (zinc-950 on white = 19.89:1; WCAG AA needs 4.5:1); the
        // representation labels are the scene's only identifier-less
        // elements.
        try runAccessibilityAudit(
            on: app,
            tolerating: [
                KnownAuditFinding(descriptionContains: "Contrast", identifier: "")
            ]
        )
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "switch", appearance: "dark")
        XCTAssertTrue(app.switches["switch-default"].waitForExistence(timeout: 5))
        // Same false positive as light: the sampled pixels under the
        // never-rendered representation label are the off-state track
        // (white@15% over zinc-950 = 1.47:1, non-text); rendered text is
        // zinc-50 on zinc-950 = 19.06:1 (WCAG AA needs 4.5:1).
        try runAccessibilityAudit(
            on: app,
            tolerating: [
                KnownAuditFinding(descriptionContains: "Contrast", identifier: "")
            ]
        )
    }
}
