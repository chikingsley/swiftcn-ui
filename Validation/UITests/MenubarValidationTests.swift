import XCTest

final class MenubarValidationTests: ValidationCase {
    // Each SCMenubarMenu's body root is a SwiftUI `Menu`, which macOS exposes
    // as an AXMenuButton (not AXButton); its identifier, label, and disabled
    // state live there. Opening one surfaces its entries as AXMenuItems by
    // title. `.firstMatch` guards against titles ("Undo") that also appear in
    // the always-present system menu bar subtree.
    func testEveryMenuRenders() {
        let app = launchHost(scene: "menubar")
        XCTAssertTrue(app.menuButtons["menubar-file-menu"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.menuButtons["menubar-view-menu"].exists)
        XCTAssertTrue(app.menuButtons["menubar-help-menu"].exists)
        XCTAssertTrue(app.menuButtons["menubar-vertical-edit-menu"].exists)
        XCTAssertTrue(app.menuButtons["menubar-disabled-menu"].exists)
        attachWindowScreenshot(of: app, named: "menubar-light")
    }

    func testPlainItemOpensNativeMenuAndRoutesIntoCallerState() {
        let app = launchHost(scene: "menubar")
        let fileMenu = app.menuButtons["menubar-file-menu"]
        XCTAssertTrue(fileMenu.waitForExistence(timeout: 5))
        fileMenu.click()

        let newFile = app.menuItems["New File"].firstMatch
        XCTAssertTrue(newFile.waitForExistence(timeout: 5), "native Menu did not expose its items")
        newFile.click()

        XCTAssertEqual(text(of: app.staticTexts["menubar-last-action"]), "Last action: New File")
        XCTAssertEqual(text(of: app.staticTexts["menubar-action-count"]), "Actions: 1")
    }

    func testDisabledItemCannotBeSelected() {
        let app = launchHost(scene: "menubar")
        app.menuButtons["menubar-file-menu"].click()
        let incognito = app.menuItems["New Incognito Window"].firstMatch
        XCTAssertTrue(incognito.waitForExistence(timeout: 5))
        XCTAssertFalse(incognito.isEnabled, "disabled item must not be selectable")
    }

    func testSubmenuItemRoutesIntoCallerState() {
        let app = launchHost(scene: "menubar")
        app.menuButtons["menubar-file-menu"].click()
        let share = app.menuItems["Share"].firstMatch
        XCTAssertTrue(share.waitForExistence(timeout: 5))
        share.click()

        let email = app.menuItems["Email"].firstMatch
        XCTAssertTrue(
            email.waitForExistence(timeout: 5),
            "submenu did not expand — nested-submenu reveal may need manual VoiceOver verification"
        )
        email.click()
        XCTAssertEqual(text(of: app.staticTexts["menubar-last-action"]), "Last action: Email")
    }

    func testCheckboxItemTogglesCallerOwnedBinding() {
        let app = launchHost(scene: "menubar")
        XCTAssertEqual(text(of: app.staticTexts["menubar-bookmarks-value"]), "Bookmarks: on")

        app.menuButtons["menubar-view-menu"].click()
        let checkbox = app.menuItems["Show Bookmarks"].firstMatch
        XCTAssertTrue(checkbox.waitForExistence(timeout: 5))
        checkbox.click()

        XCTAssertEqual(text(of: app.staticTexts["menubar-bookmarks-value"]), "Bookmarks: off")
    }

    func testRadioGroupSelectionRoutesIntoCallerState() {
        let app = launchHost(scene: "menubar")
        XCTAssertEqual(text(of: app.staticTexts["menubar-theme-value"]), "Theme: system")

        app.menuButtons["menubar-view-menu"].click()
        let darkOption = app.menuItems["Dark"].firstMatch
        XCTAssertTrue(darkOption.waitForExistence(timeout: 5))
        darkOption.click()

        XCTAssertEqual(text(of: app.staticTexts["menubar-theme-value"]), "Theme: dark")
    }

    func testVerticalOrientationRoutesIntoCallerState() {
        let app = launchHost(scene: "menubar")
        let editMenu = app.menuButtons["menubar-vertical-edit-menu"]
        XCTAssertTrue(editMenu.waitForExistence(timeout: 5))
        editMenu.click()

        let undo = app.menuItems["Undo"].firstMatch
        XCTAssertTrue(undo.waitForExistence(timeout: 5))
        undo.click()
        XCTAssertEqual(text(of: app.staticTexts["menubar-last-action"]), "Last action: Undo")
    }

    func testPerMenuDisabledTriggerIsExposedAsDisabled() {
        let app = launchHost(scene: "menubar")
        let help = app.menuButtons["menubar-help-menu"]
        XCTAssertTrue(help.waitForExistence(timeout: 5))
        XCTAssertFalse(help.isEnabled)
    }

    func testWholeMenubarDisabledPropagatesToChildMenu() {
        let app = launchHost(scene: "menubar")
        let disabled = app.menuButtons["menubar-disabled-menu"]
        XCTAssertTrue(disabled.waitForExistence(timeout: 5))
        XCTAssertFalse(disabled.isEnabled, "SCMenubar(isDisabled: true) must disable its child menus")
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "menubar", appearance: "dark")
        XCTAssertTrue(app.menuButtons["menubar-file-menu"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "menubar-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "menubar", appearance: "light")
        XCTAssertTrue(app.menuButtons["menubar-file-menu"].waitForExistence(timeout: 5))
        // Audited at rest (menus closed). The `.action` dimension is excluded:
        // each SCMenubarMenu's `Menu` surfaces as an AXMenuButton whose
        // activation is menu-open, which Apple's `.action` audit flags as
        // "missing accessibility action support equivalent to click/tap" even
        // though it is provably clickable (testPlainItemOpensNativeMenu...) and
        // VoiceOver can open it. Framework false positive; every other audit
        // dimension still runs, and the destructive "Delete File" popup content
        // remains a manual VoiceOver item.
        try runAccessibilityAudit(on: app, excluding: .action)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "menubar", appearance: "dark")
        XCTAssertTrue(app.menuButtons["menubar-file-menu"].waitForExistence(timeout: 5))
        // Same SwiftUI Menu `.action` false positive as light mode.
        try runAccessibilityAudit(on: app, excluding: .action)
    }
}
