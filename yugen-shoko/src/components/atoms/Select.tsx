import { cn } from "@/lib/cn";
import { type SelectHTMLAttributes, forwardRef } from "react";

export type SelectSize = "sm" | "md" | "lg";

export interface SelectProps extends SelectHTMLAttributes<HTMLSelectElement> {
  selectSize?: SelectSize;
  error?: boolean;
}

const sizeStyles: Record<SelectSize, string> = {
  sm: "px-3 py-1.5 text-sm rounded-md",
  md: "px-4 py-2 text-sm rounded-lg",
  lg: "px-4 py-3 text-base rounded-lg",
};

export const Select = forwardRef<HTMLSelectElement, SelectProps>(
  ({ selectSize = "md", error = false, className, children, ...props }, ref) => {
    return (
      <select
        ref={ref}
        className={cn(
          "w-full bg-input-bg border text-foreground appearance-none",
          "focus:outline-none focus:ring-2 focus:ring-input-focus focus:border-transparent",
          "disabled:opacity-50 disabled:cursor-not-allowed",
          "transition-colors",
          "bg-[url('data:image/svg+xml;charset=utf-8,%3Csvg%20xmlns%3D%22http%3A%2F%2Fwww.w3.org%2F2000%2Fsvg%22%20width%3D%2216%22%20height%3D%2216%22%20viewBox%3D%220%200%2024%2024%22%20fill%3D%22none%22%20stroke%3D%22%236B6B6B%22%20stroke-width%3D%222%22%3E%3Cpath%20d%3D%22m6%209%206%206%206-6%22%2F%3E%3C%2Fsvg%3E')] bg-[length:16px] bg-[right_12px_center] bg-no-repeat pr-10",
          error ? "border-red-400 focus:ring-red-400" : "border-input-border",
          sizeStyles[selectSize],
          className
        )}
        {...props}
      >
        {children}
      </select>
    );
  }
);

Select.displayName = "Select";
