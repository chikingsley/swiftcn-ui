import {
  ButtonGroup,
  ButtonGroupSeparator,
  ButtonGroupText,
} from "@/components/ui/button-group"
import { Button } from "@/components/ui/button"
import { StateRow, StatesContainer } from "@/lib/showcase"

export default function ButtonGroupShowcase() {
  return (
    <StatesContainer>
      <StateRow label="Three buttons (rest)">
        <ButtonGroup>
          <Button variant="outline">Left</Button>
          <Button variant="outline">Center</Button>
          <Button variant="outline">Right</Button>
        </ButtonGroup>
      </StateRow>
      <StateRow label="With separator">
        <ButtonGroup>
          <Button variant="outline">Copy</Button>
          <ButtonGroupSeparator />
          <Button variant="outline">Paste</Button>
        </ButtonGroup>
      </StateRow>
      <StateRow label="With text addon">
        <ButtonGroup>
          <ButtonGroupText>Sort</ButtonGroupText>
          <Button variant="outline">Ascending</Button>
        </ButtonGroup>
      </StateRow>
    </StatesContainer>
  )
}
