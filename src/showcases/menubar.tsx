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
 * menu is forced OPEN via the Root's `defaultValue` matching that Menu's
 * `value`.
 */
export default function MenubarShowcase() {
  return (
    <StatesContainer>
      <StateRow label="open / expanded">
        <Menubar defaultValue="file">
          <MenubarMenu value="file">
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
          <MenubarMenu value="edit">
            <MenubarTrigger>Edit</MenubarTrigger>
          </MenubarMenu>
          <MenubarMenu value="view">
            <MenubarTrigger>View</MenubarTrigger>
          </MenubarMenu>
        </Menubar>
      </StateRow>
    </StatesContainer>
  )
}
