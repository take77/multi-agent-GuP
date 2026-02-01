"use client";

import Link from "next/link";
import { Typography } from "@/components/atoms/Typography";
import { Button } from "@/components/atoms/Button";
import { GenreBadge } from "../atoms/GenreBadge";
import { ChapterList } from "./ChapterList";
import { LoadingSpinner } from "../atoms/LoadingSpinner";
import type { NovelDetail } from "../types";

interface NovelDetailViewProps {
  novel: NovelDetail | null;
  isLoading: boolean;
}

export function NovelDetailView({ novel, isLoading }: NovelDetailViewProps) {
  if (isLoading) return <LoadingSpinner />;
  if (!novel) return null;

  const firstEpisode = novel.chapters[0]?.episodes[0];

  return (
    <div className="space-y-8">
      {/* ヘッダー */}
      <div className="flex flex-col gap-6 sm:flex-row">
        {/* カバー画像 */}
        <div className="w-full shrink-0 sm:w-48">
          {novel.cover_image_url ? (
            <img
              src={novel.cover_image_url}
              alt={novel.title}
              className="aspect-[3/4] w-full rounded-xl object-cover"
            />
          ) : (
            <div className="flex aspect-[3/4] w-full items-center justify-center rounded-xl bg-muted">
              <Typography variant="h1" className="text-muted-foreground">
                {novel.title.charAt(0)}
              </Typography>
            </div>
          )}
        </div>

        {/* メタ情報 */}
        <div className="flex flex-col gap-4">
          <div>
            <Typography variant="h1">{novel.title}</Typography>
            <Typography variant="bodySmall" className="mt-1 text-muted-foreground">
              {novel.author_name}
            </Typography>
          </div>
          <GenreBadge genre={novel.genre} />
          <Typography variant="body">{novel.description || novel.synopsis}</Typography>
          <div className="flex items-center gap-4">
            <Typography variant="caption">
              全{novel.episode_count}話
            </Typography>
            <Typography variant="caption">
              {novel.like_count.toLocaleString()} いいね
            </Typography>
          </div>
          {firstEpisode && (
            <Link href={`/novels/${novel.id}/read?episode=${firstEpisode.id}`}>
              <Button size="lg">読み始める</Button>
            </Link>
          )}
        </div>
      </div>

      {/* エピソード一覧 */}
      <section>
        <Typography variant="h2" className="mb-4">
          エピソード
        </Typography>
        <ChapterList chapters={novel.chapters} novelId={novel.id} />
      </section>
    </div>
  );
}
