"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { FormLayout } from "@/layouts";
import { Input, Textarea, Select } from "@/components/atoms";
import { FormField } from "@/components/molecules";
import { worldSettingsApi, type WorldSetting } from "@/lib/api";
import { CATEGORIES } from "./hooks/useWorldSettings";

interface WorldSettingFormProps {
  setting?: WorldSetting;
}

export function WorldSettingForm({ setting }: WorldSettingFormProps) {
  const router = useRouter();
  const isEdit = !!setting;

  const [form, setForm] = useState({
    category: setting?.category ?? "",
    title: setting?.title ?? "",
    description: setting?.description ?? "",
    details: setting?.details ? JSON.stringify(setting.details, null, 2) : "{}",
  });
  const [submitting, setSubmitting] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});

  const handleChange = (field: string, value: string) => {
    setForm((prev) => ({ ...prev, [field]: value }));
    setErrors((prev) => ({ ...prev, [field]: "" }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    const newErrors: Record<string, string> = {};
    if (!form.category) newErrors.category = "カテゴリは必須です";
    if (!form.title.trim()) newErrors.title = "タイトルは必須です";

    let parsedDetails: Record<string, unknown> = {};
    try {
      parsedDetails = JSON.parse(form.details);
    } catch {
      newErrors.details = "JSONの形式が正しくありません";
    }

    if (Object.keys(newErrors).length > 0) {
      setErrors(newErrors);
      return;
    }

    setSubmitting(true);
    try {
      const payload = {
        category: form.category as WorldSetting["category"],
        title: form.title,
        description: form.description || null,
        details: parsedDetails,
      };
      if (isEdit) {
        await worldSettingsApi.update(setting!.id, payload);
      } else {
        await worldSettingsApi.create(payload);
      }
      router.push("/admin/world-settings");
    } catch {
      setErrors({ title: "保存に失敗しました" });
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <FormLayout
      title={isEdit ? `${setting!.title} を編集` : "世界観設定 新規作成"}
      description={isEdit ? "世界観設定を編集します" : "新しい世界観設定を作成します"}
      submitLabel={isEdit ? "更新" : "作成"}
      onCancel={() => router.push("/admin/world-settings")}
      isSubmitting={submitting}
      onSubmit={handleSubmit}
    >
      <FormField label="カテゴリ" htmlFor="category" required error={errors.category}>
        <Select
          id="category"
          value={form.category}
          onChange={(e) => handleChange("category", e.target.value)}
          error={!!errors.category}
        >
          <option value="">選択してください</option>
          {CATEGORIES.map((c) => (
            <option key={c.id} value={c.id}>{c.label}</option>
          ))}
        </Select>
      </FormField>

      <FormField label="タイトル" htmlFor="title" required error={errors.title}>
        <Input
          id="title"
          value={form.title}
          onChange={(e) => handleChange("title", e.target.value)}
          placeholder="設定のタイトル"
          error={!!errors.title}
        />
      </FormField>

      <FormField label="説明" htmlFor="description">
        <Textarea
          id="description"
          value={form.description}
          onChange={(e) => handleChange("description", e.target.value)}
          placeholder="設定の説明..."
          rows={4}
        />
      </FormField>

      <FormField
        label="詳細 (JSON)"
        htmlFor="details"
        error={errors.details}
        hint="追加の構造化データをJSON形式で入力"
      >
        <Textarea
          id="details"
          value={form.details}
          onChange={(e) => handleChange("details", e.target.value)}
          className="font-mono text-xs"
          rows={6}
          error={!!errors.details}
        />
      </FormField>
    </FormLayout>
  );
}
