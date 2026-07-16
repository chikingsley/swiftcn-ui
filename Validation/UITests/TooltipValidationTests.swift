import XCTest

final class TooltipValidationTests: ValidationCase {
    private let tooltips = [
        (edge: "top", help: "Top tooltip"),
        (edge: "bottom", help: "Bottom tooltip"),
        (edge: "leading", help: "Leading tooltip"),
        (edge: "trailing", help: "Trailing tooltip"),
    ]

    func testEveryEdgeExposesTriggerHelpAndRoutesItsAction() {
        let app = launchHost(scene: "tooltip")
        let count = app.staticTexts["tooltip-action-count"]
        XCTAssertTrue(count.waitForExistence(timeout: 5))

        for tooltip in tooltips {
            let trigger = app.buttons["tooltip-trigger-\(tooltip.edge)"]
            XCTAssertTrue(trigger.exists, "\(tooltip.edge) trigger is missing")
            XCTAssertEqual(trigger.label, tooltip.edge.capitalized)
            XCTAssertTrue(trigger.isEnabled)
            XCTAssertTrue(trigger.isHittable)
            print("SC-MANUAL-VALIDATION: \(trigger.identifier) AXHelp must read '\(tooltip.help)'")
            trigger.click()
        }

        // XCTest's macOS snapshot omits AXHelp/accessibilityHint entirely,
        // including after the deterministic focus-presentation request. The
        // trigger's role, identity, label, enabled/hittable state, and routed
        // action are the strongest automated contract. Reading each expected
        // help string with VoiceOver remains manual VALIDATION.
        XCTAssertEqual(text(of: count), "Actions: \(tooltips.count)")
    }

    func testFocusedTriggerRequestsPresentationWithoutFakingHover() {
        let app = launchHost(scene: "tooltip")
        let trigger = app.buttons["tooltip-trigger-top"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        trigger.click()
        XCTAssertTrue(trigger.isHittable, "trigger must remain an interactive target")

        // SCTooltipContent intentionally uses accessibilityHidden(true), so
        // its visual bubble must not become duplicate spoken text. XCUITest
        // cannot reliably synthesize macOS hover or observe that hidden view;
        // pointer-open and pointer-dismiss remain manual VALIDATION residue.
        XCTAssertEqual(
            app.staticTexts.matching(NSPredicate(format: "value == %@", "Top tooltip")).count,
            0
        )
    }

    func testDisabledTriggerIsExposedAsDisabled() {
        let app = launchHost(scene: "tooltip")
        let trigger = app.buttons["tooltip-disabled"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        XCTAssertEqual(trigger.label, "Disabled tooltip")
        XCTAssertFalse(trigger.isEnabled)
        trigger.click()
        XCTAssertEqual(text(of: app.staticTexts["tooltip-action-count"]), "Actions: 0")

        // AXHelp is omitted from macOS XCTest snapshots even for disabled
        // buttons. VoiceOver must manually confirm "Unavailable tooltip";
        // role, label, disabled semantics, and blocked action are automated.
        print("SC-MANUAL-VALIDATION: tooltip-disabled AXHelp must read 'Unavailable tooltip'")
    }

    func testLightAppearanceRendersProviderAndFocusedTrigger() {
        let app = launchHost(scene: "tooltip", appearance: "light")
        let trigger = app.buttons["tooltip-trigger-top"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        trigger.click()
        attachWindowScreenshot(of: app, named: "tooltip-light")
    }

    func testDarkAppearanceRendersProviderAndFocusedTrigger() {
        let app = launchHost(scene: "tooltip", appearance: "dark")
        let trigger = app.buttons["tooltip-trigger-top"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        trigger.click()
        attachWindowScreenshot(of: app, named: "tooltip-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "tooltip", appearance: "light")
        let trigger = app.buttons["tooltip-trigger-top"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        // Keyboard focus is the deterministic macOS presentation path. The
        // bubble is intentionally hidden from AX, but it is visually present
        // when the audit runs and its help remains attached to this trigger.
        trigger.click()
        try runAccessibilityAudit(on: app)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "tooltip", appearance: "dark")
        let trigger = app.buttons["tooltip-trigger-top"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        trigger.click()
        try runAccessibilityAudit(on: app)
    }
}
