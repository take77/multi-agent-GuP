import { cn } from "@/lib/cn";
import type { HTMLAttributes, ElementType } from "react";

type TypographyVariant =
  | "h1"
  | "h2"
  | "h3"
  | "h4"
  | "body"
  | "bodySmall"
  | "caption";

export interface TypographyProps extends HTMLAttributes<HTMLElement> {
  variant?: TypographyVariant;
  as?: ElementType;
}

const variantConfig: Record<TypographyVariant, { tag: ElementType; style: string }> = {
  h1: {
    tag: "h1",
    style: "font-serif text-3xl md:text-4xl font-bold tracking-wide",
  },
  h2: {
    tag: "h2",
    style: "font-serif text-2xl md:text-3xl font-bold tracking-wide",
  },
  h3: {
    tag: "h3",
    style: "font-serif text-xl md:text-2xl font-semibold tracking-wide",
  },
  h4: {
    tag: "h4",
    style: "font-serif text-lg md:text-xl font-semibold tracking-wide",
  },
  body: {
    tag: "p",
    style: "font-sans text-base leading-relaxed",
  },
  bodySmall: {
    tag: "p",
    style: "font-sans text-sm leading-relaxed",
  },
  caption: {
    tag: "span",
    style: "font-sans text-xs text-muted-foreground",
  },
};

export function Typography({
  variant = "body",
  as,
  className,
  children,
  ...props
}: TypographyProps) {
  const config = variantConfig[variant];
  const Component = as ?? config.tag;

  return (
    <Component className={cn(config.style, className)} {...props}>
      {children}
    </Component>
  );
}
