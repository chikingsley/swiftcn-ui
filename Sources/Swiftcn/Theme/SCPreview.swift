import SwiftUI

/// Standard framing for component previews and Showcase demos: injects the
/// theme (previews don't inherit app-level modifiers), paints the themed
/// background, and optionally labels the example.
public struct SCPreview<Content: View>: View {
    var title: String?
    @ViewBuilder var content: Content

    public init(_ title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let title {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(Theme.default.mutedForeground)
            }
            content
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(Theme.default.background)
        .theme(.default)
    }
}
