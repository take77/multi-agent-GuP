import { cn } from "@/lib/cn";
import { type TextareaHTMLAttributes, forwardRef } from "react";

export interface TextareaProps extends TextareaHTMLAttributes<HTMLTextAreaElement> {
  error?: boolean;
}

export const Textarea = forwardRef<HTMLTextAreaElement, TextareaProps>(
  ({ error = false, className, ...props }, ref) => {
    return (
      <textarea
        ref={ref}
        className={cn(
          "w-full bg-input-bg border text-foreground rounded-lg px-4 py-2 text-sm",
          "placeholder:text-input-placeholder",
          "focus:outline-none focus:ring-2 focus:ring-input-focus focus:border-transparent",
          "disabled:opacity-50 disabled:cursor-not-allowed",
          "resize-y min-h-[80px]",
          "transition-colors",
          error ? "border-red-400 focus:ring-red-400" : "border-input-border",
          className
        )}
        {...props}
      />
    );
  }
);

Textarea.displayName = "Textarea";
