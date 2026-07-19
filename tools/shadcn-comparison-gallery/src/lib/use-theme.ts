import { useEffect } from "react"
import { useSearchParams } from "react-router-dom"

/**
 * Reads `?theme=dark` from the URL and toggles the `dark` class on <html>.
 * Any other value (or none) is light. Used by every route so screenshots can
 * be taken in either theme just by changing the query string.
 */
export function useThemeFromQuery() {
  const [params] = useSearchParams()
  const theme = params.get("theme") === "dark" ? "dark" : "light"

  useEffect(() => {
    const root = document.documentElement
    root.classList.toggle("dark", theme === "dark")
    root.style.colorScheme = theme
    return () => {
      root.classList.remove("dark")
      root.style.colorScheme = ""
    }
  }, [theme])

  return theme
}
