import {
  Drawer,
  DrawerClose,
  DrawerContent,
  DrawerDescription,
  DrawerFooter,
  DrawerHeader,
  DrawerTitle,
  DrawerTrigger,
} from "@/components/ui/drawer"
import { Button } from "@/components/ui/button"
import { StateRow, StatesContainer } from "@/lib/showcase"

/**
 * Modal overlays portal to <body> and cover the viewport, so this page shows
 * the drawer OPEN by default (`defaultOpen`) — the open state is the content.
 * `onOpenAutoFocus` is prevented so no stray focus ring appears.
 */
export default function DrawerShowcase() {
  return (
    <StatesContainer>
      <StateRow label="open">
        <Drawer defaultOpen direction="bottom">
          <DrawerTrigger asChild>
            <Button variant="outline">Open drawer</Button>
          </DrawerTrigger>
          <DrawerContent onOpenAutoFocus={(e) => e.preventDefault()}>
            <div className="mx-auto w-full max-w-sm">
              <DrawerHeader>
                <DrawerTitle>Move goal</DrawerTitle>
                <DrawerDescription>
                  Set your daily activity goal.
                </DrawerDescription>
              </DrawerHeader>
              <DrawerFooter>
                <Button>Submit</Button>
                <DrawerClose asChild>
                  <Button variant="outline">Cancel</Button>
                </DrawerClose>
              </DrawerFooter>
            </div>
          </DrawerContent>
        </Drawer>
      </StateRow>
    </StatesContainer>
  )
}
