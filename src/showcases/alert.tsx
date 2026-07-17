import { Info, TriangleAlert } from "lucide-react"
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert"
import { StateRow, StatesContainer } from "@/lib/showcase"

export default function AlertShowcase() {
  return (
    <StatesContainer>
      <StateRow label="Default">
        <Alert>
          <Info />
          <AlertTitle>Heads up!</AlertTitle>
          <AlertDescription>
            You can add components to your app using the CLI.
          </AlertDescription>
        </Alert>
      </StateRow>
      <StateRow label="Destructive">
        <Alert variant="destructive">
          <TriangleAlert />
          <AlertTitle>Something went wrong</AlertTitle>
          <AlertDescription>
            Your session has expired. Please log in again.
          </AlertDescription>
        </Alert>
      </StateRow>
    </StatesContainer>
  )
}
