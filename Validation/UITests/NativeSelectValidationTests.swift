import XCTest

final class NativeSelectValidationTests: ValidationCase {
    func testEveryInstanceRenders() {
        let app = launchHost(scene: "nativeselect")
        XCTAssertTrue(app.popUpButtons["nativeselect-controlled"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.popUpButtons["nativeselect-small"].exists)
        XCTAssertTrue(app.popUpButtons["nativeselect-invalid"].exists)
        XCTAssertTrue(app.popUpButtons["nativeselect-disabled"].exists)
        attachWindowScreenshot(of: app, named: "nativeselect-light")
    }

    func testControlledSelectionRoutesIntoCallerStateThroughGroups() {
        let app = launchHost(scene: "nativeselect")
        let picker = app.popUpButtons["nativeselect-controlled"]
        XCTAssertTrue(picker.waitForExistence(timeout: 5))
        picker.click()

        // Options from both SCNativeSelectOptGroup sections surface.
        XCTAssertTrue(
            app.menuItems["Grapes"].firstMatch.waitForExistence(timeout: 5),
            "native Picker did not expose grouped options"
        )
        XCTAssertTrue(app.menuItems["Carrot"].firstMatch.exists)

        app.menuItems["Blueberry"].firstMatch.click()
        XCTAssertEqual(text(of: app.staticTexts["nativeselect-controlled-value"]), "Controlled: blueberry")
        XCTAssertEqual(text(of: app.staticTexts["nativeselect-change-count"]), "Changes: 1")
    }

    // SwiftUI's `Picker(.menu)` ignores a per-option `.disabled(...)`, so
    // SCNativeSelectOption also applies `.selectionDisabled(isDisabled)` —
    // the macOS 14/iOS 17 API for exactly this — which validation confirmed
    // does disable the menu item (isEnabled == false, not selectable).
    func testDisabledOptionIsNotSelectable_knownSwiftUIPickerGap() {
        let app = launchHost(scene: "nativeselect")
        let picker = app.popUpButtons["nativeselect-controlled"]
        XCTAssertTrue(picker.waitForExistence(timeout: 5))
        picker.click()

        let disabledOption = app.menuItems["Grapes"].firstMatch
        XCTAssertTrue(disabledOption.waitForExistence(timeout: 5))
        XCTAssertFalse(
            disabledOption.isEnabled,
            "SCNativeSelectOption(isDisabled: true) must disable the option, but SwiftUI Picker(.menu) ignores it"
        )
    }

    func testSmallSizedSelectRoutesIntoCallerState() {
        let app = launchHost(scene: "nativeselect")
        let picker = app.popUpButtons["nativeselect-small"]
        XCTAssertTrue(picker.waitForExistence(timeout: 5))
        picker.click()
        app.menuItems["Carrot"].firstMatch.click()
        XCTAssertEqual(text(of: app.staticTexts["nativeselect-small-value"]), "Small: carrot")
    }

    func testInvalidSelectRenders() {
        let app = launchHost(scene: "nativeselect")
        let invalid = app.popUpButtons["nativeselect-invalid"]
        XCTAssertTrue(invalid.waitForExistence(timeout: 5))
        // The destructive-tinted border NativeSelect.swift's `border` draws
        // for isInvalid is visual-only, not exposed as a queryable property;
        // it remains a manual VoiceOver/visual item, evidenced by the
        // screenshot below.
        attachWindowScreenshot(of: app, named: "nativeselect-invalid-light")
    }

    func testDisabledSelectIsExposedAsDisabled() {
        let app = launchHost(scene: "nativeselect")
        let disabled = app.popUpButtons["nativeselect-disabled"]
        XCTAssertTrue(disabled.waitForExistence(timeout: 5))
        XCTAssertFalse(disabled.isEnabled)
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "nativeselect", appearance: "dark")
        XCTAssertTrue(app.popUpButtons["nativeselect-controlled"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "nativeselect-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "nativeselect", appearance: "light")
        XCTAssertTrue(app.popUpButtons["nativeselect-controlled"].waitForExistence(timeout: 5))
        // Audited at rest. The `.action` dimension is excluded for the same
        // SwiftUI reason as Select: `Picker(.menu)` surfaces as an
        // AXPopUpButton whose activation is menu-open, which Apple's `.action`
        // audit flags as "missing accessibility action support equivalent to
        // click/tap" even though it is provably clickable
        // (testControlledSelectionRoutesIntoCallerStateThroughGroups) and
        // VoiceOver can open it. Framework false positive; every other audit
        // dimension still runs.
        try runAccessibilityAudit(on: app, excluding: .action)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "nativeselect", appearance: "dark")
        XCTAssertTrue(app.popUpButtons["nativeselect-controlled"].waitForExistence(timeout: 5))
        // Same SwiftUI Picker `.action` false positive as light mode.
        try runAccessibilityAudit(on: app, excluding: .action)
    }
}
