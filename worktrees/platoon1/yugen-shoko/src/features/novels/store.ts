import { create } from "zustand";
import type { Novel, NovelDetail, Episode, PaginationMeta, Bookmark } from "./types";
import type { Genre } from "./constants";

interface NovelsState {
  // 一覧
  novels: Novel[];
  pagination: PaginationMeta | null;
  selectedGenre: Genre | null;
  isLoadingList: boolean;

  // 詳細
  currentNovel: NovelDetail | null;
  isLoadingDetail: boolean;

  // 読書
  currentEpisode: Episode | null;
  fontSize: number;
  bookmarks: Bookmark[];
  isLoadingEpisode: boolean;

  // アクション: 一覧
  setNovels: (novels: Novel[], meta: PaginationMeta) => void;
  setSelectedGenre: (genre: Genre | null) => void;
  setLoadingList: (loading: boolean) => void;

  // アクション: 詳細
  setCurrentNovel: (novel: NovelDetail | null) => void;
  setLoadingDetail: (loading: boolean) => void;

  // アクション: 読書
  setCurrentEpisode: (episode: Episode | null) => void;
  setFontSize: (size: number) => void;
  toggleBookmark: (novelId: number, episodeId: number, position: number) => void;
  setLoadingEpisode: (loading: boolean) => void;
}

export const useNovelsStore = create<NovelsState>((set, get) => ({
  // 初期値
  novels: [],
  pagination: null,
  selectedGenre: null,
  isLoadingList: false,
  currentNovel: null,
  isLoadingDetail: false,
  currentEpisode: null,
  fontSize: 16,
  bookmarks: loadBookmarks(),
  isLoadingEpisode: false,

  // 一覧
  setNovels: (novels, meta) => set({ novels, pagination: meta }),
  setSelectedGenre: (genre) => set({ selectedGenre: genre }),
  setLoadingList: (loading) => set({ isLoadingList: loading }),

  // 詳細
  setCurrentNovel: (novel) => set({ currentNovel: novel }),
  setLoadingDetail: (loading) => set({ isLoadingDetail: loading }),

  // 読書
  setCurrentEpisode: (episode) => set({ currentEpisode: episode }),
  setFontSize: (size) => set({ fontSize: Math.max(12, Math.min(28, size)) }),
  toggleBookmark: (novelId, episodeId, position) => {
    const { bookmarks } = get();
    const existing = bookmarks.findIndex(
      (b) => b.novelId === novelId && b.episodeId === episodeId,
    );
    let updated: Bookmark[];
    if (existing >= 0) {
      updated = bookmarks.filter((_, i) => i !== existing);
    } else {
      updated = [
        ...bookmarks,
        { novelId, episodeId, position, createdAt: new Date().toISOString() },
      ];
    }
    set({ bookmarks: updated });
    saveBookmarks(updated);
  },
  setLoadingEpisode: (loading) => set({ isLoadingEpisode: loading }),
}));

function loadBookmarks(): Bookmark[] {
  if (typeof window === "undefined") return [];
  try {
    const raw = localStorage.getItem("yugen-bookmarks");
    return raw ? JSON.parse(raw) : [];
  } catch {
    return [];
  }
}

function saveBookmarks(bookmarks: Bookmark[]): void {
  localStorage.setItem("yugen-bookmarks", JSON.stringify(bookmarks));
}
