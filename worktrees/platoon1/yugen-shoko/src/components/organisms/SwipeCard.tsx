"use client";

import { cn } from "@/lib/cn";
import {
  type HTMLAttributes,
  type TouchEvent,
  type MouseEvent,
  useCallback,
  useRef,
  useState,
} from "react";

export type SwipeDirection = "left" | "right";

export interface SwipeCardProps extends Omit<HTMLAttributes<HTMLDivElement>, "onDragEnd"> {
  /** Callback when card is swiped past threshold */
  onSwipe?: (direction: SwipeDirection) => void;
  /** Callback when card is double-tapped */
  onDoubleTap?: () => void;
  /** Minimum distance (px) to trigger swipe */
  swipeThreshold?: number;
  /** Whether swipe gestures are enabled */
  swipeable?: boolean;
}

const ROTATION_FACTOR = 0.1;
const OPACITY_FACTOR = 0.003;

export function SwipeCard({
  onSwipe,
  onDoubleTap,
  swipeThreshold = 100,
  swipeable = true,
  className,
  children,
  ...props
}: SwipeCardProps) {
  const cardRef = useRef<HTMLDivElement>(null);
  const [offset, setOffset] = useState({ x: 0, y: 0 });
  const [isDragging, setIsDragging] = useState(false);
  const [isExiting, setIsExiting] = useState(false);
  const startPos = useRef({ x: 0, y: 0 });
  const lastTap = useRef(0);

  const handleStart = useCallback(
    (clientX: number, clientY: number) => {
      if (!swipeable || isExiting) return;

      // Double-tap detection
      const now = Date.now();
      if (now - lastTap.current < 300) {
        onDoubleTap?.();
        lastTap.current = 0;
        return;
      }
      lastTap.current = now;

      setIsDragging(true);
      startPos.current = { x: clientX, y: clientY };
    },
    [swipeable, isExiting, onDoubleTap]
  );

  const handleMove = useCallback(
    (clientX: number, clientY: number) => {
      if (!isDragging) return;
      setOffset({
        x: clientX - startPos.current.x,
        y: clientY - startPos.current.y,
      });
    },
    [isDragging]
  );

  const handleEnd = useCallback(() => {
    if (!isDragging) return;
    setIsDragging(false);

    if (Math.abs(offset.x) > swipeThreshold) {
      const direction: SwipeDirection = offset.x > 0 ? "right" : "left";
      setIsExiting(true);
      // Animate off-screen
      setOffset({ x: offset.x > 0 ? 500 : -500, y: offset.y });
      setTimeout(() => {
        onSwipe?.(direction);
        setOffset({ x: 0, y: 0 });
        setIsExiting(false);
      }, 300);
    } else {
      // Snap back
      setOffset({ x: 0, y: 0 });
    }
  }, [isDragging, offset, swipeThreshold, onSwipe]);

  // Touch handlers
  const onTouchStart = (e: TouchEvent) => {
    const touch = e.touches[0];
    handleStart(touch.clientX, touch.clientY);
  };
  const onTouchMove = (e: TouchEvent) => {
    const touch = e.touches[0];
    handleMove(touch.clientX, touch.clientY);
  };
  const onTouchEnd = () => handleEnd();

  // Mouse handlers
  const onMouseDown = (e: MouseEvent) => handleStart(e.clientX, e.clientY);
  const onMouseMove = (e: MouseEvent) => handleMove(e.clientX, e.clientY);
  const onMouseUp = () => handleEnd();
  const onMouseLeave = () => {
    if (isDragging) handleEnd();
  };

  const rotation = offset.x * ROTATION_FACTOR;
  const likeOpacity = Math.max(0, offset.x * OPACITY_FACTOR);
  const nopeOpacity = Math.max(0, -offset.x * OPACITY_FACTOR);

  return (
    <div
      ref={cardRef}
      className={cn(
        "relative select-none rounded-[var(--radius-swipe)] border border-border bg-card shadow-[var(--shadow-card)] overflow-hidden",
        isDragging ? "cursor-grabbing" : swipeable ? "cursor-grab" : "",
        !isDragging && !isExiting && "transition-transform duration-300 ease-[var(--ease-gentle)]",
        isExiting && "transition-all duration-300 ease-out",
        className
      )}
      style={{
        transform: `translate(${offset.x}px, ${offset.y * 0.3}px) rotate(${rotation}deg)`,
      }}
      onTouchStart={onTouchStart}
      onTouchMove={onTouchMove}
      onTouchEnd={onTouchEnd}
      onMouseDown={onMouseDown}
      onMouseMove={onMouseMove}
      onMouseUp={onMouseUp}
      onMouseLeave={onMouseLeave}
      role="button"
      tabIndex={0}
      aria-label="スワイプして評価"
      {...props}
    >
      {children}

      {/* Like overlay (right swipe) */}
      <div
        className="pointer-events-none absolute inset-0 flex items-start justify-start p-6"
        style={{ opacity: likeOpacity }}
      >
        <span className="rounded border-2 border-green-500 px-3 py-1 text-lg font-bold text-green-500 -rotate-12">
          LIKE
        </span>
      </div>

      {/* Nope overlay (left swipe) */}
      <div
        className="pointer-events-none absolute inset-0 flex items-start justify-end p-6"
        style={{ opacity: nopeOpacity }}
      >
        <span className="rounded border-2 border-red-500 px-3 py-1 text-lg font-bold text-red-500 rotate-12">
          NOPE
        </span>
      </div>
    </div>
  );
}
