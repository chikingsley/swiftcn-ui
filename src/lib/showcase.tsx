import * as React from "react"

/**
 * A single captioned state. The label sits above the rendered state so a
 * screenshot clearly shows which state each block is.
 */
export function StateRow({
  label,
  children,
  className,
}: {
  label: string
  children: React.ReactNode
  className?: string
}) {
  return (
    <div className="flex flex-col gap-2 border-b border-dashed border-border/60 py-5 last:border-b-0">
      <div className="text-xs font-medium uppercase tracking-wider text-muted-foreground">
        {label}
      </div>
      <div className={className ?? "flex flex-wrap items-start gap-4"}>
        {children}
      </div>
    </div>
  )
}

/**
 * Vertical stack of StateRows for one component. `data-states` marks the
 * region a tight element screenshot would target (overlays portal out of it,
 * so capture uses full-page — see scripts/capture.ts).
 */
export function StatesContainer({ children }: { children: React.ReactNode }) {
  return (
    <div data-states className="flex w-full max-w-2xl flex-col">
      {children}
    </div>
  )
}
