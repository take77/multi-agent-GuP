import { cn } from "@/lib/cn";
import { type InputHTMLAttributes, forwardRef } from "react";

export type InputSize = "sm" | "md" | "lg";

export interface InputProps extends InputHTMLAttributes<HTMLInputElement> {
  inputSize?: InputSize;
  error?: boolean;
}

const sizeStyles: Record<InputSize, string> = {
  sm: "px-3 py-1.5 text-sm rounded-md",
  md: "px-4 py-2 text-sm rounded-lg",
  lg: "px-4 py-3 text-base rounded-lg",
};

export const Input = forwardRef<HTMLInputElement, InputProps>(
  ({ inputSize = "md", error = false, className, ...props }, ref) => {
    return (
      <input
        ref={ref}
        className={cn(
          "w-full bg-input-bg border text-foreground",
          "placeholder:text-input-placeholder",
          "focus:outline-none focus:ring-2 focus:ring-input-focus focus:border-transparent",
          "disabled:opacity-50 disabled:cursor-not-allowed",
          "transition-colors",
          error ? "border-red-400 focus:ring-red-400" : "border-input-border",
          sizeStyles[inputSize],
          className
        )}
        {...props}
      />
    );
  }
);

Input.displayName = "Input";
