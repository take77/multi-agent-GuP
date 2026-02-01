"use client";

import Link from "next/link";
import { Typography } from "@/components/atoms/Typography";
import type { Episode } from "../types";

interface EpisodeListItemProps {
  episode: Episode;
  novelId: number;
}

export function EpisodeListItem({ episode, novelId }: EpisodeListItemProps) {
  return (
    <Link
      href={`/novels/${novelId}/read?episode=${episode.id}`}
      className="flex items-center justify-between rounded-lg border border-border px-4 py-3 transition-colors hover:bg-muted"
    >
      <div className="flex items-center gap-3">
        <span className="flex h-8 w-8 items-center justify-center rounded-full bg-accent/15 text-sm font-medium text-accent">
          {episode.number}
        </span>
        <Typography variant="bodySmall">{episode.title}</Typography>
      </div>
      <Typography variant="caption">
        {episode.word_count.toLocaleString()}字
      </Typography>
    </Link>
  );
}
