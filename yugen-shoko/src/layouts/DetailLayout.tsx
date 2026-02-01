import { cn } from "@/lib/cn";
import { Typography } from "@/components/atoms/Typography";
import { Button } from "@/components/atoms/Button";
import type { ReactNode } from "react";

export interface DetailLayoutProps {
  title: string;
  subtitle?: string;
  badge?: ReactNode;
  actions?: ReactNode;
  backLabel?: string;
  onBack?: () => void;
  children: ReactNode;
  sidebar?: ReactNode;
  className?: string;
}

export function DetailLayout({
  title,
  subtitle,
  badge,
  actions,
  backLabel = "戻る",
  onBack,
  children,
  sidebar,
  className,
}: DetailLayoutProps) {
  return (
    <div className={cn("space-y-6", className)}>
      {onBack && (
        <Button variant="ghost" size="sm" onClick={onBack}>
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round" className="mr-1">
            <path d="m15 18-6-6 6-6" />
          </svg>
          {backLabel}
        </Button>
      )}

      <div className="flex items-start justify-between">
        <div className="flex items-center gap-3">
          <Typography variant="h2">{title}</Typography>
          {badge}
        </div>
        {actions && <div className="flex items-center gap-3">{actions}</div>}
      </div>

      {subtitle && (
        <Typography variant="bodySmall" className="text-muted-foreground">
          {subtitle}
        </Typography>
      )}

      <div className={cn(sidebar ? "grid grid-cols-1 lg:grid-cols-3 gap-6" : "")}>
        <div className={cn(sidebar ? "lg:col-span-2" : "")}>
          {children}
        </div>
        {sidebar && (
          <aside className="space-y-4">{sidebar}</aside>
        )}
      </div>
    </div>
  );
}
