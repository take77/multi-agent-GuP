"use client";

import { usePathname, useRouter } from "next/navigation";
import { AdminLayout } from "@/layouts";
import type { SidebarSection } from "@/components/organisms/Sidebar";

const sidebarSections: SidebarSection[] = [
  {
    title: "コンテキスト管理",
    items: [
      {
        id: "characters",
        label: "キャラクター",
        href: "/admin/characters",
        icon: <CharIcon />,
      },
      {
        id: "world-settings",
        label: "世界観設定",
        href: "/admin/world-settings",
        icon: <GlobeIcon />,
      },
      {
        id: "foreshadowings",
        label: "伏線管理",
        href: "/admin/foreshadowings",
        icon: <LinkIcon />,
      },
      {
        id: "relationships",
        label: "関係性",
        href: "/admin/relationships",
        icon: <GraphIcon />,
      },
    ],
  },
];

function activeIdFromPath(pathname: string): string {
  if (pathname.startsWith("/admin/characters")) return "characters";
  if (pathname.startsWith("/admin/world-settings")) return "world-settings";
  if (pathname.startsWith("/admin/foreshadowings")) return "foreshadowings";
  if (pathname.startsWith("/admin/relationships")) return "relationships";
  return "";
}

export default function AdminLayoutWrapper({
  children,
}: {
  children: React.ReactNode;
}) {
  const pathname = usePathname();

  return (
    <AdminLayout
      sidebarSections={sidebarSections}
      activeSidebarId={activeIdFromPath(pathname)}
      brand="幽玄書庫"
    >
      {children}
    </AdminLayout>
  );
}

// --- Inline icons (simple SVGs) ---

function CharIcon() {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2" />
      <circle cx="9" cy="7" r="4" />
      <path d="M22 21v-2a4 4 0 0 0-3-3.87" />
      <path d="M16 3.13a4 4 0 0 1 0 7.75" />
    </svg>
  );
}

function GlobeIcon() {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="12" cy="12" r="10" />
      <line x1="2" y1="12" x2="22" y2="12" />
      <path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z" />
    </svg>
  );
}

function LinkIcon() {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <path d="M10 13a5 5 0 0 0 7.54.54l3-3a5 5 0 0 0-7.07-7.07l-1.72 1.71" />
      <path d="M14 11a5 5 0 0 0-7.54-.54l-3 3a5 5 0 0 0 7.07 7.07l1.71-1.71" />
    </svg>
  );
}

function GraphIcon() {
  return (
    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
      <circle cx="6" cy="6" r="3" />
      <circle cx="6" cy="18" r="3" />
      <circle cx="18" cy="12" r="3" />
      <line x1="8.6" y1="7.4" x2="15.4" y2="10.6" />
      <line x1="8.6" y1="16.6" x2="15.4" y2="13.4" />
    </svg>
  );
}
