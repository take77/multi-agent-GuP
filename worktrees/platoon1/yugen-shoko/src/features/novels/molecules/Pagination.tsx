"use client";

import { Button } from "@/components/atoms/Button";
import { Typography } from "@/components/atoms/Typography";
import type { PaginationMeta } from "../types";

interface PaginationProps {
  meta: PaginationMeta;
  onPageChange: (page: number) => void;
}

export function Pagination({ meta, onPageChange }: PaginationProps) {
  const { current_page, total_pages } = meta;

  if (total_pages <= 1) return null;

  return (
    <nav className="flex items-center justify-center gap-2 pt-8" aria-label="ページネーション">
      <Button
        variant="outline"
        size="sm"
        disabled={current_page <= 1}
        onClick={() => onPageChange(current_page - 1)}
      >
        前へ
      </Button>
      <Typography variant="caption">
        {current_page} / {total_pages}
      </Typography>
      <Button
        variant="outline"
        size="sm"
        disabled={current_page >= total_pages}
        onClick={() => onPageChange(current_page + 1)}
      >
        次へ
      </Button>
    </nav>
  );
}
