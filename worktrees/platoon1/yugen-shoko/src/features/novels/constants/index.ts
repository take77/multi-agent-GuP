export const GENRES = [
  "異世界ファンタジー",
  "恋愛",
  "冒険",
  "ミステリー",
  "SF",
  "ホラー",
  "コメディ",
  "歴史",
] as const;

export type Genre = (typeof GENRES)[number];

export const PER_PAGE = 12;
