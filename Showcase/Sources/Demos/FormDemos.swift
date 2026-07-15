// ============================================================
// FormDemos.swift — Swiftcn macOS Showcase
// Live demos for the Forms & Input category, mirroring each
// component's #Preview content.
// ============================================================
import SwiftUI
import Swiftcn

// MARK: - Button

struct ButtonDemo: View {
    @State private var lastAction = "Choose a button."

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            DemoSection("Variants") {
                WrappingRow {
                    demoButton("Default", variant: .default)
                    demoButton("Destructive", variant: .destructive)
                    demoButton("Outline", variant: .outline)
                    demoButton("Secondary", variant: .secondary)
                    demoButton("Ghost", variant: .ghost)
                    demoButton("Link", variant: .link)
                }
            }
            DemoSection("Sizes") {
                WrappingRow {
                    demoButton("Small", variant: .outline, size: .sm)
                    demoButton("Default", variant: .outline)
                    demoButton("Large", variant: .outline, size: .lg)
                    Button {
                        lastAction = "Icon button"
                    } label: {
                        Image(systemName: "chevron.right")
                    }
                    .buttonStyle(.sc(.outline, size: .icon))
                }
            }
            DemoSection("States") {
                HStack(spacing: 12) {
                    Button("Disabled") { lastAction = "Disabled" }.buttonStyle(.sc()).disabled(true)
                    Button {
                        lastAction = "Sign in with Email"
                    } label: {
                        Label("Sign in with Email", systemImage: "envelope")
                    }
                    .buttonStyle(.sc())
                    Button {
                    } label: {
                        HStack(spacing: 8) {
                            ProgressView().controlSize(.small)
                            Text("Generating")
                        }
                    }
                    .buttonStyle(.sc())
                    .disabled(true)
                }
            }
            Text(lastAction).scMuted()
        }
    }

    private func demoButton(
        _ label: String,
        variant: SCButtonVariant,
        size: SCButtonSize = .default
    ) -> some View {
        Button(label) { lastAction = label }
            .buttonStyle(.sc(variant, size: size))
    }
}

// MARK: - Button Group

struct ButtonGroupDemo: View {
    @State private var count = 0
    @State private var lastAction = "Choose an action."

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SCButtonGroup(items: [
                .init(label: "Copy") { lastAction = "Copied" },
                .init(label: "Paste") { lastAction = "Pasted" },
                .init(label: "Cut") { lastAction = "Cut" },
            ])
            SCButtonGroup(
                variant: .secondary,
                items: [
                    .init(label: "Archive", systemImage: "archivebox") {
                        lastAction = "Archived"
                    },
                    .init(systemImage: "trash") { lastAction = "Deleted" },
                ])
            HStack(spacing: 12) {
                SCButtonGroup(
                    size: .sm,
                    items: [
                        .init(systemImage: "minus") { count -= 1 },
                        .init(systemImage: "plus") { count += 1 },
                    ])
                Text("Count: \(count)")
                    .scMuted()
            }
            Text(lastAction).scMuted()
        }
    }
}

// MARK: - Calendar

struct CalendarDemo: View {
    @State private var date: Date? = Date()
    @State private var range: ClosedRange<Date>?
    @State private var bounded: Date?

    private var bounds: ClosedRange<Date> {
        let today = Calendar.current.startOfDay(for: Date())
        let limit = Calendar.current.date(byAdding: .month, value: 2, to: today) ?? today
        return today...limit
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 28) {
            DemoSection("Single date") {
                SCCalendar(selection: $date)
            }
            DemoSection("Range · tap two days") {
                VStack(alignment: .leading, spacing: 10) {
                    SCCalendar(range: $range)
                    Text(
                        range.map {
                            let start = $0.lowerBound.formatted(date: .abbreviated, time: .omitted)
                            let end = $0.upperBound.formatted(date: .abbreviated, time: .omitted)
                            return "\(start) – \(end)"
                        } ?? "No range selected"
                    )
                    .scMuted()
                }
            }
            DemoSection("Bounds & disabled weekends") {
                SCCalendar(
                    selection: $bounded,
                    bounds: bounds,
                    disabled: { Calendar.current.isDateInWeekend($0) }
                )
            }
        }
    }
}

