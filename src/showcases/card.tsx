import { Button } from "@/components/ui/button"
import {
  Card,
  CardAction,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card"
import { StateRow, StatesContainer } from "@/lib/showcase"

export default function CardShowcase() {
  return (
    <StatesContainer>
      <StateRow label="Full (header, content, footer)">
        <Card className="w-80">
          <CardHeader>
            <CardTitle>Create project</CardTitle>
            <CardDescription>
              Deploy your new project in one click.
            </CardDescription>
          </CardHeader>
          <CardContent>
            <p className="text-sm">
              Give your project a name and choose a deployment region to get
              started.
            </p>
          </CardContent>
          <CardFooter className="justify-between">
            <Button variant="outline">Cancel</Button>
            <Button>Deploy</Button>
          </CardFooter>
        </Card>
      </StateRow>
      <StateRow label="Content only">
        <Card className="w-80">
          <CardContent>
            <p className="text-sm">
              A minimal card with a single block of content and no header or
              footer.
            </p>
          </CardContent>
        </Card>
      </StateRow>
      <StateRow label="With CardAction">
        <Card className="w-80">
          <CardHeader>
            <CardTitle>Notifications</CardTitle>
            <CardDescription>You have 3 unread messages.</CardDescription>
            <CardAction>
              <Button variant="outline" size="sm">
                Mark all read
              </Button>
            </CardAction>
          </CardHeader>
          <CardContent>
            <p className="text-sm">Updates from your team appear here.</p>
          </CardContent>
        </Card>
      </StateRow>
    </StatesContainer>
  )
}
