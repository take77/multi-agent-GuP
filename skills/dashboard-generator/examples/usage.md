# dashboard-generator 使用例

## 1. 基本的な使用方法

### 最小構成での生成

```bash
# プロジェクト名のみ指定
generate-dashboard \
  --template templates/dashboard.md.template \
  --project "multi-agent-GuP" \
  --output dashboard.md
```

### 出力例

```
[INFO] Loading template: templates/dashboard.md.template
[INFO] Project name: multi-agent-GuP
[INFO] Replacing placeholders...
  - {{PROJECT_NAME}} → multi-agent-GuP
  - {{TIMESTAMP}} → 2026-01-29 15:50
  - {{DATE}} → 2026-01-29
  - {{TIME}} → 15:50
[INFO] Writing to: dashboard.md
[SUCCESS] Generated: dashboard.md
  - Placeholders replaced: 4
  - Sections: 5
```

## 2. 状態YAMLを使用した動的生成

### 状態ファイルから動的にデータを取得

```bash
generate-dashboard \
  --template templates/dashboard.md.template \
  --project "multi-agent-GuP" \
  --status status/master_status.yaml \
  --output dashboard.md
```

### 出力例

```
[INFO] Loading template: templates/dashboard.md.template
[INFO] Loading status: status/master_status.yaml
[INFO] Building dynamic sections...
  - TASK_TABLE: 8 tasks
  - SKILL_CANDIDATES: 5 candidates
  - DAILY_ACHIEVEMENTS: 12 entries
[INFO] Replacing placeholders...
  - 12 placeholders replaced
[SUCCESS] Generated: dashboard.md
```

## 3. カスタム値を使用

### 任意の置換値を指定

```bash
generate-dashboard \
  --template templates/dashboard.md.template \
  --project "multi-agent-GuP" \
  --values custom-values.yaml \
  --output dashboard.md
```

### custom-values.yaml の例

```yaml
# カスタムプレースホルダー
TEAM_NAME: "あんこうチーム"
COMMANDER: "西住みほ"
MISSION_STATUS: "作戦実行中"

# セクションの上書き
SECTION_URGENT: |
  ### 緊急事項
  - 第3中隊の支援が必要
  - デプロイ承認待ち
```

## 4. セクションのフィルタリング

### 特定セクションのみ含める

```bash
generate-dashboard \
  --template templates/dashboard.md.template \
  --project "multi-agent-GuP" \
  --include-sections "urgent,in_progress" \
  --output dashboard.md
```

### 出力例

```
[INFO] Filtering sections: urgent, in_progress
[INFO] Excluded sections: completed, waiting, questions
[SUCCESS] Generated: dashboard.md (filtered)
```

## 5. タイムスタンプフォーマットの変更

### 日本語フォーマット

```bash
generate-dashboard \
  --template templates/dashboard.md.template \
  --project "multi-agent-GuP" \
  --timestamp-format "%Y年%m月%d日 %H時%M分" \
  --output dashboard.md
```

### 出力例

```
最終更新: 2026年01月29日 15時50分
```

## 6. バリデーションのみ

### テンプレートの検証

```bash
generate-dashboard \
  --validate-only \
  --template templates/dashboard.md.template
```

### 出力例

```
[VALIDATE] templates/dashboard.md.template
  ✓ File exists
  ✓ Valid Markdown format
  ✓ Placeholders found: 12
    - {{PROJECT_NAME}}
    - {{TIMESTAMP}}
    - {{SECTION_URGENT}}
    - {{SECTION_IN_PROGRESS}}
    - ...
[RESULT] Valid template - ready for generation
```

## 7. 定期実行（cron）

### 5分ごとにダッシュボードを更新

```bash
# crontab -e
*/5 * * * * /path/to/generate-dashboard \
  --template /path/to/templates/dashboard.md.template \
  --project "multi-agent-GuP" \
  --status /path/to/status/master_status.yaml \
  --output /path/to/dashboard.md
```

## 8. トラブルシューティング

### テンプレートが見つからない場合

```
[ERROR] Template not found: templates/dashboard.md.template
  Solution: Check the file path and ensure the file exists
```

### 未置換プレースホルダーがある場合

```
[WARNING] Unreplaced placeholders found:
  - {{CUSTOM_FIELD}} at line 15
  - {{UNKNOWN_SECTION}} at line 28
  Solution: Add these to custom_values or remove from template
```

### 状態YAMLの形式エラー

```
[ERROR] Invalid status YAML format
  File: status/master_status.yaml
  Line: 23
  Error: Expected array but got string
  Solution: Check the YAML syntax at the specified line
```
