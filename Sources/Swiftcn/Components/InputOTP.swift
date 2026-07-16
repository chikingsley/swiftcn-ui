// ============================================================
// InputOTP.swift — swiftcn-ui
// Depends on: Field.swift · Theme/
// ============================================================
import SwiftUI

// MARK: - Pattern

/// The native text-entry intent used by a one-time-code field.
public enum SCInputOTPInputMode: CaseIterable, Equatable, Hashable, Sendable {
    /// Uses the preferred mode declared by the selected pattern.
    case automatic
    /// Presents a general text keyboard on iPadOS.
    case text
    /// Presents a numeric keyboard on iPadOS.
    case numeric
}

/// A reusable character filter for one-time-code input.
public struct SCInputOTPPattern: Sendable {
    private let accepts: @Sendable (Character) -> Bool
    fileprivate let preferredInputMode: SCInputOTPInputMode

    public init(
        inputMode: SCInputOTPInputMode = .text,
        _ accepts: @escaping @Sendable (Character) -> Bool
    ) {
        self.accepts = accepts
        self.preferredInputMode = inputMode
    }

    public func contains(_ character: Character) -> Bool {
        accepts(character)
    }

    public static let digits = Self(inputMode: .numeric) { character in
        character.isASCII && character.isNumber
    }

    public static let alphanumeric = Self { character in
        character.isASCII && (character.isLetter || character.isNumber)
    }

    public static let any = Self { !$0.isNewline }
}

// MARK: - Root context

private struct SCInputOTPContext {
    var code = ""
    var length = 1
    var activeIndex: Int?
    var isFocused = false
    var isInvalid = false
    var requestFocus: () -> Void = {}
}

private struct SCInputOTPContextKey: EnvironmentKey {
    static var defaultValue: SCInputOTPContext { SCInputOTPContext() }
}

private enum SCInputOTPGroupPosition {
    case single
    case first
    case middle
    case last
}

private struct SCInputOTPGroupPositionKey: EnvironmentKey {
    static let defaultValue = SCInputOTPGroupPosition.single
}

extension EnvironmentValues {
    fileprivate var scInputOTP: SCInputOTPContext {
        get { self[SCInputOTPContextKey.self] }
        set { self[SCInputOTPContextKey.self] = newValue }
    }

    fileprivate var scInputOTPGroupPosition: SCInputOTPGroupPosition {
        get { self[SCInputOTPGroupPositionKey.self] }
        set { self[SCInputOTPGroupPositionKey.self] = newValue }
    }
}

// MARK: - Root

/// A controlled one-time-code input with caller-composed groups, slots, and
/// separators. One real native TextField owns typing, paste, selection,
/// deletion, keyboard input, and iOS one-time-code autofill.
public struct SCInputOTP<Content: View>: View {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.scFieldInvalid) private var fieldIsInvalid
    @FocusState private var isFocused: Bool

    @Binding private var code: String
    private let length: Int
    private let pattern: SCInputOTPPattern
    private let inputMode: SCInputOTPInputMode
    private let explicitIsInvalid: Bool?
    private let accessibilityLabel: String
    private let onChange: ((String) -> Void)?
    private let onComplete: ((String) -> Void)?
    private let content: Content

    public init(
        code: Binding<String>,
        length: Int,
        pattern: SCInputOTPPattern = .digits,
        inputMode: SCInputOTPInputMode = .automatic,
        isInvalid: Bool? = nil,
        accessibilityLabel: String = "One-time code",
        onChange: ((String) -> Void)? = nil,
        onComplete: ((String) -> Void)? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self._code = code
        self.length = max(length, 1)
        self.pattern = pattern
        self.inputMode = inputMode
        self.explicitIsInvalid = isInvalid
        self.accessibilityLabel = accessibilityLabel
        self.onChange = onChange
        self.onComplete = onComplete
        self.content = content()
    }

    public var body: some View {
        ZStack {
            hiddenField

            HStack(spacing: 8) {
                content
            }
            .accessibilityHidden(true)
        }
        .environment(
            \.scInputOTP,
            SCInputOTPContext(
                code: code,
                length: length,
                activeIndex: activeIndex,
                isFocused: isFocused,
                isInvalid: resolvedIsInvalid,
                requestFocus: {
                    if isEnabled { isFocused = true }
                }
            )
        )
        .contentShape(Rectangle())
        .onTapGesture {
            if isEnabled { isFocused = true }
        }
        .opacity(isEnabled ? 1 : 0.5)
        .animation(.easeOut(duration: 0.15), value: code)
        .animation(.easeOut(duration: 0.15), value: isFocused)
        .onAppear { sanitize(code, sendsCallbacks: false) }
        .onChange(of: code) { _, newValue in
            sanitize(newValue, sendsCallbacks: true)
        }
    }

    private var hiddenField: some View {
        TextField(accessibilityLabel, text: $code)
            .textFieldStyle(.plain)
            .focused($isFocused)
            .autocorrectionDisabled()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .opacity(0.01)
            .accessibilityLabel(Text(accessibilityLabel))
            .accessibilityValue(Text(accessibilityValue))
            // The web input announces invalidity through aria-invalid; a hint
            // is the native equivalent, matching SCSwitch.
            .accessibilityHint(resolvedIsInvalid ? "Invalid entry" : "")
            .modifier(SCInputOTPTextEntryModifier(inputMode: resolvedInputMode))
    }

    private var resolvedIsInvalid: Bool {
        explicitIsInvalid ?? fieldIsInvalid
    }

    private var activeIndex: Int? {
        guard isFocused else { return nil }
        return min(code.count, length - 1)
    }

    private var accessibilityValue: String {
        let characters = code.isEmpty ? "Empty" : code.map(String.init).joined(separator: " ")
        return "\(characters), \(code.count) of \(length) characters entered"
    }

    private var resolvedInputMode: SCInputOTPInputMode {
        inputMode == .automatic ? pattern.preferredInputMode : inputMode
    }

    private func sanitize(_ candidate: String, sendsCallbacks: Bool) {
        let sanitized = String(candidate.filter(pattern.contains).prefix(length))
        guard sanitized == candidate else {
            code = sanitized
            return
        }
        guard sendsCallbacks else { return }
        onChange?(sanitized)
        if sanitized.count == length {
            onComplete?(sanitized)
        }
    }
}

