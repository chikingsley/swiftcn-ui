// ============================================================
// FormDemos.swift — Swiftcn Showcase
// Live demos for the Forms & Input category, mirroring each
// component's #Preview content.
// ============================================================
import SwiftUI
import Swiftcn

// MARK: - Button

struct ButtonDemo: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            DemoSection("Variants") {
                WrappingRow {
                    Button("Default") {}.buttonStyle(.sc())
                    Button("Destructive") {}.buttonStyle(.sc(.destructive))
                    Button("Outline") {}.buttonStyle(.sc(.outline))
                    Button("Secondary") {}.buttonStyle(.sc(.secondary))
                    Button("Ghost") {}.buttonStyle(.sc(.ghost))
                    Button("Link") {}.buttonStyle(.sc(.link))
                }
            }
            DemoSection("Sizes") {
                WrappingRow {
                    Button("Small") {}.buttonStyle(.sc(.outline, size: .sm))
                    Button("Default") {}.buttonStyle(.sc(.outline))
                    Button("Large") {}.buttonStyle(.sc(.outline, size: .lg))
                    Button {} label: { Image(systemName: "chevron.right") }
                        .buttonStyle(.sc(.outline, size: .icon))
                }
            }
            DemoSection("States") {
                HStack(spacing: 12) {
                    Button("Disabled") {}.buttonStyle(.sc()).disabled(true)
                    Button {} label: {
                        Label("Sign in with Email", systemImage: "envelope")
                    }
                    .buttonStyle(.sc())
                }
            }
        }
    }
}

// MARK: - Button Group

struct ButtonGroupDemo: View {
    @State private var count = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            SCButtonGroup(items: [
                .init(label: "Copy"),
                .init(label: "Paste"),
                .init(label: "Cut"),
            ])
            SCButtonGroup(variant: .secondary, items: [
                .init(label: "Archive", systemImage: "archivebox"),
                .init(systemImage: "trash"),
            ])
            HStack(spacing: 12) {
                SCButtonGroup(size: .sm, items: [
                    .init(systemImage: "minus") { count -= 1 },
                    .init(systemImage: "plus") { count += 1 },
                ])
                Text("Count: \(count)")
                    .scMuted()
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
    @State private var fruit: String? = nil
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
                SCToggleGroup(selection: $alignment, items: [
                    .init(value: "left", systemImage: "text.alignleft"),
                    .init(value: "center", systemImage: "text.aligncenter"),
                    .init(value: "right", systemImage: "text.alignright"),
                ])
            }
            DemoSection("Multi select") {
                SCToggleGroup(selection: $styles, items: [
                    .init(value: "bold", systemImage: "bold"),
                    .init(value: "italic", systemImage: "italic"),
                    .init(value: "underline", systemImage: "underline"),
                ])
            }
            DemoSection("Labels") {
                SCToggleGroup(selection: $period, items: [
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
