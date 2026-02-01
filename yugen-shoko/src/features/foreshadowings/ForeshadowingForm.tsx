"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { FormLayout } from "@/layouts";
import { Input, Textarea, Select } from "@/components/atoms";
import { FormField } from "@/components/molecules";
import { foreshadowingsApi, type Foreshadowing } from "@/lib/api";
import { STATUS_OPTIONS, IMPORTANCE_OPTIONS } from "./hooks/useForeshadowings";

interface ForeshadowingFormProps {
  foreshadowing?: Foreshadowing;
}

export function ForeshadowingForm({ foreshadowing }: ForeshadowingFormProps) {
  const router = useRouter();
  const isEdit = !!foreshadowing;

  const [form, setForm] = useState({
    title: foreshadowing?.title ?? "",
    description: foreshadowing?.description ?? "",
    status: foreshadowing?.status ?? "planted",
    importance: foreshadowing?.importance ?? "normal",
    planted_episode_id: foreshadowing?.planted_episode_id?.toString() ?? "",
    planned_resolution_episode: foreshadowing?.planned_resolution_episode?.toString() ?? "",
  });
  const [submitting, setSubmitting] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});

  const handleChange = (field: string, value: string) => {
    setForm((prev) => ({ ...prev, [field]: value }));
    setErrors((prev) => ({ ...prev, [field]: "" }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!form.title.trim()) {
      setErrors({ title: "タイトルは必須です" });
      return;
    }
    setSubmitting(true);
    try {
      const payload = {
        title: form.title,
        description: form.description || null,
        status: form.status,
        importance: form.importance,
        planted_episode_id: form.planted_episode_id ? parseInt(form.planted_episode_id, 10) : null,
        planned_resolution_episode: form.planned_resolution_episode ? parseInt(form.planned_resolution_episode, 10) : null,
      };
      if (isEdit) {
        await foreshadowingsApi.update(foreshadowing!.id, payload);
      } else {
        await foreshadowingsApi.create(payload);
      }
      router.push("/admin/foreshadowings");
    } catch {
      setErrors({ title: "保存に失敗しました" });
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <FormLayout
      title={isEdit ? `${foreshadowing!.title} を編集` : "伏線 新規作成"}
      description={isEdit ? "伏線情報を編集します" : "新しい伏線を作成します"}
      submitLabel={isEdit ? "更新" : "作成"}
      onCancel={() => router.push("/admin/foreshadowings")}
      isSubmitting={submitting}
      onSubmit={handleSubmit}
    >
      <FormField label="タイトル" htmlFor="title" required error={errors.title}>
        <Input
          id="title"
          value={form.title}
          onChange={(e) => handleChange("title", e.target.value)}
          placeholder="伏線のタイトル"
          error={!!errors.title}
        />
      </FormField>

      <FormField label="説明" htmlFor="description">
        <Textarea
          id="description"
          value={form.description}
          onChange={(e) => handleChange("description", e.target.value)}
          placeholder="伏線の詳細な説明..."
          rows={4}
        />
      </FormField>

      <div className="grid gap-6 md:grid-cols-2">
        <FormField label="ステータス" htmlFor="status">
          <Select
            id="status"
            value={form.status}
            onChange={(e) => handleChange("status", e.target.value)}
          >
            {STATUS_OPTIONS.map((s) => (
              <option key={s.id} value={s.id}>{s.label}</option>
            ))}
          </Select>
        </FormField>

        <FormField label="重要度" htmlFor="importance">
          <Select
            id="importance"
            value={form.importance}
            onChange={(e) => handleChange("importance", e.target.value)}
          >
            {IMPORTANCE_OPTIONS.map((i) => (
              <option key={i.id} value={i.id}>{i.label}</option>
            ))}
          </Select>
        </FormField>
      </div>

      <div className="grid gap-6 md:grid-cols-2">
        <FormField label="設置話 (エピソードID)" htmlFor="planted_episode_id">
          <Input
            id="planted_episode_id"
            type="number"
            value={form.planted_episode_id}
            onChange={(e) => handleChange("planted_episode_id", e.target.value)}
            placeholder="エピソードID"
          />
        </FormField>

        <FormField label="回収予定話" htmlFor="planned_resolution_episode">
          <Input
            id="planned_resolution_episode"
            type="number"
            value={form.planned_resolution_episode}
            onChange={(e) => handleChange("planned_resolution_episode", e.target.value)}
            placeholder="話数"
          />
        </FormField>
      </div>
    </FormLayout>
  );
}
