import { Checkbox } from "@/components/ui/checkbox"
import { Label } from "@/components/ui/label"
import { StateRow, StatesContainer } from "@/lib/showcase"

export default function LabelShowcase() {
  return (
    <StatesContainer>
      <StateRow label="Default">
        <Label htmlFor="email">Email address</Label>
      </StateRow>
      <StateRow label="Paired with control">
        <Label htmlFor="terms">
          <Checkbox id="terms" defaultChecked />
          Accept terms and conditions
        </Label>
      </StateRow>
      <StateRow label="Disabled (peer)">
        <div className="flex items-center gap-2">
          <Checkbox id="disabled-terms" className="peer" disabled />
          <Label htmlFor="disabled-terms">Accept terms and conditions</Label>
        </div>
      </StateRow>
    </StatesContainer>
  )
}
