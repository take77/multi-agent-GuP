"use client";

import { cn } from "@/lib/cn";

interface SwipeIndicatorProps {
  direction: "left" | "right";
  visible: boolean;
}

export function SwipeIndicator({ direction, visible }: SwipeIndicatorProps) {
  return (
    <div
      className={cn(
        "pointer-events-none fixed top-1/2 z-50 -translate-y-1/2 rounded-full px-4 py-2 text-sm font-medium transition-opacity duration-200",
        direction === "right"
          ? "left-4 bg-accent text-white"
          : "right-4 bg-muted text-muted-foreground",
        visible ? "opacity-100" : "opacity-0",
      )}
    >
      {direction === "right" ? "お気に入り" : "スキップ"}
    </div>
  );
}
