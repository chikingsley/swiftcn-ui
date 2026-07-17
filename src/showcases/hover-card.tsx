import { CalendarDays } from "lucide-react"
import {
  HoverCard,
  HoverCardContent,
  HoverCardTrigger,
} from "@/components/ui/hover-card"
import { Button } from "@/components/ui/button"
import { StateRow, StatesContainer } from "@/lib/showcase"

/**
 * The hover card portals its content to <body> anchored to the trigger, so
 * this page renders it OPEN by default (`defaultOpen`, `openDelay={0}`).
 */
export default function HoverCardShowcase() {
  return (
    <StatesContainer>
      <StateRow label="open / expanded">
        <HoverCard defaultOpen openDelay={0}>
          <HoverCardTrigger asChild>
            <Button variant="link">@nextjs</Button>
          </HoverCardTrigger>
          <HoverCardContent className="w-80">
            <div className="flex justify-between gap-4">
              <div className="space-y-1">
                <h4 className="text-sm font-semibold">@nextjs</h4>
                <p className="text-sm">
                  The React Framework – created and maintained by @vercel.
                </p>
                <div className="flex items-center pt-2 text-muted-foreground">
                  <CalendarDays className="mr-2 size-4 opacity-70" />
                  <span className="text-xs">Joined December 2021</span>
                </div>
              </div>
            </div>
          </HoverCardContent>
        </HoverCard>
      </StateRow>
    </StatesContainer>
  )
}
