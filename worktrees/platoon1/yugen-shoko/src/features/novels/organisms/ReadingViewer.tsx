"use client";

import { useRef, useCallback, useMemo } from "react";
import { cn } from "@/lib/cn";
import { Typography } from "@/components/atoms/Typography";
import { Button } from "@/components/atoms/Button";
import { useSwipe } from "../hooks/useSwipe";
import { usePinch } from "../hooks/usePinch";
import { useBookmark } from "../hooks/useBookmark";
import { useNovelsStore } from "../store";
import type { Episode, Chapter } from "../types";

interface ReadingViewerProps {
  episode: Episode | null;
  chapters: Chapter[];
  novelId: number;
  isLoading: boolean;
  onNavigate: (episodeId: number) => void;
}

export function ReadingViewer({
  episode,
  chapters,
  novelId,
  isLoading,
  onNavigate,
}: ReadingViewerProps) {
  const containerRef = useRef<HTMLDivElement>(null);
  const { fontSize, setFontSize } = useNovelsStore();

  // 全エピソードのフラットリスト
  const allEpisodes = useMemo(
    () => chapters.flatMap((ch) => ch.episodes),
    [chapters],
  );

  const currentIndex = allEpisodes.findIndex((ep) => ep.id === episode?.id);
  const prevEpisode = currentIndex > 0 ? allEpisodes[currentIndex - 1] : null;
  const nextEpisode =
    currentIndex < allEpisodes.length - 1 ? allEpisodes[currentIndex + 1] : null;

  const { isBookmarked, toggle: toggleBookmark } = useBookmark(
    novelId,
    episode?.id ?? 0,
  );

  const handlePrev = useCallback(() => {
    if (prevEpisode) onNavigate(prevEpisode.id);
  }, [prevEpisode, onNavigate]);

  const handleNext = useCallback(() => {
    if (nextEpisode) onNavigate(nextEpisode.id);
  }, [nextEpisode, onNavigate]);

  const handleDoubleTap = useCallback(() => {
    toggleBookmark(window.scrollY);
  }, [toggleBookmark]);

  // スワイプ: 横で前後話移動
  useSwipe(
    {
      onSwipeLeft: handleNext,
      onSwipeRight: handlePrev,
      onDoubleTap: handleDoubleTap,
    },
    containerRef,
  );

  // ピンチ: 文字サイズ変更
  usePinch(
    {
      onPinchOut: () => setFontSize(fontSize + 2),
      onPinchIn: () => setFontSize(fontSize - 2),
    },
    containerRef,
  );

  if (isLoading) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <div className="h-8 w-8 animate-spin rounded-full border-2 border-accent border-t-transparent" />
      </div>
    );
  }

  if (!episode) {
    return (
      <div className="flex min-h-screen items-center justify-center">
        <Typography variant="body" className="text-muted-foreground">
          エピソードが見つかりませんでした
        </Typography>
      </div>
    );
  }

  return (
    <div ref={containerRef} className="relative min-h-screen select-none">
      {/* しおりインジケーター */}
      {isBookmarked && (
        <div className="fixed right-4 top-20 z-40 rounded-full bg-accent px-3 py-1 text-xs text-white">
          しおり済
        </div>
      )}

      {/* 読書ヘッダー（スクロールで半透明化） */}
      <header className="sticky top-0 z-30 border-b border-border bg-background/90 px-4 py-3 backdrop-blur-sm">
        <div className="mx-auto flex max-w-2xl items-center justify-between">
          <Typography variant="caption" className="truncate">
            第{episode.number}話 {episode.title}
          </Typography>
          <div className="flex items-center gap-2">
            <button
              onClick={() => setFontSize(fontSize - 2)}
              className="rounded-md px-2 py-1 text-xs text-muted-foreground hover:bg-muted"
              aria-label="文字を小さく"
            >
              A-
            </button>
            <span className="text-xs text-muted-foreground">{fontSize}</span>
            <button
              onClick={() => setFontSize(fontSize + 2)}
              className="rounded-md px-2 py-1 text-xs text-muted-foreground hover:bg-muted"
              aria-label="文字を大きく"
            >
              A+
            </button>
          </div>
        </div>
      </header>

      {/* 本文 */}
      <article
        className="mx-auto max-w-2xl px-4 py-8"
        style={{ fontSize: `${fontSize}px`, lineHeight: 2 }}
      >
        <Typography variant="h2" className="mb-8 text-center">
          {episode.title}
        </Typography>
        <div
          className={cn(
            "whitespace-pre-wrap font-sans leading-[2]",
            "tracking-wide",
          )}
        >
          {episode.content}
        </div>
      </article>

      {/* ナビゲーションフッター */}
      <footer className="border-t border-border px-4 py-6">
        <div className="mx-auto flex max-w-2xl items-center justify-between">
          {prevEpisode ? (
            <Button variant="outline" size="sm" onClick={handlePrev}>
              ← 前話
            </Button>
          ) : (
            <div />
          )}
          <button
            onClick={() => toggleBookmark(window.scrollY)}
            className={cn(
              "rounded-full px-4 py-2 text-sm transition-colors",
              isBookmarked
                ? "bg-accent text-white"
                : "border border-border text-muted-foreground hover:bg-muted",
            )}
          >
            {isBookmarked ? "しおりを外す" : "しおりを挟む"}
          </button>
          {nextEpisode ? (
            <Button variant="outline" size="sm" onClick={handleNext}>
              次話 →
            </Button>
          ) : (
            <div />
          )}
        </div>
      </footer>
    </div>
  );
}
