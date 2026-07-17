import { Check, ChevronsUpDown } from "lucide-react"
import { Button } from "@/components/ui/button"
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
} from "@/components/ui/command"
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover"
import { cn } from "@/lib/utils"
import { StateRow, StatesContainer } from "@/lib/showcase"

// The shadcn "combobox" is the command + popover composition pattern.
const frameworks = [
  { value: "next", label: "Next.js" },
  { value: "sveltekit", label: "SvelteKit" },
  { value: "nuxt", label: "Nuxt.js" },
  { value: "remix", label: "Remix" },
  { value: "astro", label: "Astro" },
]

const selected = "sveltekit"

export default function ComboboxShowcase() {
  return (
    <StatesContainer>
      <StateRow label="open / expanded (command inside popover)">
        <Popover defaultOpen>
          <PopoverTrigger asChild>
            <Button
              variant="outline"
              role="combobox"
              className="w-[240px] justify-between"
            >
              {frameworks.find((f) => f.value === selected)?.label}
              <ChevronsUpDown className="opacity-50" />
            </Button>
          </PopoverTrigger>
          <PopoverContent
            className="w-[240px] p-0"
            onOpenAutoFocus={(e) => e.preventDefault()}
          >
            <Command>
              <CommandInput placeholder="Search framework..." />
              <CommandList>
                <CommandEmpty>No framework found.</CommandEmpty>
                <CommandGroup>
                  {frameworks.map((f) => (
                    <CommandItem key={f.value} value={f.value}>
                      <Check
                        className={cn(
                          "mr-2 size-4",
                          selected === f.value ? "opacity-100" : "opacity-0"
                        )}
                      />
                      {f.label}
                    </CommandItem>
                  ))}
                </CommandGroup>
              </CommandList>
            </Command>
          </PopoverContent>
        </Popover>
      </StateRow>
      <StateRow label="rest (closed trigger)">
        <Button variant="outline" role="combobox" className="w-[240px] justify-between">
          Select framework...
          <ChevronsUpDown className="opacity-50" />
        </Button>
      </StateRow>
    </StatesContainer>
  )
}
