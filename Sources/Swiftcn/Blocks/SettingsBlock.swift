// ============================================================
// Blocks/SettingsBlock.swift — swiftcn-ui
// Depends on: Theme/ · Card.swift · Item.swift · Avatar.swift ·
//             Switch.swift · Select.swift · Field.swift ·
//             Separator.swift · Alert.swift · Button.swift ·
//             Typography.swift
// ============================================================
import SwiftUI

// MARK: - Block

/// A complete settings screen — the grouped-cards layout every iOS app
/// ships: a profile card, a preferences card (switches + theme select),
/// and a danger zone. All control state lives inside the block, so it
/// drops into a preview or Showcase page with zero wiring.
///
///     SCSettingsBlock()
public struct SCSettingsBlock: View {
    @Environment(\.theme) private var theme

    @State private var pushNotifications = true
    @State private var emailDigest = false
    @State private var appearance: String? = "System"

    public init() {}

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                header
                profileCard
                preferencesCard
                dangerZoneCard
            }
            .padding(20)
        }
        .background(theme.background)
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Settings")
                .scH2()
            Text("Manage your account and app preferences.")
                .scMuted()
        }
    }

    // MARK: Profile

    private var profileCard: some View {
        SCCard {
            SCCardHeader {
                SCCardTitle("Profile")
            }
            SCCardContent {
                SCItem("Sofia Davis", description: "sofia@example.com") {
                    SCAvatar(url: nil, fallback: "SD")
                } trailing: {
                    Button("Edit") {}
                        .buttonStyle(.sc(.outline, size: .sm))
                }
            }
        }
    }

    // MARK: Preferences

    private var preferencesCard: some View {
        SCCard {
            SCCardHeader {
                SCCardTitle("Preferences")
                SCCardDescription("Choose what you get notified about and how the app looks.")
            }
            SCCardContent {
                VStack(spacing: 12) {
                    Toggle(isOn: $pushNotifications) {
                        toggleLabel(
                            "Push notifications",
                            caption: "Get alerts on this device."
                        )
                    }
                    .toggleStyle(.scSwitch)

                    SCSeparator()

                    Toggle(isOn: $emailDigest) {
                        toggleLabel(
                            "Email digest",
                            caption: "A weekly summary in your inbox."
                        )
                    }
                    .toggleStyle(.scSwitch)

                    SCSeparator()

                    SCField("Theme", description: "System follows your device appearance.") {
                        SCSelect(
                            selection: $appearance,
                            placeholder: "Select a theme",
                            options: ["System", "Light", "Dark"]
                        )
                    }
                }
            }
        }
    }

    private func toggleLabel(_ title: String, caption: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
            Text(caption)
                .font(.footnote)
                .foregroundStyle(theme.mutedForeground)
        }
    }

    // MARK: Danger zone

    private var dangerZoneCard: some View {
        SCCard {
            SCCardHeader {
                SCCardTitle("Danger zone")
                SCCardDescription("Irreversible actions. Proceed with care.")
            }
            SCCardContent {
                VStack(alignment: .leading, spacing: 12) {
                    SCAlert(
                        icon: "exclamationmark.triangle",
                        title: "This cannot be undone",
                        description: "Deleting your account permanently removes your profile and all associated data.",
                        variant: .destructive
                    )
                    Button("Delete account") {}
                        .buttonStyle(.sc(.destructive))
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Settings") {
    SCPreview {
        SCSettingsBlock()
    }
    .frame(height: 700)
}
