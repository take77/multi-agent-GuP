"use client";

import Link from "next/link";
import { Card, CardHeader, CardContent, CardFooter } from "@/components/molecules/Card";
import { Typography } from "@/components/atoms/Typography";
import { GenreBadge } from "../atoms/GenreBadge";
import type { Novel } from "../types";

interface NovelCardProps {
  novel: Novel;
}

export function NovelCard({ novel }: NovelCardProps) {
  return (
    <Link href={`/novels/${novel.id}`} className="block">
      <Card hoverable className="h-full">
        {novel.cover_image_url && (
          <div className="mb-4 aspect-[3/4] overflow-hidden rounded-lg bg-muted">
            <img
              src={novel.cover_image_url}
              alt={novel.title}
              className="h-full w-full object-cover"
            />
          </div>
        )}
        {!novel.cover_image_url && (
          <div className="mb-4 flex aspect-[3/4] items-center justify-center rounded-lg bg-muted">
            <Typography variant="h3" className="text-muted-foreground">
              {novel.title.charAt(0)}
            </Typography>
          </div>
        )}
        <CardHeader>
          <Typography variant="h4" className="line-clamp-2">
            {novel.title}
          </Typography>
          <Typography variant="caption">{novel.author_name}</Typography>
        </CardHeader>
        <CardContent>
          <Typography variant="bodySmall" className="line-clamp-3">
            {novel.synopsis}
          </Typography>
        </CardContent>
        <CardFooter>
          <div className="flex items-center justify-between">
            <GenreBadge genre={novel.genre} />
            <Typography variant="caption">
              {novel.episode_count}話
            </Typography>
          </div>
        </CardFooter>
      </Card>
    </Link>
  );
}
