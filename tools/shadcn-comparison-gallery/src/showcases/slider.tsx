import { Slider } from "@/components/ui/slider"
import { StateRow, StatesContainer } from "@/lib/showcase"

export default function SliderShowcase() {
  return (
    <StatesContainer>
      <StateRow label="Single value">
        <Slider defaultValue={[50]} className="w-64" />
      </StateRow>
      <StateRow label="Range">
        <Slider defaultValue={[25, 75]} className="w-64" />
      </StateRow>
      <StateRow label="Disabled">
        <Slider defaultValue={[50]} disabled className="w-64" />
      </StateRow>
      <StateRow label="Stepped">
        <Slider defaultValue={[40]} step={10} className="w-64" />
      </StateRow>
    </StatesContainer>
  )
}
