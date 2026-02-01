"use client";

import { Typography } from "@/components/atoms/Typography";
import { EpisodeListItem } from "../molecules/EpisodeListItem";
import type { Chapter } from "../types";

interface ChapterListProps {
  chapters: Chapter[];
  novelId: number;
}

export function ChapterList({ chapters, novelId }: ChapterListProps) {
  return (
    <div className="space-y-6">
      {chapters.map((chapter) => (
        <section key={chapter.id}>
          <Typography variant="h4" className="mb-3">
            第{chapter.number}章 {chapter.title}
          </Typography>
          <div className="space-y-2">
            {chapter.episodes.map((episode) => (
              <EpisodeListItem
                key={episode.id}
                episode={episode}
                novelId={novelId}
              />
            ))}
          </div>
        </section>
      ))}
    </div>
  );
}
