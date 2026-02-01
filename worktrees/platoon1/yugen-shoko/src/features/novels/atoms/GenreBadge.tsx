"use client";

import { Badge } from "@/components/atoms/Badge";
import type { Genre } from "../constants";

interface GenreBadgeProps {
  genre: Genre;
  selected?: boolean;
  onClick?: () => void;
}

export function GenreBadge({ genre, selected = false, onClick }: GenreBadgeProps) {
  return (
    <Badge
      variant={selected ? "accent" : "default"}
      className={onClick ? "cursor-pointer hover:opacity-80" : undefined}
      onClick={onClick}
      role={onClick ? "button" : undefined}
      aria-pressed={onClick ? selected : undefined}
    >
      {genre}
    </Badge>
  );
}
