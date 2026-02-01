"use client";

import { NovelCard } from "../molecules/NovelCard";
import { LoadingSpinner } from "../atoms/LoadingSpinner";
import { Typography } from "@/components/atoms/Typography";
import type { Novel } from "../types";

interface NovelGridProps {
  novels: Novel[];
  isLoading: boolean;
}

export function NovelGrid({ novels, isLoading }: NovelGridProps) {
  if (isLoading) return <LoadingSpinner />;

  if (novels.length === 0) {
    return (
      <div className="py-16 text-center">
        <Typography variant="body" className="text-muted-foreground">
          小説が見つかりませんでした
        </Typography>
      </div>
    );
  }

  return (
    <div className="grid grid-cols-1 gap-6 sm:grid-cols-2 lg:grid-cols-3 xl:grid-cols-4">
      {novels.map((novel) => (
        <NovelCard key={novel.id} novel={novel} />
      ))}
    </div>
  );
}
