// ============================================================
// Catalog.swift — Swiftcn Showcase
// The registry: one entry per component, block, and effect.
// AnyView is deliberately permitted here — this is the app's
// internal heterogeneous catalog, not library API.
// ============================================================
import SwiftUI
import Swiftcn

// MARK: - Category

enum Category: String, CaseIterable, Identifiable {
    case formsAndInput
    case display
    case feedback
    case navigation
    case overlays
    case blocks
    case effects

    var id: String { rawValue }

    var title: String {
        switch self {
        case .formsAndInput: "Forms & Input"
        case .display:       "Display"
        case .feedback:      "Feedback"
        case .navigation:    "Navigation"
        case .overlays:      "Overlays"
        case .blocks:        "Blocks"
        case .effects:       "Effects"
        }
    }

    var systemImage: String {
        switch self {
        case .formsAndInput: "square.and.pencil"
        case .display:       "square.grid.2x2"
        case .feedback:      "bell.badge"
        case .navigation:    "sidebar.leading"
        case .overlays:      "square.stack"
        case .blocks:        "cube"
        case .effects:       "sparkles"
        }
    }
}

// MARK: - Entry

struct ComponentEntry: Identifiable {
    let id: String
    let name: String
    let category: Category
    /// Sidebar row icon (SF Symbol) — keeps the icon rail meaningful.
    let icon: String
    /// One-line description shown at the top of the detail page.
    let description: String
    /// A 2–4 line usage snippet rendered as monospaced text.
    let usage: String
    /// Builds the live demo for the detail page.
    let demoView: @MainActor () -> AnyView
}

// MARK: - Catalog

