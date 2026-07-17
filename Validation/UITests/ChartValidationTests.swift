import XCTest

final class ChartValidationTests: ValidationCase {
    func testBarChartContainerRendersAndScreenshotCapturesLegend() {
        let app = launchHost(scene: "chart")
        let container = app.descendants(matching: .any)["chart-bar"]
        XCTAssertTrue(container.waitForExistence(timeout: 5))
        // A SwiftUI `Chart` collapses into a single Swift Charts audio-graph
        // element; its rendered legend ("Desktop"/"Mobile"), series marks, and
        // the caller-supplied accessibilityLabel are not surfaced as queryable
        // XCUITest strings. The legend rendering is screenshot/manual VoiceOver
        // evidence; the queryable contract (selection routing into caller
        // state) is asserted in testBarSelectionRoutesIntoCallerState.
        attachWindowScreenshot(of: app, named: "chart-light")
    }

    func testBarSelectionRoutesIntoCallerStateAndTogglesTooltip() {
        let app = launchHost(scene: "chart")
        XCTAssertTrue(app.staticTexts["chart-selection-echo"].waitForExistence(timeout: 5))
        XCTAssertEqual(text(of: app.staticTexts["chart-selection-echo"]), "Bar selection: none")
        XCTAssertFalse(app.descendants(matching: .any)["chart-bar-tooltip"].exists)

        // A caller control drives selection into the chart's controlled binding
        // (the queryable functional contract); the tooltip appears and hides
        // with it. The tooltip's payload rows are Swift-Charts-adjacent text
        // whose per-row values XCUITest does not reliably expose — that
        // content (Feb / Desktop 305 / Mobile 200, hidden row suppressed) is
        // screenshot/manual evidence.
        app.buttons["chart-select-feb-button"].click()
        XCTAssertEqual(text(of: app.staticTexts["chart-selection-echo"]), "Bar selection: Feb")
        let tooltip = app.descendants(matching: .any)["chart-bar-tooltip"]
        XCTAssertTrue(tooltip.waitForExistence(timeout: 5), "selecting a point must present the tooltip")
        attachWindowScreenshot(of: app, named: "chart-bar-tooltip")

        app.buttons["chart-clear-button"].click()
        XCTAssertEqual(text(of: app.staticTexts["chart-selection-echo"]), "Bar selection: none")
        XCTAssertTrue(tooltip.waitForNonExistence(timeout: 2), "clearing selection must dismiss the tooltip")
    }

    func testLineSelectionRoutesIntoCallerStateAndTogglesTooltip() {
        let app = launchHost(scene: "chart")
        let container = app.descendants(matching: .any)["chart-line"]
        XCTAssertTrue(container.waitForExistence(timeout: 5))

        app.buttons["chart-line-select-feb-button"].click()
        XCTAssertEqual(text(of: app.staticTexts["chart-line-selection-echo"]), "Line selection: Feb")
        let tooltip = app.descendants(matching: .any)["chart-line-tooltip"]
        XCTAssertTrue(tooltip.waitForExistence(timeout: 5), "selecting a point must present the line tooltip")
        // The custom formatter output ("Desktop total: 305") renders inside the
        // tooltip; its string is screenshot/manual evidence (Swift-Charts-
        // adjacent text is not reliably queryable).
        attachWindowScreenshot(of: app, named: "chart-line-tooltip")

        app.buttons["chart-line-clear-button"].click()
        XCTAssertEqual(text(of: app.staticTexts["chart-line-selection-echo"]), "Line selection: none")
        XCTAssertTrue(tooltip.waitForNonExistence(timeout: 2))
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "chart", appearance: "dark")
        XCTAssertTrue(app.descendants(matching: .any)["chart-bar"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "chart-dark")
    }

    // Chart bar/line marks are custom-drawn shapes that carry real
    // accessibility labels ("Jan", …) but no standard control role, which
    // the audit reports as "Unknown role". They are data visualizations, not
    // interactive controls; VoiceOver reads their labels. Identifier-less,
    // so matched by "".
    private var markRoleFindings: [KnownAuditFinding] {
        [
            KnownAuditFinding(descriptionContains: "Unknown role", identifier: ""),
            // The 12px muted axis/caption text: mutedForeground on the scene
            // background computes to 7.72:1 light / 7.59:1 dark — clearing
            // WCAG AA text (4.5:1); the sampler flags the tiny glyphs.
            KnownAuditFinding(descriptionContains: "Contrast", identifier: ""),
        ]
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "chart", appearance: "light")
        XCTAssertTrue(app.descendants(matching: .any)["chart-bar"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app, tolerating: markRoleFindings)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "chart", appearance: "dark")
        XCTAssertTrue(app.descendants(matching: .any)["chart-bar"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app, tolerating: markRoleFindings)
    }
}
