import { CreditCard, LogOut, Settings, User } from "lucide-react"
import {
  DropdownMenu,
  DropdownMenuCheckboxItem,
  DropdownMenuContent,
  DropdownMenuGroup,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuRadioGroup,
  DropdownMenuRadioItem,
  DropdownMenuSeparator,
  DropdownMenuShortcut,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
import { Button } from "@/components/ui/button"
import { StateRow, StatesContainer } from "@/lib/showcase"

/**
 * The menu portals its content to <body> anchored to the trigger, so this page
 * renders it OPEN by default (`defaultOpen`).
 */
export default function DropdownMenuShowcase() {
  return (
    <StatesContainer>
      <StateRow label="open / expanded">
        <DropdownMenu defaultOpen>
          <DropdownMenuTrigger render={<Button variant="outline" />}>
            Open menu
          </DropdownMenuTrigger>
          <DropdownMenuContent className="w-56" align="start">
            <DropdownMenuLabel>My Account</DropdownMenuLabel>
            <DropdownMenuSeparator />
            <DropdownMenuGroup>
              <DropdownMenuItem>
                <User />
                Profile
                <DropdownMenuShortcut>⇧⌘P</DropdownMenuShortcut>
              </DropdownMenuItem>
              <DropdownMenuItem>
                <CreditCard />
                Billing
                <DropdownMenuShortcut>⌘B</DropdownMenuShortcut>
              </DropdownMenuItem>
              <DropdownMenuItem>
                <Settings />
                Settings
                <DropdownMenuShortcut>⌘S</DropdownMenuShortcut>
              </DropdownMenuItem>
            </DropdownMenuGroup>
            <DropdownMenuSeparator />
            <DropdownMenuCheckboxItem checked>
              Status Bar
            </DropdownMenuCheckboxItem>
            <DropdownMenuSeparator />
            <DropdownMenuRadioGroup value="pedro">
              <DropdownMenuRadioItem value="pedro">
                Pedro Duarte
              </DropdownMenuRadioItem>
              <DropdownMenuRadioItem value="colm">
                Colm Tuite
              </DropdownMenuRadioItem>
            </DropdownMenuRadioGroup>
            <DropdownMenuSeparator />
            <DropdownMenuItem>
              <LogOut />
              Log out
              <DropdownMenuShortcut>⇧⌘Q</DropdownMenuShortcut>
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </StateRow>
    </StatesContainer>
  )
}
