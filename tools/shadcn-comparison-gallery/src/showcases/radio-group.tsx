import { Label } from "@/components/ui/label"
import { RadioGroup, RadioGroupItem } from "@/components/ui/radio-group"
import { StateRow, StatesContainer } from "@/lib/showcase"

export default function RadioGroupShowcase() {
  return (
    <StatesContainer>
      <StateRow label="Group (one selected)">
        <RadioGroup defaultValue="comfortable">
          <div className="flex items-center gap-2">
            <RadioGroupItem value="default" id="r1" />
            <Label htmlFor="r1">Default</Label>
          </div>
          <div className="flex items-center gap-2">
            <RadioGroupItem value="comfortable" id="r2" />
            <Label htmlFor="r2">Comfortable</Label>
          </div>
          <div className="flex items-center gap-2">
            <RadioGroupItem value="compact" id="r3" />
            <Label htmlFor="r3">Compact</Label>
          </div>
        </RadioGroup>
      </StateRow>
      <StateRow label="Disabled group">
        <RadioGroup defaultValue="one" disabled>
          <div className="flex items-center gap-2">
            <RadioGroupItem value="one" id="d1" />
            <Label htmlFor="d1">Option one</Label>
          </div>
          <div className="flex items-center gap-2">
            <RadioGroupItem value="two" id="d2" />
            <Label htmlFor="d2">Option two</Label>
          </div>
        </RadioGroup>
      </StateRow>
      <StateRow label="Single disabled item">
        <RadioGroup defaultValue="enabled">
          <div className="flex items-center gap-2">
            <RadioGroupItem value="enabled" id="s1" />
            <Label htmlFor="s1">Enabled</Label>
          </div>
          <div className="flex items-center gap-2">
            <RadioGroupItem value="blocked" id="s2" disabled />
            <Label htmlFor="s2">Blocked</Label>
          </div>
        </RadioGroup>
      </StateRow>
    </StatesContainer>
  )
}
