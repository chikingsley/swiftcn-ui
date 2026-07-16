import XCTest

final class SliderValidationTests: ValidationCase {
    func testScalarRangeContinuousAndDisabledSlidersRender() {
        let app = launchHost(scene: "slider")
        XCTAssertTrue(app.sliders["slider-scalar"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.sliders["slider-continuous"].exists)
        XCTAssertEqual(app.sliders.matching(identifier: "slider-range").count, 2)
        XCTAssertTrue(app.sliders["slider-disabled"].exists)
        attachWindowScreenshot(of: app, named: "slider-light")
    }

    func testAccessibilityAdjustmentRoutesIntoCallerOwnedScalarBinding() throws {
        let app = launchHost(scene: "slider")
        let slider = app.sliders["slider-scalar"]
        XCTAssertTrue(slider.waitForExistence(timeout: 5))
        XCTAssertEqual(numericValue(of: slider), 40)

        // The exposed representation carries the real value and bounds, which
        // is what assistive clients read and adjust through.
        XCTAssertTrue(slider.isEnabled)

        // XCUITest's adjust(toNormalizedSliderPosition:) is deliberately not
        // called: macOS publishes no AXOrientation for a SwiftUI
        // accessibilityRepresentation, so the harness cannot synthesize that
        // adjustment and silently no-ops. This is a harness limitation, not a
        // component contract — VoiceOver adjusts through increment/decrement
        // on the value above, which remains a manual VALIDATION item. A real
        // pointer drag proves the same caller-owned binding path here.
        let start = slider.coordinate(withNormalizedOffset: CGVector(dx: 0.4, dy: 0.5))
        let end = slider.coordinate(withNormalizedOffset: CGVector(dx: 0.7, dy: 0.5))
        start.press(forDuration: 0.1, thenDragTo: end)

        let dragged = try XCTUnwrap(numericValue(of: slider))
        XCTAssertGreaterThan(dragged, 40, "dragging must move the caller-owned value")
        XCTAssertEqual(
            text(of: app.staticTexts["slider-scalar-echo"]),
            "Scalar: \(Int(dragged))",
            "the caller's binding and the exposed value must agree"
        )
    }

    func testRangeExposesOneAdjustableControlPerThumb() {
        let app = launchHost(scene: "slider")
        let sliders = app.sliders.matching(identifier: "slider-range")
        XCTAssertTrue(sliders.firstMatch.waitForExistence(timeout: 5))
        XCTAssertEqual(sliders.count, 2)
        XCTAssertEqual(sliders.element(boundBy: 0).label, "Range minimum")
        XCTAssertEqual(numericValue(of: sliders.element(boundBy: 0)), 20)
        XCTAssertEqual(sliders.element(boundBy: 1).label, "Range maximum")
        XCTAssertEqual(numericValue(of: sliders.element(boundBy: 1)), 80)
    }

    func testDisabledSliderIsExposedAsDisabled() {
        let app = launchHost(scene: "slider")
        let slider = app.sliders["slider-disabled"]
        XCTAssertTrue(slider.waitForExistence(timeout: 5))
        XCTAssertFalse(slider.isEnabled)
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "slider", appearance: "dark")
        XCTAssertTrue(app.sliders["slider-scalar"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "slider-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "slider", appearance: "light")
        XCTAssertTrue(app.sliders["slider-scalar"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "slider", appearance: "dark")
        XCTAssertTrue(app.sliders["slider-scalar"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }

    private func numericValue(of element: XCUIElement) -> Double? {
        (element.value as? NSNumber)?.doubleValue
    }
}
