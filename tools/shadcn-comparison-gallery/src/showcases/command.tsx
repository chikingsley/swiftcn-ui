import { Calendar, CreditCard, Plus, Search, Settings, User } from "lucide-react"
import {
  Command,
  CommandInput,
  CommandList,
  CommandGroup,
  CommandItem,
  CommandShortcut,
  CommandSeparator,
} from "@/components/ui/command"
import { StateRow, StatesContainer } from "@/lib/showcase"

export default function CommandShowcase() {
  return (
    <StatesContainer>
      <StateRow label="Palette (open, inline)">
        <Command className="rounded-lg border shadow-md max-w-md">
          <CommandInput placeholder="Type a command or search..." />
          <CommandList>
            <CommandGroup heading="Suggestions">
              <CommandItem>
                <Calendar />
                Calendar
              </CommandItem>
              <CommandItem>
                <Search />
                Search Emoji
              </CommandItem>
              <CommandItem>
                <Plus />
                New File
                <CommandShortcut>⌘N</CommandShortcut>
              </CommandItem>
            </CommandGroup>
            <CommandSeparator />
            <CommandGroup heading="Settings">
              <CommandItem>
                <User />
                Profile
                <CommandShortcut>⌘P</CommandShortcut>
              </CommandItem>
              <CommandItem>
                <CreditCard />
                Billing
                <CommandShortcut>⌘B</CommandShortcut>
              </CommandItem>
              <CommandItem>
                <Settings />
                Settings
                <CommandShortcut>⌘S</CommandShortcut>
              </CommandItem>
            </CommandGroup>
          </CommandList>
        </Command>
      </StateRow>
    </StatesContainer>
  )
}
