import XCTest

/// Regression coverage for the manually composed `SCComboboxItem` path.
///
/// The macOS overlay mouse fix replaced a native `Button` with a tap gesture.
/// Mouse selection alone is therefore insufficient evidence: the row must stay
/// reachable without a mouse and must continue publishing an enabled Button
/// with a default accessibility action for VoiceOver.
final class ComboboxKeyboardAccessibilityValidationTests: ValidationCase {
    func testManualItemCanBeReachedAndActivatedWithoutAMouse() {
        let app = launchHost(scene: "combobox")
        let input = app.textFields["combobox-color-input"]
        XCTAssertTrue(input.waitForExistence(timeout: 5))
        input.click()

        let red = app.buttons["combobox-color-option-Red"]
        XCTAssertTrue(red.waitForExistence(timeout: 5))

        // macOS XCUITest cannot read keyboard-focus state directly. Drive the
        // user contract instead: Tab must enter the manually composed option
        // row and Return must invoke its selection action.
        app.typeKey(XCUIKeyboardKey.tab, modifierFlags: [])
        app.typeKey(XCUIKeyboardKey.return, modifierFlags: [])

        XCTAssertEqual(
            text(of: app.staticTexts["combobox-color-value"]),
            "Color value: Red",
            "SCComboboxItem must retain keyboard activation after its mouse hit-testing fix"
        )
        XCTAssertEqual(
            text(of: app.staticTexts["combobox-color-change-count"]),
            "Color changes: 1"
        )
    }

    func testManualItemPublishesTheVoiceOverButtonContract() {
        let app = launchHost(scene: "combobox")
        let input = app.textFields["combobox-color-input"]
        XCTAssertTrue(input.waitForExistence(timeout: 5))
        input.click()

        let red = app.descendants(matching: .any)["combobox-color-option-Red"]
        XCTAssertTrue(red.waitForExistence(timeout: 5))
        XCTAssertEqual(red.elementType, .button)
        XCTAssertTrue(red.isEnabled)

        // XCUITest cannot drive VoiceOver itself. Before landing the component
        // change, manually enable VoiceOver, navigate to Red, verify it is
        // announced as an enabled button, and activate it once with VO-Space;
        // the Color value must become Red and Color changes must become 1.
        print(
            "SC-MANUAL-VALIDATION: SCComboboxItem 'Red' must be announced as "
                + "an enabled button and activate once with VO-Space"
        )
    }
}
