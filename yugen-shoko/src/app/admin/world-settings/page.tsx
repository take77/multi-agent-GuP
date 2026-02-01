"use client";

import { useRouter } from "next/navigation";
import {
  useWorldSettings,
  CATEGORIES,
} from "@/features/world-settings/hooks/useWorldSettings";
import { ListLayout } from "@/layouts";
import { Button, Badge } from "@/components/atoms";
import { TabGroup, Card, CardHeader, CardContent, type Tab } from "@/components/molecules";
import { DataTable, type Column } from "@/components/organisms";
import type { WorldSetting } from "@/lib/api";

const categoryLabel: Record<string, string> = Object.fromEntries(
  CATEGORIES.map((c) => [c.id, c.label])
);

const columns: Column<WorldSetting>[] = [
  { id: "title", header: "タイトル", accessor: (r) => r.title },
  {
    id: "category",
    header: "カテゴリ",
    accessor: (r) => (
      <Badge variant="accent">{categoryLabel[r.category] ?? r.category}</Badge>
    ),
    width: "120px",
  },
  {
    id: "description",
    header: "説明",
    accessor: (r) => (
      <span className="line-clamp-2 text-sm text-muted-foreground">
        {r.description ?? ""}
      </span>
    ),
  },
];

export default function WorldSettingsPage() {
  const router = useRouter();
  const { settings, loading, error, category, setCategory, meta, page, setPage } =
    useWorldSettings();

  const tabs: Tab[] = [
    { id: "all", label: "すべて", content: null },
    ...CATEGORIES.map((c) => ({ id: c.id, label: c.label, content: null })),
  ];

  const handleTabChange = (tabId: string) => {
    setCategory(tabId === "all" ? undefined : tabId);
  };

  return (
    <ListLayout
      title="世界観設定"
      description="小説の世界観設定を管理します"
      actions={
        <Button onClick={() => router.push("/admin/world-settings/new")}>
          新規作成
        </Button>
      }
      filters={
        <TabGroup
          tabs={tabs}
          defaultTab="all"
          onChange={handleTabChange}
          className="w-full"
        />
      }
      pagination={
        meta && meta.total > meta.per_page ? (
          <div className="flex items-center gap-3">
            <Button variant="outline" size="sm" disabled={page <= 1} onClick={() => setPage(page - 1)}>
              前へ
            </Button>
            <span className="text-sm text-muted-foreground">
              {page} / {Math.ceil(meta.total / meta.per_page)}
            </span>
            <Button variant="outline" size="sm" disabled={page >= Math.ceil(meta.total / meta.per_page)} onClick={() => setPage(page + 1)}>
              次へ
            </Button>
          </div>
        ) : null
      }
    >
      {loading && (
        <p className="text-muted-foreground py-8 text-center">読み込み中...</p>
      )}
      {error && (
        <p className="text-red-400 py-8 text-center">{error}</p>
      )}
      {!loading && !error && (
        <DataTable
          columns={columns}
          data={settings}
          keyExtractor={(r) => r.id.toString()}
          emptyMessage="世界観設定がまだ登録されていません"
          onRowClick={(r) => router.push(`/admin/world-settings/${r.id}/edit`)}
        />
      )}
    </ListLayout>
  );
}
