"use client";

import { cn } from "@/lib/cn";
import { ThemeToggle } from "@/components/atoms/ThemeToggle";
import type { ReactNode } from "react";

export interface NavItem {
  id: string;
  label: string;
  href?: string;
  onClick?: () => void;
}

export interface NavigationProps {
  brand?: ReactNode;
  items?: NavItem[];
  activeId?: string;
  actions?: ReactNode;
  className?: string;
}

export function Navigation({
  brand,
  items = [],
  activeId,
  actions,
  className,
}: NavigationProps) {
  return (
    <header
      className={cn(
        "flex items-center justify-between px-6 h-14",
        "bg-card border-b border-border",
        className
      )}
    >
      <div className="flex items-center gap-6">
        {brand && (
          <div className="font-serif font-bold text-lg tracking-wide">
            {brand}
          </div>
        )}
        {items.length > 0 && (
          <nav className="hidden md:flex items-center gap-1">
            {items.map((item) => {
              const Component = item.href ? "a" : "button";
              return (
                <Component
                  key={item.id}
                  href={item.href}
                  onClick={item.onClick}
                  className={cn(
                    "px-3 py-1.5 text-sm rounded-md transition-colors",
                    activeId === item.id
                      ? "text-accent font-medium"
                      : "text-muted-foreground hover:text-foreground hover:bg-muted"
                  )}
                >
                  {item.label}
                </Component>
              );
            })}
          </nav>
        )}
      </div>

      <div className="flex items-center gap-3">
        {actions}
        <ThemeToggle />
      </div>
    </header>
  );
}
