// ============================================================
// SheetParts.swift — swiftcn-ui
// Supplemental source for: sheet
// ============================================================
import SwiftUI

// MARK: - Header, footer, title, and description

public struct SCSheetHeader<Content: View>: View {
    private let alignment: HorizontalAlignment
    private let content: Content

    public init(
        alignment: HorizontalAlignment = .leading,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: alignment, spacing: 6) {
            content
        }
        .frame(maxWidth: .infinity, alignment: alignment == .center ? .center : .leading)
    }
}

/// A bottom action region with arbitrary content.
public struct SCSheetFooter<Content: View>: View {
    private let alignment: HorizontalAlignment
    private let content: Content

    public init(
        alignment: HorizontalAlignment = .leading,
        @ViewBuilder content: () -> Content
    ) {
        self.alignment = alignment
        self.content = content()
    }

    public var body: some View {
        VStack(alignment: alignment, spacing: 8) {
            content
        }
        .frame(maxWidth: .infinity, alignment: alignment == .trailing ? .trailing : .leading)
    }
}

public struct SCSheetTitle<Content: View>: View {
    @Environment(\.theme) private var theme
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .font(.headline)
            .foregroundStyle(theme.foreground)
            .accessibilityAddTraits(.isHeader)
    }
}

extension SCSheetTitle where Content == Text {
    public init(_ title: String) {
        self.init { Text(title) }
    }
}

public struct SCSheetDescription<Content: View>: View {
    @Environment(\.theme) private var theme
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .font(.subheadline)
            .foregroundStyle(theme.mutedForeground)
    }
}

extension SCSheetDescription where Content == Text {
    public init(_ description: String) {
        self.init { Text(description) }
    }
}

// MARK: - Previews

#Preview("Sheet · composition") {
    @Previewable @State var name = "Pedro Duarte"
    @Previewable @State var username = "@peduarte"

    SCPreview {
        SCSheet(defaultPresented: false) {
            SCSheetTrigger("Open")
                .buttonStyle(.sc(.outline))
        } content: {
            SCSheetContent {
                SCSheetHeader {
                    SCSheetTitle("Edit profile")
                    SCSheetDescription(
                        "Make changes to your profile here. Save when you're done."
                    )
                }
                SCFieldGroup {
                    SCField("Name") {
                        SCInput("Name", value: $name)
                    }
                    SCField("Username") {
                        SCInput("Username", value: $username)
                    }
                }
                Spacer(minLength: 0)
                SCSheetFooter {
                    Button("Save changes") {}
                        .buttonStyle(.sc())
                    SCSheetClose("Close")
                        .buttonStyle(.sc(.outline))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview("Sheet · sides") {
    @Previewable @State var presentedEdge: SCSheetEdge?

    SCPreview {
        HStack {
            ForEach(SCSheetEdge.allCases, id: \.self) { edge in
                Button(String(describing: edge).capitalized) {
                    presentedEdge = edge
                }
                .buttonStyle(.sc(.outline))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .scSheet(
            isPresented: Binding(
                get: { presentedEdge != nil },
                set: { if !$0 { presentedEdge = nil } }
            ),
            edge: presentedEdge ?? .trailing,
            maximumPanelSize: 420
        ) {
            SCSheetContent(showsCloseButton: false) {
                SCSheetHeader {
                    SCSheetTitle("\(String(describing: presentedEdge ?? .trailing).capitalized) sheet")
                    SCSheetDescription("The same engine supports all four semantic edges.")
                }
                SCSheetClose("Close")
                    .buttonStyle(.sc(.outline))
            }
        }
    }
}
