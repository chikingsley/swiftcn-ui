import { Folder, Plus } from "lucide-react"
import {
  Empty,
  EmptyHeader,
  EmptyTitle,
  EmptyDescription,
  EmptyContent,
  EmptyMedia,
} from "@/components/ui/empty"
import { Button } from "@/components/ui/button"
import { StateRow, StatesContainer } from "@/lib/showcase"

export default function EmptyShowcase() {
  return (
    <StatesContainer>
      <StateRow label="Empty state (icon media, title, description, action)">
        <Empty className="border">
          <EmptyHeader>
            <EmptyMedia variant="icon">
              <Folder />
            </EmptyMedia>
            <EmptyTitle>No projects yet</EmptyTitle>
            <EmptyDescription>
              Create your first project to get started.
            </EmptyDescription>
          </EmptyHeader>
          <EmptyContent>
            <Button>
              <Plus /> New project
            </Button>
          </EmptyContent>
        </Empty>
      </StateRow>
    </StatesContainer>
  )
}
