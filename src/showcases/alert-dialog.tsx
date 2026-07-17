import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog"
import { Button } from "@/components/ui/button"
import { StateRow, StatesContainer } from "@/lib/showcase"

/**
 * Modal overlays portal to <body> and cover the viewport, so this page shows
 * the alert dialog OPEN by default (`defaultOpen`) — the open state is the
 * content. `onOpenAutoFocus` is prevented so no stray focus ring appears.
 */
export default function AlertDialogShowcase() {
  return (
    <StatesContainer>
      <StateRow label="open">
        <AlertDialog defaultOpen>
          <AlertDialogTrigger asChild>
            <Button variant="outline">Show dialog</Button>
          </AlertDialogTrigger>
          <AlertDialogContent
            onOpenAutoFocus={(e) => e.preventDefault()}
          >
            <AlertDialogHeader>
              <AlertDialogTitle>Are you absolutely sure?</AlertDialogTitle>
              <AlertDialogDescription>
                This action cannot be undone. This will permanently delete your
                account and remove your data from our servers.
              </AlertDialogDescription>
            </AlertDialogHeader>
            <AlertDialogFooter>
              <AlertDialogCancel>Cancel</AlertDialogCancel>
              <AlertDialogAction>Continue</AlertDialogAction>
            </AlertDialogFooter>
          </AlertDialogContent>
        </AlertDialog>
      </StateRow>
    </StatesContainer>
  )
}
