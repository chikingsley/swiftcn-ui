import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectLabel,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { StateRow, StatesContainer } from "@/lib/showcase"

/**
 * The Select portals its listbox to <body>, so this page renders it OPEN by
 * default (`defaultOpen`) — the open listbox is the state under test.
 */
export default function SelectShowcase() {
  return (
    <StatesContainer>
      <StateRow label="open / expanded">
        <Select defaultOpen defaultValue="apple">
          <SelectTrigger className="w-56">
            <SelectValue placeholder="Select a fruit" />
          </SelectTrigger>
          <SelectContent>
            <SelectGroup>
              <SelectLabel>Fruits</SelectLabel>
              <SelectItem value="apple">Apple</SelectItem>
              <SelectItem value="banana">Banana</SelectItem>
              <SelectItem value="blueberry">Blueberry</SelectItem>
              <SelectItem value="grapes">Grapes</SelectItem>
            </SelectGroup>
          </SelectContent>
        </Select>
      </StateRow>
      <StateRow label="closed / disabled trigger">
        <Select disabled>
          <SelectTrigger className="w-56">
            <SelectValue placeholder="Select a fruit" />
          </SelectTrigger>
        </Select>
      </StateRow>
    </StatesContainer>
  )
}
