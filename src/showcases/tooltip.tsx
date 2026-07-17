import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip"
import { Button } from "@/components/ui/button"
import { StateRow, StatesContainer } from "@/lib/showcase"

/**
 * The tooltip portals its content to <body> anchored to the trigger, so this
 * page renders it OPEN by default (`defaultOpen`).
 */
export default function TooltipShowcase() {
  return (
    <StatesContainer>
      <StateRow label="open / expanded">
        <TooltipProvider>
          <Tooltip defaultOpen>
            <TooltipTrigger asChild>
              <Button variant="outline">Hover</Button>
            </TooltipTrigger>
            <TooltipContent>Add to library</TooltipContent>
          </Tooltip>
        </TooltipProvider>
      </StateRow>
    </StatesContainer>
  )
}
