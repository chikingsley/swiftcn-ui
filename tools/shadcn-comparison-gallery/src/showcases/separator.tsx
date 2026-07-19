import { Separator } from "@/components/ui/separator"
import { StateRow, StatesContainer } from "@/lib/showcase"

export default function SeparatorShowcase() {
  return (
    <StatesContainer>
      <StateRow label="Horizontal" className="flex w-full flex-col gap-4">
        <div className="text-sm">Above the separator</div>
        <Separator />
        <div className="text-sm">Below the separator</div>
      </StateRow>
      <StateRow label="Vertical" className="flex items-center gap-4">
        <span className="text-sm">Docs</span>
        <Separator orientation="vertical" className="h-5" />
        <span className="text-sm">Source</span>
        <Separator orientation="vertical" className="h-5" />
        <span className="text-sm">Blog</span>
      </StateRow>
    </StatesContainer>
  )
}
