import XCTest

final class SidebarValidationTests: ValidationCase {
    func testCompositionRendersHeaderGroupMenuAndFooter() {
        let app = launchHost(scene: "sidebar")
        let layout = app.groups["sidebar-layout"]
        XCTAssertTrue(layout.waitForExistence(timeout: 5))

        XCTAssertEqual(text(of: app.staticTexts["sidebar-header-label"]), "Swiftcn")
        XCTAssertTrue(app.buttons["sidebar-menu-home"].exists)
        XCTAssertTrue(app.buttons["sidebar-menu-inbox"].exists)
        XCTAssertTrue(app.buttons["sidebar-menu-disabled"].exists)
        XCTAssertTrue(app.buttons["sidebar-submenu-item"].exists)
        XCTAssertTrue(app.textFields["sidebar-search"].exists)
        XCTAssertEqual(text(of: app.staticTexts["sidebar-footer-label"]), "Alex Chen")
        attachWindowScreenshot(of: app, named: "sidebar-light")
    }

    func testTriggerTogglesCollapseAndEchoesState() {
        let app = launchHost(scene: "sidebar")
        let trigger = app.buttons["sidebar-trigger"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        XCTAssertEqual(text(of: app.staticTexts["sidebar-open-state"]), "Open: true")

        trigger.click()
        XCTAssertEqual(text(of: app.staticTexts["sidebar-open-state"]), "Open: false")
        XCTAssertEqual(text(of: app.staticTexts["sidebar-open-change-count"]), "OpenChanges: 1")

        trigger.click()
        XCTAssertEqual(text(of: app.staticTexts["sidebar-open-state"]), "Open: true")
        XCTAssertEqual(text(of: app.staticTexts["sidebar-open-change-count"]), "OpenChanges: 2")
    }

    func testKeyboardShortcutsToggleCollapse() {
        let app = launchHost(scene: "sidebar")
        let openState = app.staticTexts["sidebar-open-state"]
        XCTAssertTrue(openState.waitForExistence(timeout: 5))
        XCTAssertEqual(text(of: openState), "Open: true")

        app.typeKey("b", modifierFlags: .command)
        XCTAssertEqual(text(of: openState), "Open: false")

        app.typeKey("b", modifierFlags: .control)
        XCTAssertEqual(text(of: openState), "Open: true")

        XCTAssertEqual(text(of: app.staticTexts["sidebar-open-change-count"]), "OpenChanges: 2")
    }

    func testCollapsingHidesRailOnlyContentButKeepsMenuButtons() {
        let app = launchHost(scene: "sidebar")
        let trigger = app.buttons["sidebar-trigger"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))

        XCTAssertTrue(app.buttons["sidebar-menu-action-home"].exists)
        XCTAssertTrue(app.buttons["sidebar-group-action"].exists)
        XCTAssertTrue(app.textFields["sidebar-search"].exists)
        XCTAssertTrue(app.buttons["sidebar-submenu-item"].exists)

        trigger.click()
        XCTAssertEqual(text(of: app.staticTexts["sidebar-open-state"]), "Open: false")

        XCTAssertFalse(app.buttons["sidebar-menu-action-home"].exists, "row action must hide on the icon rail")
        XCTAssertFalse(app.buttons["sidebar-group-action"].exists, "group action must hide on the icon rail")
        XCTAssertFalse(app.textFields["sidebar-search"].exists, "search input must hide on the icon rail")
        XCTAssertFalse(app.buttons["sidebar-submenu-item"].exists, "sub-menu must hide entirely on the icon rail")

        XCTAssertTrue(app.buttons["sidebar-menu-home"].exists, "top-level menu rows remain on the icon rail")
        XCTAssertTrue(app.buttons["sidebar-menu-inbox"].exists)
        // Collapsed rows swap their trailing-edge tooltip in via .scTooltip;
        // AXHelp is unreadable from macOS XCTest snapshots (see
        // TooltipValidationTests), so its text remains manual VALIDATION.
        print("SC-MANUAL-VALIDATION: sidebar-menu-home must show a 'Home' tooltip on the icon rail")

        trigger.click()
        XCTAssertEqual(text(of: app.staticTexts["sidebar-open-state"]), "Open: true")
        XCTAssertTrue(app.buttons["sidebar-menu-action-home"].exists, "row action must return once expanded")
        XCTAssertTrue(app.textFields["sidebar-search"].exists)
    }

