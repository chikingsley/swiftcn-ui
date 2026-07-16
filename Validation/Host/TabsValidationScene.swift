import Swiftcn
import SwiftUI

/// Typed controlled tabs cover both variants and orientations, disabled
/// triggers, callback delivery, and mounted versus conditional panels.
struct TabsValidationScene: View {
    private enum Tab: String, Hashable {
        case account
        case password
        case settings
    }

    @State private var horizontalSelection: Tab = .account
    @State private var horizontalCallback = "none"
    @State private var verticalSelection: Tab? = .password

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Horizontal: \(horizontalSelection.rawValue)")
                .accessibilityIdentifier("tabs-horizontal-selection")
            Text("Callback: \(horizontalCallback)")
                .accessibilityIdentifier("tabs-horizontal-callback")
            Text("Vertical: \(verticalSelection?.rawValue ?? "none")")
                .accessibilityIdentifier("tabs-vertical-selection")

            SCTabs(
                selection: $horizontalSelection,
                onValueChange: { horizontalCallback = $0.rawValue }
            ) {
                SCTabsList(variant: .default) {
                    SCTabsTrigger("Account", value: Tab.account)
                        .accessibilityIdentifier("tabs-default-account")
                    SCTabsTrigger("Password", value: Tab.password)
                        .accessibilityIdentifier("tabs-default-password")
                    SCTabsTrigger("Settings", value: Tab.settings, isDisabled: true)
                        .accessibilityIdentifier("tabs-disabled-trigger")
                }
                .accessibilityIdentifier("tabs-default-list")
                SCTabsContent(value: Tab.account) {
                    Text("Account panel").accessibilityIdentifier("tabs-account-panel")
                }
                SCTabsContent(value: Tab.password, keepMounted: true) {
                    Text("Password panel").accessibilityIdentifier("tabs-password-panel")
                }
            }

            SCTabs(selection: $verticalSelection, orientation: .vertical) {
                SCTabsList(variant: .line) {
                    SCTabsTrigger("Vertical account", value: Tab.account)
                        .accessibilityIdentifier("tabs-line-account")
                    SCTabsTrigger("Vertical password", value: Tab.password)
                        .accessibilityIdentifier("tabs-line-password")
                }
                .accessibilityIdentifier("tabs-line-list")
                SCTabsContent(value: Tab.account) {
                    Text("Vertical account panel")
                        .accessibilityIdentifier("tabs-vertical-account-panel")
                }
                SCTabsContent(value: Tab.password) {
                    Text("Vertical password panel")
                        .accessibilityIdentifier("tabs-vertical-password-panel")
                }
            }
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
