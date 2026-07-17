import { ArrowRight } from "lucide-react"
import { Button } from "@/components/ui/button"
import { StateRow, StatesContainer } from "@/lib/showcase"

export default function ButtonShowcase() {
  return (
    <StatesContainer>
      <StateRow label="Variants (rest)">
        <Button>Default</Button>
        <Button variant="secondary">Secondary</Button>
        <Button variant="destructive">Destructive</Button>
        <Button variant="outline">Outline</Button>
        <Button variant="ghost">Ghost</Button>
        <Button variant="link">Link</Button>
      </StateRow>
      <StateRow label="Sizes">
        <Button size="sm">Small</Button>
        <Button size="default">Default</Button>
        <Button size="lg">Large</Button>
        <Button size="icon" aria-label="Next">
          <ArrowRight />
        </Button>
      </StateRow>
      <StateRow label="With icon">
        <Button>
          Continue <ArrowRight />
        </Button>
        <Button variant="outline">
          Continue <ArrowRight />
        </Button>
      </StateRow>
      <StateRow label="Disabled">
        <Button disabled>Default</Button>
        <Button variant="secondary" disabled>
          Secondary
        </Button>
        <Button variant="destructive" disabled>
          Destructive
        </Button>
        <Button variant="outline" disabled>
          Outline
        </Button>
      </StateRow>
    </StatesContainer>
  )
}
