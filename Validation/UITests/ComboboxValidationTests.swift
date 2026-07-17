import XCTest

final class ComboboxValidationTests: ValidationCase {
    // SCComboboxTrigger is a real AXButton (value "Collapsed"/"Expanded"), and
    // SCComboboxContent presents through SCOverlayPortal's NSPanel, which macOS
    // exposes as a sibling AXDialog (like the HoverCard/Popover panels).
    //
    // Framework option rows go through SCComboboxCollection, whose
    // SCComboboxRowSelectionModifier applies `.accessibilityElement(children:
    // .ignore).accessibilityLabel(option.label)` — this replaces the row's
    // accessibility subtree and DROPS any inner identifier, so those rows are
    // only queryable by their label (e.g. "Next.js"), not the scene's
    // "combobox-framework-option-*" ids. The manually composed color rows use
    // SCComboboxItem, which keeps its identifier, so those stay queryable by id.
    func testEveryInstanceRenders() {
        let app = launchHost(scene: "combobox")
        XCTAssertTrue(app.buttons["combobox-framework-trigger"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.textFields["combobox-color-input"].exists)
        XCTAssertTrue(app.buttons["combobox-disabled-trigger"].exists)
        attachWindowScreenshot(of: app, named: "combobox-light")
    }

    func testFrameworkSearchFiltersAndSelectionRoutesIntoCallerState() {
        let app = launchHost(scene: "combobox")
        let trigger = app.buttons["combobox-framework-trigger"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        trigger.click()

        let nextOption = app.buttons["Next.js"]
        XCTAssertTrue(nextOption.waitForExistence(timeout: 5), "combobox content did not present")
        XCTAssertTrue(app.buttons["SvelteKit"].exists)

        let searchField = app.textFields.matching(
            NSPredicate(format: "placeholderValue == %@", "Search frameworks…")
        ).firstMatch
        XCTAssertTrue(searchField.exists, "search field is missing")
        searchField.click()
        searchField.typeText("Sve")

        XCTAssertTrue(app.buttons["SvelteKit"].waitForExistence(timeout: 5))
        XCTAssertFalse(
            nextOption.exists,
            "search must filter out options that do not match the query"
        )

        app.buttons["SvelteKit"].click()
        // The scene echoes the caller-owned selection binding, which stores the
        // option's value ("sveltekit"), not its display label ("SvelteKit") —
        // proving the value routed into caller state.
        XCTAssertEqual(text(of: app.staticTexts["combobox-framework-value"]), "Framework value: sveltekit")
        XCTAssertEqual(text(of: app.staticTexts["combobox-framework-change-count"]), "Framework changes: 1")
        // Single-select choosing an option closes the popover, so the open
        // binding fires twice across one full cycle: opening the trigger and
        // auto-closing on selection.
        XCTAssertEqual(
            text(of: app.staticTexts["combobox-framework-open-change-count"]),
            "Framework open changes: 2"
        )
        XCTAssertTrue(nextOption.waitForNonExistence(timeout: 2), "combobox content did not dismiss")
    }

    func testDisabledOptionCannotBeSelected() {
        let app = launchHost(scene: "combobox")
        app.buttons["combobox-framework-trigger"].click()
        let disabledOption = app.buttons["Remix"]
        XCTAssertTrue(disabledOption.waitForExistence(timeout: 5))
        XCTAssertFalse(disabledOption.isEnabled, "disabled option must not be selectable")
    }

    func testPreselectedColorChipRendersAndRemovalRoutesIntoCallerState() {
        let app = launchHost(scene: "combobox")
        let echo = app.staticTexts["combobox-color-value"]
        XCTAssertTrue(echo.waitForExistence(timeout: 5))
        // The scene seeds one selected color, so its removable chip renders in
        // the always-visible SCComboboxChips input (in the window, not the
        // portal panel), making the chip + removal + caller-binding path fully
        // reachable.
        XCTAssertEqual(text(of: echo), "Color value: Green")

        let removeChip = app.buttons["Remove"].firstMatch
        XCTAssertTrue(removeChip.waitForExistence(timeout: 5), "seeded color must render as a removable chip")
        removeChip.click()
        XCTAssertEqual(text(of: echo), "Color value: ")
        XCTAssertEqual(text(of: app.staticTexts["combobox-color-change-count"]), "Color changes: 1")
    }

    func testColorOptionRowClickRoutesSelectionIntoCallerState() {
        let app = launchHost(scene: "combobox")
        let input = app.textFields["combobox-color-input"]
        XCTAssertTrue(input.waitForExistence(timeout: 5))
        input.click()

        let redOption = app.buttons["combobox-color-option-Red"]
        XCTAssertTrue(redOption.waitForExistence(timeout: 5), "color option rows must present in the panel")
        redOption.click()

        // "Green" is pre-seeded; clicking "Red" adds it (multi-select), so the
        // caller-owned set becomes both, confirming SCComboboxItem routes a
        // real selection into caller state through the opaque popover panel.
        XCTAssertEqual(text(of: app.staticTexts["combobox-color-value"]), "Color value: Green, Red")
        XCTAssertEqual(text(of: app.staticTexts["combobox-color-change-count"]), "Color changes: 1")
    }

    func testDisabledComboboxTriggerIsExposedAsDisabled() {
        let app = launchHost(scene: "combobox")
        let trigger = app.buttons["combobox-disabled-trigger"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        XCTAssertFalse(trigger.isEnabled)
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "combobox", appearance: "dark")
        XCTAssertTrue(app.buttons["combobox-framework-trigger"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "combobox-dark")
    }

    // Audited at rest (popover closed). Auditing with the SCOverlayPortal
    // NSPanel open both timed out Apple's audit (Code -56, "Audit failed to
    // complete in time") in dark mode and false-positived the muted group
    // header's contrast, so — consistent with the "menus/panels closed"
    // approach for the selection family — the panel's presented content is
    // exercised for behavior in the interaction tests and its VoiceOver
    // traversal remains manual VALIDATION. The muted list header
    // (mutedForeground) that the sampler flags is tolerated with its computed
    // ratio below.
    private var comboboxMutedContrastFindings: [KnownAuditFinding] {
        // Any muted combobox group/list header the sampler flags: mutedForeground
        // (zinc-600 #52525C light / zinc-400 #9F9FA9 dark) on the popover surface
        // (white light / zinc-900 #18181B dark) computes to 7.72:1 (light) and
        // 6.75:1 (dark) — both clear WCAG AA text (4.5:1). Identifier-less, so
        // matched by "".
        [KnownAuditFinding(descriptionContains: "Contrast", identifier: "")]
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "combobox", appearance: "light")
        XCTAssertTrue(app.buttons["combobox-framework-trigger"].waitForExistence(timeout: 5))
        // The color combobox's SCOverlayPortal panel is presented at rest, so
        // its NSPanel surfaces as an AXDialog the audit reports as having no
        // description — the identical system-owned-container false positive the
        // Popover/HoverCard suites exclude; VoiceOver traversal of that
        // container is manual VALIDATION. Its muted "Colors" list header's
        // contrast is tolerated with the computed ratio above.
        try runAccessibilityAudit(
            on: app,
            tolerating: comboboxMutedContrastFindings,
            excluding: .sufficientElementDescription
        )
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "combobox", appearance: "dark")
        XCTAssertTrue(app.buttons["combobox-framework-trigger"].waitForExistence(timeout: 5))
        // Same system-owned AXDialog + muted-header false positives as light.
        try runAccessibilityAudit(
            on: app,
            tolerating: comboboxMutedContrastFindings,
            excluding: .sufficientElementDescription
        )
    }
}