enum Catalog {
    @MainActor static let all: [ComponentEntry] = [

        // MARK: Forms & Input

        ComponentEntry(
            id: "button",
            name: "Button",
            category: .formsAndInput,
            icon: "hand.tap",
            description: "Six variants and four sizes, styled onto the native SwiftUI Button.",
            usage: """
            Button("Continue") { }.buttonStyle(.sc())
            Button("Delete") { }.buttonStyle(.sc(.destructive))
            Button("Cancel") { }.buttonStyle(.sc(.outline, size: .sm))
            """,
            demoView: { AnyView(ButtonDemo()) }
        ),
        ComponentEntry(
            id: "button-group",
            name: "Button Group",
            category: .formsAndInput,
            icon: "rectangle.split.3x1",
            description: "A row of attached buttons sharing one bordered container.",
            usage: """
            SCButtonGroup(items: [
                .init(label: "Copy") { },
                .init(label: "Paste") { },
                .init(systemImage: "ellipsis") { },
            ])
            """,
            demoView: { AnyView(ButtonGroupDemo()) }
        ),
        ComponentEntry(
            id: "calendar",
            name: "Calendar",
            category: .formsAndInput,
            icon: "calendar",
            description: "A locale-aware month grid with single-date and range selection.",
            usage: """
            SCCalendar(selection: $date)                     // single date
            SCCalendar(range: $stay)                         // date range
            SCCalendar(selection: $date, bounds: today...max)
            """,
            demoView: { AnyView(CalendarDemo()) }
        ),
        ComponentEntry(
            id: "checkbox",
            name: "Checkbox",
            category: .formsAndInput,
            icon: "checkmark.square",
            description: "A square check control for native Toggles — behavior stays native.",
            usage: """
            Toggle("Accept terms and conditions", isOn: $accepted)
                .toggleStyle(.scCheckbox)
            """,
            demoView: { AnyView(CheckboxDemo()) }
        ),
        ComponentEntry(
            id: "combobox",
            name: "Combobox",
            category: .formsAndInput,
            icon: "text.magnifyingglass",
            description: "A searchable select: a field trigger opening a filtered option list.",
            usage: """
            SCCombobox(selection: $framework,
                       options: ["Next.js", "SvelteKit", "Nuxt.js", "Remix", "Astro"])
            """,
            demoView: { AnyView(ComboboxDemo()) }
        ),
        ComponentEntry(
            id: "date-picker",
            name: "Date Picker",
            category: .formsAndInput,
            icon: "calendar.badge.clock",
            description: "An input-look trigger that opens an SCCalendar in a popover.",
            usage: """
            SCDatePicker(selection: $date)
            SCDatePicker("Date of birth", selection: $birthday, in: earliest...Date())
            """,
            demoView: { AnyView(DatePickerDemo()) }
        ),
        ComponentEntry(
            id: "field",
            name: "Field",
            category: .formsAndInput,
            icon: "rectangle.and.pencil.and.ellipsis",
            description: "Stacks a label, any control, and a description or error caption.",
            usage: """
            SCField("Email", required: true, error: "Enter a valid email.") {
                SCInput("you@example.com", text: $email)
            }
            """,
            demoView: { AnyView(FieldDemo()) }
        ),
        ComponentEntry(
            id: "input",
            name: "Input",
            category: .formsAndInput,
            icon: "character.cursor.ibeam",
            description: "A themed single-line text field with icon and trailing accessory slots.",
            usage: """
            SCInput("Email", text: $email, icon: "envelope")
            SCInput("Age", value: $age)      // Int -> number pad
            SCInput("Price", value: $price)  // Double -> decimal pad
            """,
            demoView: { AnyView(InputDemo()) }
        ),
        ComponentEntry(
            id: "input-otp",
            name: "Input OTP",
            category: .formsAndInput,
            icon: "ellipsis.rectangle",
            description: "One-time-code entry with grouped digit boxes and native autofill.",
            usage: """
            SCInputOTP(code: $code)                             // 6 digits, 3 + 3
            SCInputOTP(code: $code, length: 4, groupSize: nil)  // 4, ungrouped
            """,
            demoView: { AnyView(InputOTPDemo()) }
        ),
        ComponentEntry(
            id: "label",
            name: "Label",
            category: .formsAndInput,
            icon: "tag",
            description: "A form label with an optional destructive required asterisk.",
            usage: """
            SCLabel("Email")
            SCLabel("Password", required: true)
            """,
            demoView: { AnyView(LabelDemo()) }
        ),
        ComponentEntry(
            id: "radio-group",
            name: "Radio Group",
            category: .formsAndInput,
            icon: "smallcircle.filled.circle",
            description: "A set of mutually exclusive option rows bound to one selection.",
            usage: """
            SCRadioGroup(selection: $density) {
                SCRadio("Default", value: "default")
                SCRadio("Comfortable", value: "comfortable")
            }
            """,
            demoView: { AnyView(RadioGroupDemo()) }
        ),
        ComponentEntry(
            id: "select",
            name: "Select",
            category: .formsAndInput,
            icon: "chevron.up.chevron.down",
            description: "A dropdown styled like an input, built on the native Menu.",
            usage: """
            SCSelect(selection: $fruit,
                     placeholder: "Select a fruit",
                     options: ["Apple", "Banana", "Blueberry"])
            """,
            demoView: { AnyView(SelectDemo()) }
        ),
        ComponentEntry(
            id: "slider",
            name: "Slider",
            category: .formsAndInput,
            icon: "slider.horizontal.3",
            description: "A themed range input with optional stepping and native accessibility.",
            usage: """
            SCSlider(value: $volume)
            SCSlider(value: $rating, in: 0...100, step: 10)
            """,
            demoView: { AnyView(SliderDemo()) }
        ),
        ComponentEntry(
            id: "switch",
            name: "Switch",
            category: .formsAndInput,
            icon: "switch.2",
            description: "shadcn's capsule switch appearance for native Toggles.",
            usage: """
            Toggle("Airplane Mode", isOn: $airplaneMode)
                .toggleStyle(.scSwitch)
            """,
            demoView: { AnyView(SwitchDemo()) }
        ),
        ComponentEntry(
            id: "textarea",
            name: "Textarea",
            category: .formsAndInput,
            icon: "text.alignleft",
            description: "A themed multi-line text area with a muted placeholder.",
            usage: """
            SCTextarea("Type your message here.", text: $message)
            SCTextarea("Bio", text: $bio, minHeight: 140)
            """,
            demoView: { AnyView(TextareaDemo()) }
        ),
        ComponentEntry(
            id: "toggle",
            name: "Toggle",
            category: .formsAndInput,
            icon: "bold",
            description: "A two-state pressed button — think a toolbar Bold control.",
            usage: """
            Toggle("Bold", systemImage: "bold", isOn: $isBold)
                .toggleStyle(.scToggle())
                .labelStyle(.iconOnly)
            """,
            demoView: { AnyView(ToggleDemo()) }
        ),
        ComponentEntry(
            id: "toggle-group",
            name: "Toggle Group",
            category: .formsAndInput,
            icon: "text.aligncenter",
            description: "Attached toggle cells with single- or multi-select bindings.",
            usage: """
            SCToggleGroup(selection: $alignment, items: [
                .init(value: "left", systemImage: "text.alignleft"),
                .init(value: "center", systemImage: "text.aligncenter"),
            ])
            """,
            demoView: { AnyView(ToggleGroupDemo()) }
        ),

        // MARK: Display

        ComponentEntry(
            id: "accordion",
            name: "Accordion",
            category: .display,
            icon: "chevron.down.circle",
            description: "Vertically stacked headings that each reveal a section of content.",
            usage: """
            SCAccordion {
                SCAccordionItem("Is it accessible?", content: "Yes.")
                SCAccordionItem("Is it styled?", content: "Yes.")
            }
            """,
            demoView: { AnyView(AccordionDemo()) }
        ),
        ComponentEntry(
            id: "avatar",
            name: "Avatar",
            category: .display,
            icon: "person.crop.circle",
            description: "An async image with initials fallback, plus overlapping groups.",
            usage: """
            SCAvatar(url: URL(string: "https://github.com/shadcn.png"),
                     fallback: "CN")
            SCAvatarGroup(avatars: [(nil, "AB"), (nil, "CD")], max: 2)
            """,
            demoView: { AnyView(AvatarDemo()) }
        ),
        ComponentEntry(
            id: "badge",
            name: "Badge",
            category: .display,
            icon: "seal",
            description: "A small status pill in four variants, with a free-form content slot.",
            usage: """
            SCBadge("New")
            SCBadge("Beta", variant: .secondary)
            SCBadge(variant: .outline) { Label("Verified", systemImage: "checkmark.seal") }
            """,
            demoView: { AnyView(BadgeDemo()) }
        ),
        ComponentEntry(
            id: "card",
            name: "Card",
            category: .display,
            icon: "rectangle.inset.filled",
            description: "A themed surface composed from header, content, and footer slots.",
            usage: """
            SCCard {
                SCCardHeader {
                    SCCardTitle("Create project")
                    SCCardDescription("Deploy your new project in one click.")
                }
            }
            """,
            demoView: { AnyView(CardDemo()) }
        ),
        ComponentEntry(
            id: "carousel",
            name: "Carousel",
            category: .display,
            icon: "rectangle.stack",
            description: "A horizontally paging scroller with dot indicators and chevron controls.",
            usage: """
            SCCarousel(items: slides) { slide in
                SCCard { SCCardTitle(slide.title) }
            }
            """,
            demoView: { AnyView(CarouselDemo()) }
        ),
        ComponentEntry(
            id: "chart",
            name: "Chart",
            category: .display,
            icon: "chart.bar",
            description: "Theme series palette, muted axes, and hairline grid for Swift Charts.",
            usage: """
            Chart(data) { point in
                BarMark(x: .value("Month", point.month),
                        y: .value("Total", point.total))
            }
            .scChartStyle()
            """,
            demoView: { AnyView(ChartDemo()) }
        ),
        ComponentEntry(
            id: "chat",
            name: "Chat",
            category: .display,
            icon: "bubble.left.and.bubble.right",
            description: "Message bubbles, attachments, markers, a typing indicator, and a composer.",
            usage: """
            SCMessageScroller {
                SCMessage(role: .sent) { SCMessageBubble("I can't log in.", role: .sent) }
                SCMessage(role: .received, avatar: (nil, "SD")) { SCTypingIndicator() }
            }
            SCChatInputBar(text: $draft) { send() }
            """,
            demoView: { AnyView(ChatDemo()) }
        ),
        ComponentEntry(
            id: "collapsible",
            name: "Collapsible",
            category: .display,
            icon: "rectangle.expand.vertical",
            description: "An interactive panel that expands and collapses, controlled or not.",
            usage: """
            SCCollapsible {
                Text("@peduarte starred 3 repositories")
            } content: {
                Text("@radix-ui/primitives")
            }
            """,
            demoView: { AnyView(CollapsibleDemo()) }
        ),
        ComponentEntry(
            id: "empty",
            name: "Empty",
            category: .display,
            icon: "tray",
            description: "A centered empty state with icon, copy, and action slots.",
            usage: """
            SCEmpty("No results", systemImage: "magnifyingglass",
                    description: "Try adjusting your search.") {
                Button("Clear filters") { }.buttonStyle(.sc(.outline))
            }
            """,
            demoView: { AnyView(EmptyDemo()) }
        ),
        ComponentEntry(
            id: "item",
            name: "Item",
            category: .display,
            icon: "list.bullet.rectangle",
            description: "A generic list row: leading media, title, description, accessory.",
            usage: """
            SCItem("Notifications", description: "Manage alert settings.") {
                Image(systemName: "bell")
            } trailing: {
                Image(systemName: "chevron.right")
            }
            """,
            demoView: { AnyView(ItemDemo()) }
        ),
        ComponentEntry(
            id: "kbd",
            name: "Kbd",
            category: .display,
            icon: "keyboard",
            description: "Keycap chips for displaying keyboard shortcuts.",
            usage: """
            SCKbd("⌘")
            SCKbdGroup(["⌘", "⇧", "P"])
            """,
            demoView: { AnyView(KbdDemo()) }
        ),
        ComponentEntry(
            id: "resizable",
            name: "Resizable",
            category: .display,
            icon: "rectangle.split.2x1",
            description: "A two-pane split view with a draggable divider — nestable for layouts.",
            usage: """
            SCResizableSplit(fraction: 0.3, range: 0.2...0.6) {
                SidebarPane()
            } second: {
                DetailPane()
            }
            """,
            demoView: { AnyView(ResizableDemo()) }
        ),
        ComponentEntry(
            id: "separator",
            name: "Separator",
            category: .display,
            icon: "minus",
            description: "A 1pt rule — horizontal, vertical, or labeled.",
            usage: """
            SCSeparator()
            SCSeparator(.vertical)
            SCSeparator(label: "or continue with")
            """,
            demoView: { AnyView(SeparatorDemo()) }
        ),
        ComponentEntry(
            id: "table",
            name: "Table",
            category: .display,
            icon: "tablecells",
            description: "A themed data grid with sortable columns, row selection, and a caption.",
            usage: """
            SCTable(rows: invoices, columns: [
                SCTableColumn("Invoice") { $0.id },
                SCTableColumn("Status") { $0.status },
            ], caption: "A list of your recent invoices.")
            """,
            demoView: { AnyView(TableDemo()) }
        ),
        ComponentEntry(
            id: "typography",
            name: "Typography",
            category: .display,
            icon: "textformat",
            description: "shadcn's type scale as chainable view modifiers.",
            usage: """
            Text("Taxing Laughter").scH1()
            Text("Enter your email address.").scMuted()
            Text("swift build").scInlineCode()
            """,
            demoView: { AnyView(TypographyDemo()) }
        ),

        // MARK: Feedback

        ComponentEntry(
            id: "alert",
            name: "Alert",
            category: .feedback,
            icon: "exclamationmark.triangle",
            description: "An inline callout banner — default or destructive, with slots.",
            usage: """
            SCAlert(icon: "terminal", title: "Heads up!",
                    description: "You can add components using the CLI.")
            """,
            demoView: { AnyView(AlertDemo()) }
        ),
        ComponentEntry(
            id: "progress",
            name: "Progress",
            category: .feedback,
            icon: "timelapse",
            description: "A linear progress bar for native ProgressViews, with an indeterminate sweep.",
            usage: """
            ProgressView(value: 0.6).progressViewStyle(.scLinear)
            ProgressView("Uploading…", value: 0.3).progressViewStyle(.scLinear)
            ProgressView().progressViewStyle(.scLinear)  // indeterminate
            """,
            demoView: { AnyView(ProgressDemo()) }
        ),
        ComponentEntry(
            id: "skeleton",
            name: "Skeleton",
            category: .feedback,
            icon: "rectangle.dashed",
            description: "Loading placeholders with a shimmer sweep, block or redaction based.",
            usage: """
            SCSkeleton(width: 200, height: 14)
            articleView.scSkeleton(when: isLoading)
            """,
            demoView: { AnyView(SkeletonDemo()) }
        ),
        ComponentEntry(
            id: "spinner",
            name: "Spinner",
            category: .feedback,
            icon: "rays",
            description: "An indeterminate rotating arc that fades into the primary color.",
            usage: """
            SCSpinner()
            SCSpinner(size: 32, lineWidth: 3)
            """,
            demoView: { AnyView(SpinnerDemo()) }
        ),
        ComponentEntry(
            id: "toast",
            name: "Toast",
            category: .feedback,
            icon: "bell",
            description: "Sonner-style stacked notifications dispatched from a global center.",
            usage: """
            SCToastCenter.shared.show(title: "Changes saved", variant: .success)
            // Host the stack once, near the root:
            ContentView().scToaster()
            """,
            demoView: { AnyView(ToastDemo()) }
        ),

        // MARK: Navigation

        ComponentEntry(
            id: "breadcrumb",
            name: "Breadcrumb",
            category: .navigation,
            icon: "chevron.right",
            description: "The path to the current resource, with optional middle truncation.",
            usage: """
            SCBreadcrumb(items: [
                SCBreadcrumbItem("Home") { },
                SCBreadcrumbItem("Components") { },
                SCBreadcrumbItem("Breadcrumb"),
            ])
            """,
            demoView: { AnyView(BreadcrumbDemo()) }
        ),
        ComponentEntry(
            id: "command",
            name: "Command",
            category: .navigation,
            icon: "command",
            description: "A filterable, keyboard-navigable command list — inline or as a ⌘K palette.",
            usage: """
            .scCommandPalette(isPresented: $showPalette, groups: [
                SCCommandGroup(label: "Settings", items: [
                    SCCommandItem(title: "Profile", systemImage: "person", shortcut: "⌘P") { openProfile() },
                ]),
            ])
            """,
            demoView: { AnyView(CommandDemo()) }
        ),
        ComponentEntry(
            id: "pagination",
            name: "Pagination",
            category: .navigation,
            icon: "123.rectangle",
            description: "Previous/next links around a windowed row of page numbers.",
            usage: """
            SCPagination(current: $page, total: 10)
            SCPagination(current: $page, total: 42, maxVisible: 9)
            """,
            demoView: { AnyView(PaginationDemo()) }
        ),
        ComponentEntry(
            id: "tabs",
            name: "Tabs",
            category: .navigation,
            icon: "square.split.2x1",
            description: "Segmented or underline tab strips with a sliding indicator — no AnyView.",
            usage: """
            SCTabs(selection: $tab, tabs: [
                SCTabItem(value: Section.account, label: "Account"),
                SCTabItem(value: Section.password, label: "Password"),
            ]) { tab in panel(for: tab) }
            """,
            demoView: { AnyView(TabsDemo()) }
        ),
        ComponentEntry(
            id: "sidebar",
            name: "Sidebar",
            category: .navigation,
            icon: "sidebar.leading",
            description: "The flagship: a composable, collapsible app sidebar. This app's shell is one.",
            usage: """
            SCSidebarLayout(collapsible: .icon, persistenceKey: nil) {
                SCSidebarHeader { identity }
                SCSidebarContent { groups }
            } detail: { mainView }
            """,
            demoView: { AnyView(SidebarComponentDemo()) }
        ),

        // MARK: Overlays

        ComponentEntry(
            id: "dialog",
            name: "Dialog",
            category: .overlays,
            icon: "rectangle.center.inset.filled",
            description: "A centered modal dialog rendered as a pure SwiftUI overlay.",
            usage: """
            .scDialog(isPresented: $showDialog) {
                SCDialogContent {
                    SCDialogTitle("Edit profile")
                }
            }
            """,
            demoView: { AnyView(DialogDemo()) }
        ),
        ComponentEntry(
            id: "alert-dialog",
            name: "Alert Dialog",
            category: .overlays,
            icon: "exclamationmark.bubble",
            description: "A modal confirmation that interrupts — the user must choose.",
            usage: """
            .scAlertDialog(isPresented: $showDelete,
                           title: "Delete account?",
                           message: "This action cannot be undone.",
                           confirmLabel: "Delete", role: .destructive) { delete() }
            """,
            demoView: { AnyView(AlertDialogDemo()) }
        ),
        ComponentEntry(
            id: "sheet",
            name: "Sheet",
            category: .overlays,
            icon: "sidebar.trailing",
            description: "A panel that slides in from any container edge — a slide-over.",
            usage: """
            .scSheet(isPresented: $showSettings, edge: .trailing) {
                SCSheetContent {
                    SCSheetHeader { SCSheetTitle("Settings") }
                }
            }
            """,
            demoView: { AnyView(SheetDemo()) }
        ),
        ComponentEntry(
            id: "drawer",
            name: "Drawer",
            category: .overlays,
            icon: "rectangle.bottomthird.inset.filled",
            description: "A vaul-style bottom drawer with drag-to-dismiss.",
            usage: """
            .scDrawer(isPresented: $showDrawer) {
                SCDrawerContent {
                    SCDrawerHeader { SCDrawerTitle("Are you sure?") }
                }
            }
            """,
            demoView: { AnyView(DrawerDemo()) }
        ),
        ComponentEntry(
            id: "popover",
            name: "Popover",
            category: .overlays,
            icon: "bubble.middle.top",
            description: "A themed anchored popover on the native primitive — stays a popover on iPhone.",
            usage: """
            Button("Open popover") { isPresented = true }
                .scPopover(isPresented: $isPresented) {
                    Text("Place content for the popover here.")
                }
            """,
            demoView: { AnyView(PopoverDemo()) }
        ),
        ComponentEntry(
            id: "tooltip",
            name: "Tooltip",
            category: .overlays,
            icon: "bubble.middle.bottom",
            description: "A small text bubble beside any view — hover on pointer, long-press on touch.",
            usage: """
            Button("Add to library") {}
                .buttonStyle(.sc(.outline))
                .scTooltip("Add to library")
            """,
            demoView: { AnyView(TooltipDemo()) }
        ),
        ComponentEntry(
            id: "hover-card",
            name: "Hover Card",
            category: .overlays,
            icon: "rectangle.on.rectangle",
            description: "A rich preview card in a native popover — hover to open, long-press on touch.",
            usage: """
            Text("@swiftcn")
                .scHoverCard {
                    Text("shadcn/ui for SwiftUI — themed by design tokens.")
                }
            """,
            demoView: { AnyView(HoverCardDemo()) }
        ),

        // MARK: Blocks

        ComponentEntry(
            id: "login-block",
            name: "Login",
            category: .blocks,
            icon: "person.badge.key",
            description: "A complete login screen — the port of shadcn/ui's login-01 block.",
            usage: """
            SCLoginBlock(
                onSubmit: { email, password in signIn(email, password) },
                onApple: { signInWithApple() }
            )
            """,
            demoView: { AnyView(LoginBlockDemo()) }
        ),
        ComponentEntry(
            id: "settings-block",
            name: "Settings",
            category: .blocks,
            icon: "gearshape",
            description: "A grouped settings screen: profile, preferences, and a danger zone.",
            usage: """
            SCSettingsBlock()
            """,
            demoView: { AnyView(SettingsBlockDemo()) }
        ),
        ComponentEntry(
            id: "sidebar-block",
            name: "Sidebar App",
            category: .blocks,
            icon: "sidebar.left",
            description: "shadcn's sidebar-07 block: an icon-rail sidebar shell around your detail content.",
            usage: """
            SCSidebarBlock()                // stock placeholder detail
            SCSidebarBlock { MyContent() }  // your detail content
            """,
            demoView: { AnyView(SidebarBlockDemo()) }
        ),
        ComponentEntry(
            id: "dashboard-block",
            name: "Dashboard",
            category: .blocks,
            icon: "rectangle.3.group",
            description: "shadcn's dashboard-01 block: stat cards, revenue chart, and recent sales behind a sidebar.",
            usage: """
            SCDashboardBlock()
            """,
            demoView: { AnyView(DashboardBlockDemo()) }
        ),
        ComponentEntry(
            id: "chat-block",
            name: "Chat App",
            category: .blocks,
            icon: "message",
            description: "shadcn's chat-01 block: contact header, conversation, and a live composer.",
            usage: """
            SCChatBlock()
            """,
            demoView: { AnyView(ChatBlockDemo()) }
        ),

        // MARK: Effects

        ComponentEntry(
            id: "aurora",
            name: "Aurora",
            category: .effects,
            icon: "sun.haze",
            description: "A soft, slowly drifting color wash of blurred theme-tinted blobs.",
            usage: """
            ZStack {
                SCAuroraBackground()
                heroContent
            }
            """,
            demoView: { AnyView(AuroraDemo()) }
        ),
        ComponentEntry(
            id: "dot-pattern",
            name: "Dot Pattern",
            category: .effects,
            icon: "circle.grid.3x3",
            description: "A Canvas-drawn dotted background with an optional radial fade.",
            usage: """
            ZStack {
                SCDotPattern(fade: true)
                heroContent
            }
            """,
            demoView: { AnyView(DotPatternDemo()) }
        ),
        ComponentEntry(
            id: "marquee",
            name: "Marquee",
            category: .effects,
            icon: "arrow.left.arrow.right",
            description: "Scrolls content in an endless horizontal loop, fading at the edges.",
            usage: """
            SCMarquee {
                HStack(spacing: 32) {
                    ForEach(stack, id: \\.self) { SCBadge($0, variant: .secondary) }
                }
            }
            """,
            demoView: { AnyView(MarqueeDemo()) }
        ),
        ComponentEntry(
            id: "number-ticker",
            name: "Number Ticker",
            category: .effects,
            icon: "number",
            description: "Rolls each digit into place when a numeric value changes.",
            usage: """
            SCNumberTicker(value: downloads)
                .scH2()
            SCNumberTicker(value: revenue, format: .number.precision(.fractionLength(2)))
            """,
            demoView: { AnyView(NumberTickerDemo()) }
        ),
        ComponentEntry(
            id: "shimmer",
            name: "Shimmer",
            category: .effects,
            icon: "sparkles",
            description: "Sweeps a soft highlight across any view, masked to its shape.",
            usage: """
            Text("Introducing swiftcn 2.0").scShimmer()
            Button("Upgrade") { }.buttonStyle(.sc()).scShimmer(duration: 3)
            """,
            demoView: { AnyView(ShimmerDemo()) }
        ),
        ComponentEntry(
            id: "shimmer-button",
            name: "Shimmer Button",
            category: .effects,
            icon: "button.programmable",
            description: "A call-to-action whose border a highlight endlessly laps.",
            usage: """
            SCShimmerButton(text: "Get Started") { start() }
            """,
            demoView: { AnyView(ShimmerButtonDemo()) }
        ),
    ]

    /// Entries for one sidebar group, in catalog order.
    @MainActor static func entries(in category: Category) -> [ComponentEntry] {
        all.filter { $0.category == category }
    }
}
