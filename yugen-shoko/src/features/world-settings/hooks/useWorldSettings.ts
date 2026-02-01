"use client";

import { useCallback, useEffect, useState } from "react";
import { worldSettingsApi, type WorldSetting, type ApiMeta } from "@/lib/api";

export const CATEGORIES = [
  { id: "geography", label: "地理" },
  { id: "magic", label: "魔法体系" },
  { id: "culture", label: "文化" },
  { id: "history", label: "歴史" },
  { id: "politics", label: "政治" },
] as const;

export function useWorldSettings() {
  const [settings, setSettings] = useState<WorldSetting[]>([]);
  const [meta, setMeta] = useState<ApiMeta | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [category, setCategory] = useState<string | undefined>(undefined);
  const [page, setPage] = useState(1);

  const fetchSettings = useCallback(async (cat?: string, p = 1) => {
    setLoading(true);
    setError(null);
    try {
      const res = await worldSettingsApi.list(cat, p);
      setSettings(res.data.data);
      setMeta(res.data.meta ?? null);
    } catch {
      setError("世界観設定の取得に失敗しました");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchSettings(category, page);
  }, [category, page, fetchSettings]);

  return {
    settings,
    meta,
    loading,
    error,
    category,
    setCategory: (c: string | undefined) => { setCategory(c); setPage(1); },
    page,
    setPage,
    refetch: () => fetchSettings(category, page),
  };
}

export function useWorldSetting(id: number) {
  const [setting, setSetting] = useState<WorldSetting | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    worldSettingsApi
      .get(id)
      .then((res) => { if (!cancelled) setSetting(res.data.data); })
      .catch(() => { if (!cancelled) setError("世界観設定の取得に失敗しました"); })
      .finally(() => { if (!cancelled) setLoading(false); });
    return () => { cancelled = true; };
  }, [id]);

  return { setting, loading, error };
}
