import { Bold } from "lucide-react"
import { Toggle } from "@/components/ui/toggle"
import { StateRow, StatesContainer } from "@/lib/showcase"

export default function ToggleShowcase() {
  return (
    <StatesContainer>
      <StateRow label="Rest (off)">
        <Toggle aria-label="Toggle italic">Italic</Toggle>
      </StateRow>
      <StateRow label="Pressed (on)">
        <Toggle defaultPressed aria-label="Toggle italic">
          Italic
        </Toggle>
      </StateRow>
      <StateRow label="Outline variant">
        <Toggle variant="outline" aria-label="Toggle italic">
          Outline
        </Toggle>
        <Toggle variant="outline" defaultPressed aria-label="Toggle italic">
          Outline
        </Toggle>
      </StateRow>
      <StateRow label="With icon">
        <Toggle aria-label="Toggle bold">
          <Bold />
        </Toggle>
        <Toggle defaultPressed aria-label="Toggle bold">
          <Bold />
        </Toggle>
      </StateRow>
      <StateRow label="Disabled">
        <Toggle disabled aria-label="Toggle italic">
          Italic
        </Toggle>
        <Toggle disabled defaultPressed aria-label="Toggle italic">
          Italic
        </Toggle>
      </StateRow>
    </StatesContainer>
  )
}
