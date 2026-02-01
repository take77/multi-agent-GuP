"use client";

import { useCallback, useEffect, useState } from "react";
import { charactersApi, type Character, type ApiMeta } from "@/lib/api";

export function useCharacters() {
  const [characters, setCharacters] = useState<Character[]>([]);
  const [meta, setMeta] = useState<ApiMeta | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState("");

  const fetchCharacters = useCallback(async (p: number) => {
    setLoading(true);
    setError(null);
    try {
      const res = await charactersApi.list(p);
      setCharacters(res.data.data);
      setMeta(res.data.meta ?? null);
    } catch {
      setError("キャラクター一覧の取得に失敗しました");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchCharacters(page);
  }, [page, fetchCharacters]);

  const filtered = search
    ? characters.filter(
        (c) =>
          c.name.toLowerCase().includes(search.toLowerCase()) ||
          c.role?.toLowerCase().includes(search.toLowerCase())
      )
    : characters;

  return {
    characters: filtered,
    allCharacters: characters,
    meta,
    loading,
    error,
    page,
    setPage,
    search,
    setSearch,
    refetch: () => fetchCharacters(page),
  };
}

export function useCharacter(id: number) {
  const [character, setCharacter] = useState<Character | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    setLoading(true);
    charactersApi
      .get(id)
      .then((res) => {
        if (!cancelled) setCharacter(res.data.data);
      })
      .catch(() => {
        if (!cancelled) setError("キャラクターの取得に失敗しました");
      })
      .finally(() => {
        if (!cancelled) setLoading(false);
      });
    return () => { cancelled = true; };
  }, [id]);

  return { character, loading, error };
}
