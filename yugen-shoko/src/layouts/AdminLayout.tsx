"use client";

import { cn } from "@/lib/cn";
import { Sidebar, type SidebarSection } from "@/components/organisms/Sidebar";
import { Navigation, type NavItem } from "@/components/organisms/Navigation";
import { useState, type ReactNode } from "react";

export interface AdminLayoutProps {
  children: ReactNode;
  sidebarSections: SidebarSection[];
  activeSidebarId?: string;
  navItems?: NavItem[];
  activeNavId?: string;
  brand?: ReactNode;
  navActions?: ReactNode;
  sidebarHeader?: ReactNode;
  sidebarFooter?: ReactNode;
  className?: string;
}

export function AdminLayout({
  children,
  sidebarSections,
  activeSidebarId,
  navItems,
  activeNavId,
  brand,
  navActions,
  sidebarHeader,
  sidebarFooter,
  className,
}: AdminLayoutProps) {
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);

  return (
    <div className={cn("flex flex-col h-screen", className)}>
      <Navigation
        brand={brand}
        items={navItems}
        activeId={activeNavId}
        actions={navActions}
      />
      <div className="flex flex-1 overflow-hidden">
        <Sidebar
          sections={sidebarSections}
          activeId={activeSidebarId}
          collapsed={sidebarCollapsed}
          header={sidebarHeader}
          footer={
            <button
              onClick={() => setSidebarCollapsed((c) => !c)}
              className="text-xs text-muted-foreground hover:text-foreground transition-colors"
              aria-label={sidebarCollapsed ? "サイドバーを展開" : "サイドバーを折りたたむ"}
            >
              {sidebarCollapsed ? ">>" : "<<"}
            </button>
          }
        />
        <main className="flex-1 overflow-y-auto p-6 bg-background">
          {children}
        </main>
      </div>
    </div>
  );
}
