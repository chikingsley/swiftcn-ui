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

    /// macOS static text exposes its string through AXValue, not AXLabel.
    func text(of element: XCUIElement) -> String {
        (element.value as? String) ?? element.label
    }

    /// A documented, tolerated audit finding for one scene: matched by issue
    /// description substring plus the element's accessibility identifier.
    struct KnownAuditFinding {
        let descriptionContains: String
        let identifier: String
    }

    /// Runs Apple's accessibility audit, printing each issue's element so a
    /// failure names the offender instead of only the issue category.
    ///
    /// macOS window plumbing (SwiftUI's hosting view and the title-bar
    /// controls region) surfaces as disabled, identifier-less structural
    /// Groups whose issues no app code can address; those are expected.
    /// Scene-specific known findings must be declared explicitly. Everything
    /// else fails the audit normally.
    func runAccessibilityAudit(
        on app: XCUIApplication,
        tolerating known: [KnownAuditFinding] = []
    ) throws {
        try app.performAccessibilityAudit(for: .all) { issue in
            if let element = issue.element,
                element.elementType == .group,
                !element.isEnabled,
                element.identifier.isEmpty
            {
                print("SC-AUDIT-EXPECTED: window chrome group (\(issue.compactDescription))")
                return true
            }
            if let element = issue.element,
                known.contains(where: {
                    issue.compactDescription.contains($0.descriptionContains)
                        && element.identifier == $0.identifier
                })
            {
                print("SC-AUDIT-KNOWN: \(issue.compactDescription) on '\(element.identifier)'")
                return true
            }
            let element = issue.element.map { "\($0.debugDescription)" } ?? "unknown element"
            print("SC-AUDIT-ISSUE: \(issue.compactDescription) -> \(element)")
            print("SC-AUDIT-DETAIL: \(issue.detailedDescription)")
            return false
        }
    }
}
