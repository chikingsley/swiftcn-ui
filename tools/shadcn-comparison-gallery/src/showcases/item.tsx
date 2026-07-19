import { Bell, CreditCard, Package, User } from "lucide-react"
import {
  Item,
  ItemActions,
  ItemContent,
  ItemDescription,
  ItemGroup,
  ItemMedia,
  ItemSeparator,
  ItemTitle,
} from "@/components/ui/item"
import { Button } from "@/components/ui/button"
import { StateRow, StatesContainer } from "@/lib/showcase"

export default function ItemShowcase() {
  return (
    <StatesContainer>
      <StateRow label="Item (media + content + actions)" className="w-full">
        <Item variant="outline" className="max-w-md">
          <ItemMedia variant="icon">
            <User />
          </ItemMedia>
          <ItemContent>
            <ItemTitle>Ada Lovelace</ItemTitle>
            <ItemDescription>
              First computer programmer. Member since 1843.
            </ItemDescription>
          </ItemContent>
          <ItemActions>
            <Button variant="outline" size="sm">
              View
            </Button>
          </ItemActions>
        </Item>
      </StateRow>

      <StateRow label="Variants" className="flex w-full flex-col gap-4">
        <Item variant="default" className="max-w-md">
          <ItemContent>
            <ItemTitle>Default</ItemTitle>
            <ItemDescription>Transparent background, no border.</ItemDescription>
          </ItemContent>
        </Item>
        <Item variant="outline" className="max-w-md">
          <ItemContent>
            <ItemTitle>Outline</ItemTitle>
            <ItemDescription>Bordered surface.</ItemDescription>
          </ItemContent>
        </Item>
        <Item variant="muted" className="max-w-md">
          <ItemContent>
            <ItemTitle>Muted</ItemTitle>
            <ItemDescription>Muted background fill.</ItemDescription>
          </ItemContent>
        </Item>
      </StateRow>

      <StateRow label="Group with separators" className="w-full">
        <ItemGroup className="max-w-md rounded-lg border">
          <Item>
            <ItemMedia variant="icon">
              <Bell />
            </ItemMedia>
            <ItemContent>
              <ItemTitle>Notifications</ItemTitle>
              <ItemDescription>Manage how you are notified.</ItemDescription>
            </ItemContent>
          </Item>
          <ItemSeparator />
          <Item>
            <ItemMedia variant="icon">
              <CreditCard />
            </ItemMedia>
            <ItemContent>
              <ItemTitle>Billing</ItemTitle>
              <ItemDescription>Update your payment method.</ItemDescription>
            </ItemContent>
          </Item>
          <ItemSeparator />
          <Item>
            <ItemMedia variant="icon">
              <Package />
            </ItemMedia>
            <ItemContent>
              <ItemTitle>Shipping</ItemTitle>
              <ItemDescription>Set your delivery address.</ItemDescription>
            </ItemContent>
          </Item>
        </ItemGroup>
      </StateRow>
    </StatesContainer>
  )
}
