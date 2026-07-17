import XCTest

final class CalendarValidationTests: ValidationCase {
    func testSingleSelectionSelectsAndDeselects() {
        let app = launchHost(scene: "calendar")
        let calendar = app.descendants(matching: .any)["calendar-single"]
        let day15 = calendar.buttons[dayLabel(2024, 7, 15)]
        XCTAssertTrue(day15.waitForExistence(timeout: 5))

        day15.click()
        XCTAssertEqual(text(of: app.staticTexts["calendar-single-echo"]), "Single: Jul 15, 2024")

        // Default `allowsDeselection` is true: clicking the same selected day again clears it.
        day15.click()
        XCTAssertEqual(text(of: app.staticTexts["calendar-single-echo"]), "Single: none")
        attachWindowScreenshot(of: app, named: "calendar-light")
    }

    func testMultipleSelectionTogglesIndividualDates() {
        let app = launchHost(scene: "calendar")
        let calendar = app.descendants(matching: .any)["calendar-multiple"]
        XCTAssertTrue(calendar.buttons[dayLabel(2024, 7, 5)].waitForExistence(timeout: 5))

        calendar.buttons[dayLabel(2024, 7, 5)].click()
        calendar.buttons[dayLabel(2024, 7, 12)].click()
        calendar.buttons[dayLabel(2024, 7, 19)].click()
        XCTAssertEqual(
            text(of: app.staticTexts["calendar-multiple-echo"]),
            "Multiple: Jul 5, 2024, Jul 12, 2024, Jul 19, 2024"
        )

        calendar.buttons[dayLabel(2024, 7, 12)].click()
        XCTAssertEqual(
            text(of: app.staticTexts["calendar-multiple-echo"]),
            "Multiple: Jul 5, 2024, Jul 19, 2024"
        )
    }

    func testRangeSelectionSpansTwoVisibleMonths() {
        let app = launchHost(scene: "calendarrange")
        let calendar = app.descendants(matching: .any)["calendar-range"]
        XCTAssertTrue(calendar.buttons[dayLabel(2024, 7, 10)].waitForExistence(timeout: 5))
        XCTAssertTrue(
            calendar.staticTexts.matching(NSPredicate(format: "value == 'July 2024'")).firstMatch.exists
        )
        XCTAssertTrue(
            calendar.staticTexts.matching(NSPredicate(format: "value == 'August 2024'")).firstMatch.exists,
            "numberOfMonths: 2 must render a second visible month"
        )

        calendar.buttons[dayLabel(2024, 7, 10)].click()
        calendar.buttons[dayLabel(2024, 7, 20)].click()
        XCTAssertEqual(
            text(of: app.staticTexts["calendar-range-echo"]),
            "Range: Jul 10, 2024 to Jul 20, 2024"
        )

        // A click while a range is already set clears it and starts a new
        // anchor (Calendar.swift's `select`); the range that follows crosses
        // the month boundary into the second visible month.
        calendar.buttons[dayLabel(2024, 8, 5)].click()
        XCTAssertEqual(text(of: app.staticTexts["calendar-range-echo"]), "Range: none")
        calendar.buttons[dayLabel(2024, 8, 10)].click()
        XCTAssertEqual(
            text(of: app.staticTexts["calendar-range-echo"]),
            "Range: Aug 5, 2024 to Aug 10, 2024"
        )
    }

    func testBoundsDisabledWeekendsBlockSelectionButWeekdaysWork() {
        let app = launchHost(scene: "calendarextras")
        let calendar = app.descendants(matching: .any)["calendar-disabled-dates"]
        // July 13, 2024 is a Saturday.
        let saturday = calendar.buttons[dayLabel(2024, 7, 13)]
        XCTAssertTrue(saturday.waitForExistence(timeout: 5))
        XCTAssertFalse(saturday.isEnabled)

        saturday.click()
        XCTAssertEqual(text(of: app.staticTexts["calendar-disabled-dates-echo"]), "Disabled-dates selection: none")

        let monday = calendar.buttons[dayLabel(2024, 7, 15)]
        XCTAssertTrue(monday.isEnabled)
        monday.click()
        XCTAssertEqual(
            text(of: app.staticTexts["calendar-disabled-dates-echo"]),
            "Disabled-dates selection: Jul 15, 2024"
        )
    }

