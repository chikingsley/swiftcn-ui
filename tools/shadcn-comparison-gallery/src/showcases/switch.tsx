import { Label } from "@/components/ui/label"
import { Switch } from "@/components/ui/switch"
import { StateRow, StatesContainer } from "@/lib/showcase"

export default function SwitchShowcase() {
  return (
    <StatesContainer>
      <StateRow label="Off">
        <Switch />
      </StateRow>
      <StateRow label="On">
        <Switch defaultChecked />
      </StateRow>
      <StateRow label="Disabled">
        <Switch disabled />
        <Switch defaultChecked disabled />
      </StateRow>
      <StateRow label="With label">
        <Label htmlFor="airplane-mode">
          <Switch id="airplane-mode" defaultChecked />
          Airplane mode
        </Label>
      </StateRow>
    </StatesContainer>
  )
}
