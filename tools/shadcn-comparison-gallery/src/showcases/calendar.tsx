import { Calendar } from "@/components/ui/calendar"
import { StateRow, StatesContainer } from "@/lib/showcase"

// Fixed to July 2024 so screenshots are deterministic.
const JULY_2024 = new Date(2024, 6, 1)

export default function CalendarShowcase() {
  return (
    <StatesContainer>
      <StateRow label="single selection (July 15, 2024)">
        <Calendar
          mode="single"
          defaultMonth={JULY_2024}
          selected={new Date(2024, 6, 15)}
          onSelect={() => {}}
          className="rounded-md border"
        />
      </StateRow>
      <StateRow label="range selection (July 8 – 12, 2024)">
        <Calendar
          mode="range"
          defaultMonth={JULY_2024}
          selected={{ from: new Date(2024, 6, 8), to: new Date(2024, 6, 12) }}
          onSelect={() => {}}
          className="rounded-md border"
        />
      </StateRow>
      <StateRow label="with dropdown caption + two months">
        <Calendar
          mode="single"
          defaultMonth={JULY_2024}
          selected={new Date(2024, 6, 15)}
          onSelect={() => {}}
          numberOfMonths={2}
          captionLayout="dropdown"
          className="rounded-md border"
        />
      </StateRow>
    </StatesContainer>
  )
}