    func testMenuButtonsRouteSelectionAndActivation() {
        let app = launchHost(scene: "sidebar")
        XCTAssertTrue(app.buttons["sidebar-menu-home"].waitForExistence(timeout: 5))

        app.buttons["sidebar-menu-inbox"].click()
        XCTAssertEqual(text(of: app.staticTexts["sidebar-selection-echo"]), "Selection: Inbox")
        XCTAssertEqual(text(of: app.staticTexts["sidebar-last-activated"]), "Last: inbox")

        app.buttons["sidebar-menu-home"].click()
        XCTAssertEqual(text(of: app.staticTexts["sidebar-selection-echo"]), "Selection: Home")
        XCTAssertEqual(text(of: app.staticTexts["sidebar-last-activated"]), "Last: home")
        XCTAssertEqual(text(of: app.staticTexts["sidebar-activation-count"]), "Activations: 2")
    }

    func testRowActionGroupActionAndSubmenuRouteIndependently() {
        let app = launchHost(scene: "sidebar")
        XCTAssertTrue(app.buttons["sidebar-menu-action-home"].waitForExistence(timeout: 5))

        app.buttons["sidebar-menu-action-home"].click()
        XCTAssertEqual(text(of: app.staticTexts["sidebar-last-activated"]), "Last: menu-action-home")

        app.buttons["sidebar-group-action"].click()
        XCTAssertEqual(text(of: app.staticTexts["sidebar-last-activated"]), "Last: group-action")

        app.buttons["sidebar-submenu-item"].click()
        XCTAssertEqual(text(of: app.staticTexts["sidebar-last-activated"]), "Last: submenu-get-started")
        XCTAssertEqual(text(of: app.staticTexts["sidebar-activation-count"]), "Activations: 3")
    }

    func testSearchFieldRoutesTypedTextIntoCallerOwnedBinding() {
        let app = launchHost(scene: "sidebar")
        let field = app.textFields["sidebar-search"]
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        focusAndType(field, "swift", in: app)
        XCTAssertEqual(text(of: app.staticTexts["sidebar-search-echo"]), "Search: swift")
    }

    func testDisabledMenuButtonIsExposedAsDisabled() {
        let app = launchHost(scene: "sidebar")
        let button = app.buttons["sidebar-menu-disabled"]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        XCTAssertFalse(button.isEnabled)
    }

    func testMenuSkeletonRendersWithoutEnteringAccessibilityTree() {
        let app = launchHost(scene: "sidebar")
        XCTAssertTrue(app.groups["sidebar-layout"].waitForExistence(timeout: 5))
        XCTAssertEqual(
            app.descendants(matching: .any).matching(identifier: "sidebar-menu-skeleton").count,
            0,
            "sidebar-menu-skeleton must be hidden from accessibility"
        )
    }

    func testPersistenceRestoresAcrossRelaunch() {
        let app = launchHost(scene: "sidebarpersisted")
        let trigger = app.buttons["sidebar-persisted-trigger"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        let echo = app.staticTexts["sidebar-persisted-echo"]

        // Drive to a known closed state before relaunching, so the
        // assertion does not depend on whatever a previous run left behind
        // in UserDefaults under this scene-private persistence key.
        if text(of: echo) != "Persisted: closed" {
            trigger.click()
        }
        XCTAssertEqual(text(of: echo), "Persisted: closed")

        app.terminate()
        app.launch()
        XCTAssertTrue(app.staticTexts["sidebar-persisted-echo"].waitForExistence(timeout: 5))
        XCTAssertEqual(
            text(of: app.staticTexts["sidebar-persisted-echo"]), "Persisted: closed",
            "collapse state must survive relaunch via persistenceKey"
        )

        // Round-trip the other direction so the test also proves this is
        // real persistence, not a coincidental default.
        app.buttons["sidebar-persisted-trigger"].click()
        XCTAssertEqual(text(of: app.staticTexts["sidebar-persisted-echo"]), "Persisted: open")
        app.terminate()
        app.launch()
        XCTAssertTrue(app.staticTexts["sidebar-persisted-echo"].waitForExistence(timeout: 5))
        XCTAssertEqual(text(of: app.staticTexts["sidebar-persisted-echo"]), "Persisted: open")
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "sidebar", appearance: "dark")
        XCTAssertTrue(app.groups["sidebar-layout"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "sidebar-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "sidebar", appearance: "light")
        XCTAssertTrue(app.groups["sidebar-layout"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app, excluding: .contrast)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "sidebar", appearance: "dark")
        XCTAssertTrue(app.groups["sidebar-layout"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app, excluding: .contrast)
    }

    /// A single click occasionally fails to hand the field keyboard focus in
    /// the validation host (typeText then throws "no keyboard focus"); click,
    /// wait for focus, and retry once before typing.
    private func focusAndType(_ field: XCUIElement, _ text: String, in app: XCUIApplication) {
        field.click()
        Thread.sleep(forTimeInterval: 0.4)
        // Type at the application level: macOS routes keystrokes to the
        // window's field editor, whose focus the AX TextField does not
        // always report (element-level typeText then refuses to dispatch).
        app.typeText(text)
    }
}
