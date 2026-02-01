"use client";

import { use } from "react";
import { useForeshadowing } from "@/features/foreshadowings/hooks/useForeshadowings";
import { ForeshadowingForm } from "@/features/foreshadowings/ForeshadowingForm";

export default function EditForeshadowingPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = use(params);
  const { foreshadowing, loading, error } = useForeshadowing(parseInt(id, 10));

  if (loading) {
    return <p className="text-muted-foreground py-8 text-center">読み込み中...</p>;
  }
  if (error || !foreshadowing) {
    return <p className="text-red-400 py-8 text-center">{error ?? "データが見つかりません"}</p>;
  }

  return <ForeshadowingForm foreshadowing={foreshadowing} />;
}
