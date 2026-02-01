"use client";

import { useRef, useCallback, useEffect } from "react";

interface PinchHandlers {
  onPinchIn?: () => void;
  onPinchOut?: () => void;
}

const PINCH_THRESHOLD = 30;

export function usePinch(
  handlers: PinchHandlers,
  elementRef: React.RefObject<HTMLElement | null>,
) {
  const initialDistance = useRef(0);

  const getDistance = (touches: TouchList): number => {
    if (touches.length < 2) return 0;
    const dx = touches[0].clientX - touches[1].clientX;
    const dy = touches[0].clientY - touches[1].clientY;
    return Math.sqrt(dx * dx + dy * dy);
  };

  const handleTouchStart = useCallback((e: TouchEvent) => {
    if (e.touches.length === 2) {
      initialDistance.current = getDistance(e.touches);
    }
  }, []);

  const handleTouchEnd = useCallback(
    (e: TouchEvent) => {
      if (e.touches.length === 0 && initialDistance.current > 0) {
        const finalDistance = getDistance(e.changedTouches);
        // changedTouches may only have 1 finger on touchend, use stored initial
        // Only fire if we had a 2-finger gesture
        if (initialDistance.current > 0 && e.changedTouches.length >= 1) {
          // We rely on touchmove for more precise detection below
        }
        initialDistance.current = 0;
      }
    },
    [handlers],
  );

  const handleTouchMove = useCallback(
    (e: TouchEvent) => {
      if (e.touches.length !== 2 || initialDistance.current === 0) return;

      const currentDistance = getDistance(e.touches);
      const delta = currentDistance - initialDistance.current;

      if (Math.abs(delta) > PINCH_THRESHOLD) {
        if (delta > 0) {
          handlers.onPinchOut?.();
        } else {
          handlers.onPinchIn?.();
        }
        // リセットして連続発火を制御
        initialDistance.current = currentDistance;
      }
    },
    [handlers],
  );

  useEffect(() => {
    const el = elementRef.current;
    if (!el) return;

    el.addEventListener("touchstart", handleTouchStart, { passive: true });
    el.addEventListener("touchmove", handleTouchMove, { passive: true });
    el.addEventListener("touchend", handleTouchEnd, { passive: true });

    return () => {
      el.removeEventListener("touchstart", handleTouchStart);
      el.removeEventListener("touchmove", handleTouchMove);
      el.removeEventListener("touchend", handleTouchEnd);
    };
  }, [elementRef, handleTouchStart, handleTouchMove, handleTouchEnd]);
}
