import {
  Menubar,
  MenubarContent,
  MenubarItem,
  MenubarMenu,
  MenubarSeparator,
  MenubarShortcut,
  MenubarTrigger,
} from "@/components/ui/menubar"
import { StateRow, StatesContainer } from "@/lib/showcase"

/**
 * The menubar renders inline, but its menu content portals to <body>. The File
 * menu is forced OPEN via that menu root's `defaultOpen` state.
 */
export default function MenubarShowcase() {
  return (
    <StatesContainer>
      <StateRow label="open / expanded">
        <Menubar>
          <MenubarMenu defaultOpen>
            <MenubarTrigger>File</MenubarTrigger>
            <MenubarContent>
              <MenubarItem>
                New Tab <MenubarShortcut>⌘T</MenubarShortcut>
              </MenubarItem>
              <MenubarItem>
                New Window <MenubarShortcut>⌘N</MenubarShortcut>
              </MenubarItem>
              <MenubarSeparator />
              <MenubarItem>Share</MenubarItem>
              <MenubarSeparator />
              <MenubarItem>
                Print <MenubarShortcut>⌘P</MenubarShortcut>
              </MenubarItem>
            </MenubarContent>
          </MenubarMenu>
          <MenubarMenu>
            <MenubarTrigger>Edit</MenubarTrigger>
          </MenubarMenu>
          <MenubarMenu>
            <MenubarTrigger>View</MenubarTrigger>
          </MenubarMenu>
        </Menubar>
      </StateRow>
    </StatesContainer>
  )
}
