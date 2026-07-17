import { ScrollArea, ScrollBar } from "@/components/ui/scroll-area"
import { StateRow, StatesContainer } from "@/lib/showcase"

const tags = Array.from({ length: 15 }, (_, i) => `v1.2.0-beta.${i + 1}`)

const boxes = Array.from({ length: 10 }, (_, i) => i + 1)

export default function ScrollAreaShowcase() {
  return (
    <StatesContainer>
      <StateRow label="Vertical scroll">
        <ScrollArea className="h-48 w-64 rounded-md border">
          <div className="p-4">
            <h4 className="mb-4 text-sm leading-none font-medium">Tags</h4>
            {tags.map((tag) => (
              <div
                key={tag}
                className="border-b py-2 text-sm last:border-b-0"
              >
                {tag}
              </div>
            ))}
          </div>
        </ScrollArea>
      </StateRow>
      <StateRow label="Horizontal scroll">
        <ScrollArea className="w-96 rounded-md border whitespace-nowrap">
          <div className="flex w-max gap-4 p-4">
            {boxes.map((box) => (
              <div
                key={box}
                className="flex size-24 shrink-0 items-center justify-center rounded-md border bg-muted text-lg font-medium"
              >
                {box}
              </div>
            ))}
          </div>
          <ScrollBar orientation="horizontal" />
        </ScrollArea>
      </StateRow>
    </StatesContainer>
  )
}