// MARK: - Checkbox

struct CheckboxDemo: View {
    @State private var accepted = true
    @State private var marketing = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle("Accept terms and conditions", isOn: $accepted)
                .toggleStyle(.scCheckbox)
            Toggle("Receive marketing emails", isOn: $marketing)
                .toggleStyle(.scCheckbox)
            Toggle("Disabled checked", isOn: .constant(true))
                .toggleStyle(.scCheckbox)
                .disabled(true)
        }
    }
}

// MARK: - Combobox

struct ComboboxDemo: View {
    @State private var framework: String?
    @State private var priority: Int? = 2
    @State private var assignees: Set<String> = ["Ada"]
    @State private var peopleQuery = ""

    private let people = [
        SCComboboxOption(value: "Ada", label: "Ada Lovelace", keywords: ["analytical engine"], group: "Core team"),
        SCComboboxOption(value: "Grace", label: "Grace Hopper", keywords: ["compiler"], group: "Core team"),
        SCComboboxOption(value: "Linus", label: "Linus Torvalds", keywords: ["kernel"], group: "Maintainers"),
        SCComboboxOption(
            value: "Guest",
            label: "External guest",
            group: "Maintainers",
            isDisabled: true
        ),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            DemoSection("Single selection") {
                SCCombobox(
                    selection: $framework,
                    options: ["Next.js", "SvelteKit", "Nuxt.js", "Remix", "Astro"],
                    placeholder: "Select framework…",
                    searchPlaceholder: "Search framework…"
                )
            }
            DemoSection("Grouped multi-select · custom trigger and rows") {
                SCCombobox(
                    selection: $assignees,
                    options: people,
                    placeholder: "Assign people…",
                    searchPlaceholder: "Search names or skills…",
                    query: $peopleQuery,
                    trigger: { selected, expanded in
                        HStack {
                            Text(selected.isEmpty ? "Assign people…" : "\(selected.count) assigned")
                            Spacer()
                            Image(systemName: expanded ? "chevron.up" : "chevron.down")
                        }
                        .padding(.horizontal, 12)
                        .frame(maxWidth: .infinity, minHeight: 40)
                    },
                    row: { option, selected in
                        HStack {
                            Image(systemName: selected ? "checkmark.circle.fill" : "circle")
                            VStack(alignment: .leading, spacing: 2) {
                                Text(option.label)
                                Text(option.keywords.first ?? "No additional keywords")
                                    .scMuted()
                            }
                            Spacer()
                            if option.isDisabled { SCBadge("Unavailable", variant: .outline) }
                        }
                    },
                    groupHeader: { title in
                        Text(title.uppercased())
                            .font(.caption2.weight(.semibold))
                            .padding(.horizontal, 10)
                    },
                    empty: {
                        Text("No matching people")
                            .scMuted()
                    }
                )
                Text("Selected: \(assignees.sorted().joined(separator: ", "))")
                    .scMuted()
            }
            DemoSection("Typed values and disabled state") {
                SCCombobox(
                    selection: $priority,
                    options: [
                        SCComboboxOption(value: 1, label: "Low"),
                        SCComboboxOption(value: 2, label: "Medium"),
                        SCComboboxOption(value: 3, label: "High"),
                        SCComboboxOption(value: 4, label: "Urgent"),
                    ],
                    placeholder: "Priority…"
                )
                SCCombobox(
                    selection: .constant(String?.none),
                    options: ["One", "Two"],
                    placeholder: "Disabled"
                )
                .disabled(true)
            }
        }
    }
}

// MARK: - Date Picker

struct DatePickerDemo: View {
    @State private var date: Date?
    @State private var bounded: Date?

    private var bounds: ClosedRange<Date> {
        let today = Calendar.current.startOfDay(for: Date())
        let limit = Calendar.current.date(byAdding: .month, value: 1, to: today) ?? today
        return today...limit
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SCDatePicker(selection: $date)
            SCDatePicker("Within a month", selection: $bounded, in: bounds)
            SCDatePicker(selection: .constant(nil))
                .disabled(true)
        }
    }
}

// MARK: - Field

