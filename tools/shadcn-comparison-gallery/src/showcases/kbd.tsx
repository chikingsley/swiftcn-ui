import { Kbd, KbdGroup } from "@/components/ui/kbd"
import { StateRow, StatesContainer } from "@/lib/showcase"

export default function KbdShowcase() {
  return (
    <StatesContainer>
      <StateRow label="Single keys">
        <Kbd>K</Kbd>
        <Kbd>Esc</Kbd>
        <Kbd>Enter</Kbd>
        <Kbd>⌘</Kbd>
      </StateRow>
      <StateRow label="Group (combo)">
        <KbdGroup>
          <Kbd>Ctrl</Kbd>
          <Kbd>K</Kbd>
        </KbdGroup>
      </StateRow>
      <StateRow label="Inline in a sentence">
        <p className="text-sm text-muted-foreground">
          Press{" "}
          <KbdGroup>
            <Kbd>Ctrl</Kbd>
            <Kbd>K</Kbd>
          </KbdGroup>{" "}
          to open the command menu.
        </p>
      </StateRow>
    </StatesContainer>
  )
}
