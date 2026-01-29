# dashboard-generator

テンプレートからプレースホルダーを置換してdashboard.mdを自動生成するスキル。

## 概要

マルチエージェントシステムにおいて、プロジェクトの状況を一目で把握できるダッシュボード（`dashboard.md`）を、テンプレートと状態データから自動生成する。`{{PLACEHOLDER}}` 形式のプレースホルダーを置換し、動的なダッシュボードを構築。

## 機能

- テンプレートファイルの読み込み
- `{{PLACEHOLDER}}` 形式のプレースホルダー置換
- 状態YAMLからの自動データ取得
- セクション構成のカスタマイズ
- Markdown形式で出力
- タイムスタンプ自動挿入

## 使用方法

### 基本的な使い方

```bash
# ダッシュボードを生成
generate-dashboard \
  --template templates/dashboard.md.template \
  --project "multi-agent-GuP" \
  --output dashboard.md
```

### 状態YAMLを使用

```bash
# 状態ファイルから動的にデータを取得
generate-dashboard \
  --template templates/dashboard.md.template \
  --status status/master_status.yaml \
  --output dashboard.md
```

### カスタム値を指定

```bash
# カスタム置換値を指定
generate-dashboard \
  --template templates/dashboard.md.template \
  --values custom-values.yaml \
  --output dashboard.md
```

## プレースホルダー一覧

### 基本プレースホルダー

| プレースホルダー | 説明 | 例 |
|------------------|------|-----|
| `{{PROJECT_NAME}}` | プロジェクト名 | multi-agent-GuP |
| `{{TIMESTAMP}}` | 生成日時 | 2026-01-29 15:47 |
| `{{DATE}}` | 日付 | 2026-01-29 |
| `{{TIME}}` | 時刻 | 15:47 |

### セクションプレースホルダー

| プレースホルダー | 説明 |
|------------------|------|
| `{{SECTION_URGENT}}` | 要対応セクション |
| `{{SECTION_IN_PROGRESS}}` | 進行中タスク |
| `{{SECTION_COMPLETED}}` | 完了タスク |
| `{{SECTION_WAITING}}` | 待機中タスク |
| `{{SECTION_QUESTIONS}}` | 伺い事項 |

### 動的プレースホルダー

| プレースホルダー | 説明 |
|------------------|------|
| `{{TASK_TABLE}}` | タスク一覧テーブル |
| `{{SKILL_CANDIDATES}}` | スキル化候補一覧 |
| `{{DAILY_ACHIEVEMENTS}}` | 本日の戦果 |
| `{{PLATOON_STATUS}}` | 中隊別状況 |

## 入力

| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| template_path | string | Yes | テンプレートファイルパス |
| project_name | string | Yes | プロジェクト名 |
| status_yaml | string | No | 状態ファイルパス |
| custom_values | file | No | カスタム置換値YAML |
| output_path | string | No | 出力先パス（デフォルト: dashboard.md） |

## 出力

- 生成された `dashboard.md`
- 生成レポート（置換されたプレースホルダー一覧）

## ダッシュボード構成

```
📊 戦況報告
├── 🚨 要対応（ユーザーのご判断待ち）
│   └── スキル化候補一覧
├── 🔄 進行中
│   └── コマンド別タスク状況
├── ✅ 本日の戦果
│   └── 完了タスク一覧
├── ⏸️ 待機中
│   └── 待機タスク一覧
└── ❓ 伺い事項
    └── 質問・確認事項
```

## 参考

このスキルは `multi-agent-GuP` の `dashboard.md` を参考に設計された。

## バージョン

- 1.0.0 - 初版作成
