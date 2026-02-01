"use client";

import { useCallback, useEffect, useState } from "react";
import {
  relationshipsApi,
  charactersApi,
  type CharacterRelationship,
  type Character,
} from "@/lib/api";

export function useRelationshipGraph() {
  const [relationships, setRelationships] = useState<CharacterRelationship[]>([]);
  const [characters, setCharacters] = useState<Character[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [selected, setSelected] = useState<CharacterRelationship | null>(null);

  const fetchData = useCallback(async () => {
    setLoading(true);
    setError(null);
    try {
      const [relRes, charRes] = await Promise.all([
        relationshipsApi.list(1, 100),
        charactersApi.list(1, 100),
      ]);
      setRelationships(relRes.data.data);
      setCharacters(charRes.data.data);
    } catch {
      setError("関係性データの取得に失敗しました");
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  // Build graph data for react-force-graph
  const graphData = {
    nodes: characters.map((c) => ({
      id: c.id.toString(),
      name: c.name,
      role: c.role ?? "",
    })),
    links: relationships.map((r) => ({
      source: r.character_id.toString(),
      target: r.related_character_id.toString(),
      label: r.relationship_type,
      intensity: r.intensity ?? 5,
      relationshipId: r.id,
    })),
  };

  return {
    relationships,
    characters,
    graphData,
    loading,
    error,
    selected,
    setSelected,
    refetch: fetchData,
  };
}
