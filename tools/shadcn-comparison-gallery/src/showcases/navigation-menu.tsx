import {
  NavigationMenu,
  NavigationMenuContent,
  NavigationMenuItem,
  NavigationMenuLink,
  NavigationMenuList,
  NavigationMenuTrigger,
} from "@/components/ui/navigation-menu"
import { StateRow, StatesContainer } from "@/lib/showcase"

/**
 * The active item's content panel renders in the viewport (which portals near
 * the menu). The "Getting started" item is forced OPEN via the Root's
 * `defaultValue` matching that Item's `value`.
 */
export default function NavigationMenuShowcase() {
  return (
    <StatesContainer>
      <StateRow label="open / expanded">
        <NavigationMenu defaultValue="getting-started">
          <NavigationMenuList>
            <NavigationMenuItem value="getting-started">
              <NavigationMenuTrigger>Getting started</NavigationMenuTrigger>
              <NavigationMenuContent>
                <ul className="grid w-[400px] gap-2 p-2">
                  <li>
                    <NavigationMenuLink href="#introduction">
                      <div className="text-sm font-medium leading-none">
                        Introduction
                      </div>
                      <p className="text-sm leading-snug text-muted-foreground">
                        Re-usable components built with Radix UI and Tailwind
                        CSS.
                      </p>
                    </NavigationMenuLink>
                  </li>
                  <li>
                    <NavigationMenuLink href="#installation">
                      <div className="text-sm font-medium leading-none">
                        Installation
                      </div>
                      <p className="text-sm leading-snug text-muted-foreground">
                        How to install dependencies and structure your app.
                      </p>
                    </NavigationMenuLink>
                  </li>
                  <li>
                    <NavigationMenuLink href="#typography">
                      <div className="text-sm font-medium leading-none">
                        Typography
                      </div>
                      <p className="text-sm leading-snug text-muted-foreground">
                        Styles for headings, paragraphs, lists, and more.
                      </p>
                    </NavigationMenuLink>
                  </li>
                </ul>
              </NavigationMenuContent>
            </NavigationMenuItem>
            <NavigationMenuItem value="docs">
              <NavigationMenuLink href="#docs">Docs</NavigationMenuLink>
            </NavigationMenuItem>
          </NavigationMenuList>
        </NavigationMenu>
      </StateRow>
    </StatesContainer>
  )
}
