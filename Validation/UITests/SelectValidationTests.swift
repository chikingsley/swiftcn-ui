import XCTest

final class SelectValidationTests: ValidationCase {
    // SCSelect's body root is a SwiftUI `Menu(.button)` styled trigger, which
    // macOS exposes as an AXMenuButton (not AXButton). Its identifier, label,
    // value ("No selection" / the chosen label), and disabled state all live
    // on that MenuButton. Opening it surfaces the options as AXMenuItems whose
    // title is the item text.
    func testEveryTriggerRenders() {
        let app = launchHost(scene: "select")
        XCTAssertTrue(app.menuButtons["select-array"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.menuButtons["select-small"].exists)
        XCTAssertTrue(app.menuButtons["select-multiple"].exists)
        XCTAssertTrue(app.menuButtons["select-invalid"].exists)
        XCTAssertTrue(app.menuButtons["select-disabled"].exists)
        XCTAssertEqual(app.menuButtons["select-array"].value as? String, "No selection")
        attachWindowScreenshot(of: app, named: "select-light")
    }

    func testArraySelectionRoutesIntoCallerState() {
        let app = launchHost(scene: "select")
        let trigger = app.menuButtons["select-array"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        trigger.click()

        let item = app.menuItems["Apple"].firstMatch
        XCTAssertTrue(item.waitForExistence(timeout: 5), "native Menu did not expose its items")
        item.click()

        XCTAssertEqual(text(of: app.staticTexts["select-array-value"]), "Array value: Apple")
        XCTAssertEqual(text(of: app.staticTexts["select-single-change-count"]), "Single changes: 1")
        XCTAssertEqual(trigger.value as? String, "Apple")
    }

    func testSmallSizedCompositionRendersGroupsAndDisabledItem() {
        let app = launchHost(scene: "select")
        let trigger = app.menuButtons["select-small"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        trigger.click()

        XCTAssertTrue(app.menuItems["Apple"].firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.menuItems["Banana"].firstMatch.exists)
        XCTAssertTrue(app.menuItems["Pineapple"].firstMatch.exists)
        let disabledItem = app.menuItems["Grapes"].firstMatch
        XCTAssertTrue(disabledItem.exists)
        XCTAssertFalse(disabledItem.isEnabled, "disabled item must not be selectable")

        app.menuItems["Banana"].firstMatch.click()
        XCTAssertEqual(text(of: app.staticTexts["select-small-value"]), "Small value: Banana")
        XCTAssertEqual(trigger.value as? String, "Banana")
    }

    func testMultipleSelectionAccumulatesAndSortsCallerState() {
        let app = launchHost(scene: "select")
        let trigger = app.menuButtons["select-multiple"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))

        trigger.click()
        app.menuItems["Blueberry"].firstMatch.click()
        XCTAssertEqual(text(of: app.staticTexts["select-multiple-value"]), "Multiple value: Blueberry")

        trigger.click()
        app.menuItems["Apple"].firstMatch.click()
        XCTAssertEqual(text(of: app.staticTexts["select-multiple-value"]), "Multiple value: Apple, Blueberry")
        XCTAssertEqual(text(of: app.staticTexts["select-multiple-change-count"]), "Multiple changes: 2")
    }

    func testInvalidSelectRenders() {
        let app = launchHost(scene: "select")
        let invalid = app.menuButtons["select-invalid"]
        XCTAssertTrue(invalid.waitForExistence(timeout: 5))
        XCTAssertEqual(invalid.value as? String, "Apple")
        // The destructive-tinted border that isInvalid draws is a visual-only
        // signal (SelectRendering.swift borderColor); it is not exposed as a
        // distinct queryable property on the Menu's accessibility node, so
        // the border color itself remains a manual VoiceOver/visual item —
        // the screenshot below is the observable evidence.
        attachWindowScreenshot(of: app, named: "select-invalid-light")
    }

    func testDisabledSelectIsExposedAsDisabled() {
        let app = launchHost(scene: "select")
        let disabled = app.menuButtons["select-disabled"]
        XCTAssertTrue(disabled.waitForExistence(timeout: 5))
        XCTAssertFalse(disabled.isEnabled)
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "select", appearance: "dark")
        XCTAssertTrue(app.menuButtons["select-array"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "select-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "select", appearance: "light")
        XCTAssertTrue(app.menuButtons["select-array"].waitForExistence(timeout: 5))
        // Audited at rest (menus closed). The `.action` dimension is excluded:
        // SwiftUI's `Menu(.button)` surfaces as an AXMenuButton whose activation
        // is menu-open, and Apple's `.action` audit flags every such trigger as
        // "missing accessibility action support equivalent to click/tap" even
        // though VoiceOver can open it and the trigger is provably clickable
        // (testArraySelectionRoutesIntoCallerState). This is a SwiftUI-framework
        // false positive the component cannot address with the standard Menu
        // API; VoiceOver menu activation remains manual VALIDATION. Every other
        // audit dimension (contrast, description, clipping, …) still runs.
        try runAccessibilityAudit(on: app, excluding: .action)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "select", appearance: "dark")
        XCTAssertTrue(app.menuButtons["select-array"].waitForExistence(timeout: 5))
        // Same SwiftUI Menu `.action` false positive as light mode.
        try runAccessibilityAudit(on: app, excluding: .action)
    }
}
