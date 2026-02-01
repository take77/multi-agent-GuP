"use client";

import { use } from "react";
import { useRouter } from "next/navigation";
import { useCharacter } from "@/features/characters/hooks/useCharacters";
import { DetailLayout } from "@/layouts";
import { Button, Badge, Typography } from "@/components/atoms";
import { Card, CardHeader, CardContent } from "@/components/molecules";
import { charactersApi } from "@/lib/api";

export default function CharacterDetailPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const { id } = use(params);
  const router = useRouter();
  const { character, loading, error } = useCharacter(parseInt(id, 10));

  const handleDelete = async () => {
    if (!confirm("このキャラクターを削除しますか？")) return;
    await charactersApi.delete(parseInt(id, 10));
    router.push("/admin/characters");
  };

  if (loading) {
    return <p className="text-muted-foreground py-8 text-center">読み込み中...</p>;
  }
  if (error || !character) {
    return <p className="text-red-400 py-8 text-center">{error ?? "データが見つかりません"}</p>;
  }

  const fields = [
    { label: "年齢", value: character.age ? `${character.age}歳` : null },
    { label: "外見", value: character.appearance },
    { label: "能力", value: character.abilities },
    { label: "性格", value: character.personality },
    { label: "口調", value: character.speech_style },
    { label: "背景", value: character.background },
  ];

  return (
    <DetailLayout
      title={character.name}
      badge={character.role ? <Badge variant="accent">{character.role}</Badge> : undefined}
      onBack={() => router.push("/admin/characters")}
      backLabel="一覧に戻る"
      actions={
        <>
          <Button
            variant="outline"
            onClick={() => router.push(`/admin/characters/${id}/edit`)}
          >
            編集
          </Button>
          <Button variant="ghost" onClick={handleDelete}>
            削除
          </Button>
        </>
      }
    >
      <div className="space-y-4">
        {fields.map(
          (f) =>
            f.value && (
              <Card key={f.label}>
                <CardHeader>
                  <Typography variant="h4">{f.label}</Typography>
                </CardHeader>
                <CardContent>
                  <Typography variant="body" className="whitespace-pre-wrap">
                    {f.value}
                  </Typography>
                </CardContent>
              </Card>
            )
        )}
      </div>
    </DetailLayout>
  );
}
