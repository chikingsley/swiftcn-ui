import { Checkbox } from "@/components/ui/checkbox"
import { Label } from "@/components/ui/label"
import { StateRow, StatesContainer } from "@/lib/showcase"

export default function CheckboxShowcase() {
  return (
    <StatesContainer>
      <StateRow label="Unchecked">
        <Checkbox />
      </StateRow>
      <StateRow label="Checked">
        <Checkbox defaultChecked />
      </StateRow>
      <StateRow label="Disabled">
        <Checkbox disabled />
        <Checkbox defaultChecked disabled />
      </StateRow>
      <StateRow label="With label">
        <Label htmlFor="newsletter">
          <Checkbox id="newsletter" defaultChecked />
          Subscribe to the newsletter
        </Label>
      </StateRow>
      <StateRow label="Invalid / error (aria-invalid)">
        <Checkbox aria-invalid />
      </StateRow>
    </StatesContainer>
  )
}
