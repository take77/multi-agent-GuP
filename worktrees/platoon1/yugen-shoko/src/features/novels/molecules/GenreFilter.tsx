"use client";

import { GenreBadge } from "../atoms/GenreBadge";
import { GENRES, type Genre } from "../constants";

interface GenreFilterProps {
  selected: Genre | null;
  onSelect: (genre: Genre | null) => void;
}

export function GenreFilter({ selected, onSelect }: GenreFilterProps) {
  return (
    <div className="flex flex-wrap gap-2" role="group" aria-label="ジャンルフィルター">
      <GenreBadge
        genre={"すべて" as Genre}
        selected={selected === null}
        onClick={() => onSelect(null)}
      />
      {GENRES.map((genre) => (
        <GenreBadge
          key={genre}
          genre={genre}
          selected={selected === genre}
          onClick={() => onSelect(selected === genre ? null : genre)}
        />
      ))}
    </div>
  );
}