private struct SCInputOTPTextEntryModifier: ViewModifier {
    let inputMode: SCInputOTPInputMode

    @ViewBuilder
    func body(content: Content) -> some View {
        #if os(iOS)
            content
                .textInputAutocapitalization(inputMode == .text ? .characters : .never)
                .keyboardType(inputMode == .numeric ? .numberPad : .asciiCapable)
                .textContentType(.oneTimeCode)
        #else
            content
        #endif
    }
}

// MARK: - Compact convenience composition

extension SCInputOTP where Content == AnyView {
    /// A compact grouped initializer composed from the same public Root,
    /// Group, Slot, and Separator parts.
    public init(
        code: Binding<String>,
        length: Int = 6,
        groupSize: Int? = 3,
        pattern: SCInputOTPPattern = .digits,
        inputMode: SCInputOTPInputMode = .automatic,
        isInvalid: Bool? = nil,
        accessibilityLabel: String = "One-time code",
        onChange: ((String) -> Void)? = nil,
        onComplete: ((String) -> Void)? = nil
    ) {
        let safeLength = max(length, 1)
        let groups = Self.groups(length: safeLength, groupSize: groupSize)

        self.init(
            code: code,
            length: safeLength,
            pattern: pattern,
            inputMode: inputMode,
            isInvalid: isInvalid,
            accessibilityLabel: accessibilityLabel,
            onChange: onChange,
            onComplete: onComplete
        ) {
            AnyView(
                HStack(spacing: 8) {
                    ForEach(Array(groups.enumerated()), id: \.offset) { offset, indices in
                        SCInputOTPGroup(indices: indices)
                        if offset < groups.count - 1 {
                            SCInputOTPSeparator()
                        }
                    }
                }
            )
        }
    }

    private static func groups(length: Int, groupSize: Int?) -> [Range<Int>] {
        guard let groupSize, groupSize > 0 else { return [0..<length] }
        return stride(from: 0, to: length, by: groupSize).map { start in
            start..<min(start + groupSize, length)
        }
    }
}

// MARK: - Group builder

@resultBuilder
public enum SCInputOTPGroupBuilder {
    public static func buildBlock(_ components: [SCInputOTPSlot]...) -> [SCInputOTPSlot] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ expression: SCInputOTPSlot) -> [SCInputOTPSlot] {
        [expression]
    }

    public static func buildOptional(_ component: [SCInputOTPSlot]?) -> [SCInputOTPSlot] {
        component ?? []
    }

    public static func buildEither(first component: [SCInputOTPSlot]) -> [SCInputOTPSlot] {
        component
    }

    public static func buildEither(second component: [SCInputOTPSlot]) -> [SCInputOTPSlot] {
        component
    }

    public static func buildArray(_ components: [[SCInputOTPSlot]]) -> [SCInputOTPSlot] {
        components.flatMap { $0 }
    }
}

/// A contiguous group of slots with shared inner borders and semantic outer
/// corner geometry.
public struct SCInputOTPGroup: View {
    private let slots: [SCInputOTPSlot]

    public init(@SCInputOTPGroupBuilder content: () -> [SCInputOTPSlot]) {
        self.slots = content()
    }

    public init(
        indices: Range<Int>,
        width: CGFloat = 40,
        height: CGFloat = 48
    ) {
        self.slots = indices.map {
            SCInputOTPSlot(index: $0, width: width, height: height)
        }
    }

