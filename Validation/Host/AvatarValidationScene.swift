import Swiftcn
import SwiftUI

/// Fallback-path avatars (nil URLs — tests run without network) at every
/// preset size, a composed avatar with badge, and an overflowing avatar
/// group behind an add-member button, so UI tests can prove fallback
/// rendering, sizes, group overflow counts, and state-driven re-rendering.
struct AvatarValidationScene: View {
    @State private var members: [(URL?, String)] = [
        (nil, "CN"), (nil, "AB"), (nil, "CD"), (nil, "EF"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Members: \(members.count)")
                .accessibilityIdentifier("avatar-member-count")

            HStack(spacing: 12) {
                SCAvatar(url: nil, fallback: "SM", size: .sm)
                    .accessibilityIdentifier("avatar-size-sm")
                SCAvatar(url: nil, fallback: "DF")
                    .accessibilityIdentifier("avatar-size-default")
                SCAvatar(url: nil, fallback: "LG", size: .lg)
                    .accessibilityIdentifier("avatar-size-lg")
            }

            SCAvatar(size: .lg) {
                SCAvatarFallback("VB")
                SCAvatarBadge {
                    Image(systemName: "checkmark")
                        .accessibilityLabel("Verified")
                }
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier("avatar-composed")

            SCAvatarGroup(avatars: members, max: 3)
                .accessibilityIdentifier("avatar-group")

            Button("Add member") {
                members.append((nil, "GH"))
            }
            .buttonStyle(.sc(.outline, size: .sm))
            .accessibilityIdentifier("avatar-add-member")
        }
        .padding(24)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}
