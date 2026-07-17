import XCTest

final class DropdownMenuValidationTests: ValidationCase {
    // SCDropdownMenu's body root is a SwiftUI `Menu`, which macOS exposes as an
    // AXMenuButton (not AXButton); its identifier, label, and disabled state
    // live there. Opening it surfaces actions/checkbox/radio/submenu entries as
    // AXMenuItems by title. `.firstMatch` guards against titles that also
    // appear in the always-present system menu bar subtree.
    func testTriggersRender() {
        let app = launchHost(scene: "dropdownmenu")
        XCTAssertTrue(app.menuButtons["dropdownmenu-trigger"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.menuButtons["dropdownmenu-disabled"].exists)
        attachWindowScreenshot(of: app, named: "dropdownmenu-light")
    }

    func testPlainItemOpensNativeMenuAndRoutesIntoCallerState() {
        let app = launchHost(scene: "dropdownmenu")
        let trigger = app.menuButtons["dropdownmenu-trigger"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        trigger.click()

        let billing = app.menuItems["Billing"].firstMatch
        XCTAssertTrue(billing.waitForExistence(timeout: 5), "native Menu did not expose its items")
        billing.click()

        XCTAssertEqual(text(of: app.staticTexts["dropdownmenu-last-action"]), "Last action: Billing")
        XCTAssertEqual(text(of: app.staticTexts["dropdownmenu-action-count"]), "Actions: 1")
    }

    func testDisabledItemCannotBeSelected() {
        let app = launchHost(scene: "dropdownmenu")
        app.menuButtons["dropdownmenu-trigger"].click()
        let apiItem = app.menuItems["API"].firstMatch
        XCTAssertTrue(apiItem.waitForExistence(timeout: 5))
        XCTAssertFalse(apiItem.isEnabled, "disabled item must not be selectable")
    }

    func testCheckboxItemTogglesCallerOwnedBinding() {
        let app = launchHost(scene: "dropdownmenu")
        XCTAssertEqual(text(of: app.staticTexts["dropdownmenu-status-bar-value"]), "Status bar: on")

        app.menuButtons["dropdownmenu-trigger"].click()
        let checkbox = app.menuItems["Show Status Bar"].firstMatch
        XCTAssertTrue(checkbox.waitForExistence(timeout: 5))
        checkbox.click()

        XCTAssertEqual(text(of: app.staticTexts["dropdownmenu-status-bar-value"]), "Status bar: off")
    }

    func testRadioGroupSelectionRoutesIntoCallerState() {
        let app = launchHost(scene: "dropdownmenu")
        XCTAssertEqual(text(of: app.staticTexts["dropdownmenu-position-value"]), "Position: bottom")

        app.menuButtons["dropdownmenu-trigger"].click()
        let topOption = app.menuItems["Top"].firstMatch
        XCTAssertTrue(topOption.waitForExistence(timeout: 5))
        topOption.click()

        XCTAssertEqual(text(of: app.staticTexts["dropdownmenu-position-value"]), "Position: top")
    }

    func testSubmenuItemRoutesIntoCallerState() {
        let app = launchHost(scene: "dropdownmenu")
        app.menuButtons["dropdownmenu-trigger"].click()
        let subTrigger = app.menuItems["Invite Users"].firstMatch
        XCTAssertTrue(subTrigger.waitForExistence(timeout: 5))
        subTrigger.click()

        let email = app.menuItems["Email"].firstMatch
        XCTAssertTrue(
            email.waitForExistence(timeout: 5),
            "submenu did not expand — nested-submenu reveal may need manual VoiceOver verification"
        )
        email.click()
        XCTAssertEqual(text(of: app.staticTexts["dropdownmenu-last-action"]), "Last action: Email")
    }

    func testDisabledTriggerIsExposedAsDisabled() {
        let app = launchHost(scene: "dropdownmenu")
        let disabled = app.menuButtons["dropdownmenu-disabled"]
        XCTAssertTrue(disabled.waitForExistence(timeout: 5))
        XCTAssertFalse(disabled.isEnabled)
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "dropdownmenu", appearance: "dark")
        XCTAssertTrue(app.menuButtons["dropdownmenu-trigger"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "dropdownmenu-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "dropdownmenu", appearance: "light")
        XCTAssertTrue(app.menuButtons["dropdownmenu-trigger"].waitForExistence(timeout: 5))
        // Audited at rest (menus closed). The `.action` dimension is excluded:
        // SwiftUI's `Menu` surfaces the trigger as an AXMenuButton whose
        // activation is menu-open, which Apple's `.action` audit flags as
        // "missing accessibility action support equivalent to click/tap" even
        // though it is provably clickable (testPlainItemOpensNativeMenu...) and
        // VoiceOver can open it. Framework false positive; every other audit
        // dimension still runs, and the destructive "Log Out" popup content
        // remains a manual VoiceOver item.
        try runAccessibilityAudit(on: app, excluding: .action)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "dropdownmenu", appearance: "dark")
        XCTAssertTrue(app.menuButtons["dropdownmenu-trigger"].waitForExistence(timeout: 5))
        // Same SwiftUI Menu `.action` false positive as light mode.
        try runAccessibilityAudit(on: app, excluding: .action)
    }
}
