import AppKit
import SwiftUI
import Swiftcn

@main
struct ValidationHostApp: App {
    var body: some Scene {
        WindowGroup("Swiftcn Validation") {
            ValidationRootView()
        }
        .windowResizability(.contentSize)
    }
}

/// Routes `--sc-scene <key>` to one deterministic component scene and applies
/// `--sc-appearance light|dark` so UI tests control both axes per launch.
/// `--sc-width`/`--sc-height` enlarge the fixed content frame for scenes whose
/// stacked instances exceed the 780×560 default (macOS XCUITest cannot click
/// content outside the window, so every element must fit the frame).
struct ValidationRootView: View {
    private let scene: String
    private let appearance: ColorScheme?
    private let width: CGFloat
    private let height: CGFloat

    init() {
        let arguments = ProcessInfo.processInfo.arguments
        scene = Self.value(named: "--sc-scene", in: arguments) ?? "button"
        switch Self.value(named: "--sc-appearance", in: arguments) {
        case "dark": appearance = .dark
        case "light": appearance = .light
        default: appearance = nil
        }
        width = Self.value(named: "--sc-width", in: arguments).flatMap { Double($0) } ?? 780
        height = Self.value(named: "--sc-height", in: arguments).flatMap { Double($0) } ?? 560
    }

    var body: some View {
        Group {
            switch scene {
            case "button": ButtonValidationScene()
            case "badge": BadgeValidationScene()
            case "switch": SwitchValidationScene()
            case "checkbox": CheckboxValidationScene()
            case "separator": SeparatorValidationScene()
            case "skeleton": SkeletonValidationScene()
            case "alert": AlertValidationScene()
            case "avatar": AvatarValidationScene()
            case "input": InputValidationScene()
            case "textarea": TextareaValidationScene()
            case "label": LabelValidationScene()
            case "radiogroup": RadioGroupValidationScene()
            case "slider": SliderValidationScene()
            case "progress": ProgressValidationScene()
            case "inputotp": InputOTPValidationScene()
            case "card": CardValidationScene()
            case "aspectratio": AspectRatioValidationScene()
            case "kbd": KbdValidationScene()
            case "typography": TypographyValidationScene()
            case "empty": EmptyValidationScene()
            case "item": ItemValidationScene()
            case "spinner": SpinnerValidationScene()
            case "collapsible": CollapsibleValidationScene()
            case "accordion": AccordionValidationScene()
            case "tabs": TabsValidationScene()
            case "toggle": ToggleValidationScene()
            case "togglegroup": ToggleGroupValidationScene()
            case "breadcrumb": BreadcrumbValidationScene()
            case "pagination": PaginationValidationScene()
            case "dialog": DialogValidationScene()
            case "sheet": SheetValidationScene()
            case "drawer": DrawerValidationScene()
            case "popover": PopoverValidationScene()
            case "tooltip": TooltipValidationScene()
            case "hovercard": HoverCardValidationScene()
            case "alertdialog": AlertDialogValidationScene()
            case "attachment": AttachmentValidationScene()
            case "bubble": BubbleValidationScene()
            case "buttongroup": ButtonGroupValidationScene()
            case "calendar": CalendarValidationScene(part: .selection)
            case "calendarrange": CalendarValidationScene(part: .range)
            case "calendarextras": CalendarValidationScene(part: .extras)
            case "calendarmisc": CalendarValidationScene(part: .misc)
            case "carousel": CarouselValidationScene()
            case "chart": ChartValidationScene()
            case "combobox": ComboboxValidationScene()
            case "command": CommandValidationScene()
            case "contextmenu": ContextMenuValidationScene()
            case "datatable": DataTableValidationScene()
            case "datepicker": DatePickerValidationScene()
            case "direction": DirectionValidationScene()
            case "dropdownmenu": DropdownMenuValidationScene()
            case "field": FieldValidationScene()
            case "inputgroup": InputGroupValidationScene()
            case "marker": MarkerValidationScene()
            case "menubar": MenubarValidationScene()
            case "message": MessageValidationScene()
            case "messagescroller": MessageScrollerValidationScene()
            case "nativeselect": NativeSelectValidationScene()
            case "navigationmenu": NavigationMenuValidationScene()
            case "resizable": ResizableValidationScene()
            case "scrollarea": ScrollAreaValidationScene()
            case "select": SelectValidationScene()
            case "sidebar": SidebarValidationScene(part: .main)
            case "sidebarpersisted": SidebarValidationScene(part: .persisted)
            case "sonner": SonnerValidationScene()
            case "table": TableValidationScene(part: .typed)
            case "tablerowtap": TableValidationScene(part: .rowTap)
            case "tableprimitive": TableValidationScene(part: .primitive)
            case "toast": ToastValidationScene()
            default:
                Text("Unknown scene: \(scene)")
                    .accessibilityIdentifier("sc-unknown-scene")
            }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Swiftcn validation scene: \(scene)")
        .frame(width: width, height: height, alignment: .topLeading)
        .background(Theme.default.background)
        .theme(.default)
        .preferredColorScheme(appearance)
        .navigationTitle("Swiftcn validation — \(scene)")
        .onAppear {
            // SwiftUI's NSHostingView has no accessibility description, which
            // Apple's own accessibility audit flags on every run. Label it
            // directly so audits report only real content issues.
            for window in NSApplication.shared.windows {
                window.contentView?.setAccessibilityLabel("Swiftcn validation host")
            }
        }
    }

    private static func value(named name: String, in arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: name),
            arguments.indices.contains(index + 1)
        else { return nil }
        return arguments[index + 1]
    }
}
