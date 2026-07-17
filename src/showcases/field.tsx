import {
  Field,
  FieldLabel,
  FieldDescription,
  FieldError,
  FieldGroup,
  FieldLegend,
  FieldSet,
} from "@/components/ui/field"
import { Input } from "@/components/ui/input"
import { StateRow, StatesContainer } from "@/lib/showcase"

export default function FieldShowcase() {
  return (
    <StatesContainer>
      <StateRow label="Field with label and description (rest)">
        <FieldGroup className="max-w-sm">
          <Field>
            <FieldLabel htmlFor="username">Username</FieldLabel>
            <Input id="username" placeholder="shadcn" />
            <FieldDescription>
              This is your public display name.
            </FieldDescription>
          </Field>
        </FieldGroup>
      </StateRow>
      <StateRow label="Invalid / error (data-invalid + aria-invalid)">
        <FieldGroup className="max-w-sm">
          <Field data-invalid="true">
            <FieldLabel htmlFor="email">Email</FieldLabel>
            <Input
              id="email"
              type="email"
              aria-invalid
              defaultValue="not-an-email"
            />
            <FieldError>Enter a valid email address.</FieldError>
          </Field>
        </FieldGroup>
      </StateRow>
      <StateRow label="FieldSet with legend grouping two fields">
        <FieldSet className="max-w-sm">
          <FieldLegend>Delivery address</FieldLegend>
          <FieldDescription>
            Where should we send your order?
          </FieldDescription>
          <FieldGroup>
            <Field>
              <FieldLabel htmlFor="city">City</FieldLabel>
              <Input id="city" placeholder="San Francisco" />
            </Field>
            <Field>
              <FieldLabel htmlFor="zip">ZIP code</FieldLabel>
              <Input id="zip" placeholder="94103" />
            </Field>
          </FieldGroup>
        </FieldSet>
      </StateRow>
    </StatesContainer>
  )
}
