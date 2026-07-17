import XCTest

final class CommandValidationTests: ValidationCase {
    func testInlineListRendersAndFiltersBySearchAndKeywords() {
        let app = launchHost(scene: "command")
        XCTAssertTrue(app.buttons["Calendar"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Search Emoji"].exists)
        XCTAssertTrue(app.buttons["Profile"].exists)
        XCTAssertTrue(app.buttons["Billing"].exists)

        let searchField = app.textFields.matching(
            NSPredicate(format: "placeholderValue == %@", "Search commands…")
        ).firstMatch
        XCTAssertTrue(searchField.exists)
        searchField.click()
        searchField.typeText("smiley")

        XCTAssertTrue(app.buttons["Search Emoji"].waitForExistence(timeout: 5))
        XCTAssertFalse(app.buttons["Calendar"].exists, "keyword search must filter out non-matching items")
        XCTAssertFalse(app.buttons["Profile"].exists)
        attachWindowScreenshot(of: app, named: "command-light")
    }

    func testInlineSelectionRoutesIntoCallerState() {
        let app = launchHost(scene: "command")
        let calendar = app.buttons["Calendar"]
        XCTAssertTrue(calendar.waitForExistence(timeout: 5))
        calendar.click()

        XCTAssertEqual(text(of: app.staticTexts["command-inline-run-count"]), "Inline runs: 1")
        XCTAssertEqual(text(of: app.staticTexts["command-last-inline-run"]), "Last inline: Calendar")
    }

    func testGenericCollectionSupportsPerItemDisabling() {
        let app = launchHost(scene: "command")
        let enabledTask = app.buttons["Enabled Task"]
        let disabledTask = app.buttons["Disabled Task"]
        XCTAssertTrue(enabledTask.waitForExistence(timeout: 5))
        XCTAssertTrue(disabledTask.exists)
        XCTAssertFalse(disabledTask.isEnabled, "isItemEnabled must disable the generic collection's row")

        enabledTask.click()
        XCTAssertEqual(text(of: app.staticTexts["command-task-run-count"]), "Task runs: 1")
        XCTAssertEqual(text(of: app.staticTexts["command-last-task-run"]), "Last task: Enabled Task")
    }

    func testDisabledRootDisablesInputAndItems() {
        let app = launchHost(scene: "command")
        let disabledItem = app.buttons["command-disabled-item"]
        XCTAssertTrue(disabledItem.waitForExistence(timeout: 5))
        XCTAssertFalse(disabledItem.isEnabled)

        let disabledSearch = app.textFields.matching(
            NSPredicate(format: "placeholderValue == %@", "Disabled search…")
        ).firstMatch
        XCTAssertTrue(disabledSearch.exists)
        XCTAssertFalse(disabledSearch.isEnabled, "SCCommandRoot(isDisabled: true) must disable its input too")
    }

    func testPaletteOpensRunsSelectedActionAndDismisses() {
        let app = launchHost(scene: "command")
        let trigger = app.buttons["command-palette-trigger"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        trigger.click()

        let actionA = app.buttons["Palette Action A"]
        XCTAssertTrue(actionA.waitForExistence(timeout: 5), "command palette did not present")
        XCTAssertTrue(
            app.textFields.matching(
                NSPredicate(format: "placeholderValue == %@", "Search palette…")
            ).firstMatch.exists
        )

        actionA.click()
        XCTAssertTrue(actionA.waitForNonExistence(timeout: 2), "choosing an item must dismiss the palette")
        XCTAssertEqual(text(of: app.staticTexts["command-palette-run-count"]), "Palette runs: 1")
        XCTAssertEqual(text(of: app.staticTexts["command-last-palette-run"]), "Last palette: Palette Action A")
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "command", appearance: "dark")
        XCTAssertTrue(app.buttons["Calendar"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "command-dark")
    }

    // The audit flags SCCommandSeparator — a decorative 1pt hairline
    // (Rectangle().fill(theme.border).frame(height: 1)) that the library
    // already marks `.accessibilityHidden(true)` — with "Unknown role":
    // SwiftUI still surfaces the hidden hairline to the audit as a role-less
    // "Other" element. It carries no text, no action, and no identifier, so it
    // is matched by an empty identifier. This is a benign framework artifact of
    // a decorative divider, not a contrast, description, or interaction defect.
    private var separatorRoleFindings: [KnownAuditFinding] {
        [KnownAuditFinding(descriptionContains: "Unknown role", identifier: "")]
    }

    // The dark audit's sampler flags the muted "Tasks" group heading
    // (SCCommandGroupView: mutedForeground caption on the popover surface) —
    // the same token pair the Combobox suite tolerates. zinc-400 (#9F9FA9) on
    // zinc-900 (#18181B) computes to 6.75:1, clearing WCAG AA text (4.5:1);
    // the light pair (zinc-600 on white, 7.72:1) passes the sampler without
    // toleration, so only the dark audit carries this finding. Identifier-less
    // heading text, so matched by "".
    private var mutedHeadingContrastFindings: [KnownAuditFinding] {
        [KnownAuditFinding(descriptionContains: "Contrast", identifier: "")]
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "command", appearance: "light")
        XCTAssertTrue(app.buttons["Calendar"].waitForExistence(timeout: 5))
        // Audited at rest with the ⌘K palette closed. The inline SCCommandList
        // and the generic SCCommandCollection are always-visible real command
        // content, so this still audits the component's rendered surface; the
        // palette's presentation path is exercised for behavior in
        // testPaletteOpensRunsSelectedActionAndDismisses.
        try runAccessibilityAudit(on: app, tolerating: separatorRoleFindings)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "command", appearance: "dark")
        XCTAssertTrue(app.buttons["Calendar"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(
            on: app,
            tolerating: separatorRoleFindings + mutedHeadingContrastFindings
        )
    }
}
