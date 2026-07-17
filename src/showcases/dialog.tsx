import {
  Dialog,
  DialogClose,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { StateRow, StatesContainer } from "@/lib/showcase"

/**
 * Modal overlays portal to <body> and cover the viewport, so this page shows
 * the dialog OPEN by default (`defaultOpen`) — the open state is the content.
 */
export default function DialogShowcase() {
  return (
    <StatesContainer>
      <StateRow label="Trigger (rest) — dialog opens over it">
        <Dialog defaultOpen>
          <DialogTrigger asChild>
            <Button variant="outline">Edit profile</Button>
          </DialogTrigger>
          <DialogContent className="sm:max-w-md">
            <DialogHeader>
              <DialogTitle>Edit profile</DialogTitle>
              <DialogDescription>
                Make changes to your profile here. Click save when you're done.
              </DialogDescription>
            </DialogHeader>
            <div className="grid gap-4 py-2">
              <div className="grid gap-2">
                <Label htmlFor="name">Name</Label>
                <Input id="name" defaultValue="Ada Lovelace" />
              </div>
              <div className="grid gap-2">
                <Label htmlFor="username">Username</Label>
                <Input id="username" defaultValue="@ada" />
              </div>
            </div>
            <DialogFooter>
              <DialogClose asChild>
                <Button variant="outline">Cancel</Button>
              </DialogClose>
              <Button>Save changes</Button>
            </DialogFooter>
          </DialogContent>
        </Dialog>
      </StateRow>
    </StatesContainer>
  )
}
