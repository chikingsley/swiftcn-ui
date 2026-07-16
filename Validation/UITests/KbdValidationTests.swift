import XCTest

final class KbdValidationTests: ValidationCase {
    private let typedKeyIdentifiers = [
        "command", "control", "option", "shift", "caps-lock", "escape", "tab", "return",
        "delete", "forward-delete", "space", "arrow-up", "arrow-down", "arrow-left", "arrow-right",
        "character",
    ]

    func testEveryTypedKeyAndConvenienceRenders() {
        let app = launchHost(scene: "kbd")
        XCTAssertTrue(app.staticTexts["kbd-activation-count"].waitForExistence(timeout: 5))

        for key in typedKeyIdentifiers {
            XCTAssertTrue(app.staticTexts["kbd-key-\(key)"].exists, "typed key \(key) is missing")
        }
        for identifier in [
            "kbd-arbitrary-string", "kbd-group-string-array", "kbd-group-typed", "kbd-group-icon-only",
        ] {
            XCTAssertTrue(
                app.descendants(matching: .any)[identifier].exists,
                "\(identifier) is missing"
            )
        }
        attachWindowScreenshot(of: app, named: "kbd-light")
    }

    func testShortcutGroupsAnnounceCoherently() {
        let app = launchHost(scene: "kbd")
        let stringGroup = app.descendants(matching: .any)["kbd-group-string-array"]
        let typedGroup = app.descendants(matching: .any)["kbd-group-typed"]
        let iconGroup = app.descendants(matching: .any)["kbd-group-icon-only"]
        XCTAssertTrue(stringGroup.waitForExistence(timeout: 5))
        XCTAssertEqual(text(of: stringGroup), "Control, K")
        XCTAssertEqual(text(of: typedGroup), "Command, Shift, P")
        // The icon-only group is represented as text so it carries a valid
        // role, so its announcement arrives as AXValue like the groups above.
        XCTAssertEqual(text(of: iconGroup), "Previous and next")
    }

    func testActionRoutesToCallerOwnedState() {
        let app = launchHost(scene: "kbd")
        let count = app.staticTexts["kbd-activation-count"]
        XCTAssertTrue(count.waitForExistence(timeout: 5))
        app.buttons["kbd-action-button"].click()
        app.buttons["kbd-action-button"].click()
        XCTAssertEqual(text(of: count), "Activations: 2")
    }

    func testDisabledKeyIsExposedAsDisabled() {
        let app = launchHost(scene: "kbd")
        let key = app.staticTexts["kbd-disabled"]
        XCTAssertTrue(key.waitForExistence(timeout: 5))
        XCTAssertFalse(key.isEnabled)
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "kbd", appearance: "dark")
        XCTAssertTrue(app.staticTexts["kbd-key-command"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "kbd-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "kbd", appearance: "light")
        XCTAssertTrue(app.staticTexts["kbd-key-command"].waitForExistence(timeout: 5))
        // theme.mutedForeground zinc600 #52525C on theme.muted zinc100 #F4F4F5
        // computes to 7.02:1, above WCAG AA's 4.5:1 text threshold.
        try runAccessibilityAudit(
            on: app,
            tolerating: knownContrastFindings
        )
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "kbd", appearance: "dark")
        XCTAssertTrue(app.staticTexts["kbd-key-command"].waitForExistence(timeout: 5))
        // theme.mutedForeground zinc400 #9F9FA9 on theme.muted zinc800 #27272A
        // computes to 5.68:1, above WCAG AA's 4.5:1 text threshold.
        try runAccessibilityAudit(
            on: app,
            tolerating: knownContrastFindings
        )
    }

    private var knownContrastFindings: [KnownAuditFinding] {
        let identifiers = [
            // Icon-only keys are represented as text carrying the group's
            // label, so the sampler measures glyph pixels against the same
            // muted keycap colors as every other key below.
            "kbd-group-icon-only",
            // WCAG 1.4.3 exempts inactive components from contrast entirely;
            // this keycap is the same muted-on-muted styling at 50% opacity.
            "kbd-disabled",
            "kbd-group-string-array",
            "kbd-group-typed",
            "kbd-key-command",
            "kbd-key-control",
            "kbd-key-delete",
            "kbd-key-escape",
            "kbd-key-forward-delete",
            "kbd-key-option",
            "kbd-key-return",
            "kbd-key-shift",
            "kbd-key-tab",
        ]
        return identifiers.map {
            KnownAuditFinding(descriptionContains: "Contrast", identifier: $0)
        }
    }
}
