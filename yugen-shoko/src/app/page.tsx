import { Typography } from "@/components/atoms/Typography";
import { Button } from "@/components/atoms/Button";
import { Badge } from "@/components/atoms/Badge";
import { Card, CardHeader, CardContent } from "@/components/molecules/Card";

export default function Home() {
  return (
    <main className="min-h-screen p-8 max-w-4xl mx-auto">
      <Typography variant="h1" className="mb-2">
        幽玄書庫
      </Typography>
      <Typography variant="bodySmall" className="text-muted-foreground mb-8">
        Ethereal Library - Design System
      </Typography>

      <div className="grid gap-6 md:grid-cols-2">
        <Card hoverable>
          <CardHeader>
            <Typography variant="h3">Buttons</Typography>
          </CardHeader>
          <CardContent>
            <div className="flex flex-wrap gap-3">
              <Button variant="primary">Primary</Button>
              <Button variant="secondary">Secondary</Button>
              <Button variant="ghost">Ghost</Button>
              <Button variant="outline">Outline</Button>
            </div>
          </CardContent>
        </Card>

        <Card hoverable>
          <CardHeader>
            <Typography variant="h3">Badges</Typography>
          </CardHeader>
          <CardContent>
            <div className="flex flex-wrap gap-3">
              <Badge>Default</Badge>
              <Badge variant="accent">Accent</Badge>
              <Badge variant="sub">Sub</Badge>
              <Badge variant="outline">Outline</Badge>
            </div>
          </CardContent>
        </Card>
      </div>
    </main>
  );
}
