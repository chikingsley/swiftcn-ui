import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import { StateRow, StatesContainer } from "@/lib/showcase"

export default function InputShowcase() {
  return (
    <StatesContainer>
      <StateRow label="Rest (empty, placeholder)">
        <Input placeholder="Email" className="max-w-xs" />
      </StateRow>
      <StateRow label="With value">
        <Input defaultValue="hello@example.com" className="max-w-xs" />
      </StateRow>
      <StateRow label="With label">
        <div className="grid w-full max-w-xs items-center gap-2">
          <Label htmlFor="email">Email</Label>
          <Input id="email" type="email" placeholder="you@example.com" />
        </div>
      </StateRow>
      <StateRow label="Disabled">
        <Input disabled placeholder="Disabled" className="max-w-xs" />
      </StateRow>
      <StateRow label="Invalid / error (aria-invalid)">
        <div className="grid w-full max-w-xs items-center gap-2">
          <Label htmlFor="pw">Password</Label>
          <Input
            id="pw"
            aria-invalid
            defaultValue="short"
            type="password"
          />
          <p className="text-sm text-destructive">
            Must be at least 8 characters.
          </p>
        </div>
      </StateRow>
      <StateRow label="File input">
        <Input type="file" className="max-w-xs" />
      </StateRow>
    </StatesContainer>
  )
}