struct FieldDemo: View {
    @State private var email = ""
    @State private var invalidEmail = "not-an-email"

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SCField("Email", required: true, description: "We'll never share your email.") {
                SCInput("you@example.com", text: $email, icon: "envelope")
            }
            SCField("Email", required: true, error: "Enter a valid email address.") {
                SCInput("you@example.com", text: $invalidEmail, icon: "envelope")
            }
        }
    }
}

// MARK: - Input

struct InputDemo: View {
    @State private var email = ""
    @State private var age = 0
    @State private var query = "swiftcn"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SCInput("Email", text: $email, icon: "envelope")
            SCInput("Age", value: $age)
            SCInput("Search", text: $query, icon: "magnifyingglass") {
                Button {
                    query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search")
            }
            SCInput("Disabled", text: $email).disabled(true)
        }
    }
}

// MARK: - Input OTP

struct InputOTPDemo: View {
    @State private var code = ""
    @State private var plain = "12"

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            DemoSection("6 digits, grouped") {
                VStack(alignment: .leading, spacing: 10) {
                    SCInputOTP(code: $code)
                    Text("Entered: \(code)")
                        .scMuted()
                }
            }
            DemoSection("4 digits, ungrouped") {
                SCInputOTP(code: $plain, length: 4, groupSize: nil)
            }
        }
    }
}

// MARK: - Label

struct LabelDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            SCLabel("Email")
            SCLabel("Password", required: true)
        }
    }
}

// MARK: - Radio Group

struct RadioGroupDemo: View {
    @State private var density = "comfortable"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SCRadioGroup(selection: $density) {
                SCRadio("Default", value: "default")
                SCRadio("Comfortable", value: "comfortable")
                SCRadio("Compact", value: "compact")
            }
            Text("Selected: \(density)")
                .scMuted()
        }
    }
}

// MARK: - Select

struct SelectDemo: View {
    @State private var fruit: String?
    @State private var theme: String? = "Dark"

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SCSelect(
                selection: $fruit,
                placeholder: "Select a fruit",
                options: ["Apple", "Banana", "Blueberry", "Grapes", "Pineapple"]
            )
            SCSelect(
                selection: $theme,
                placeholder: "Theme",
                options: ["Light", "Dark", "System"]
            )
            SCSelect(
                selection: .constant(String?.none),
                placeholder: "Disabled",
                options: ["One", "Two"]
            )
            .disabled(true)
        }
    }
}

// MARK: - Slider

struct SliderDemo: View {
    @State private var value = 0.5
    @State private var stepped = 40.0

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                SCSlider(value: $value)
                Text(value, format: .percent.precision(.fractionLength(0)))
                    .scMuted()
            }
            VStack(alignment: .leading, spacing: 10) {
                SCSlider(value: $stepped, in: 0...100, step: 10)
                Text("Stepped: \(Int(stepped))")
                    .scMuted()
            }
            SCSlider(value: .constant(0.3))
                .disabled(true)
        }
        .frame(maxWidth: 320)
    }
}

// MARK: - Switch

struct SwitchDemo: View {
    @State private var airplaneMode = true
    @State private var wifi = false

    var body: some View {
        VStack(spacing: 12) {
            Toggle("Airplane Mode", isOn: $airplaneMode)
                .toggleStyle(.scSwitch)
            Toggle("Wi-Fi", isOn: $wifi)
                .toggleStyle(.scSwitch)
            Toggle("Disabled on", isOn: .constant(true))
                .toggleStyle(.scSwitch)
                .disabled(true)
        }
        .frame(maxWidth: 320)
    }
}

// MARK: - Textarea

struct TextareaDemo: View {
    @State private var message = ""
    @State private var bio = "swiftcn brings shadcn/ui's design language to SwiftUI."

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SCTextarea("Type your message here.", text: $message)
            SCTextarea("Bio", text: $bio, minHeight: 80)
        }
    }
}

// MARK: - Toggle

