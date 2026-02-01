"use client";

import { use } from "react";
import { useWorldSetting } from "@/features/world-settings/hooks/useWorldSettings";
import { WorldSettingForm } from "@/features/world-settings/WorldSettingForm";

export default function EditWorldSettingPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = use(params);
  const { setting, loading, error } = useWorldSetting(parseInt(id, 10));

  if (loading) {
    return <p className="text-muted-foreground py-8 text-center">読み込み中...</p>;
  }
  if (error || !setting) {
    return <p className="text-red-400 py-8 text-center">{error ?? "データが見つかりません"}</p>;
  }

  return <WorldSettingForm setting={setting} />;
}
