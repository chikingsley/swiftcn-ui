import XCTest

final class InputGroupValidationTests: ValidationCase {
    func testEveryAddonAndControlRenders() {
        let app = launchHost(scene: "inputgroup")
        let search = searchField(in: app)
        XCTAssertTrue(search.waitForExistence(timeout: 5))

        XCTAssertTrue(app.images["Search icon"].exists)
        XCTAssertTrue(app.staticTexts["inputgroup-query-length"].exists)
        XCTAssertTrue(app.buttons["inputgroup-copy-button"].exists)
        XCTAssertTrue(textarea(in: app).exists)
        XCTAssertTrue(app.staticTexts["inputgroup-block-start-addon"].exists)
        XCTAssertTrue(app.buttons["inputgroup-refresh-button"].exists)
        XCTAssertTrue(invalidField(in: app).exists)
        XCTAssertTrue(disabledField(in: app).exists)
        attachWindowScreenshot(of: app, named: "inputgroup-light")
    }

    func testTypingRoutesIntoCallerOwnedStringBindingAndLengthAddon() {
        let app = launchHost(scene: "inputgroup")
        let field = searchField(in: app)
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        focusAndType(field, "swiftcn", in: app)
        XCTAssertEqual(text(of: app.staticTexts["inputgroup-query-echo"]), "Query: swiftcn")
        XCTAssertEqual(text(of: app.staticTexts["inputgroup-query-length"]), "7")
    }

    func testCopyButtonAddonRoutesItsAction() {
        let app = launchHost(scene: "inputgroup")
        let button = app.buttons["inputgroup-copy-button"]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        button.click()
        button.click()
        XCTAssertEqual(text(of: app.staticTexts["inputgroup-copy-count"]), "Copy actions: 2")
    }

    func testLeadingAddonTapForwardsFocusToTheRealControlWithoutClickingIt() {
        let app = launchHost(scene: "inputgroup")
        // The magnifying-glass addon carries no button; SCInputGroupAddon's
        // own onTapGesture must request focus for the sibling control
        // (InputGroup.swift:327-337). Its inner Image's accessibilityLabel is
        // the stable handle now that the addon part cannot take an
        // identifier inside the typed builder. Typing immediately after,
        // without ever clicking the field, is the strongest proof focus
        // genuinely moved.
        let addon = app.images["Search icon"]
        XCTAssertTrue(addon.waitForExistence(timeout: 5))
        addon.click()
        app.typeText("routed")
        XCTAssertEqual(text(of: app.staticTexts["inputgroup-query-echo"]), "Query: routed")
    }

    func testTrailingTextAddonTapForwardsFocusWithoutTriggeringItsSiblingButton() {
        let app = launchHost(scene: "inputgroup")
        let lengthText = app.staticTexts["inputgroup-query-length"]
        XCTAssertTrue(lengthText.waitForExistence(timeout: 5))

        lengthText.click()
        app.typeText("hi")
        XCTAssertEqual(text(of: app.staticTexts["inputgroup-query-echo"]), "Query: hi")
        XCTAssertEqual(
            text(of: app.staticTexts["inputgroup-copy-count"]),
            "Copy actions: 0",
            "tapping the addon's text must not also activate its sibling button"
        )
    }

    func testTextareaBlockAddonsRenderAndRouteTypingAndButtonAction() {
        let app = launchHost(scene: "inputgroup")
        let editor = textarea(in: app)
        XCTAssertTrue(editor.waitForExistence(timeout: 5))

        focusAndType(editor, "Great work", in: app)
        XCTAssertEqual(text(of: app.staticTexts["inputgroup-message-echo"]), "Message: Great work")
        XCTAssertEqual(
            text(of: app.staticTexts["inputgroup-character-count"]),
            "10/500 characters"
        )

        app.buttons["inputgroup-refresh-button"].click()
        XCTAssertEqual(text(of: app.staticTexts["inputgroup-refresh-count"]), "Refresh actions: 1")
    }

    func testInvalidInputGroupRemainsFunctional() {
        let app = launchHost(scene: "inputgroup")
        let field = invalidField(in: app)
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        focusAndType(field, "!", in: app)
        XCTAssertEqual(text(of: app.staticTexts["inputgroup-invalid-echo"]), "Invalid field: bad-value!")

        // SCInputGroup resolves isInvalid to theme.destructive on its border
        // and forwards \.scFieldInvalid to the child, which only surfaces as
        // an accessibilityHint (Input.swift:138); XCTest's macOS snapshot
        // omits AXHelp entirely (see TooltipValidationTests), so the invalid
        // border/hint itself remains a manual VoiceOver check. This proves
        // the invalid instance is still a real, editable control.
        print("SC-MANUAL-VALIDATION: inputgroup-invalid AXHelp must read 'Invalid entry'")
    }

    func testDisabledGroupExposesDisabledControl() {
        let app = launchHost(scene: "inputgroup")
        let field = disabledField(in: app)
        XCTAssertTrue(field.waitForExistence(timeout: 5))
        XCTAssertFalse(field.isEnabled)
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "inputgroup", appearance: "dark")
        XCTAssertTrue(searchField(in: app).waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "inputgroup-dark")
    }

    // The sampler flags the 13px muted addon texts ("Comment", the length
    // counter): mutedForeground on the input surface computes to 7.72:1
    // (light) and 7.59:1 (dark) — both clear WCAG AA text (4.5:1).
    // Identifier-less, so matched by "".
    private var mutedTextContrastFindings: [KnownAuditFinding] {
        [
            KnownAuditFinding(descriptionContains: "Contrast", identifier: ""),
            KnownAuditFinding(descriptionContains: "Contrast", identifier: "inputgroup-block-start-addon"),
            KnownAuditFinding(descriptionContains: "Contrast", identifier: "inputgroup-query-length"),
            KnownAuditFinding(descriptionContains: "Contrast", identifier: "inputgroup-character-count"),
        ]
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "inputgroup", appearance: "light")
        XCTAssertTrue(searchField(in: app).waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app, tolerating: mutedTextContrastFindings)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "inputgroup", appearance: "dark")
        XCTAssertTrue(searchField(in: app).waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app, tolerating: mutedTextContrastFindings)
    }

    // MARK: - Locators

    /// SCInputGroup uses a typed result builder that rejects a
    /// ModifiedContent-wrapped part, so the input and textarea controls carry
    /// no identifier of their own; the group container's identifier is the
    /// stable anchor, and each control is the sole field/text view scoped
    /// beneath it.
    private func group(_ identifier: String, in app: XCUIApplication) -> XCUIElement {
        app.descendants(matching: .any)[identifier]
    }

    private func searchField(in app: XCUIApplication) -> XCUIElement {
        group("inputgroup-inline", in: app).textFields.firstMatch
    }

    private func textarea(in app: XCUIApplication) -> XCUIElement {
        group("inputgroup-block", in: app).textViews.firstMatch
    }

    private func invalidField(in app: XCUIApplication) -> XCUIElement {
        group("inputgroup-invalid", in: app).textFields.firstMatch
    }

    private func disabledField(in app: XCUIApplication) -> XCUIElement {
        group("inputgroup-disabled", in: app).textFields.firstMatch
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
