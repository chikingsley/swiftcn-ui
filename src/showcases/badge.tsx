import { Check, Bell } from "lucide-react"
import { Badge } from "@/components/ui/badge"
import { StateRow, StatesContainer } from "@/lib/showcase"

export default function BadgeShowcase() {
  return (
    <StatesContainer>
      <StateRow label="Variants (rest)">
        <Badge>Default</Badge>
        <Badge variant="secondary">Secondary</Badge>
        <Badge variant="destructive">Destructive</Badge>
        <Badge variant="outline">Outline</Badge>
        <Badge variant="ghost">Ghost</Badge>
        <Badge variant="link">Link</Badge>
      </StateRow>
      <StateRow label="With icon">
        <Badge>
          <Check />
          Verified
        </Badge>
        <Badge variant="secondary">
          <Bell />
          Notifications
        </Badge>
      </StateRow>
      <StateRow label="As link (asChild)">
        <Badge asChild>
          <a href="#">Documentation</a>
        </Badge>
      </StateRow>
    </StatesContainer>
  )
}
