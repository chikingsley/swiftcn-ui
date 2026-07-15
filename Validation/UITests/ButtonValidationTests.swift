import XCTest

final class ButtonValidationTests: ValidationCase {
    private let variants = ["default", "destructive", "outline", "secondary", "ghost", "link"]
    private let sizes = ["default", "xs", "sm", "lg", "icon", "iconXS", "iconSM", "iconLG"]

    func testEveryVariantRendersAndRoutesItsAction() {
        let app = launchHost(scene: "button")
        let count = app.staticTexts["button-activation-count"]
        XCTAssertTrue(count.waitForExistence(timeout: 5))

        for variant in variants {
            let button = app.buttons["button-variant-\(variant)"]
            XCTAssertTrue(button.exists, "variant \(variant) is missing")
            button.click()
            XCTAssertEqual(
                app.staticTexts["button-last-activated"].label,
                "Last: \(variant)",
                "variant \(variant) did not route its action"
            )
        }
        XCTAssertEqual(count.label, "Activations: \(variants.count)")
        attachWindowScreenshot(of: app, named: "button-light")
    }

    func testEverySizeRendersAndRoutesItsAction() {
        let app = launchHost(scene: "button")
        let count = app.staticTexts["button-activation-count"]
        XCTAssertTrue(count.waitForExistence(timeout: 5))

        for size in sizes {
            let button = app.buttons["button-size-\(size)"]
            XCTAssertTrue(button.exists, "size \(size) is missing")
            button.click()
            XCTAssertEqual(
                app.staticTexts["button-last-activated"].label,
                "Last: size-\(size)",
                "size \(size) did not route its action"
            )
        }
        XCTAssertEqual(count.label, "Activations: \(sizes.count)")
    }

    func testDisabledButtonIsExposedAsDisabled() {
        let app = launchHost(scene: "button")
        let button = app.buttons["button-disabled"]
        XCTAssertTrue(button.waitForExistence(timeout: 5))
        XCTAssertFalse(button.isEnabled)
    }

    func testDarkAppearanceRenders() {
        let app = launchHost(scene: "button", appearance: "dark")
        XCTAssertTrue(app.buttons["button-variant-default"].waitForExistence(timeout: 5))
        attachWindowScreenshot(of: app, named: "button-dark")
    }

    func testAccessibilityAudit() throws {
        let app = launchHost(scene: "button")
        XCTAssertTrue(app.buttons["button-variant-default"].waitForExistence(timeout: 5))
        try app.performAccessibilityAudit()
    }
}
