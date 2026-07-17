import { Textarea } from "@/components/ui/textarea"
import { StateRow, StatesContainer } from "@/lib/showcase"

export default function TextareaShowcase() {
  return (
    <StatesContainer>
      <StateRow label="Rest (empty, placeholder)">
        <Textarea placeholder="Type your message here." className="max-w-sm" />
      </StateRow>
      <StateRow label="With value">
        <Textarea
          defaultValue={"Line one\nLine two\nLine three"}
          className="max-w-sm"
        />
      </StateRow>
      <StateRow label="Disabled">
        <Textarea
          disabled
          placeholder="Type your message here."
          className="max-w-sm"
        />
      </StateRow>
      <StateRow label="Invalid / error (aria-invalid)">
        <Textarea
          aria-invalid
          defaultValue="Too short"
          className="max-w-sm"
        />
      </StateRow>
    </StatesContainer>
  )
}
