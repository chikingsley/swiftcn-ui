import { Skeleton } from "@/components/ui/skeleton"
import { StateRow, StatesContainer } from "@/lib/showcase"

export default function SkeletonShowcase() {
  return (
    <StatesContainer>
      <StateRow label="Loading card">
        <div className="flex items-center gap-4">
          <Skeleton className="size-12 rounded-full" />
          <div className="flex flex-col gap-2">
            <Skeleton className="h-4 w-48" />
            <Skeleton className="h-4 w-32" />
          </div>
        </div>
      </StateRow>
      <StateRow label="Text lines">
        <div className="flex flex-col gap-2">
          <Skeleton className="h-4 w-64" />
          <Skeleton className="h-4 w-56" />
          <Skeleton className="h-4 w-40" />
        </div>
      </StateRow>
    </StatesContainer>
  )
}
