"use client";

import { useEffect, useCallback } from "react";
import { useParams, useSearchParams, useRouter } from "next/navigation";
import Link from "next/link";
import { Typography } from "@/components/atoms/Typography";
import { ReadingViewer } from "@/features/novels/organisms/ReadingViewer";
import { useNovelsStore } from "@/features/novels/store";
import { useNovelsApi } from "@/features/novels/useApi";

export default function ReadPage() {
  const params = useParams();
  const searchParams = useSearchParams();
  const router = useRouter();

  const novelId = Number(params.id);
  const episodeId = Number(searchParams.get("episode"));

  const { currentNovel, currentEpisode, isLoadingDetail, isLoadingEpisode } =
    useNovelsStore();
  const { fetchNovelDetail, fetchEpisode } = useNovelsApi();

  // 小説詳細を取得（章構造が必要）
  useEffect(() => {
    if (novelId && (!currentNovel || currentNovel.id !== novelId)) {
      fetchNovelDetail(novelId);
    }
  }, [novelId, currentNovel, fetchNovelDetail]);

  // エピソードを取得
  useEffect(() => {
    if (novelId && episodeId) {
      fetchEpisode(novelId, episodeId);
    }
  }, [novelId, episodeId, fetchEpisode]);

  const handleNavigate = useCallback(
    (newEpisodeId: number) => {
      router.push(`/novels/${novelId}/read?episode=${newEpisodeId}`);
      window.scrollTo({ top: 0, behavior: "smooth" });
    },
    [novelId, router],
  );

  return (
    <div className="min-h-screen bg-background">
      {/* 最小限のトップバー */}
      <div className="fixed left-0 right-0 top-0 z-50 flex items-center justify-between bg-background/80 px-4 py-2 backdrop-blur-sm">
        <Link
          href={`/novels/${novelId}`}
          className="text-accent transition-colors hover:text-accent-hover"
        >
          <Typography variant="caption">← 作品詳細</Typography>
        </Link>
        {currentNovel && (
          <Typography variant="caption" className="truncate px-4">
            {currentNovel.title}
          </Typography>
        )}
        <div className="w-16" />
      </div>

      <div className="pt-10">
        <ReadingViewer
          episode={currentEpisode}
          chapters={currentNovel?.chapters ?? []}
          novelId={novelId}
          isLoading={isLoadingDetail || isLoadingEpisode}
          onNavigate={handleNavigate}
        />
      </div>
    </div>
  );
}
