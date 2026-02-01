"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { FormLayout } from "@/layouts";
import { Input, Textarea, Select } from "@/components/atoms";
import { FormField } from "@/components/molecules";
import { charactersApi, type Character } from "@/lib/api";

const ROLE_OPTIONS = [
  "主人公",
  "ヒロイン",
  "ライバル",
  "師匠",
  "仲間",
  "敵",
  "サブキャラ",
  "モブ",
];

interface CharacterFormProps {
  character?: Character;
}

export function CharacterForm({ character }: CharacterFormProps) {
  const router = useRouter();
  const isEdit = !!character;

  const [form, setForm] = useState({
    name: character?.name ?? "",
    age: character?.age?.toString() ?? "",
    appearance: character?.appearance ?? "",
    abilities: character?.abilities ?? "",
    personality: character?.personality ?? "",
    speech_style: character?.speech_style ?? "",
    background: character?.background ?? "",
    role: character?.role ?? "",
  });
  const [submitting, setSubmitting] = useState(false);
  const [errors, setErrors] = useState<Record<string, string>>({});

  const handleChange = (field: string, value: string) => {
    setForm((prev) => ({ ...prev, [field]: value }));
    setErrors((prev) => ({ ...prev, [field]: "" }));
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!form.name.trim()) {
      setErrors({ name: "名前は必須です" });
      return;
    }
    setSubmitting(true);
    try {
      const payload = {
        ...form,
        age: form.age ? parseInt(form.age, 10) : null,
      };
      if (isEdit) {
        await charactersApi.update(character!.id, payload);
      } else {
        await charactersApi.create(payload);
      }
      router.push("/admin/characters");
    } catch {
      setErrors({ name: "保存に失敗しました" });
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <FormLayout
      title={isEdit ? `${character!.name} を編集` : "キャラクター新規作成"}
      description={isEdit ? "キャラクター情報を編集します" : "新しいキャラクターを作成します"}
      submitLabel={isEdit ? "更新" : "作成"}
      onCancel={() => router.push("/admin/characters")}
      isSubmitting={submitting}
      onSubmit={handleSubmit}
    >
      <div className="grid gap-6 md:grid-cols-2">
        <FormField label="名前" htmlFor="name" required error={errors.name}>
          <Input
            id="name"
            value={form.name}
            onChange={(e) => handleChange("name", e.target.value)}
            placeholder="キャラクター名"
            error={!!errors.name}
          />
        </FormField>

        <FormField label="年齢" htmlFor="age">
          <Input
            id="age"
            type="number"
            value={form.age}
            onChange={(e) => handleChange("age", e.target.value)}
            placeholder="年齢"
          />
        </FormField>
      </div>

      <FormField label="役割" htmlFor="role">
        <Select
          id="role"
          value={form.role}
          onChange={(e) => handleChange("role", e.target.value)}
        >
          <option value="">選択してください</option>
          {ROLE_OPTIONS.map((r) => (
            <option key={r} value={r}>{r}</option>
          ))}
        </Select>
      </FormField>

      <FormField label="外見" htmlFor="appearance">
        <Textarea
          id="appearance"
          value={form.appearance}
          onChange={(e) => handleChange("appearance", e.target.value)}
          placeholder="外見の特徴を記述..."
          rows={3}
        />
      </FormField>

      <FormField label="能力" htmlFor="abilities">
        <Textarea
          id="abilities"
          value={form.abilities}
          onChange={(e) => handleChange("abilities", e.target.value)}
          placeholder="能力・スキルを記述..."
          rows={3}
        />
      </FormField>

      <FormField label="性格" htmlFor="personality">
        <Textarea
          id="personality"
          value={form.personality}
          onChange={(e) => handleChange("personality", e.target.value)}
          placeholder="性格の特徴を記述..."
          rows={3}
        />
      </FormField>

      <FormField label="口調" htmlFor="speech_style">
        <Textarea
          id="speech_style"
          value={form.speech_style}
          onChange={(e) => handleChange("speech_style", e.target.value)}
          placeholder="口調や話し方の特徴..."
          rows={3}
        />
      </FormField>

      <FormField label="背景" htmlFor="background">
        <Textarea
          id="background"
          value={form.background}
          onChange={(e) => handleChange("background", e.target.value)}
          placeholder="経歴・背景情報..."
          rows={4}
        />
      </FormField>
    </FormLayout>
  );
}
