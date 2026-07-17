import type { ComponentType } from "react"

import AccordionShowcase from "./accordion"
import AlertShowcase from "./alert"
import AlertDialogShowcase from "./alert-dialog"
import AspectRatioShowcase from "./aspect-ratio"
import AvatarShowcase from "./avatar"
import BadgeShowcase from "./badge"
import BreadcrumbShowcase from "./breadcrumb"
import ButtonShowcase from "./button"
import ButtonGroupShowcase from "./button-group"
import CalendarShowcase from "./calendar"
import CardShowcase from "./card"
import ChartShowcase from "./chart"
import CheckboxShowcase from "./checkbox"
import CollapsibleShowcase from "./collapsible"
import ComboboxShowcase from "./combobox"
import CommandShowcase from "./command"
import ContextMenuShowcase from "./context-menu"
import DialogShowcase from "./dialog"
import DrawerShowcase from "./drawer"
import DropdownMenuShowcase from "./dropdown-menu"
import EmptyShowcase from "./empty"
import FieldShowcase from "./field"
import HoverCardShowcase from "./hover-card"
import InputShowcase from "./input"
import InputGroupShowcase from "./input-group"
import InputOtpShowcase from "./input-otp"
import ItemShowcase from "./item"
import KbdShowcase from "./kbd"
import LabelShowcase from "./label"
import MenubarShowcase from "./menubar"
import NavigationMenuShowcase from "./navigation-menu"
import PaginationShowcase from "./pagination"
import PopoverShowcase from "./popover"
import ProgressShowcase from "./progress"
import RadioGroupShowcase from "./radio-group"
import ResizableShowcase from "./resizable"
import ScrollAreaShowcase from "./scroll-area"
import SelectShowcase from "./select"
import SeparatorShowcase from "./separator"
import SheetShowcase from "./sheet"
import SidebarShowcase from "./sidebar"
import SkeletonShowcase from "./skeleton"
import SliderShowcase from "./slider"
import SonnerShowcase from "./sonner"
import SwitchShowcase from "./switch"
import TableShowcase from "./table"
import TabsShowcase from "./tabs"
import TextareaShowcase from "./textarea"
import ToggleShowcase from "./toggle"
import ToggleGroupShowcase from "./toggle-group"
import TooltipShowcase from "./tooltip"

export type Showcase = {
  id: string
  title: string
  Component: ComponentType
}

/**
 * Single source of truth. The index page, the `/c/:id` routes, and the
 * Playwright capture script (which scrapes the index for `[data-cid]`) all
 * derive from this one array, so they cannot drift.
 */
export const showcases: Showcase[] = [
  { id: "button", title: "Button", Component: ButtonShowcase },
  { id: "badge", title: "Badge", Component: BadgeShowcase },
  { id: "input", title: "Input", Component: InputShowcase },
  { id: "textarea", title: "Textarea", Component: TextareaShowcase },
  { id: "label", title: "Label", Component: LabelShowcase },
  { id: "checkbox", title: "Checkbox", Component: CheckboxShowcase },
  { id: "switch", title: "Switch", Component: SwitchShowcase },
  { id: "radio-group", title: "Radio Group", Component: RadioGroupShowcase },
  { id: "select", title: "Select", Component: SelectShowcase },
  { id: "combobox", title: "Combobox", Component: ComboboxShowcase },
  { id: "command", title: "Command", Component: CommandShowcase },
  { id: "popover", title: "Popover", Component: PopoverShowcase },
  { id: "dropdown-menu", title: "Dropdown Menu", Component: DropdownMenuShowcase },
  { id: "context-menu", title: "Context Menu", Component: ContextMenuShowcase },
  { id: "menubar", title: "Menubar", Component: MenubarShowcase },
  { id: "navigation-menu", title: "Navigation Menu", Component: NavigationMenuShowcase },
  { id: "dialog", title: "Dialog", Component: DialogShowcase },
  { id: "alert-dialog", title: "Alert Dialog", Component: AlertDialogShowcase },
  { id: "sheet", title: "Sheet", Component: SheetShowcase },
  { id: "drawer", title: "Drawer", Component: DrawerShowcase },
  { id: "hover-card", title: "Hover Card", Component: HoverCardShowcase },
  { id: "tooltip", title: "Tooltip", Component: TooltipShowcase },
  { id: "accordion", title: "Accordion", Component: AccordionShowcase },
  { id: "collapsible", title: "Collapsible", Component: CollapsibleShowcase },
  { id: "tabs", title: "Tabs", Component: TabsShowcase },
  { id: "card", title: "Card", Component: CardShowcase },
  { id: "avatar", title: "Avatar", Component: AvatarShowcase },
  { id: "alert", title: "Alert", Component: AlertShowcase },
  { id: "separator", title: "Separator", Component: SeparatorShowcase },
  { id: "skeleton", title: "Skeleton", Component: SkeletonShowcase },
  { id: "progress", title: "Progress", Component: ProgressShowcase },
  { id: "slider", title: "Slider", Component: SliderShowcase },
  { id: "breadcrumb", title: "Breadcrumb", Component: BreadcrumbShowcase },
  { id: "pagination", title: "Pagination", Component: PaginationShowcase },
  { id: "calendar", title: "Calendar", Component: CalendarShowcase },
  { id: "table", title: "Table", Component: TableShowcase },
  { id: "scroll-area", title: "Scroll Area", Component: ScrollAreaShowcase },
  { id: "resizable", title: "Resizable", Component: ResizableShowcase },
  { id: "sidebar", title: "Sidebar", Component: SidebarShowcase },
  { id: "sonner", title: "Sonner (Toast)", Component: SonnerShowcase },
  { id: "toggle", title: "Toggle", Component: ToggleShowcase },
  { id: "toggle-group", title: "Toggle Group", Component: ToggleGroupShowcase },
  { id: "input-otp", title: "Input OTP", Component: InputOtpShowcase },
  { id: "aspect-ratio", title: "Aspect Ratio", Component: AspectRatioShowcase },
  { id: "kbd", title: "Kbd", Component: KbdShowcase },
  { id: "field", title: "Field", Component: FieldShowcase },
  { id: "button-group", title: "Button Group", Component: ButtonGroupShowcase },
  { id: "input-group", title: "Input Group", Component: InputGroupShowcase },
  { id: "item", title: "Item", Component: ItemShowcase },
  { id: "empty", title: "Empty", Component: EmptyShowcase },
  { id: "chart", title: "Chart", Component: ChartShowcase },
]

export const showcaseById: Map<string, Showcase> = new Map(
  showcases.map((s) => [s.id, s])
)
