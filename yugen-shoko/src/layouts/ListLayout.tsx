import { cn } from "@/lib/cn";
import { Typography } from "@/components/atoms/Typography";
import type { ReactNode } from "react";

export interface ListLayoutProps {
  title: string;
  description?: string;
  actions?: ReactNode;
  filters?: ReactNode;
  children: ReactNode;
  pagination?: ReactNode;
  className?: string;
}

export function ListLayout({
  title,
  description,
  actions,
  filters,
  children,
  pagination,
  className,
}: ListLayoutProps) {
  return (
    <div className={cn("space-y-6", className)}>
      <div className="flex items-start justify-between">
        <div>
          <Typography variant="h2">{title}</Typography>
          {description && (
            <Typography variant="bodySmall" className="mt-1 text-muted-foreground">
              {description}
            </Typography>
          )}
        </div>
        {actions && <div className="flex items-center gap-3">{actions}</div>}
      </div>

      {filters && (
        <div className="flex items-center gap-3 flex-wrap">{filters}</div>
      )}

      <div>{children}</div>

      {pagination && (
        <div className="flex justify-center pt-4">{pagination}</div>
      )}
    </div>
  );
}
