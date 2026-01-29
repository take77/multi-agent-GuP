# code-review-checklist-generator 使用例

このドキュメントでは、code-review-checklist-generator スキルの詳細な使用例を説明する。

## 基本的な使い方

### 1. プロジェクトパスを指定して実行

最もシンプルな使い方。プロジェクトの技術スタックを自動検出し、チェックリストを生成する。

```bash
# コマンドライン
generate-checklist --project /path/to/my-project

# 出力例
✓ 検出された技術スタック: React, TypeScript, Jest
✓ チェックリスト生成完了: ./review-checklist.md
  - 12 カテゴリ
  - 45 チェック項目
```

### 2. 出力先を指定

```bash
generate-checklist \
  --project /path/to/my-project \
  --output ./docs/review-checklist.md
```

### 3. カスタム設定ファイルを使用

```bash
generate-checklist \
  --project /path/to/my-project \
  --config ./custom-rules.yaml \
  --output ./review-checklist.md
```

## ユースケース別の使用例

### ユースケース1: React + TypeScript プロジェクト

```bash
# プロジェクト構造
my-react-app/
├── package.json      # react, typescript を検出
├── tsconfig.json
├── src/
│   ├── components/
│   └── App.tsx
└── tests/

# 実行
generate-checklist --project ./my-react-app

# 生成されるチェックリストには以下が含まれる:
# - 共通項目（機能性、セキュリティ等）
# - React固有項目（コンポーネント設計、Hooks、状態管理）
# - TypeScript固有項目（型定義、null安全性）
```

### ユースケース2: Rails プロジェクト

```bash
# プロジェクト構造
my-rails-app/
├── Gemfile           # rails, rspec を検出
├── app/
├── config/
└── spec/

# 実行
generate-checklist --project ./my-rails-app

# 生成されるチェックリストには以下が含まれる:
# - 共通項目
# - Rails固有項目（N+1クエリ、セキュリティ、バリデーション）
# - RSpec項目（テストカバレッジ）
```

### ユースケース3: Python + FastAPI プロジェクト

```bash
# プロジェクト構造
my-fastapi-app/
├── pyproject.toml    # fastapi, pytest を検出
├── requirements.txt
├── app/
└── tests/

# 実行
generate-checklist --project ./my-fastapi-app

# 生成されるチェックリストには以下が含まれる:
# - 共通項目
# - Python固有項目（型ヒント、例外処理、PEP8）
# - FastAPI固有項目（バリデーション、依存性注入）
```

## カスタムルールの追加

### インラインでカスタムルールを指定

```bash
generate-checklist \
  --project ./my-project \
  --custom-rule "プロジェクト固有:社内ライブラリを使用しているか:high" \
  --custom-rule "プロジェクト固有:ログ形式が統一されているか:medium"
```

### 設定ファイルでカスタムルールを指定

```yaml
# custom-rules.yaml
custom_rules:
  - category: "社内規約"
    items:
      - item: "コーディング規約v2.0に準拠しているか"
        severity: high
      - item: "社内ライブラリの最新版を使用しているか"
        severity: medium

  - category: "ドキュメント"
    items:
      - item: "APIドキュメントが更新されているか"
        severity: medium
      - item: "変更履歴が記載されているか"
        severity: low
```

```bash
generate-checklist \
  --project ./my-project \
  --config ./custom-rules.yaml
```

## 特定ルールの無効化

レガシーコードや段階的な改善を行っている場合、特定のルールを無効化できる。

```yaml
# custom-rules.yaml
disabled_rules:
  - "typescript/strict-null-checks"  # 段階的に対応中
  - "react/no-deprecated-apis"       # 旧バージョンをサポート中
```

## 重要度の上書き

プロジェクトの方針に応じて、特定ルールの重要度を変更できる。

```yaml
# custom-rules.yaml
severity_overrides:
  "security/sql-injection": critical    # SQLインジェクションは最重要
  "security/xss": critical              # XSSも最重要
  "test/coverage-threshold": high       # テストカバレッジを重視
  "style/line-length": low              # 行の長さは優先度低
```

## プログラムからの使用

### TypeScript/JavaScript

```typescript
import { generateChecklist, ChecklistOptions } from 'code-review-checklist-generator';

const options: ChecklistOptions = {
  projectPath: '/path/to/project',
  customRules: [
    {
      category: 'プロジェクト固有',
      item: '社内ライブラリを使用しているか',
      severity: 'high'
    }
  ],
  outputFormat: 'markdown'
};

const result = await generateChecklist(options);

console.log('検出された技術スタック:', result.detectedStack);
console.log('カテゴリ数:', result.categories.length);
console.log('チェック項目数:', result.totalItems);

// Markdownを出力
fs.writeFileSync('./review-checklist.md', result.markdown);
```

### Python

```python
from code_review_checklist_generator import generate_checklist

result = generate_checklist(
    project_path="/path/to/project",
    custom_rules=[
        {
            "category": "プロジェクト固有",
            "item": "社内ライブラリを使用しているか",
            "severity": "high"
        }
    ],
    output_format="markdown"
)

print(f"検出された技術スタック: {result.detected_stack}")
print(f"カテゴリ数: {len(result.categories)}")

# Markdownを出力
with open("./review-checklist.md", "w") as f:
    f.write(result.markdown)
```

## CI/CDとの統合

### GitHub Actions

```yaml
# .github/workflows/review-checklist.yml
name: Generate Review Checklist

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  generate-checklist:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Generate Checklist
        run: |
          generate-checklist \
            --project . \
            --config .github/review-rules.yaml \
            --output ./pr-checklist.md

      - name: Post Checklist as Comment
        uses: actions/github-script@v7
        with:
          script: |
            const fs = require('fs');
            const checklist = fs.readFileSync('./pr-checklist.md', 'utf8');
            github.rest.issues.createComment({
              owner: context.repo.owner,
              repo: context.repo.repo,
              issue_number: context.issue.number,
              body: checklist
            });
```

## トラブルシューティング

### 技術スタックが正しく検出されない

手動で技術スタックを指定できる：

```yaml
# custom-rules.yaml
tech_stack_override:
  - react
  - typescript
  - jest
```

### 特定のディレクトリを除外したい

```yaml
# custom-rules.yaml
exclude_paths:
  - node_modules
  - vendor
  - dist
  - build
```

### 出力形式を変更したい

```bash
# YAML形式で出力
generate-checklist --project . --format yaml

# JSON形式で出力
generate-checklist --project . --format json
```

---

*このドキュメントは code-review-checklist-generator v1.0 に基づいて作成されました。*
