"use client";

import { useEffect, useCallback } from "react";
import { Typography } from "@/components/atoms/Typography";
import { ThemeToggle } from "@/components/atoms/ThemeToggle";
import { GenreFilter } from "./molecules/GenreFilter";
import { NovelGrid } from "./organisms/NovelGrid";
import { Pagination } from "./molecules/Pagination";
import { useNovelsStore } from "./store";
import { useNovelsApi } from "./useApi";
import type { Genre } from "./constants";

export default function NovelsPage() {
  const {
    novels,
    pagination,
    selectedGenre,
    isLoadingList,
    setSelectedGenre,
  } = useNovelsStore();
  const { fetchNovels } = useNovelsApi();

  useEffect(() => {
    fetchNovels(1, selectedGenre);
  }, [fetchNovels, selectedGenre]);

  const handleGenreChange = useCallback(
    (genre: Genre | null) => {
      setSelectedGenre(genre);
    },
    [setSelectedGenre],
  );

  const handlePageChange = useCallback(
    (page: number) => {
      fetchNovels(page, selectedGenre);
      window.scrollTo({ top: 0, behavior: "smooth" });
    },
    [fetchNovels, selectedGenre],
  );

  return (
    <main className="min-h-screen bg-background px-4 py-8 sm:px-8 lg:px-16">
      <div className="mx-auto max-w-7xl">
        {/* ヘッダー */}
        <header className="mb-8 flex items-center justify-between">
          <div>
            <Typography variant="h1">幽玄書庫</Typography>
            <Typography variant="bodySmall" className="mt-1 text-muted-foreground">
              物語の世界へ
            </Typography>
          </div>
          <ThemeToggle />
        </header>

        {/* ジャンルフィルター */}
        <section className="mb-8">
          <GenreFilter selected={selectedGenre} onSelect={handleGenreChange} />
        </section>

        {/* 小説一覧 */}
        <NovelGrid novels={novels} isLoading={isLoadingList} />

        {/* ページネーション */}
        {pagination && (
          <Pagination meta={pagination} onPageChange={handlePageChange} />
        )}
      </div>
    </main>
  );
}
