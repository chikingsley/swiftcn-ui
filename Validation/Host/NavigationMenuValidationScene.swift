import SwiftUI
import Swiftcn

private let navigationMenuValidationURL =
    URL(string: "https://example.com/swiftcn") ?? URL(fileURLWithPath: "/")

/// A controlled SCNavigationMenu whose value is mirrored into a visible
/// echo, native popover triggers and content, active/disabled links and
/// actions, and a disabled trigger, so UI tests can prove real
/// controlled-value routing, action/link routing, and disabled semantics
/// through the accessibility tree. Hover-driven open/close and nested
/// keyboard traversal are documented residue in the UI test file, matching
/// this codebase's established Tooltip precedent that XCUITest cannot
/// reliably synthesize macOS hover.
struct NavigationMenuValidationScene: View {
    @State private var openItem: String?
    @State private var actionCount = 0
    @State private var lastAction = "none"
    @State private var openedURLCount = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Open item: \(openItem ?? "none")")
                .accessibilityIdentifier("navigationmenu-open-item")
            Text("Actions: \(actionCount)")
                .accessibilityIdentifier("navigationmenu-action-count")
            Text("Last action: \(lastAction)")
                .accessibilityIdentifier("navigationmenu-last-action")
            Text("URLs opened: \(openedURLCount)")
                .accessibilityIdentifier("navigationmenu-url-open-count")

            SCNavigationMenu(value: $openItem) {
                SCNavigationMenuList {
                    SCNavigationMenuItem(value: "getting-started") {
                        SCNavigationMenuTrigger("Getting started")
                            .accessibilityIdentifier("navigationmenu-trigger-getting-started")
                    } content: {
                        SCNavigationMenuContent(idealWidth: 280) {
                            VStack(alignment: .leading, spacing: 4) {
                                SCNavigationMenuAction {
                                    actionCount += 1
                                    lastAction = "Introduction"
                                } label: {
                                    Text("Introduction")
                                }
                                .accessibilityIdentifier("navigationmenu-action-introduction")

                                SCNavigationMenuAction(isDisabled: true, action: {}) {
                                    Text("Disabled action")
                                }
                                .accessibilityIdentifier("navigationmenu-action-disabled")

                                SCNavigationMenuLink(
                                    "swiftcn on GitHub",
                                    destination: navigationMenuValidationURL
                                )
                                .accessibilityIdentifier("navigationmenu-link")
                            }
                        }
                        .accessibilityIdentifier("navigationmenu-getting-started-content")
                    }

                    SCNavigationMenuItem(value: "components") {
                        SCNavigationMenuTrigger("Components")
                            .accessibilityIdentifier("navigationmenu-trigger-components")
                    } content: {
                        SCNavigationMenuContent(idealWidth: 240) {
                            SCNavigationMenuAction(isActive: true) {
                                actionCount += 1
                                lastAction = "Tabs"
                            } label: {
                                Text("Tabs")
                            }
                            .accessibilityIdentifier("navigationmenu-action-active")
                        }
                        .accessibilityIdentifier("navigationmenu-components-content")
                    }

                    SCNavigationMenuItem(value: "documentation") {
                        SCNavigationMenuAction(presentation: .trigger) {
                            actionCount += 1
                            lastAction = "Documentation"
                        } label: {
                            Text("Documentation")
                        }
                        .accessibilityIdentifier("navigationmenu-trigger-documentation")
                    }

                    SCNavigationMenuItem(value: "disabled-trigger") {
                        SCNavigationMenuTrigger("Disabled trigger", isDisabled: true)
                            .accessibilityIdentifier("navigationmenu-trigger-disabled")
                    } content: {
                        SCNavigationMenuContent {
                            Text("Unreachable")
                        }
                    }
                }
            }
            .accessibilityIdentifier("navigationmenu-root")
        }
        .environment(
            \.openURL,
            OpenURLAction { _ in
                openedURLCount += 1
                return .handled
            }
        )
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
