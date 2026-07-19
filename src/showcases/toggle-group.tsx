import { Bold, Italic, Underline } from "lucide-react"
import { ToggleGroup, ToggleGroupItem } from "@/components/ui/toggle-group"
import { StateRow, StatesContainer } from "@/lib/showcase"

export default function ToggleGroupShowcase() {
  return (
    <StatesContainer>
      <StateRow label="Single select (one selected)">
        <ToggleGroup defaultValue={["bold"]}>
          <ToggleGroupItem value="bold" aria-label="Toggle bold">
            <Bold />
          </ToggleGroupItem>
          <ToggleGroupItem value="italic" aria-label="Toggle italic">
            <Italic />
          </ToggleGroupItem>
          <ToggleGroupItem value="underline" aria-label="Toggle underline">
            <Underline />
          </ToggleGroupItem>
        </ToggleGroup>
      </StateRow>
      <StateRow label="Multiple select">
        <ToggleGroup multiple defaultValue={["bold"]}>
          <ToggleGroupItem value="bold" aria-label="Toggle bold">
            <Bold />
          </ToggleGroupItem>
          <ToggleGroupItem value="italic" aria-label="Toggle italic">
            <Italic />
          </ToggleGroupItem>
          <ToggleGroupItem value="underline" aria-label="Toggle underline">
            <Underline />
          </ToggleGroupItem>
        </ToggleGroup>
      </StateRow>
      <StateRow label="Disabled">
        <ToggleGroup defaultValue={["bold"]} disabled>
          <ToggleGroupItem value="bold" aria-label="Toggle bold">
            <Bold />
          </ToggleGroupItem>
          <ToggleGroupItem value="italic" aria-label="Toggle italic">
            <Italic />
          </ToggleGroupItem>
          <ToggleGroupItem value="underline" aria-label="Toggle underline">
            <Underline />
          </ToggleGroupItem>
        </ToggleGroup>
      </StateRow>
    </StatesContainer>
  )
}
