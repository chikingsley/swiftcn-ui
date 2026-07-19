import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion"
import { StateRow, StatesContainer } from "@/lib/showcase"

/**
 * Animations are globally disabled, so `defaultValue={["item-1"]}` renders the
 * first item's content instantly — this page shows the FORCED-EXPANDED state.
 */
export default function AccordionShowcase() {
  return (
    <StatesContainer>
      <StateRow label="Single, first item expanded">
        <Accordion defaultValue={["item-1"]} className="w-full max-w-md">
          <AccordionItem value="item-1">
            <AccordionTrigger>Is it accessible?</AccordionTrigger>
            <AccordionContent>
              Yes. It adheres to the WAI-ARIA design pattern.
            </AccordionContent>
          </AccordionItem>
          <AccordionItem value="item-2">
            <AccordionTrigger>Is it styled?</AccordionTrigger>
            <AccordionContent>
              Yes. It comes with default styles that match the other
              components&apos; aesthetic.
            </AccordionContent>
          </AccordionItem>
          <AccordionItem value="item-3">
            <AccordionTrigger>Is it animated?</AccordionTrigger>
            <AccordionContent>
              Yes. It is animated by default, but you can disable it if you
              prefer.
            </AccordionContent>
          </AccordionItem>
        </Accordion>
      </StateRow>
    </StatesContainer>
  )
}
