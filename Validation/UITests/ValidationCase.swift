import XCTest

/// Shared launch and evidence helpers for component validation tests.
class ValidationCase: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    func launchHost(scene: String, appearance: String? = nil) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--sc-scene", scene]
        if let appearance {
            app.launchArguments += ["--sc-appearance", appearance]
        }
        app.launch()
        return app
    }

    func attachWindowScreenshot(of app: XCUIApplication, named name: String) {
        let attachment = XCTAttachment(screenshot: app.windows.firstMatch.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
