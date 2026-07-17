import { Link } from "react-router-dom"
import { useThemeFromQuery } from "@/lib/use-theme"
import { showcases } from "@/showcases/registry"

export default function IndexPage() {
  const theme = useThemeFromQuery()
  const suffix = theme === "dark" ? "?theme=dark" : ""

  return (
    <div className="min-h-screen bg-background text-foreground">
      <div className="mx-auto max-w-3xl px-6 py-10">
        <h1 className="text-2xl font-semibold tracking-tight">
          swiftcn/ui — shadcn reference
        </h1>
        <p className="mt-2 text-sm text-muted-foreground">
          Official shadcn/ui components (new-york style, zinc theme) rendered in
          fixed visual states for side-by-side screenshot comparison against the
          SwiftUI port. Append <code>?theme=dark</code> to any route for dark
          mode.
        </p>
        <div className="mt-8 grid grid-cols-2 gap-x-8 gap-y-1 sm:grid-cols-3">
          {showcases.map((s) => (
            <Link
              key={s.id}
              to={`/c/${s.id}${suffix}`}
              data-cid={s.id}
              className="rounded-md px-2 py-1.5 text-sm text-foreground hover:bg-accent hover:text-accent-foreground"
            >
              {s.title}
            </Link>
          ))}
        </div>
        <p className="mt-8 text-xs text-muted-foreground">
          {showcases.length} components
        </p>
      </div>
    </div>
  )
}
