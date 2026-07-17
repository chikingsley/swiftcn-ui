import { useEffect } from "react"
import { useSearchParams } from "react-router-dom"
import { toast } from "sonner"
import { Toaster } from "@/components/ui/sonner"
import { Button } from "@/components/ui/button"
import { StateRow, StatesContainer } from "@/lib/showcase"

/**
 * Toasts portal to <body> and auto-dismiss. For deterministic screenshots we
 * fire a fixed set on mount with `duration: Infinity` (pinned open) and pass an
 * explicit `theme` so the toast matches the page theme (sonner's next-themes
 * default would otherwise follow the OS, not our `.dark` class).
 */
export default function SonnerShowcase() {
  const [params] = useSearchParams()
  const theme = params.get("theme") === "dark" ? "dark" : "light"

  useEffect(() => {
    toast.dismiss()
    toast("Event has been created", {
      id: "t-default",
      description: "Monday, January 1 at 9:00 AM",
      duration: Infinity,
      action: { label: "Undo", onClick: () => {} },
    })
    toast.success("Changes saved", {
      id: "t-success",
      description: "Your profile has been updated.",
      duration: Infinity,
    })
    toast.error("Unable to save", {
      id: "t-error",
      description: "There was a problem with your request.",
      duration: Infinity,
    })
  }, [])

  return (
    <StatesContainer>
      <StateRow label="toasts (pinned open, top-center) — see top of page">
        <p className="text-sm text-muted-foreground">
          Default, success, and error toasts render via a portal.
        </p>
        <Button variant="outline" onClick={() => toast("Another toast")}>
          Show toast
        </Button>
      </StateRow>
      <Toaster theme={theme} position="top-center" expand />
    </StatesContainer>
  )
}
