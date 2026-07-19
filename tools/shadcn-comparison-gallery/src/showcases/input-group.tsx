import { Search } from "lucide-react"
import {
  InputGroup,
  InputGroupAddon,
  InputGroupButton,
  InputGroupText,
  InputGroupInput,
} from "@/components/ui/input-group"
import { StateRow, StatesContainer } from "@/lib/showcase"

export default function InputGroupShowcase() {
  return (
    <StatesContainer>
      <StateRow label="Rest (input only)">
        <InputGroup className="max-w-sm">
          <InputGroupInput placeholder="Search..." />
        </InputGroup>
      </StateRow>
      <StateRow label="Leading icon addon (inline-start)">
        <InputGroup className="max-w-sm">
          <InputGroupAddon align="inline-start">
            <Search />
          </InputGroupAddon>
          <InputGroupInput placeholder="Search projects" />
        </InputGroup>
      </StateRow>
      <StateRow label="Trailing button addon (inline-end)">
        <InputGroup className="max-w-sm">
          <InputGroupInput placeholder="Enter a command" />
          <InputGroupAddon align="inline-end">
            <InputGroupButton>Send</InputGroupButton>
          </InputGroupAddon>
        </InputGroup>
      </StateRow>
      <StateRow label="Text prefix addon (inline-start)">
        <InputGroup className="max-w-sm">
          <InputGroupAddon align="inline-start">
            <InputGroupText>https://</InputGroupText>
          </InputGroupAddon>
          <InputGroupInput placeholder="example.com" />
        </InputGroup>
      </StateRow>
    </StatesContainer>
  )
}
