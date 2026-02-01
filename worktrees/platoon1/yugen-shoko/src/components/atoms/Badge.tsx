import { cn } from "@/lib/cn";
import type { HTMLAttributes } from "react";

export type BadgeVariant = "default" | "accent" | "sub" | "outline";

export interface BadgeProps extends HTMLAttributes<HTMLSpanElement> {
  variant?: BadgeVariant;
}

const variantStyles: Record<BadgeVariant, string> = {
  default: "bg-badge-bg text-badge-foreground",
  accent: "bg-accent/15 text-accent",
  sub: "bg-sub/15 text-sub",
  outline: "bg-transparent text-foreground border border-border",
};

export function Badge({
  variant = "default",
  className,
  children,
  ...props
}: BadgeProps) {
  return (
    <span
      className={cn(
        "inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium",
        variantStyles[variant],
        className
      )}
      {...props}
    >
      {children}
    </span>
  );
}
