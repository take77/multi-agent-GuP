"use client";

import { useRef, useCallback, useEffect } from "react";

interface SwipeHandlers {
  onSwipeLeft?: () => void;
  onSwipeRight?: () => void;
  onSwipeUp?: () => void;
  onSwipeDown?: () => void;
  onDoubleTap?: () => void;
}

interface SwipeState {
  offsetX: number;
  offsetY: number;
  isSwiping: boolean;
}

const SWIPE_THRESHOLD = 50;
const DOUBLE_TAP_DELAY = 300;

export function useSwipe(
  handlers: SwipeHandlers,
  elementRef: React.RefObject<HTMLElement | null>,
) {
  const startX = useRef(0);
  const startY = useRef(0);
  const lastTapTime = useRef(0);
  const stateRef = useRef<SwipeState>({ offsetX: 0, offsetY: 0, isSwiping: false });

  const handleTouchStart = useCallback((e: TouchEvent) => {
    const touch = e.touches[0];
    startX.current = touch.clientX;
    startY.current = touch.clientY;
    stateRef.current.isSwiping = true;
  }, []);

  const handleTouchEnd = useCallback(
    (e: TouchEvent) => {
      if (!stateRef.current.isSwiping) return;
      stateRef.current.isSwiping = false;

      const touch = e.changedTouches[0];
      const deltaX = touch.clientX - startX.current;
      const deltaY = touch.clientY - startY.current;
      const absDeltaX = Math.abs(deltaX);
      const absDeltaY = Math.abs(deltaY);

      // ダブルタップ検出
      if (absDeltaX < 10 && absDeltaY < 10) {
        const now = Date.now();
        if (now - lastTapTime.current < DOUBLE_TAP_DELAY) {
          handlers.onDoubleTap?.();
          lastTapTime.current = 0;
          return;
        }
        lastTapTime.current = now;
        return;
      }

      // 横スワイプ優先
      if (absDeltaX > absDeltaY && absDeltaX > SWIPE_THRESHOLD) {
        if (deltaX > 0) {
          handlers.onSwipeRight?.();
        } else {
          handlers.onSwipeLeft?.();
        }
        return;
      }

      // 縦スワイプ
      if (absDeltaY > absDeltaX && absDeltaY > SWIPE_THRESHOLD) {
        if (deltaY > 0) {
          handlers.onSwipeDown?.();
        } else {
          handlers.onSwipeUp?.();
        }
      }
    },
    [handlers],
  );

  useEffect(() => {
    const el = elementRef.current;
    if (!el) return;

    el.addEventListener("touchstart", handleTouchStart, { passive: true });
    el.addEventListener("touchend", handleTouchEnd, { passive: true });

    return () => {
      el.removeEventListener("touchstart", handleTouchStart);
      el.removeEventListener("touchend", handleTouchEnd);
    };
  }, [elementRef, handleTouchStart, handleTouchEnd]);
}
