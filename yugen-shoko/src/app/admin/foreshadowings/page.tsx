"use client";

import { useRouter } from "next/navigation";
import {
  useForeshadowings,
  STATUS_OPTIONS,
  IMPORTANCE_OPTIONS,
} from "@/features/foreshadowings/hooks/useForeshadowings";
import { ListLayout } from "@/layouts";
import { Button, Badge, Select } from "@/components/atoms";
import { DataTable, type Column } from "@/components/organisms";
import type { Foreshadowing } from "@/lib/api";

const statusBadgeVariant: Record<string, "accent" | "sub" | "default" | "outline"> = {
  planted: "accent",
  hinted: "sub",
  resolved: "default",
  abandoned: "outline",
};

const statusLabel: Record<string, string> = Object.fromEntries(
  STATUS_OPTIONS.map((s) => [s.id, s.label])
);

const importanceLabel: Record<string, string> = Object.fromEntries(
  IMPORTANCE_OPTIONS.map((i) => [i.id, i.label])
);

export default function ForeshadowingsPage() {
  const router = useRouter();
  const {
    foreshadowings,
    loading,
    error,
    statusFilter,
    setStatusFilter,
    importanceFilter,
    setImportanceFilter,
    meta,
    page,
    setPage,
    handleResolve,
    handleAbandon,
  } = useForeshadowings();

  const columns: Column<Foreshadowing>[] = [
    { id: "title", header: "タイトル", accessor: (r) => r.title },
    {
      id: "status",
      header: "ステータス",
      accessor: (r) => (
        <Badge variant={statusBadgeVariant[r.status] ?? "default"}>
          {statusLabel[r.status] ?? r.status}
        </Badge>
      ),
      width: "100px",
    },
    {
      id: "importance",
      header: "重要度",
      accessor: (r) => importanceLabel[r.importance] ?? r.importance,
      width: "80px",
    },
    {
      id: "planted",
      header: "設置話",
      accessor: (r) => r.planted_episode_id ?? "-",
      width: "80px",
      align: "center",
    },
    {
      id: "resolved",
      header: "回収話",
      accessor: (r) => r.resolved_episode_id ?? (r.planned_resolution_episode ? `(予定: ${r.planned_resolution_episode})` : "-"),
      width: "120px",
      align: "center",
    },
    {
      id: "actions",
      header: "",
      accessor: (r) => (
        <div className="flex gap-2">
          {r.status !== "resolved" && r.status !== "abandoned" && (
            <>
              <Button
                size="sm"
                variant="outline"
                onClick={(e) => {
                  e.stopPropagation();
                  handleResolve(r.id);
                }}
              >
                回収
              </Button>
              <Button
                size="sm"
                variant="ghost"
                onClick={(e) => {
                  e.stopPropagation();
                  handleAbandon(r.id);
                }}
              >
                破棄
              </Button>
            </>
          )}
        </div>
      ),
      width: "160px",
      align: "right",
    },
  ];

  return (
    <ListLayout
      title="伏線管理"
      description="物語の伏線を管理・追跡します"
      actions={
        <Button onClick={() => router.push("/admin/foreshadowings/new")}>
          新規作成
        </Button>
      }
      filters={
        <>
          <Select
            selectSize="sm"
            className="w-36"
            value={statusFilter ?? ""}
            onChange={(e) => setStatusFilter(e.target.value || undefined)}
          >
            <option value="">全ステータス</option>
            {STATUS_OPTIONS.map((s) => (
              <option key={s.id} value={s.id}>{s.label}</option>
            ))}
          </Select>
          <Select
            selectSize="sm"
            className="w-32"
            value={importanceFilter ?? ""}
            onChange={(e) => setImportanceFilter(e.target.value || undefined)}
          >
            <option value="">全重要度</option>
            {IMPORTANCE_OPTIONS.map((i) => (
              <option key={i.id} value={i.id}>{i.label}</option>
            ))}
          </Select>
        </>
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
          data={foreshadowings}
          keyExtractor={(r) => r.id.toString()}
          emptyMessage="伏線がまだ登録されていません"
          onRowClick={(r) => router.push(`/admin/foreshadowings/${r.id}/edit`)}
        />
      )}
    </ListLayout>
  );
}
