import {
  Sheet,
  SheetClose,
  SheetContent,
  SheetDescription,
  SheetFooter,
  SheetHeader,
  SheetTitle,
  SheetTrigger,
} from "@/components/ui/sheet"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { StateRow, StatesContainer } from "@/lib/showcase"

/**
 * Modal overlays portal to <body> and cover the viewport, so this page shows
 * the sheet OPEN by default (`defaultOpen`) — the open state is the content.
 * `onOpenAutoFocus` is prevented so no stray focus ring appears.
 */
export default function SheetShowcase() {
  return (
    <StatesContainer>
      <StateRow label="open">
        <Sheet defaultOpen>
          <SheetTrigger render={<Button variant="outline" />}>
            Edit profile
          </SheetTrigger>
          <SheetContent
            side="right"
            initialFocus={false}
          >
            <SheetHeader>
              <SheetTitle>Edit profile</SheetTitle>
              <SheetDescription>
                Make changes to your profile here. Click save when you're done.
              </SheetDescription>
            </SheetHeader>
            <div className="grid flex-1 auto-rows-min gap-6 px-4">
              <div className="grid gap-2">
                <Label htmlFor="sheet-name">Name</Label>
                <Input id="sheet-name" defaultValue="Ada Lovelace" />
              </div>
              <div className="grid gap-2">
                <Label htmlFor="sheet-username">Username</Label>
                <Input id="sheet-username" defaultValue="@ada" />
              </div>
            </div>
            <SheetFooter>
              <Button>Save changes</Button>
              <SheetClose render={<Button variant="outline" />}>
                Cancel
              </SheetClose>
            </SheetFooter>
          </SheetContent>
        </Sheet>
      </StateRow>
    </StatesContainer>
  )
}