struct ToggleDemo: View {
    @State private var isBold = true
    @State private var isItalic = false
    @State private var labeled = true

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack(spacing: 8) {
                Toggle("Bold", systemImage: "bold", isOn: $isBold)
                    .toggleStyle(.scToggle())
                    .labelStyle(.iconOnly)
                Toggle("Italic", systemImage: "italic", isOn: $isItalic)
                    .toggleStyle(.scToggle(variant: .outline))
                    .labelStyle(.iconOnly)
                Toggle("Underline", systemImage: "underline", isOn: .constant(false))
                    .toggleStyle(.scToggle())
                    .labelStyle(.iconOnly)
                    .disabled(true)
            }
            HStack(spacing: 8) {
                Toggle("Small", isOn: $labeled)
                    .toggleStyle(.scToggle(variant: .outline, size: .sm))
                Toggle("Default", systemImage: "italic", isOn: $labeled)
                    .toggleStyle(.scToggle(variant: .outline))
                Toggle("Large", isOn: $labeled)
                    .toggleStyle(.scToggle(variant: .outline, size: .lg))
            }
        }
    }
}

// MARK: - Toggle Group

struct ToggleGroupDemo: View {
    @State private var alignment: String? = "left"
    @State private var styles: Set<String> = ["bold"]
    @State private var period: String? = "week"

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            DemoSection("Single select") {
                SCToggleGroup(
                    selection: $alignment,
                    items: [
                        .init(value: "left", systemImage: "text.alignleft"),
                        .init(value: "center", systemImage: "text.aligncenter"),
                        .init(value: "right", systemImage: "text.alignright"),
                    ])
            }
            DemoSection("Multi select") {
                SCToggleGroup(
                    selection: $styles,
                    items: [
                        .init(value: "bold", systemImage: "bold"),
                        .init(value: "italic", systemImage: "italic"),
                        .init(value: "underline", systemImage: "underline"),
                    ])
            }
            DemoSection("Labels") {
                SCToggleGroup(
                    selection: $period,
                    items: [
                        .init(value: "day", label: "Day"),
                        .init(value: "week", label: "Week"),
                        .init(value: "month", label: "Month"),
                    ])
            }
        }
    }
}

// MARK: - Shared demo helpers

/// A captioned sub-section inside a demo stage.
struct DemoSection<Content: View>: View {
    @Environment(\.theme) private var theme

    let title: String
    @ViewBuilder var content: Content

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.caption)
                .foregroundStyle(theme.mutedForeground)
            content
        }
    }
}

/// Lays children out in rows that wrap on narrow widths (iPhone).
struct WrappingRow<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        FlowLayout(spacing: 10) {
            content
        }
    }
}

/// A minimal left-to-right flow layout for demo rows.
struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var width: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > 0, x + size.width > maxWidth {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
            width = max(width, x - spacing)
        }
        return CGSize(width: proposal.width ?? width, height: y + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        var x = bounds.minX
        var y = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x > bounds.minX, x + size.width > bounds.maxX {
                x = bounds.minX
                y += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: x, y: y), proposal: .unspecified)
            x += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
    }
}

#Preview("Form · Button") { ShowcasePreview { ButtonDemo() } }
#Preview("Form · Button Group") { ShowcasePreview { ButtonGroupDemo() } }
#Preview("Form · Calendar") { ShowcasePreview { CalendarDemo() } }
#Preview("Form · Checkbox") { ShowcasePreview { CheckboxDemo() } }
#Preview("Form · Combobox") { ShowcasePreview { ComboboxDemo() } }
#Preview("Form · Date Picker") { ShowcasePreview { DatePickerDemo() } }
#Preview("Form · Field") { ShowcasePreview { FieldDemo() } }
#Preview("Form · Input") { ShowcasePreview { InputDemo() } }
#Preview("Form · Input OTP") { ShowcasePreview { InputOTPDemo() } }
#Preview("Form · Label") { ShowcasePreview { LabelDemo() } }
#Preview("Form · Radio Group") { ShowcasePreview { RadioGroupDemo() } }
#Preview("Form · Select") { ShowcasePreview { SelectDemo() } }
#Preview("Form · Slider") { ShowcasePreview { SliderDemo() } }
#Preview("Form · Switch") { ShowcasePreview { SwitchDemo() } }
#Preview("Form · Textarea") { ShowcasePreview { TextareaDemo() } }
#Preview("Form · Toggle") { ShowcasePreview { ToggleDemo() } }
#Preview("Form · Toggle Group") { ShowcasePreview { ToggleGroupDemo() } }
