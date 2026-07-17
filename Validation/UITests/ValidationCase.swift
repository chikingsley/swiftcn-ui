import XCTest

/// Shared launch and evidence helpers for component validation tests.
class ValidationCase: XCTestCase {
    override func setUp() {
        continueAfterFailure = false
    }

    func launchHost(
        scene: String,
        appearance: String? = nil,
        width: Int? = nil,
        height: Int? = nil
    ) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["--sc-scene", scene]
        if let appearance {
            app.launchArguments += ["--sc-appearance", appearance]
        }
        if let width { app.launchArguments += ["--sc-width", "\(width)"] }
        if let height { app.launchArguments += ["--sc-height", "\(height)"] }
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
    ///
    /// The parent/child dimension is excluded from recording entirely: the
    /// macOS title-bar controls region fails it on every run of any SwiftUI
    /// window, and issues tolerated by the handler still render as error
    /// rows in Xcode's report.
    func runAccessibilityAudit(
        on app: XCUIApplication,
        tolerating known: [KnownAuditFinding] = [],
        excluding excludedTypes: XCUIAccessibilityAuditType = []
    ) throws {
        do {
            try performAudit(on: app, tolerating: known, excluding: excludedTypes)
        } catch let error as NSError
            where error.domain == "com.apple.xcode.xctest.accessibilityAudit" && error.code == -56
        {
            // "Audit failed to complete in time" is Apple's audit timing out
            // under load, not a finding about the scene; one retry after the
            // machine settles keeps real findings while dropping the flake.
            Thread.sleep(forTimeInterval: 1)
            try performAudit(on: app, tolerating: known, excluding: excludedTypes)
        }
    }

    private func performAudit(
        on app: XCUIApplication,
        tolerating known: [KnownAuditFinding],
        excluding excludedTypes: XCUIAccessibilityAuditType
    ) throws {
        var auditTypes = XCUIAccessibilityAuditType.all
        auditTypes.subtract(.parentChild)
        auditTypes.subtract(excludedTypes)
        try app.performAccessibilityAudit(for: auditTypes) { issue in
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
                    guard issue.compactDescription.contains($0.descriptionContains) else { return false }
                    // "*" matches any element; a trailing "*" is a prefix match;
                    // otherwise the identifier must match exactly. This lets a
                    // scene tolerate a whole class of sampler false-positive
                    // (e.g. small-muted-text contrast on many row identifiers)
                    // in one declaration instead of enumerating each element.
                    if $0.identifier == "*" { return true }
                    if $0.identifier.hasSuffix("*") {
                        return element.identifier.hasPrefix(String($0.identifier.dropLast()))
                    }
                    return element.identifier == $0.identifier
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
