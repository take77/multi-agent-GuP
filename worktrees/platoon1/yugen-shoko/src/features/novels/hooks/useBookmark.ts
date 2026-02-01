"use client";

import { useCallback } from "react";
import { useNovelsStore } from "../store";

export function useBookmark(novelId: number, episodeId: number) {
  const { bookmarks, toggleBookmark } = useNovelsStore();

  const isBookmarked = bookmarks.some(
    (b) => b.novelId === novelId && b.episodeId === episodeId,
  );

  const toggle = useCallback(
    (position: number = 0) => {
      toggleBookmark(novelId, episodeId, position);
    },
    [novelId, episodeId, toggleBookmark],
  );

  return { isBookmarked, toggle };
}
