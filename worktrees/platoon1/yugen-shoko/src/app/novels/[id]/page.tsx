"use client";

import { useEffect } from "react";
import { useParams } from "next/navigation";
import Link from "next/link";
import { Typography } from "@/components/atoms/Typography";
import { ThemeToggle } from "@/components/atoms/ThemeToggle";
import { NovelDetailView } from "@/features/novels/organisms/NovelDetailView";
import { useNovelsStore } from "@/features/novels/store";
import { useNovelsApi } from "@/features/novels/useApi";

export default function NovelDetailPage() {
  const params = useParams();
  const id = Number(params.id);
  const { currentNovel, isLoadingDetail } = useNovelsStore();
  const { fetchNovelDetail } = useNovelsApi();

  useEffect(() => {
    if (id) fetchNovelDetail(id);
  }, [id, fetchNovelDetail]);

  return (
    <main className="min-h-screen bg-background px-4 py-8 sm:px-8 lg:px-16">
      <div className="mx-auto max-w-4xl">
        <header className="mb-8 flex items-center justify-between">
          <Link href="/novels" className="text-accent hover:text-accent-hover transition-colors">
            <Typography variant="bodySmall">← 一覧に戻る</Typography>
          </Link>
          <ThemeToggle />
        </header>
        <NovelDetailView novel={currentNovel} isLoading={isLoadingDetail} />
      </div>
    </main>
  );
}
