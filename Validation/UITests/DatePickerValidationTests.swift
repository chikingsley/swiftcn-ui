import XCTest

final class DatePickerValidationTests: ValidationCase {
    func testBasicPickerSelectsADayAndAutoDismisses() {
        let app = launchHost(scene: "datepicker", height: 730)
        let trigger = app.buttons["datepicker-basic-trigger"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))

        trigger.click()
        let day = app.buttons[dayLabel(2024, 7, 15)]
        XCTAssertTrue(day.waitForExistence(timeout: 5))
        day.click()

        XCTAssertEqual(text(of: app.staticTexts["datepicker-basic-echo"]), "Basic: Jul 15, 2024")
        XCTAssertTrue(day.waitForNonExistence(timeout: 2), "dismissesOnSelection must close the popover")
        attachWindowScreenshot(of: app, named: "datepicker-light")
    }

    func testRangePickerPresetRoutesIntoCallerOwnedBinding() {
        let app = launchHost(scene: "datepicker", height: 730)
        let trigger = app.buttons["datepicker-range-trigger"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))

        trigger.click()
        let preset = app.buttons["This week"]
        XCTAssertTrue(preset.waitForExistence(timeout: 5))
        preset.click()

        XCTAssertEqual(text(of: app.staticTexts["datepicker-range-echo"]), "Range: Jul 8, 2024 to Jul 14, 2024")
        XCTAssertTrue(preset.waitForNonExistence(timeout: 2))
    }

    func testRangePickerAnchorClickHoldsOpenUntilTheRangeCompletes() {
        let app = launchHost(scene: "datepicker", height: 730)
        let trigger = app.buttons["datepicker-range-trigger"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        trigger.click()

        let start = app.buttons[dayLabel(2024, 7, 10)]
        XCTAssertTrue(start.waitForExistence(timeout: 5))
        start.click()
        // A single anchor click sets the anchor but neither completes the
        // range nor dismisses (dismissesOnSelection only fires once the range
        // binding is non-nil). The popover stays open for the second pick.
        XCTAssertEqual(text(of: app.staticTexts["datepicker-range-echo"]), "Range: none")
        XCTAssertTrue(start.exists, "the range popover must stay open after the anchor click")
        // Completing the range requires clicking a second day in the 2-month
        // grid, which overflows the popover frame (the second month's day
        // buttons report AX frames outside the popover's bounds, so a
        // synthesized click lands outside and dismisses). Two-click range
        // completion is a manual VALIDATION item; preset-driven range
        // selection (testRangePickerPresetRoutesIntoCallerOwnedBinding)
        // covers the caller-binding path automatically.
        print("SC-MANUAL-VALIDATION: two-click range completion across the datepicker 2-month grid")
    }

    func testDateOfBirthShowsExistingSelectionAndRoutesANewOne() {
        let app = launchHost(scene: "datepicker", height: 730)
        let trigger = app.buttons["datepicker-birth-trigger"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        trigger.click()

        let existing = app.buttons[dayLabel(1990, 1, 15)]
        XCTAssertTrue(existing.waitForExistence(timeout: 5))
        XCTAssertTrue(existing.isSelected, "the pre-seeded birth date must render as selected")
        XCTAssertGreaterThanOrEqual(
            app.popUpButtons.count, 2, "dateOfBirth uses dropdown month/year captions"
        )

        app.buttons[dayLabel(1990, 1, 20)].click()
        XCTAssertEqual(text(of: app.staticTexts["datepicker-birth-echo"]), "Birth: Jan 20, 1990")
        XCTAssertTrue(existing.waitForNonExistence(timeout: 2))
    }

    func testInputPickerCommitsValidTextAndRejectsInvalidText() {
        let app = launchHost(scene: "datepicker", height: 730)
        let container = app.descendants(matching: .any)["datepicker-input"]
        let field = container.textFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5))

        field.click()
        Thread.sleep(forTimeInterval: 0.4)
        app.typeText("Jul 16, 2024\n")
        XCTAssertEqual(text(of: app.staticTexts["datepicker-input-echo"]), "Input: Jul 16, 2024")

        field.doubleClick()
        Thread.sleep(forTimeInterval: 0.4)
        app.typeText("not-a-real-date\n")
        XCTAssertTrue(
            container.staticTexts.matching(NSPredicate(format: "value == 'Enter a valid date.'")).firstMatch
                .waitForExistence(timeout: 5)
        )
    }

    func testInputPickerCalendarButtonOpensAndCommitsADay() {
        let app = launchHost(scene: "datepicker", height: 730)
        let container = app.descendants(matching: .any)["datepicker-input"]
        let openCalendar = container.buttons["Open calendar"]
        XCTAssertTrue(openCalendar.waitForExistence(timeout: 5))

        openCalendar.click()
        let day = app.buttons[dayLabel(2024, 7, 22)]
        XCTAssertTrue(day.waitForExistence(timeout: 5))
        Thread.sleep(forTimeInterval: 0.3)
        day.click()

        XCTAssertEqual(text(of: app.staticTexts["datepicker-input-echo"]), "Input: Jul 22, 2024")
        XCTAssertTrue(day.waitForNonExistence(timeout: 2))
    }

    func testNaturalLanguageParsingUpdatesWhileTyping() {
        let app = launchHost(scene: "datepicker", height: 730)
        let container = app.descendants(matching: .any)["datepicker-nl"]
        let field = container.textFields.firstMatch
        XCTAssertTrue(field.waitForExistence(timeout: 5))

        field.click()
        Thread.sleep(forTimeInterval: 0.4)
        app.typeText("today")
        XCTAssertEqual(text(of: app.staticTexts["datepicker-nl-echo"]), "Natural language: Jul 15, 2024")
        XCTAssertTrue(
            container.staticTexts.matching(NSPredicate(format: "value == 'Selected Jul 15, 2024'")).firstMatch
                .waitForExistence(timeout: 5),
            "showsParsedDate must render the live-parsed confirmation"
        )
    }

    func testDateTimePickerEnablesTimeControlOnlyAfterADateIsChosen() {
        let app = launchHost(scene: "datepicker", height: 730)
        let container = app.descendants(matching: .any)["datepicker-datetime"]
        let trigger = container.buttons["Select date"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        // The compact native time control is disabled until a date exists.
        XCTAssertFalse(container.datePickers.firstMatch.isEnabled)

        trigger.click()
        let dtDay = app.buttons[dayLabel(2024, 7, 15)]
        XCTAssertTrue(dtDay.waitForExistence(timeout: 5))
        Thread.sleep(forTimeInterval: 0.3)
        dtDay.click()

        XCTAssertEqual(
            text(of: app.staticTexts["datepicker-datetime-echo"]),
            "Date/time: " + expectedDateTime()
        )
        XCTAssertTrue(container.datePickers.firstMatch.isEnabled, "time control must enable once a date is set")
        // The compact time control's own segment editing is a native AppKit
        // date/time field; keystroke-level hour/minute entry remains a
        // manual VALIDATION item rather than a synthesized XCUITest edit.
    }

    func testDisabledPickerIsExposedAsDisabled() {
        let app = launchHost(scene: "datepicker", height: 730)
        let trigger = app.buttons["datepicker-disabled-trigger"]
        XCTAssertTrue(trigger.waitForExistence(timeout: 5))
        XCTAssertFalse(trigger.isEnabled)
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "datepicker", appearance: "dark", height: 730)
        XCTAssertTrue(app.buttons["datepicker-basic-trigger"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "datepicker-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "datepicker", appearance: "light", height: 730)
        XCTAssertTrue(app.buttons["datepicker-basic-trigger"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "datepicker", appearance: "dark", height: 730)
        XCTAssertTrue(app.buttons["datepicker-basic-trigger"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
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

    private func expectedDateTime() -> String {
        date(2024, 7, 15).formatted(date: .abbreviated, time: .shortened)
    }
}
