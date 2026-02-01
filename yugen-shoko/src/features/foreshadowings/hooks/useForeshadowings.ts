"use client";

import { useCallback, useEffect, useState } from "react";
import {
  foreshadowingsApi,
  type Foreshadowing,
  type ForeshadowingStatus,
  type ForeshadowingImportance,
  type ApiMeta,
} from "@/lib/api";

export const STATUS_OPTIONS: { id: ForeshadowingStatus; label: string; color: string }[] = [
  { id: "planted", label: "設置済", color: "accent" },
  { id: "hinted", label: "示唆中", color: "sub" },
  { id: "resolved", label: "回収済", color: "default" },
  { id: "abandoned", label: "破棄", color: "outline" },
];

export const IMPORTANCE_OPTIONS: { id: ForeshadowingImportance; label: string }[] = [
  { id: "minor", label: "軽微" },
  { id: "normal", label: "通常" },
  { id: "major", label: "重要" },
  { id: "critical", label: "最重要" },
];

export function useForeshadowings() {
  const [foreshadowings, setForeshadowings] = useState<Foreshadowing[]>([]);
  const [meta, setMeta] = useState<ApiMeta | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [statusFilter, setStatusFilter] = useState<string | undefined>(undefined);
  const [importanceFilter, setImportanceFilter] = useState<string | undefined>(undefined);
  const [page, setPage] = useState(1);

  const fetchForeshadowings = useCallback(async (s?: string, i?: string, p = 1) => {
    setLoading(true);
    setError(null);
    try {
      const res = await foreshadowingsApi.list(s, i, p);
      setForeshadowings(res.data.data);
      setMeta(res.data.meta ?? null);
    } catch {
      setError("伏線一覧の取得に失敗しました");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchForeshadowings(statusFilter, importanceFilter, page);
  }, [statusFilter, importanceFilter, page, fetchForeshadowings]);

  const handleResolve = async (id: number) => {
    await foreshadowingsApi.resolve(id);
    fetchForeshadowings(statusFilter, importanceFilter, page);
  };

  const handleAbandon = async (id: number) => {
    await foreshadowingsApi.abandon(id);
    fetchForeshadowings(statusFilter, importanceFilter, page);
  };

  return {
    foreshadowings,
    meta,
    loading,
    error,
    statusFilter,
    setStatusFilter: (s: string | undefined) => { setStatusFilter(s); setPage(1); },
    importanceFilter,
    setImportanceFilter: (i: string | undefined) => { setImportanceFilter(i); setPage(1); },
    page,
    setPage,
    handleResolve,
    handleAbandon,
    refetch: () => fetchForeshadowings(statusFilter, importanceFilter, page),
  };
}

export function useForeshadowing(id: number) {
  const [foreshadowing, setForeshadowing] = useState<Foreshadowing | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    foreshadowingsApi
      .get(id)
      .then((res) => { if (!cancelled) setForeshadowing(res.data.data); })
      .catch(() => { if (!cancelled) setError("伏線の取得に失敗しました"); })
      .finally(() => { if (!cancelled) setLoading(false); });
    return () => { cancelled = true; };
  }, [id]);

  return { foreshadowing, loading, error };
}
