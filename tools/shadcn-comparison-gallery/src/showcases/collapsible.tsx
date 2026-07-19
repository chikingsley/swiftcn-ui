import { ChevronsUpDown } from "lucide-react"
import {
  Collapsible,
  CollapsibleContent,
  CollapsibleTrigger,
} from "@/components/ui/collapsible"
import { StateRow, StatesContainer } from "@/lib/showcase"

/**
 * Animations are globally disabled, so `defaultOpen` renders the collapsible
 * content instantly — this page shows the FORCED-EXPANDED state.
 */
export default function CollapsibleShowcase() {
  return (
    <StatesContainer>
      <StateRow label="Open (default)">
        <Collapsible defaultOpen className="flex w-80 flex-col gap-2">
          <div className="flex items-center justify-between gap-4 px-4">
            <h4 className="text-sm font-semibold">
              @peduarte starred 3 repositories
            </h4>
            <CollapsibleTrigger className="inline-flex size-8 items-center justify-center rounded-md hover:bg-accent hover:text-accent-foreground">
              <ChevronsUpDown className="size-4" />
              <span className="sr-only">Toggle</span>
            </CollapsibleTrigger>
          </div>
          <div className="rounded-md border px-4 py-2 font-mono text-sm">
            @radix-ui/primitives
          </div>
          <CollapsibleContent className="flex flex-col gap-2">
            <div className="rounded-md border px-4 py-2 font-mono text-sm">
              @radix-ui/colors
            </div>
            <div className="rounded-md border px-4 py-2 font-mono text-sm">
              @stitches/react
            </div>
          </CollapsibleContent>
        </Collapsible>
      </StateRow>
    </StatesContainer>
  )
}
