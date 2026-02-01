"use client";

import { useRouter } from "next/navigation";
import { useCharacters } from "@/features/characters/hooks/useCharacters";
import { ListLayout } from "@/layouts";
import { Button, Input, Badge } from "@/components/atoms";
import { Card, CardContent } from "@/components/molecules";

export default function CharactersPage() {
  const router = useRouter();
  const { characters, loading, error, search, setSearch, meta, page, setPage } =
    useCharacters();

  return (
    <ListLayout
      title="キャラクター管理"
      description="小説のキャラクターを管理します"
      actions={
        <Button onClick={() => router.push("/admin/characters/new")}>
          新規作成
        </Button>
      }
      filters={
        <Input
          placeholder="名前・役割で検索..."
          value={search}
          onChange={(e) => setSearch(e.target.value)}
          className="max-w-xs"
        />
      }
      pagination={
        meta && meta.total > meta.per_page ? (
          <div className="flex items-center gap-3">
            <Button
              variant="outline"
              size="sm"
              disabled={page <= 1}
              onClick={() => setPage(page - 1)}
            >
              前へ
            </Button>
            <span className="text-sm text-muted-foreground">
              {page} / {Math.ceil(meta.total / meta.per_page)}
            </span>
            <Button
              variant="outline"
              size="sm"
              disabled={page >= Math.ceil(meta.total / meta.per_page)}
              onClick={() => setPage(page + 1)}
            >
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
      {!loading && !error && characters.length === 0 && (
        <p className="text-muted-foreground py-8 text-center">
          キャラクターがまだ登録されていません
        </p>
      )}
      <div className="grid gap-4 sm:grid-cols-2 lg:grid-cols-3">
        {characters.map((c) => (
          <Card
            key={c.id}
            hoverable
            className="cursor-pointer"
            onClick={() => router.push(`/admin/characters/${c.id}`)}
          >
            <CardContent>
              <div className="flex items-start justify-between mb-2">
                <h3 className="font-serif font-semibold text-lg">{c.name}</h3>
                {c.role && <Badge variant="accent">{c.role}</Badge>}
              </div>
              {c.age && (
                <p className="text-sm text-muted-foreground mb-1">
                  {c.age}歳
                </p>
              )}
              {c.personality && (
                <p className="text-sm text-muted-foreground line-clamp-2">
                  {c.personality}
                </p>
              )}
            </CardContent>
          </Card>
        ))}
      </div>
    </ListLayout>
  );
}
