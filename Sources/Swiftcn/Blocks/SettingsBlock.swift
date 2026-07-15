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
/// and a danger zone. Every preference is controlled or internal: pass
/// a binding to own it, or omit it and the block keeps its own state so
/// it drops into a preview or Showcase page with zero wiring. Profile
/// identity is demo data, matching the shadcn block model of blocks as
/// copy-and-edit starting points.
///
///     SCSettingsBlock(
///         pushNotifications: $push,
///         onDeleteAccount: { confirmDeletion() }
///     )
public struct SCSettingsBlock: View {
    @Environment(\.theme) private var theme

    @State private var internalPushNotifications: Bool
    @State private var internalEmailDigest: Bool
    @State private var internalAppearance: String?

    private let externalPushNotifications: Binding<Bool>?
    private let externalEmailDigest: Binding<Bool>?
    private let externalAppearance: Binding<String?>?
    private let onEditProfile: (() -> Void)?
    private let onDeleteAccount: (() -> Void)?

    public init(
        pushNotifications: Binding<Bool>? = nil,
        defaultPushNotifications: Bool = true,
        emailDigest: Binding<Bool>? = nil,
        defaultEmailDigest: Bool = false,
        appearance: Binding<String?>? = nil,
        defaultAppearance: String? = "System",
        onEditProfile: (() -> Void)? = nil,
        onDeleteAccount: (() -> Void)? = nil
    ) {
        self.externalPushNotifications = pushNotifications
        self._internalPushNotifications = State(initialValue: defaultPushNotifications)
        self.externalEmailDigest = emailDigest
        self._internalEmailDigest = State(initialValue: defaultEmailDigest)
        self.externalAppearance = appearance
        self._internalAppearance = State(initialValue: defaultAppearance)
        self.onEditProfile = onEditProfile
        self.onDeleteAccount = onDeleteAccount
    }

    private var pushNotifications: Binding<Bool> {
        externalPushNotifications ?? $internalPushNotifications
    }

    private var emailDigest: Binding<Bool> {
        externalEmailDigest ?? $internalEmailDigest
    }

    private var appearance: Binding<String?> {
        externalAppearance ?? $internalAppearance
    }

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
                    if let onEditProfile {
                        Button("Edit", action: onEditProfile)
                            .buttonStyle(.sc(.outline, size: .sm))
                    }
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
                    Toggle(isOn: pushNotifications) {
                        toggleLabel(
                            "Push notifications",
                            caption: "Get alerts on this device."
                        )
                    }
                    .toggleStyle(.scSwitch)

                    SCSeparator()

                    Toggle(isOn: emailDigest) {
                        toggleLabel(
                            "Email digest",
                            caption: "A weekly summary in your inbox."
                        )
                    }
                    .toggleStyle(.scSwitch)

                    SCSeparator()

                    SCField("Theme", description: "System follows your device appearance.") {
                        SCSelect(
                            selection: appearance,
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
                    if let onDeleteAccount {
                        Button("Delete account", action: onDeleteAccount)
                            .buttonStyle(.sc(.destructive))
                    }
                }
            }
        }
    }
}

// MARK: - Previews

#Preview("Settings") {
    @Previewable @State var lastAction = "Choose an account action."

    SCPreview {
        VStack(spacing: 8) {
            SCSettingsBlock(
                onEditProfile: { lastAction = "Edit profile" },
                onDeleteAccount: { lastAction = "Delete account" }
            )
            Text(lastAction).scMuted()
        }
    }
    .frame(height: 700)
}

#Preview("Settings · controlled preferences") {
    @Previewable @State var push = false
    @Previewable @State var digest = true
    @Previewable @State var appearance: String? = "Dark"

    SCPreview {
        VStack(spacing: 8) {
            SCSettingsBlock(
                pushNotifications: $push,
                emailDigest: $digest,
                appearance: $appearance
            )
            Text("push \(push ? "on" : "off") · digest \(digest ? "on" : "off") · \(appearance ?? "unset")")
                .scMuted()
        }
    }
    .frame(height: 700)
}
