// ============================================================
// Avatar.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Variants

/// Preset avatar diameters, with an escape hatch for arbitrary sizes.
public enum SCAvatarSize: Sendable, Equatable {
    case sm
    case `default`
    case lg
    case custom(CGFloat)

    /// The avatar's diameter in points.
    public var points: CGFloat {
        switch self {
        case .sm:                32
        case .default:           40
        case .lg:                56
        case .custom(let side):  side
        }
    }
}

// MARK: - Component

/// An image element with a fallback for representing the user.
///
/// Loads the image asynchronously; while loading (or on failure) it shows
/// the `fallback` initials on a muted circle — the same behavior as
/// shadcn's `AvatarImage` + `AvatarFallback`.
///
///     SCAvatar(url: URL(string: "https://github.com/shadcn.png"), fallback: "CN")
///     SCAvatar(url: nil, fallback: "AB", size: .lg)
public struct SCAvatar: View {
    @Environment(\.theme) private var theme

    var url: URL?
    var fallback: String
    var size: SCAvatarSize

    /// - Parameters:
    ///   - url: Remote image URL. Pass `nil` to always show the fallback.
    ///   - fallback: Short text (usually initials) shown while loading or on failure.
    ///   - size: Preset diameter — `.sm` 32, `.default` 40, `.lg` 56, or `.custom`.
    public init(url: URL?, fallback: String, size: SCAvatarSize = .default) {
        self.url = url
        self.fallback = fallback
        self.size = size
    }

    public var body: some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            default: // .empty, .failure, and future phases
                fallbackView
            }
        }
        .frame(width: size.points, height: size.points)
        .clipShape(Circle())
        .accessibilityLabel(Text(fallback))
    }

    private var fallbackView: some View {
        Circle()
            .fill(theme.muted)
            .overlay {
                Text(fallback)
                    .font(.system(size: size.points * 0.36, weight: .medium))
                    .foregroundStyle(theme.mutedForeground)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
    }
}

// MARK: - Subcomponents

/// A row of overlapping avatars with an optional "+N" overflow indicator.
/// Each avatar gets a 2pt ring in the theme background so the stack reads
/// as separate circles.
///
///     SCAvatarGroup(avatars: [
///         (URL(string: "https://github.com/shadcn.png"), "CN"),
///         (nil, "AB"),
///         (nil, "CD"),
///     ], max: 2)
public struct SCAvatarGroup: View {
    @Environment(\.theme) private var theme

    var avatars: [(URL?, String)]
    var size: SCAvatarSize
    var maxCount: Int?
    var overlap: CGFloat

    /// - Parameters:
    ///   - avatars: `(url, fallback)` pairs, leading avatar first.
    ///   - size: Diameter preset applied to every avatar.
    ///   - max: Maximum avatars to show; the rest collapse into a "+N" circle.
    ///   - overlap: How far each avatar overlaps the previous one, in points.
    public init(
        avatars: [(URL?, String)],
        size: SCAvatarSize = .default,
        max maxCount: Int? = nil,
        overlap: CGFloat = 12
    ) {
        self.avatars = avatars
        self.size = size
        self.maxCount = maxCount
        self.overlap = overlap
    }

    private var visible: [(URL?, String)] {
        guard let maxCount, avatars.count > maxCount else { return avatars }
        return Array(avatars.prefix(maxCount))
    }

    private var overflowCount: Int {
        avatars.count - visible.count
    }

    public var body: some View {
        HStack(spacing: -overlap) {
            ForEach(Array(visible.enumerated()), id: \.offset) { _, avatar in
                SCAvatar(url: avatar.0, fallback: avatar.1, size: size)
                    .padding(2)
                    .background(theme.background, in: Circle())
            }
            if overflowCount > 0 {
                overflowBadge
            }
        }
    }

    private var overflowBadge: some View {
        Circle()
            .fill(theme.muted)
            .frame(width: size.points, height: size.points)
            .overlay {
                Text("+\(overflowCount)")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(theme.mutedForeground)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .padding(2)
            .background(theme.background, in: Circle())
            .accessibilityLabel(Text("\(overflowCount) more"))
    }
}

// MARK: - Previews

#Preview("Avatar · sizes") {
    SCPreview {
        HStack(spacing: 12) {
            SCAvatar(url: URL(string: "https://github.com/shadcn.png"), fallback: "CN", size: .sm)
            SCAvatar(url: URL(string: "https://github.com/shadcn.png"), fallback: "CN")
            SCAvatar(url: URL(string: "https://github.com/shadcn.png"), fallback: "CN", size: .lg)
            SCAvatar(url: nil, fallback: "AB", size: .custom(72))
        }
    }
}

#Preview("Avatar · fallback") {
    SCPreview {
        HStack(spacing: 12) {
            SCAvatar(url: nil, fallback: "CN")
            SCAvatar(url: nil, fallback: "AB", size: .lg)
        }
    }
}

#Preview("AvatarGroup") {
    SCPreview {
        VStack(alignment: .leading, spacing: 16) {
            SCAvatarGroup(avatars: [
                (URL(string: "https://github.com/shadcn.png"), "CN"),
                (nil, "AB"),
                (nil, "CD"),
            ])
            SCAvatarGroup(avatars: [
                (URL(string: "https://github.com/shadcn.png"), "CN"),
                (nil, "AB"),
                (nil, "CD"),
                (nil, "EF"),
                (nil, "GH"),
            ], max: 3)
        }
    }
}
