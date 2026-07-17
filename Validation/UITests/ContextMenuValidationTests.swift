import XCTest

final class ContextMenuValidationTests: ValidationCase {
    // The scene's triggers are plain AXButtons (a merged accessibility element
    // with the .isButton trait). rightClick() presents the native context menu,
    // whose entries surface as AXMenuItems by title. `.firstMatch` guards
    // against titles ("Copy", "Delete") that also exist as disabled items in
    // the always-present system Edit menu subtree — the presented menu is first
    // in tree order, so firstMatch resolves to it.
    func testTriggersRender() {
        let app = launchHost(scene: "contextmenu")
        XCTAssertTrue(app.buttons["contextmenu-trigger"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["contextmenu-modifier-trigger"].exists)
        attachWindowScreenshot(of: app, named: "contextmenu-light")
    }

    func testRightClickOpensNativeMenuAndRoutesIntoCallerState() {
        let app = launchHost(scene: "contextmenu")
        let trigger = app.buttons["contextmenu-trigger"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        trigger.rightClick()

        let copy = app.menuItems["Copy"].firstMatch
        XCTAssertTrue(copy.waitForExistence(timeout: 5), "right-click did not expose a native context menu")
        copy.click()

        XCTAssertEqual(text(of: app.staticTexts["contextmenu-last-action"]), "Last action: Copy")
        XCTAssertEqual(text(of: app.staticTexts["contextmenu-action-count"]), "Actions: 1")
    }

    func testCheckboxItemTogglesCallerOwnedBinding() {
        let app = launchHost(scene: "contextmenu")
        XCTAssertEqual(text(of: app.staticTexts["contextmenu-bookmarks-value"]), "Bookmarks: on")

        app.buttons["contextmenu-trigger"].rightClick()
        let checkbox = app.menuItems["Show Bookmarks"].firstMatch
        XCTAssertTrue(checkbox.waitForExistence(timeout: 5))
        checkbox.click()

        XCTAssertEqual(text(of: app.staticTexts["contextmenu-bookmarks-value"]), "Bookmarks: off")
    }

    func testRadioGroupSelectionRoutesIntoCallerState() {
        let app = launchHost(scene: "contextmenu")
        XCTAssertEqual(text(of: app.staticTexts["contextmenu-theme-value"]), "Theme: system")

        app.buttons["contextmenu-trigger"].rightClick()
        let darkOption = app.menuItems["Dark"].firstMatch
        XCTAssertTrue(darkOption.waitForExistence(timeout: 5))
        darkOption.click()

        XCTAssertEqual(text(of: app.staticTexts["contextmenu-theme-value"]), "Theme: dark")
    }

    func testSubmenuItemRoutesIntoCallerStateAndDisabledSiblingCannotBeSelected() {
        let app = launchHost(scene: "contextmenu")
        app.buttons["contextmenu-trigger"].rightClick()
        let subTrigger = app.menuItems["More Tools"].firstMatch
        XCTAssertTrue(subTrigger.waitForExistence(timeout: 5))
        subTrigger.click()

        let unreachable = app.menuItems["Unreachable"].firstMatch
        XCTAssertTrue(
            unreachable.waitForExistence(timeout: 5),
            "submenu did not expand — nested-submenu reveal may need manual VoiceOver verification"
        )
        XCTAssertFalse(unreachable.isEnabled, "disabled submenu item must not be selectable")

        app.menuItems["Developer Tools"].firstMatch.click()
        XCTAssertEqual(text(of: app.staticTexts["contextmenu-last-action"]), "Last action: Developer Tools")
    }

    func testModifierFormRoutesIntoCallerState() {
        let app = launchHost(scene: "contextmenu")
        let trigger = app.buttons["contextmenu-modifier-trigger"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        trigger.rightClick()

        let action = app.menuItems["Modifier Action"].firstMatch
        XCTAssertTrue(action.waitForExistence(timeout: 5), "`.scContextMenu` did not attach a native context menu")
        action.click()

        XCTAssertEqual(text(of: app.staticTexts["contextmenu-modifier-action-count"]), "Modifier actions: 1")
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "contextmenu", appearance: "dark")
        XCTAssertTrue(app.buttons["contextmenu-trigger"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "contextmenu-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "contextmenu", appearance: "light")
        XCTAssertTrue(app.buttons["contextmenu-trigger"].waitForExistence(timeout: 5))
        // Audited at rest (menus closed): opening a real native NSMenu (which
        // includes a destructive "Delete" item) during Apple's programmatic
        // audit risks the audit's own traversal dispatching synthetic events
        // into the live popup. Every trigger's label is already asserted above
        // through the real accessibility tree; native context-menu popup
        // content remains a manual VoiceOver item.
        try runAccessibilityAudit(on: app)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "contextmenu", appearance: "dark")
        XCTAssertTrue(app.buttons["contextmenu-trigger"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }
}
