import { cn } from "@/lib/cn";
import { Typography } from "@/components/atoms/Typography";
import { Button } from "@/components/atoms/Button";
import { Card } from "@/components/molecules/Card";
import type { ReactNode, FormHTMLAttributes } from "react";

export interface FormLayoutProps extends FormHTMLAttributes<HTMLFormElement> {
  title: string;
  description?: string;
  submitLabel?: string;
  cancelLabel?: string;
  onCancel?: () => void;
  isSubmitting?: boolean;
  children: ReactNode;
}

export function FormLayout({
  title,
  description,
  submitLabel = "保存",
  cancelLabel = "キャンセル",
  onCancel,
  isSubmitting = false,
  children,
  className,
  ...formProps
}: FormLayoutProps) {
  return (
    <div className="space-y-6">
      <div>
        <Typography variant="h2">{title}</Typography>
        {description && (
          <Typography variant="bodySmall" className="mt-1 text-muted-foreground">
            {description}
          </Typography>
        )}
      </div>

      <Card>
        <form className={cn("space-y-6", className)} {...formProps}>
          {children}

          <div className="flex justify-end gap-3 pt-4 border-t border-border">
            {onCancel && (
              <Button
                type="button"
                variant="ghost"
                onClick={onCancel}
                disabled={isSubmitting}
              >
                {cancelLabel}
              </Button>
            )}
            <Button type="submit" disabled={isSubmitting}>
              {isSubmitting ? "処理中..." : submitLabel}
            </Button>
          </div>
        </form>
      </Card>
    </div>
  );
}
