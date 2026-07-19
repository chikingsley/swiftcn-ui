import {
  Tabs,
  TabsContent,
  TabsList,
  TabsTrigger,
} from "@/components/ui/tabs"
import { StateRow, StatesContainer } from "@/lib/showcase"

export default function TabsShowcase() {
  return (
    <StatesContainer>
      <StateRow label="Tabs (Account active, Settings disabled)">
        <Tabs defaultValue="account" className="w-96">
          <TabsList className="w-full">
            <TabsTrigger value="account">Account</TabsTrigger>
            <TabsTrigger value="password">Password</TabsTrigger>
            <TabsTrigger value="settings" disabled>
              Settings
            </TabsTrigger>
          </TabsList>
          <TabsContent value="account">
            <p className="text-sm text-muted-foreground">
              Manage your account details and profile information.
            </p>
          </TabsContent>
          <TabsContent value="password">
            <p className="text-sm text-muted-foreground">
              Change your password and security settings.
            </p>
          </TabsContent>
          <TabsContent value="settings">
            <p className="text-sm text-muted-foreground">
              Configure your workspace preferences.
            </p>
          </TabsContent>
        </Tabs>
      </StateRow>
    </StatesContainer>
  )
}
