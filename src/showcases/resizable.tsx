import {
  ResizableHandle,
  ResizablePanel,
  ResizablePanelGroup,
} from "@/components/ui/resizable"
import { StateRow, StatesContainer } from "@/lib/showcase"

export default function ResizableShowcase() {
  return (
    <StatesContainer>
      <StateRow label="Horizontal (50 / 50, with handle)">
        <ResizablePanelGroup
          orientation="horizontal"
          className="h-48 max-w-md rounded-lg border"
        >
          <ResizablePanel defaultSize={50}>
            <div className="flex h-full items-center justify-center p-6">
              <span className="font-semibold">Panel One</span>
            </div>
          </ResizablePanel>
          <ResizableHandle withHandle />
          <ResizablePanel defaultSize={50}>
            <div className="flex h-full items-center justify-center p-6">
              <span className="font-semibold">Panel Two</span>
            </div>
          </ResizablePanel>
        </ResizablePanelGroup>
      </StateRow>
      <StateRow label="Vertical (50 / 50, with handle)">
        <ResizablePanelGroup
          orientation="vertical"
          className="h-48 max-w-md rounded-lg border"
        >
          <ResizablePanel defaultSize={50}>
            <div className="flex h-full items-center justify-center p-6">
              <span className="font-semibold">Header</span>
            </div>
          </ResizablePanel>
          <ResizableHandle withHandle />
          <ResizablePanel defaultSize={50}>
            <div className="flex h-full items-center justify-center p-6">
              <span className="font-semibold">Content</span>
            </div>
          </ResizablePanel>
        </ResizablePanelGroup>
      </StateRow>
    </StatesContainer>
  )
}
