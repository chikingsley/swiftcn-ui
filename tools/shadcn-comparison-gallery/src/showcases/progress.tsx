import { Progress } from "@/components/ui/progress"
import { StateRow, StatesContainer } from "@/lib/showcase"

export default function ProgressShowcase() {
  return (
    <StatesContainer>
      <StateRow label="Value 0">
        <Progress value={0} className="w-64" />
      </StateRow>
      <StateRow label="Value 33">
        <Progress value={33} className="w-64" />
      </StateRow>
      <StateRow label="Value 66">
        <Progress value={66} className="w-64" />
      </StateRow>
      <StateRow label="Value 100">
        <Progress value={100} className="w-64" />
      </StateRow>
    </StatesContainer>
  )
}