    func testControlledMonthBindingIsBidirectional() {
        let app = launchHost(scene: "calendarextras")
        let calendar = app.descendants(matching: .any)["calendar-controlled-month"]
        XCTAssertTrue(
            calendar.staticTexts.matching(NSPredicate(format: "value == 'July 2024'")).firstMatch
                .waitForExistence(timeout: 5)
        )

        app.buttons["calendar-jump-button"].click()
        XCTAssertTrue(
            calendar.staticTexts.matching(NSPredicate(format: "value == 'January 2025'")).firstMatch.exists,
            "external write to the month binding must move the displayed month"
        )
        XCTAssertEqual(text(of: app.staticTexts["calendar-controlled-month-echo"]), "Controlled month: January 2025")

        calendar.buttons["Next month"].click()
        XCTAssertTrue(
            calendar.staticTexts.matching(NSPredicate(format: "value == 'February 2025'")).firstMatch.exists,
            "internal navigation must write back into the caller-owned month binding"
        )
        XCTAssertEqual(text(of: app.staticTexts["calendar-controlled-month-echo"]), "Controlled month: February 2025")
    }

    func testDropdownCaptionLayoutRendersMonthAndYearPickers() {
        let app = launchHost(scene: "calendarmisc", width: 880)
        let calendar = app.descendants(matching: .any)["calendar-dropdown"]
        XCTAssertTrue(calendar.popUpButtons.firstMatch.waitForExistence(timeout: 5))
        XCTAssertEqual(calendar.popUpButtons.count, 2, "dropdown caption must expose a month and a year picker")

        let monthPicker = calendar.popUpButtons.element(boundBy: 0)
        monthPicker.click()
        app.menuItems["Sep"].click()
        XCTAssertEqual(monthPicker.value as? String, "Sep")
    }

    func testCustomDayContentRendersCallerSuppliedPricing() {
        let app = launchHost(scene: "calendarmisc", width: 880)
        let calendar = app.descendants(matching: .any)["calendar-custom-day"]
        // The custom pricing text renders inside each day Button, whose
        // accessibility subtree collapses into the button's own label — the
        // "$120"/"$100" strings are never separate static texts. The
        // screenshot is the pricing-content evidence; the grid rendering is
        // the queryable contract.
        XCTAssertTrue(calendar.buttons[dayLabel(2024, 7, 13)].waitForExistence(timeout: 5))
        XCTAssertTrue(calendar.buttons[dayLabel(2024, 7, 15)].exists)
        attachWindowScreenshot(of: app, named: "calendar-custom-day-light")
    }

    // SwiftUI's `.disabled(_:)` only ever narrows `isEnabled` (a nested
    // `.disabled(false)` cannot re-enable an ancestor's `.disabled(true)`),
    // so an ancestor disable propagates into every day and navigation button.
    // A sibling writer's suspicion that the nested clauses override the
    // ancestor was disproven by this test's own first run.
    func testDisabledCalendarBlocksDayInteraction() {
        let app = launchHost(scene: "calendarmisc", width: 880)
        let calendar = app.descendants(matching: .any)["calendar-disabled"]
        let day = calendar.buttons[dayLabel(2024, 7, 15)]
        XCTAssertTrue(day.waitForExistence(timeout: 5))
        XCTAssertFalse(day.isEnabled, "an ancestor .disabled(true) must disable every day button")

        day.click()
        XCTAssertEqual(
            text(of: app.staticTexts["calendar-disabled-echo"]),
            "Disabled-instance selection: none",
            "a disabled calendar must not route selection into the caller-owned binding"
        )
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "calendar", appearance: "dark")
        let calendar = app.descendants(matching: .any)["calendar-single"]
        XCTAssertTrue(calendar.buttons[dayLabel(2024, 7, 15)].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "calendar-dark")
    }

    // The sampler flags the tiny (13px) muted weekday-header letters:
    // mutedForeground on the scene background computes to 7.72:1 (light,
    // zinc-600 #52525C on white) and 7.59:1 (dark, zinc-400 #9F9FA9 on
    // zinc-950 #09090B) — both clear WCAG AA text (4.5:1). Identifier-less,
    // so matched by "".
    private var mutedTextContrastFindings: [KnownAuditFinding] {
        [KnownAuditFinding(descriptionContains: "Contrast", identifier: "")]
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "calendar", appearance: "light")
        let calendar = app.descendants(matching: .any)["calendar-single"]
        XCTAssertTrue(calendar.buttons[dayLabel(2024, 7, 15)].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app, tolerating: mutedTextContrastFindings)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "calendar", appearance: "dark")
        let calendar = app.descendants(matching: .any)["calendar-single"]
        XCTAssertTrue(calendar.buttons[dayLabel(2024, 7, 15)].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app, tolerating: mutedTextContrastFindings)
    }

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        return Calendar.current.date(from: components) ?? Date()
    }

    private func dayLabel(_ year: Int, _ month: Int, _ day: Int) -> String {
        date(year, month, day).formatted(date: .complete, time: .omitted)
    }
}
