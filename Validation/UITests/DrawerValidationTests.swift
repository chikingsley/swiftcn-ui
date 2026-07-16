import XCTest

final class DrawerValidationTests: ValidationCase {
    private let directions = ["up", "right", "down", "left"]
    private let behaviors = ["modal", "nonModal", "trapFocus"]

    func testEveryDirectionPresentsScrollableContentAndDismisses() {
        let app = launchHost(scene: "drawer")
        XCTAssertTrue(app.buttons["drawer-present-up"].waitForExistence(timeout: 5))

        for direction in directions {
            app.buttons["drawer-present-\(direction)"].click()
            let content = app.descendants(matching: .any)["drawer-direction-\(direction)-content"]
            XCTAssertTrue(content.waitForExistence(timeout: 5), "\(direction) drawer did not present")
            XCTAssertTrue(app.staticTexts["drawer-title"].exists)
            XCTAssertTrue(app.staticTexts["drawer-row-1"].exists)
            XCTAssertTrue(app.scrollViews["drawer-scroll-body"].exists)

            app.buttons["drawer-dismiss"].click()
            XCTAssertTrue(content.waitForNonExistence(timeout: 2), "\(direction) drawer did not dismiss")
        }
    }

    func testEveryModalBehaviorRenders() {
        let app = launchHost(scene: "drawer")
        XCTAssertTrue(app.buttons["drawer-present-behavior-modal"].waitForExistence(timeout: 5))

        for behavior in behaviors {
            app.buttons["drawer-present-behavior-\(behavior)"].click()
            let content = app.descendants(matching: .any)["drawer-behavior-\(behavior)-content"]
            XCTAssertTrue(content.waitForExistence(timeout: 5), "\(behavior) drawer did not present")
            app.buttons["drawer-dismiss"].click()
            XCTAssertTrue(content.waitForNonExistence(timeout: 2))
        }
    }

    func testActionInsideDrawerRoutesIntoCallerState() {
        let app = launchHost(scene: "drawer")
        app.buttons["drawer-present-right"].click()
        let count = app.staticTexts["drawer-action-count"]
        XCTAssertTrue(count.waitForExistence(timeout: 5))

        app.buttons["drawer-run-action"].click()
        XCTAssertEqual(text(of: count), "Actions: 1")
        app.buttons["drawer-dismiss"].click()
        XCTAssertEqual(text(of: app.staticTexts["drawer-scene-action-count"]), "Actions: 1")
    }

    func testSnapDrawerDragRoutesIntoCallerOwnedDetent() {
        let app = launchHost(scene: "drawer")
        app.buttons["drawer-present-snap"].click()
        let content = app.descendants(matching: .any)["drawer-snap-content"]
        let snap = app.staticTexts["drawer-snap-echo"]
        XCTAssertTrue(content.waitForExistence(timeout: 5))
        XCTAssertEqual(text(of: snap), "Snap: fraction-0.3")

        let start = content.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.8))
        let end = content.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.2))
        start.press(forDuration: 0.1, thenDragTo: end)
        XCTAssertEqual(text(of: snap), "Snap: fraction-0.6")
    }

    func testScrollableBodyCanReachItsLastRow() {
        let app = launchHost(scene: "drawer")
        app.buttons["drawer-present-down"].click()
        let scrollView = app.scrollViews["drawer-scroll-body"]
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5))

        scrollView.swipeUp()
        scrollView.swipeUp()
        XCTAssertTrue(app.staticTexts["drawer-row-20"].waitForExistence(timeout: 2))
    }

    func testEscapeDismissesAndDisabledTriggerIsDisabled() {
        let app = launchHost(scene: "drawer")
        let disabled = app.buttons["drawer-disabled"]
        XCTAssertTrue(disabled.waitForExistence(timeout: 5))
        XCTAssertFalse(disabled.isEnabled)

        app.buttons["drawer-present-down"].click()
        let content = app.descendants(matching: .any)["drawer-direction-down-content"]
        XCTAssertTrue(content.waitForExistence(timeout: 5))
        app.typeKey(XCUIKeyboardKey.escape, modifierFlags: [])
        XCTAssertTrue(content.waitForNonExistence(timeout: 2))
    }

    func testLightAppearanceRendersPresentedDrawer() {
        let app = launchHost(scene: "drawer", appearance: "light")
        app.buttons["drawer-present-right"].click()
        XCTAssertTrue(app.staticTexts["drawer-title"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "drawer-light")
    }

    func testDarkAppearanceRendersPresentedDrawer() {
        let app = launchHost(scene: "drawer", appearance: "dark")
        app.buttons["drawer-present-right"].click()
        XCTAssertTrue(app.staticTexts["drawer-title"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "drawer-dark")
    }

    func testAccessibilityAuditLight() throws {
        let app = launchHost(scene: "drawer", appearance: "light")
        app.buttons["drawer-present-right"].click()
        XCTAssertTrue(app.staticTexts["drawer-title"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }

    func testAccessibilityAuditDark() throws {
        let app = launchHost(scene: "drawer", appearance: "dark")
        app.buttons["drawer-present-right"].click()
        XCTAssertTrue(app.staticTexts["drawer-title"].waitForExistence(timeout: 5))
        try runAccessibilityAudit(on: app)
    }
}
