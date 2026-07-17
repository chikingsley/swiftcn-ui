import { Check } from "lucide-react"
import {
  Avatar,
  AvatarBadge,
  AvatarFallback,
  AvatarGroup,
  AvatarGroupCount,
  AvatarImage,
} from "@/components/ui/avatar"
import { StateRow, StatesContainer } from "@/lib/showcase"

export default function AvatarShowcase() {
  return (
    <StatesContainer>
      <StateRow label="Image">
        <Avatar>
          <AvatarImage src="https://github.com/shadcn.png" alt="shadcn" />
          <AvatarFallback>CN</AvatarFallback>
        </Avatar>
      </StateRow>
      <StateRow label="Fallback only">
        <Avatar>
          <AvatarFallback>CN</AvatarFallback>
        </Avatar>
      </StateRow>
      <StateRow label="With badge">
        <Avatar>
          <AvatarImage src="https://github.com/shadcn.png" alt="shadcn" />
          <AvatarFallback>CN</AvatarFallback>
          <AvatarBadge>
            <Check />
          </AvatarBadge>
        </Avatar>
      </StateRow>
      <StateRow label="Group + count">
        <AvatarGroup>
          <Avatar>
            <AvatarImage src="https://github.com/shadcn.png" alt="shadcn" />
            <AvatarFallback>CN</AvatarFallback>
          </Avatar>
          <Avatar>
            <AvatarFallback>AB</AvatarFallback>
          </Avatar>
          <Avatar>
            <AvatarFallback>XY</AvatarFallback>
          </Avatar>
          <AvatarGroupCount>+3</AvatarGroupCount>
        </AvatarGroup>
      </StateRow>
    </StatesContainer>
  )
}
