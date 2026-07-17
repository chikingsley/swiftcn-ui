import XCTest

final class DirectionValidationTests: ValidationCase {
    func testAmbientDirectionDefaultsToLeftToRight() {
        let app = launchHost(scene: "direction")
        let ambient = app.staticTexts["direction-ambient-echo"]
        XCTAssertTrue(ambient.waitForExistence(timeout: 5))
        XCTAssertEqual(text(of: ambient), "Ambient: ltr")
    }

    func testLTRProviderRendersItsRealElementsInSourceOrder() {
        let app = launchHost(scene: "direction")
        let first = app.staticTexts["direction-ltr-first"]
        let second = app.staticTexts["direction-ltr-second"]
        XCTAssertTrue(first.waitForExistence(timeout: 5))
        XCTAssertEqual(text(of: app.staticTexts["direction-ltr-echo"]), "Provider: ltr")
        XCTAssertLessThan(
            first.frame.minX, second.frame.minX,
            "under ltr, First must render to the left of Second"
        )
    }

    func testRTLProviderMirrorsRealElementOrderNotJustItsLabel() {
        let app = launchHost(scene: "direction")
        let first = app.staticTexts["direction-rtl-first"]
        let second = app.staticTexts["direction-rtl-second"]
        XCTAssertTrue(first.waitForExistence(timeout: 5))
        XCTAssertEqual(text(of: app.staticTexts["direction-rtl-echo"]), "Provider: rtl")

        // The strongest proof SCDirectionProvider is a real
        // \.layoutDirection override, not decoration: HStack physically
        // reverses child order under RTL, so the same "First" identifier
        // that led under LTR now trails.
        XCTAssertGreaterThan(
            first.frame.minX, second.frame.minX,
            "under rtl, First must render to the right of Second — the mirror image of the ltr case"
        )
    }

    func testNestedProviderOverridesTheAmbientDirectionForOnlyItsSubtree() {
        let app = launchHost(scene: "direction")
        let nestedFirst = app.staticTexts["direction-nested-first"]
        let nestedSecond = app.staticTexts["direction-nested-second"]
        XCTAssertTrue(nestedFirst.waitForExistence(timeout: 5))
        XCTAssertEqual(text(of: app.staticTexts["direction-nested-echo"]), "Nested: ltr")

        // Nested inside an .rtl provider, an inner .ltr provider must
        // restore natural order for its own subtree only — proving the
        // override is scoped to descendants, not a single global flag.
        XCTAssertLessThan(
            nestedFirst.frame.minX, nestedSecond.frame.minX,
            "the nested ltr provider must restore natural order despite its rtl ancestor"
        )

        let outerFirst = app.staticTexts["direction-rtl-first"]
        let outerSecond = app.staticTexts["direction-rtl-second"]
        XCTAssertGreaterThan(
            outerFirst.frame.minX, outerSecond.frame.minX,
            "the enclosing rtl provider's own row must remain mirrored"
        )
    }

    func testDirectionModifierMirrorsElementOrderWithoutAWrapperView() {
        let app = launchHost(scene: "direction")
        let first = app.staticTexts["direction-modifier-first"]
        let second = app.staticTexts["direction-modifier-second"]
        XCTAssertTrue(first.waitForExistence(timeout: 5))
        XCTAssertEqual(text(of: app.staticTexts["direction-modifier-echo"]), "Modifier: rtl")
        XCTAssertGreaterThan(
            first.frame.minX, second.frame.minX,
            ".scDirection(_:) must mirror layout exactly like SCDirectionProvider"
        )
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "direction", appearance: "dark")
        XCTAssertTrue(app.staticTexts["direction-rtl-first"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "direction-dark")
    }

    func testLightAppearanceRenders() {
        let app = launchHost(scene: "direction", appearance: "light")
        XCTAssertTrue(app.staticTexts["direction-rtl-first"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "direction-light")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "direction", appearance: "light")
        XCTAssertTrue(app.staticTexts["direction-rtl-first"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "direction", appearance: "dark")
        XCTAssertTrue(app.staticTexts["direction-rtl-first"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }
}
