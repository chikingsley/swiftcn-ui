import {
  Calendar,
  Home,
  Inbox,
  Search,
  Settings,
} from "lucide-react"
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarGroup,
  SidebarGroupContent,
  SidebarGroupLabel,
  SidebarHeader,
  SidebarInset,
  SidebarMenu,
  SidebarMenuButton,
  SidebarMenuItem,
  SidebarProvider,
} from "@/components/ui/sidebar"
import { StateRow, StatesContainer } from "@/lib/showcase"

const items = [
  { title: "Home", icon: Home, active: true },
  { title: "Inbox", icon: Inbox, active: false },
  { title: "Calendar", icon: Calendar, active: false },
  { title: "Search", icon: Search, active: false },
  { title: "Settings", icon: Settings, active: false },
]

/**
 * The full shadcn Sidebar uses `position: fixed` (an app shell). To render it
 * inline as one deterministic screenshot we use `collapsible="none"`, which the
 * component renders as a plain flex child (no fixed positioning, no toggle).
 */
export default function SidebarShowcase() {
  return (
    <StatesContainer>
      <StateRow label="expanded app shell (collapsible=none)">
        <div className="h-[420px] w-full overflow-hidden rounded-lg border">
          <SidebarProvider className="min-h-0 h-full">
            <Sidebar collapsible="none" className="border-r">
              <SidebarHeader className="px-3 py-3 text-sm font-semibold">
                Acme Inc
              </SidebarHeader>
              <SidebarContent>
                <SidebarGroup>
                  <SidebarGroupLabel>Application</SidebarGroupLabel>
                  <SidebarGroupContent>
                    <SidebarMenu>
                      {items.map((item) => (
                        <SidebarMenuItem key={item.title}>
                          <SidebarMenuButton isActive={item.active}>
                            <item.icon />
                            <span>{item.title}</span>
                          </SidebarMenuButton>
                        </SidebarMenuItem>
                      ))}
                    </SidebarMenu>
                  </SidebarGroupContent>
                </SidebarGroup>
              </SidebarContent>
              <SidebarFooter className="px-3 py-3 text-xs text-muted-foreground">
                v1.0.0
              </SidebarFooter>
            </Sidebar>
            <SidebarInset className="min-h-0 p-4">
              <h2 className="text-sm font-medium">Dashboard</h2>
              <p className="mt-2 text-sm text-muted-foreground">
                Main content area next to the sidebar.
              </p>
            </SidebarInset>
          </SidebarProvider>
        </div>
      </StateRow>
    </StatesContainer>
  )
}
