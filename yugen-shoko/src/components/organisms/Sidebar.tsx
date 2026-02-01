"use client";

import { cn } from "@/lib/cn";
import type { ReactNode } from "react";

export interface SidebarItem {
  id: string;
  label: string;
  icon?: ReactNode;
  href?: string;
  onClick?: () => void;
  badge?: string;
}

export interface SidebarSection {
  title?: string;
  items: SidebarItem[];
}

export interface SidebarProps {
  sections: SidebarSection[];
  activeId?: string;
  header?: ReactNode;
  footer?: ReactNode;
  collapsed?: boolean;
  className?: string;
}

export function Sidebar({
  sections,
  activeId,
  header,
  footer,
  collapsed = false,
  className,
}: SidebarProps) {
  return (
    <aside
      className={cn(
        "flex flex-col h-full bg-sidebar-bg border-r border-border",
        collapsed ? "w-16" : "w-64",
        "transition-[width] duration-200",
        className
      )}
    >
      {header && (
        <div className="p-4 border-b border-border">{header}</div>
      )}

      <nav className="flex-1 overflow-y-auto py-2">
        {sections.map((section, sIdx) => (
          <div key={sIdx} className="mb-2">
            {section.title && !collapsed && (
              <div className="px-4 py-2 text-xs font-medium text-muted-foreground uppercase tracking-wider">
                {section.title}
              </div>
            )}
            <ul>
              {section.items.map((item) => {
                const isActive = activeId === item.id;
                const Component = item.href ? "a" : "button";
                return (
                  <li key={item.id}>
                    <Component
                      href={item.href}
                      onClick={item.onClick}
                      className={cn(
                        "flex items-center gap-3 w-full px-4 py-2.5 text-sm transition-colors",
                        collapsed && "justify-center px-2",
                        isActive
                          ? "text-sidebar-active bg-sidebar-active/10 font-medium"
                          : "text-foreground hover:bg-sidebar-hover"
                      )}
                    >
                      {item.icon && (
                        <span className="flex-shrink-0 w-5 h-5">{item.icon}</span>
                      )}
                      {!collapsed && (
                        <>
                          <span className="flex-1 text-left">{item.label}</span>
                          {item.badge && (
                            <span className="text-xs bg-accent/15 text-accent rounded-full px-2 py-0.5">
                              {item.badge}
                            </span>
                          )}
                        </>
                      )}
                    </Component>
                  </li>
                );
              })}
            </ul>
          </div>
        ))}
      </nav>

      {footer && (
        <div className="p-4 border-t border-border">{footer}</div>
      )}
    </aside>
  );
}
