import axios from "axios";

const API_BASE = process.env.NEXT_PUBLIC_API_URL ?? "http://localhost:4001";

export const apiClient = axios.create({
  baseURL: `${API_BASE}/api/v1`,
  headers: { "Content-Type": "application/json" },
});

// --- Response Types ---

export interface ApiMeta {
  total: number;
  page: number;
  per_page: number;
}

export interface ApiSuccess<T> {
  success: true;
  data: T;
  meta?: ApiMeta;
}

export interface ApiError {
  success: false;
  error: {
    code: string;
    message: string;
    details?: { field: string; message: string }[];
  };
}

// --- Domain Types ---

export interface Character {
  id: number;
  novel_id: number;
  name: string;
  age: number | null;
  appearance: string | null;
  abilities: string | null;
  personality: string | null;
  speech_style: string | null;
  background: string | null;
  role: string | null;
}

export interface WorldSetting {
  id: number;
  novel_id: number;
  category: "geography" | "magic" | "culture" | "history" | "politics";
  title: string;
  description: string | null;
  details: Record<string, unknown>;
}

export interface CharacterRelationship {
  id: number;
  novel_id: number;
  character_id: number;
  related_character_id: number;
  relationship_type: string;
  description: string | null;
  intensity: number | null;
  character: { id: number; name: string };
  related_character: { id: number; name: string };
}

export type ForeshadowingStatus = "planted" | "hinted" | "resolved" | "abandoned";
export type ForeshadowingImportance = "minor" | "normal" | "major" | "critical";

export interface Foreshadowing {
  id: number;
  novel_id: number;
  title: string;
  description: string | null;
  planted_episode_id: number | null;
  resolved_episode_id: number | null;
  planned_resolution_episode: number | null;
  status: ForeshadowingStatus;
  importance: ForeshadowingImportance;
}

// --- API Functions ---

const NOVEL_ID = 1; // TODO: dynamic novel selection

function novelPath(path: string) {
  return `/novels/${NOVEL_ID}${path}`;
}

// Characters
export const charactersApi = {
  list: (page = 1, perPage = 20) =>
    apiClient.get<ApiSuccess<Character[]>>(novelPath("/characters"), {
      params: { page, per_page: perPage },
    }),
  get: (id: number) =>
    apiClient.get<ApiSuccess<Character>>(novelPath(`/characters/${id}`)),
  create: (data: Partial<Character>) =>
    apiClient.post<ApiSuccess<Character>>(novelPath("/characters"), { character: data }),
  update: (id: number, data: Partial<Character>) =>
    apiClient.put<ApiSuccess<Character>>(novelPath(`/characters/${id}`), { character: data }),
  delete: (id: number) =>
    apiClient.delete(novelPath(`/characters/${id}`)),
};

// World Settings
export const worldSettingsApi = {
  list: (category?: string, page = 1, perPage = 20) =>
    apiClient.get<ApiSuccess<WorldSetting[]>>(novelPath("/world_settings"), {
      params: { category, page, per_page: perPage },
    }),
  get: (id: number) =>
    apiClient.get<ApiSuccess<WorldSetting>>(novelPath(`/world_settings/${id}`)),
  create: (data: Partial<WorldSetting>) =>
    apiClient.post<ApiSuccess<WorldSetting>>(novelPath("/world_settings"), { world_setting: data }),
  update: (id: number, data: Partial<WorldSetting>) =>
    apiClient.put<ApiSuccess<WorldSetting>>(novelPath(`/world_settings/${id}`), { world_setting: data }),
  delete: (id: number) =>
    apiClient.delete(novelPath(`/world_settings/${id}`)),
};

// Character Relationships
export const relationshipsApi = {
  list: (page = 1, perPage = 100) =>
    apiClient.get<ApiSuccess<CharacterRelationship[]>>(novelPath("/character_relationships"), {
      params: { page, per_page: perPage },
    }),
  get: (id: number) =>
    apiClient.get<ApiSuccess<CharacterRelationship>>(novelPath(`/character_relationships/${id}`)),
  create: (data: Partial<CharacterRelationship>) =>
    apiClient.post<ApiSuccess<CharacterRelationship>>(novelPath("/character_relationships"), { character_relationship: data }),
  update: (id: number, data: Partial<CharacterRelationship>) =>
    apiClient.put<ApiSuccess<CharacterRelationship>>(novelPath(`/character_relationships/${id}`), { character_relationship: data }),
  delete: (id: number) =>
    apiClient.delete(novelPath(`/character_relationships/${id}`)),
};

// Foreshadowings
export const foreshadowingsApi = {
  list: (status?: string, importance?: string, page = 1, perPage = 20) =>
    apiClient.get<ApiSuccess<Foreshadowing[]>>(novelPath("/foreshadowings"), {
      params: { status, importance, page, per_page: perPage },
    }),
  get: (id: number) =>
    apiClient.get<ApiSuccess<Foreshadowing>>(novelPath(`/foreshadowings/${id}`)),
  create: (data: Partial<Foreshadowing>) =>
    apiClient.post<ApiSuccess<Foreshadowing>>(novelPath("/foreshadowings"), { foreshadowing: data }),
  update: (id: number, data: Partial<Foreshadowing>) =>
    apiClient.put<ApiSuccess<Foreshadowing>>(novelPath(`/foreshadowings/${id}`), { foreshadowing: data }),
  delete: (id: number) =>
    apiClient.delete(novelPath(`/foreshadowings/${id}`)),
  resolve: (id: number, resolvedEpisodeId?: number) =>
    apiClient.patch<ApiSuccess<Foreshadowing>>(novelPath(`/foreshadowings/${id}/resolve`), {
      resolved_episode_id: resolvedEpisodeId,
    }),
  abandon: (id: number) =>
    apiClient.patch<ApiSuccess<Foreshadowing>>(novelPath(`/foreshadowings/${id}/abandon`)),
};
