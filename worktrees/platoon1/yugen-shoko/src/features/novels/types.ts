import type { Genre } from "./constants";

export interface Novel {
  id: number;
  title: string;
  author_name: string;
  synopsis: string;
  genre: Genre;
  cover_image_url: string | null;
  episode_count: number;
  like_count: number;
  created_at: string;
  updated_at: string;
}

export interface Chapter {
  id: number;
  title: string;
  number: number;
  episodes: Episode[];
}

export interface Episode {
  id: number;
  title: string;
  number: number;
  chapter_id: number;
  content: string;
  word_count: number;
  published_at: string;
}

export interface NovelDetail extends Novel {
  chapters: Chapter[];
  description: string;
}

export interface PaginationMeta {
  current_page: number;
  total_pages: number;
  total_count: number;
  per_page: number;
}

export interface NovelsResponse {
  novels: Novel[];
  meta: PaginationMeta;
}

export interface ReadingProgress {
  novelId: number;
  episodeId: number;
  scrollPosition: number;
  updatedAt: string;
}

export interface Bookmark {
  novelId: number;
  episodeId: number;
  position: number;
  createdAt: string;
}
