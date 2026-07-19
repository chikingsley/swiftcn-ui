import { Info, TriangleAlert } from "lucide-react"
import { useParams } from "react-router-dom"

import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion"
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert"
import { useThemeFromQuery } from "@/lib/use-theme"

type PilotKey =
  | "accordion-expanded"
  | "accordion-collapsed"
  | "alert-default"
  | "alert-destructive"

function AccordionFixture({ expanded }: { expanded: boolean }) {
  return (
    <Accordion
      defaultValue={expanded ? ["item-1"] : []}
      className="w-[448px]"
    >
      <AccordionItem value="item-1">
        <AccordionTrigger>Is it accessible?</AccordionTrigger>
        <AccordionContent>
          Yes. It adheres to the WAI-ARIA design pattern.
        </AccordionContent>
      </AccordionItem>
      <AccordionItem value="item-2">
        <AccordionTrigger>Is it styled?</AccordionTrigger>
        <AccordionContent>
          Yes. It comes with default styles that match the other components&apos;
          aesthetic.
        </AccordionContent>
      </AccordionItem>
      <AccordionItem value="item-3">
        <AccordionTrigger>Is it animated?</AccordionTrigger>
        <AccordionContent>
          Yes. It is animated by default, but you can disable it if you prefer.
        </AccordionContent>
      </AccordionItem>
    </Accordion>
  )
}

function AlertFixture({ destructive }: { destructive: boolean }) {
  return (
    <Alert
      variant={destructive ? "destructive" : "default"}
      className="w-[672px]"
    >
      {destructive ? <TriangleAlert /> : <Info />}
      <AlertTitle>
        {destructive ? "Something went wrong" : "Heads up!"}
      </AlertTitle>
      <AlertDescription>
        {destructive
          ? "Your session has expired. Please log in again."
          : "You can add components to your app using the CLI."}
      </AlertDescription>
    </Alert>
  )
}

function fixtureFor(key: PilotKey) {
  switch (key) {
    case "accordion-expanded":
      return <AccordionFixture expanded />
    case "accordion-collapsed":
      return <AccordionFixture expanded={false} />
    case "alert-default":
      return <AlertFixture destructive={false} />
    case "alert-destructive":
      return <AlertFixture destructive />
  }
}

export default function PilotPage() {
  useThemeFromQuery()
  const { component = "", state = "" } = useParams()
  const key = `${component}-${state}` as PilotKey
  const fixture = fixtureFor(key)

  return (
    <main
      data-pilot-root
      data-pilot-key={key}
      className="inline-flex bg-background p-4 text-foreground"
    >
      {fixture}
    </main>
  )
}
