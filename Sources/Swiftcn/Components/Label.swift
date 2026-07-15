// ============================================================
// Label.swift — swiftcn-ui
// Depends on: Theme/
// ============================================================
import SwiftUI

// MARK: - Label

/// A form label with arbitrary content. An optional activation forwards a
/// pointer, touch, or accessibility action to the associated native control.
public struct SCLabel<Content: View>: View {
    @Environment(\.theme) private var theme
    @Environment(\.isEnabled) private var isEnabled

    private let required: Bool
    private let onActivate: (() -> Void)?
    private let content: Content

    public init(
        required: Bool = false,
        onActivate: (() -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.required = required
        self.onActivate = onActivate
        self.content = content()
    }

    public init(
        required: Bool = false,
        focus: FocusState<Bool>.Binding,
        @ViewBuilder content: () -> Content
    ) {
        self.init(
            required: required,
            onActivate: { focus.wrappedValue = true },
            content: content
        )
    }

    public var body: some View {
        HStack(spacing: 3) {
            content
            if required {
                Text("*")
                    .foregroundStyle(theme.destructive)
                    .accessibilityLabel(Text("Required"))
            }
        }
        .font(.footnote.weight(.medium))
        .foregroundStyle(theme.foreground)
        .fixedSize(horizontal: false, vertical: true)
        .contentShape(Rectangle())
        .opacity(isEnabled ? 1 : 0.5)
        .accessibilityElement(children: .combine)
        .modifier(SCLabelActivation(action: onActivate, isEnabled: isEnabled))
    }
}

extension SCLabel where Content == Text {
    public init(
        _ text: String,
        required: Bool = false,
        onActivate: (() -> Void)? = nil
    ) {
        self.init(required: required, onActivate: onActivate) {
            Text(text)
        }
    }

    /// A detached label that sends activation directly to a FocusState-backed
    /// control without inventing a string identifier.
    public init(
        _ text: String,
        required: Bool = false,
        focus: FocusState<Bool>.Binding
    ) {
        self.init(
            text,
            required: required,
            onActivate: { focus.wrappedValue = true }
        )
    }
}

private struct SCLabelActivation: ViewModifier {
    let action: (() -> Void)?
    let isEnabled: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if let action {
            content
                .onTapGesture {
                    if isEnabled { action() }
                }
                .accessibilityAction {
                    if isEnabled { action() }
                }
        } else {
            content
        }
    }
}

// MARK: - Native control relationship

public enum SCLabelledControlOrientation: CaseIterable, Equatable, Hashable, Sendable {
    case vertical
    case horizontal
}

public enum SCLabelPlacement: CaseIterable, Equatable, Hashable, Sendable {
    case leading
    case trailing
}

/// Associates an arbitrary label and control using SwiftUI's native
/// accessibility labelled-pair relationship. Supply the Label's `onActivate`
/// or `focus` initializer when pointer/touch activation should also be routed.
public struct SCLabelledControl<Label: View, Control: View>: View {
    @Namespace private var relationshipNamespace

    private let orientation: SCLabelledControlOrientation
    private let labelPlacement: SCLabelPlacement
    private let spacing: CGFloat
    private let label: Label
    private let control: Control

    public init(
        orientation: SCLabelledControlOrientation = .vertical,
        labelPlacement: SCLabelPlacement = .leading,
        spacing: CGFloat = 8,
        @ViewBuilder label: () -> Label,
        @ViewBuilder control: () -> Control
    ) {
        self.orientation = orientation
        self.labelPlacement = labelPlacement
        self.spacing = spacing
        self.label = label()
        self.control = control()
    }

    public var body: some View {
        switch (orientation, labelPlacement) {
        case (.vertical, .leading):
            VStack(alignment: .leading, spacing: spacing) {
                labelledLabel
                labelledControl
            }
        case (.vertical, .trailing):
            VStack(alignment: .leading, spacing: spacing) {
                labelledControl
                labelledLabel
            }
        case (.horizontal, .leading):
            HStack(alignment: .center, spacing: spacing) {
                labelledLabel
                labelledControl
            }
        case (.horizontal, .trailing):
            HStack(alignment: .center, spacing: spacing) {
                labelledControl
                labelledLabel
            }
        }
    }

    private var labelledLabel: some View {
        label.accessibilityLabeledPair(
            role: .label,
            id: "swiftcn-label",
            in: relationshipNamespace
        )
    }

    private var labelledControl: some View {
        control.accessibilityLabeledPair(
            role: .content,
            id: "swiftcn-label",
            in: relationshipNamespace
        )
    }
}

// MARK: - Previews

private struct SCLabelPreview: View {
    @State private var acceptsTerms = false
    @State private var username = ""
    @FocusState private var usernameIsFocused: Bool

    var body: some View {
        SCPreview {
            VStack(alignment: .leading, spacing: 16) {
                SCLabelledControl {
                    SCLabel(
                        "Username",
                        required: true,
                        focus: $usernameIsFocused
                    )
                } control: {
                    TextField("Username", text: $username)
                        .focused($usernameIsFocused)
                        .textFieldStyle(.roundedBorder)
                }

                SCLabelledControl(orientation: .horizontal, labelPlacement: .trailing) {
                    SCLabel(
                        "Accept terms and conditions",
                        onActivate: { acceptsTerms.toggle() }
                    )
                } control: {
                    Button {
                        acceptsTerms.toggle()
                    } label: {
                        Image(systemName: acceptsTerms ? "checkmark.square.fill" : "square")
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel(Text("Accept terms and conditions"))
                    .accessibilityValue(Text(acceptsTerms ? "On" : "Off"))
                }

                SCLabel {
                    Image(systemName: "envelope")
                    Text("Arbitrary label content")
                }

                SCLabel("Disabled").disabled(true)
            }
        }
    }
}

#Preview("Label") {
    SCLabelPreview()
}
