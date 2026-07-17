import { AspectRatio } from "@/components/ui/aspect-ratio"
import { StateRow, StatesContainer } from "@/lib/showcase"

export default function AspectRatioShowcase() {
  return (
    <StatesContainer>
      <StateRow label="16 / 9">
        <div className="w-72">
          <AspectRatio ratio={16 / 9}>
            <div className="flex h-full w-full items-center justify-center rounded-md bg-muted text-sm text-muted-foreground">
              16 / 9
            </div>
          </AspectRatio>
        </div>
      </StateRow>
      <StateRow label="1 / 1">
        <div className="w-72">
          <AspectRatio ratio={1}>
            <div className="flex h-full w-full items-center justify-center rounded-md bg-muted text-sm text-muted-foreground">
              1 / 1
            </div>
          </AspectRatio>
        </div>
      </StateRow>
    </StatesContainer>
  )
}
