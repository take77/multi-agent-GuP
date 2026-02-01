import { useCallback } from "react";
import apiClient from "@/libs/apiClient";
import { useNovelsStore } from "./store";
import type { NovelsResponse, NovelDetail, Episode } from "./types";
import type { Genre } from "./constants";
import { PER_PAGE } from "./constants";

export function useNovelsApi() {
  const {
    setNovels,
    setLoadingList,
    setCurrentNovel,
    setLoadingDetail,
    setCurrentEpisode,
    setLoadingEpisode,
  } = useNovelsStore();

  const fetchNovels = useCallback(
    async (page: number = 1, genre?: Genre | null) => {
      setLoadingList(true);
      try {
        const params: Record<string, string | number> = {
          page,
          per_page: PER_PAGE,
        };
        if (genre) params.genre = genre;
        const { data } = await apiClient.get<NovelsResponse>("/api/v1/novels", {
          params,
        });
        setNovels(data.novels, data.meta);
      } finally {
        setLoadingList(false);
      }
    },
    [setNovels, setLoadingList],
  );

  const fetchNovelDetail = useCallback(
    async (id: number) => {
      setLoadingDetail(true);
      try {
        const { data } = await apiClient.get<NovelDetail>(
          `/api/v1/novels/${id}`,
        );
        setCurrentNovel(data);
      } finally {
        setLoadingDetail(false);
      }
    },
    [setCurrentNovel, setLoadingDetail],
  );

  const fetchEpisode = useCallback(
    async (novelId: number, episodeId: number) => {
      setLoadingEpisode(true);
      try {
        const { data } = await apiClient.get<Episode>(
          `/api/v1/novels/${novelId}/episodes/${episodeId}`,
        );
        setCurrentEpisode(data);
      } finally {
        setLoadingEpisode(false);
      }
    },
    [setCurrentEpisode, setLoadingEpisode],
  );

  return { fetchNovels, fetchNovelDetail, fetchEpisode };
}