    public var body: some View {
        HStack(spacing: -1) {
            ForEach(Array(slots.enumerated()), id: \.offset) { offset, slot in
                slot
                    .environment(
                        \.scInputOTPGroupPosition,
                        position(at: offset)
                    )
            }
        }
    }

    private func position(at offset: Int) -> SCInputOTPGroupPosition {
        if slots.count <= 1 { return .single }
        if offset == 0 { return .first }
        if offset == slots.count - 1 { return .last }
        return .middle
    }
}

// MARK: - Slot

/// One visual slot backed by the root's single native text field.
public struct SCInputOTPSlot: View {
    @Environment(\.theme) private var theme
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.scInputOTP) private var input
    @Environment(\.scInputOTPGroupPosition) private var position

    public let index: Int
    private let width: CGFloat
    private let height: CGFloat
    private let explicitIsInvalid: Bool?

    public init(
        index: Int,
        width: CGFloat = 40,
        height: CGFloat = 48,
        isInvalid: Bool? = nil
    ) {
        self.index = max(index, 0)
        self.width = max(width, 24)
        self.height = max(height, 24)
        self.explicitIsInvalid = isInvalid
    }

    public var body: some View {
        ZStack {
            if let character {
                Text(String(character))
                    .font(.title3.weight(.medium).monospaced())
                    .foregroundStyle(theme.foreground)
            } else if isActive {
                caret
            }
        }
        .frame(width: width, height: height)
        .background(theme.background, in: shape)
        .overlay(shape.strokeBorder(strokeColor, lineWidth: isActive ? 1.5 : 1))
        .contentShape(shape)
        .onTapGesture { input.requestFocus() }
        .zIndex(isActive ? 1 : 0)
        .accessibilityHidden(true)
    }

    private var character: Character? {
        guard index < input.code.count else { return nil }
        return Array(input.code)[index]
    }

    private var isActive: Bool {
        input.isFocused && input.activeIndex == index
    }

    private var isInvalid: Bool {
        explicitIsInvalid ?? input.isInvalid
    }

    private var strokeColor: Color {
        if isInvalid {
            theme.destructive
        } else if isActive {
            theme.ring
        } else {
            theme.input
        }
    }

    private var caret: some View {
        TimelineView(.periodic(from: .now, by: 0.55)) { context in
            Capsule()
                .fill(theme.foreground)
                .frame(width: 1.5, height: 20)
                .opacity(caretIsVisible(at: context.date) ? 1 : 0)
        }
        .allowsHitTesting(false)
    }

    private func caretIsVisible(at date: Date) -> Bool {
        Int(date.timeIntervalSinceReferenceDate / 0.55).isMultiple(of: 2)
    }

    private var shape: UnevenRoundedRectangle {
        let radius = theme.radius
        let firstIsLeft = layoutDirection == .leftToRight
        let roundsLeft =
            position == .single || (position == .first && firstIsLeft)
            || (position == .last && !firstIsLeft)
        let roundsRight =
            position == .single || (position == .last && firstIsLeft)
            || (position == .first && !firstIsLeft)

        return UnevenRoundedRectangle(
            topLeadingRadius: roundsLeft ? radius : 0,
            bottomLeadingRadius: roundsLeft ? radius : 0,
            bottomTrailingRadius: roundsRight ? radius : 0,
            topTrailingRadius: roundsRight ? radius : 0,
            style: .continuous
        )
    }
}

// MARK: - Separator

/// The visual and accessibility separator between OTP groups.
public struct SCInputOTPSeparator: View {
    @Environment(\.theme) private var theme

    public init() {}

    public var body: some View {
        Image(systemName: "minus")
            .font(.caption)
            .foregroundStyle(theme.mutedForeground)
            .accessibilityHidden(true)
    }
}

// MARK: - Previews

#Preview("Input OTP · composed") {
    @Previewable @State var code = "12A"

    SCPreview {
        VStack(spacing: 16) {
            SCInputOTP(
                code: $code,
                length: 6,
                pattern: .alphanumeric
            ) {
                SCInputOTPGroup {
                    SCInputOTPSlot(index: 0)
                    SCInputOTPSlot(index: 1)
                    SCInputOTPSlot(index: 2)
                }
                SCInputOTPSeparator()
                SCInputOTPGroup {
                    SCInputOTPSlot(index: 3)
                    SCInputOTPSlot(index: 4)
                    SCInputOTPSlot(index: 5)
                }
            }
            Text("Entered: \(code)")
                .scMuted()
        }
    }
}

#Preview("Input OTP · convenience") {
    @Previewable @State var code = "1234"

    SCPreview {
        VStack(spacing: 16) {
            SCInputOTP(code: $code, length: 8, groupSize: 4)
            SCInputOTP(code: $code, length: 4, groupSize: nil, isInvalid: true)
            SCInputOTP(code: $code, length: 4, groupSize: nil)
                .disabled(true)
        }
    }
}
