import { Link, useParams } from "react-router-dom"
import { useThemeFromQuery } from "@/lib/use-theme"
import { showcaseById } from "@/showcases/registry"

export default function ShowcasePage() {
  const theme = useThemeFromQuery()
  const { id = "" } = useParams()
  const showcase = showcaseById.get(id)
  const suffix = theme === "dark" ? "?theme=dark" : ""

  return (
    <div className="min-h-screen bg-background text-foreground">
      <div className="mx-auto max-w-3xl px-6 py-8">
        <div className="mb-6 flex items-baseline justify-between">
          <h1 className="text-xl font-semibold tracking-tight">
            {showcase?.title ?? id}
          </h1>
          <Link
            to={`/${suffix}`}
            className="text-sm text-muted-foreground hover:text-foreground"
          >
            ← index
          </Link>
        </div>
        <main data-content data-component={id}>
          {showcase ? (
            <showcase.Component />
          ) : (
            <p className="text-sm text-muted-foreground">
              No showcase registered for <code>{id}</code>.
            </p>
          )}
        </main>
      </div>
    </div>
  )
}
