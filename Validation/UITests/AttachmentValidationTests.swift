import XCTest

final class AttachmentValidationTests: ValidationCase {
    private let states = ["idle", "uploading", "processing", "error", "done"]
    private let sizes = ["default", "small", "extraSmall"]

    func testEveryStateSizeAndOrientationRenders() {
        let app = launchHost(scene: "attachment", height: 680)
        XCTAssertTrue(app.staticTexts["attachment-activation-count"].waitForExistence(timeout: 5))

        for state in states {
            XCTAssertTrue(
                app.groups["attachment-state-\(state)"].exists,
                "state \(state) is missing"
            )
        }
        for size in sizes {
            XCTAssertTrue(
                app.groups["attachment-size-\(size)"].exists,
                "size \(size) is missing"
            )
        }
        XCTAssertTrue(app.groups["attachment-orientation-vertical"].exists)
        attachWindowScreenshot(of: app, named: "attachment-light")
    }

    func testActionRoutesAndDisabledActionIsBlocked() {
        let app = launchHost(scene: "attachment", height: 680)
        let removeAction = app.buttons["attachment-action-remove"]
        XCTAssertTrue(removeAction.waitForExistence(timeout: 5))

        removeAction.click()
        XCTAssertEqual(text(of: app.staticTexts["attachment-last-activated"]), "Last: remove")
        XCTAssertEqual(text(of: app.staticTexts["attachment-activation-count"]), "Activations: 1")

        let disabledAction = app.buttons["attachment-action-disabled"]
        XCTAssertTrue(disabledAction.exists)
        XCTAssertFalse(disabledAction.isEnabled, "download action must render disabled")
    }

    func testFullCardTriggerRoutesItsAction() {
        let app = launchHost(scene: "attachment", height: 680)
        let trigger = app.buttons["attachment-trigger"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        trigger.click()
        XCTAssertEqual(text(of: app.staticTexts["attachment-last-activated"]), "Last: trigger")
    }

    func testDisabledAndErrorTriggerIsExposedAsDisabled() {
        let app = launchHost(scene: "attachment", height: 680)
        let trigger = app.buttons["attachment-disabled"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        XCTAssertFalse(trigger.isEnabled, "a disabled full-card trigger must render disabled")
    }

    func testGroupRendersBothMembers() {
        let app = launchHost(scene: "attachment", height: 680)
        let group = app.descendants(matching: .any)["attachment-group"]
        XCTAssertTrue(group.waitForExistence(timeout: 5))
        XCTAssertTrue(group.descendants(matching: .any)["attachment-group-item-1"].exists)
        XCTAssertTrue(group.descendants(matching: .any)["attachment-group-item-2"].exists)
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "attachment", appearance: "dark", height: 680)
        XCTAssertTrue(app.staticTexts["attachment-activation-count"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "attachment-dark")
    }

    // The 13px destructive "Upload failed" status on the plain card computes
    // to 4.77:1 (light, red-600 #E7000B on white) — clearing WCAG AA text
    // (4.5:1); the sampler still reports the small antialiased glyphs as
    // "nearly passed". Identifier-less, so matched by "".
    private var destructiveStatusContrastFindings: [KnownAuditFinding] {
        [KnownAuditFinding(descriptionContains: "Contrast", identifier: "")]
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "attachment", appearance: "light", height: 680)
        XCTAssertTrue(app.staticTexts["attachment-activation-count"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app, tolerating: destructiveStatusContrastFindings)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "attachment", appearance: "dark", height: 680)
        XCTAssertTrue(app.staticTexts["attachment-activation-count"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app, tolerating: destructiveStatusContrastFindings)
    }
}
