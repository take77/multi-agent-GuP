"use client";

import { use } from "react";
import { useCharacter } from "@/features/characters/hooks/useCharacters";
import { CharacterForm } from "@/features/characters/CharacterForm";

export default function EditCharacterPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = use(params);
  const { character, loading, error } = useCharacter(parseInt(id, 10));

  if (loading) {
    return <p className="text-muted-foreground py-8 text-center">読み込み中...</p>;
  }
  if (error || !character) {
    return <p className="text-red-400 py-8 text-center">{error ?? "データが見つかりません"}</p>;
  }

  return <CharacterForm character={character} />;
}
