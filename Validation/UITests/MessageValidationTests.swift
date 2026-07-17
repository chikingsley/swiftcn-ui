import XCTest

final class MessageValidationTests: ValidationCase {
    func testStartAndEndRowsRenderComposedHeaderContentAndFooter() {
        let app = launchHost(scene: "message")
        let startRow = app.groups["message-row-start"]
        XCTAssertTrue(startRow.waitForExistence(timeout: 5))

        XCTAssertTrue(startRow.staticTexts["message-header-text"].exists)
        XCTAssertEqual(text(of: startRow.staticTexts["message-header-text"]), "Olivia")
        XCTAssertTrue(startRow.staticTexts["message-footer-text"].exists)
        XCTAssertEqual(text(of: startRow.staticTexts["message-footer-text"]), "Read Yesterday")

        XCTAssertTrue(app.groups["message-row-end"].exists)
        attachWindowScreenshot(of: app, named: "message-light")
    }

    func testNestedFooterActionRoutesIntoCallerOwnedState() {
        let app = launchHost(scene: "message")
        let action = app.buttons["message-nested-action"]
        XCTAssertTrue(action.waitForExistence(timeout: 5))
        action.click()
        XCTAssertEqual(text(of: app.staticTexts["message-last-activated"]), "Last: footer-action")
        XCTAssertEqual(text(of: app.staticTexts["message-activation-count"]), "Activations: 1")
    }

    func testGroupPairsReservedAndPopulatedAvatars() {
        let app = launchHost(scene: "message")
        let group = app.descendants(matching: .any)["message-group"]
        XCTAssertTrue(group.waitForExistence(timeout: 5))
        // An empty SCMessageAvatar() renders nothing, so it never enters the
        // accessibility tree; the observable contract is the reserved
        // column — the empty-avatar row's bubble starts at the same x as the
        // populated-avatar row's bubble beneath it.
        let reservedRowBubble = group.staticTexts.matching(
            NSPredicate(format: "value BEGINSWITH %@", "It's always a one-line change")
        ).firstMatch
        let populatedRowBubble = group.staticTexts.matching(
            NSPredicate(format: "value BEGINSWITH %@", "Alright, let me take a look")
        ).firstMatch
        XCTAssertTrue(reservedRowBubble.exists)
        XCTAssertTrue(populatedRowBubble.exists)
        XCTAssertEqual(
            reservedRowBubble.frame.minX, populatedRowBubble.frame.minX, accuracy: 1,
            "an empty SCMessageAvatar() must still reserve the avatar column"
        )
    }

    func testDisabledRowBlocksItsNestedActionWithoutHidingIt() {
        let app = launchHost(scene: "message")
        XCTAssertTrue(app.groups["message-disabled"].waitForExistence(timeout: 5))
        let action = app.buttons["message-disabled-action"]
        XCTAssertTrue(action.exists, "disabling a row must not remove its nested content from the tree")
        XCTAssertFalse(action.isEnabled)
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "message", appearance: "dark")
        XCTAssertTrue(app.groups["message-row-start"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "message-dark")
    }

    // The sampler flags the 13px avatar fallback initials ("ME"):
    // mutedForeground on the muted avatar circle computes to 7.02:1 (light,
    // zinc-600 on zinc-100) and 5.65:1 (dark, zinc-400 on zinc-800) — both
    // clear WCAG AA text (4.5:1). Identifier-less, so matched by "".
    private var avatarInitialsContrastFindings: [KnownAuditFinding] {
        [KnownAuditFinding(descriptionContains: "Contrast", identifier: "")]
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "message", appearance: "light")
        XCTAssertTrue(app.groups["message-row-start"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app, tolerating: avatarInitialsContrastFindings)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "message", appearance: "dark")
        XCTAssertTrue(app.groups["message-row-start"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app, tolerating: avatarInitialsContrastFindings)
    }
}
