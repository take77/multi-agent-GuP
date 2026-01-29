# code-review-checklist-generator

プロジェクト設定に応じたコードレビューチェックリストを自動生成するスキル。

## 概要

プロジェクトの技術スタック（React, TypeScript, Rails など）を自動検出し、そのスタックに適したコードレビューチェックリストをMarkdown形式で生成する。プロジェクトごとにカスタムルールを追加することも可能。

## 機能

- **技術スタック自動検出**
  - `package.json` → React, TypeScript, Vue, Angular など
  - `Gemfile` → Rails, Ruby など
  - `requirements.txt` / `pyproject.toml` → Python, Django, FastAPI など
  - `go.mod` → Go
  - `Cargo.toml` → Rust

- **スタック別チェックリスト生成**
  - 各技術スタックに最適化されたチェック項目
  - セキュリティ、パフォーマンス、保守性の観点を網羅

- **カスタムルール対応**
  - プロジェクト固有のルールを追加可能
  - 既存ルールの上書き/無効化も可能

- **Markdown形式出力**
  - チェックボックス形式でレビュー時に使いやすい
  - カテゴリ別に整理された構造

## 使用方法

### 基本的な使い方

```bash
# プロジェクトパスを指定して実行
generate-checklist --project /path/to/project

# 出力先を指定
generate-checklist --project /path/to/project --output ./review-checklist.md
```

### カスタム設定を使用

```bash
# カスタム設定ファイルを指定
generate-checklist \
  --project /path/to/project \
  --config ./custom-rules.yaml
```

### プログラムから使用

```typescript
import { generateChecklist } from 'code-review-checklist-generator';

const checklist = await generateChecklist({
  projectPath: '/path/to/project',
  customRules: [
    { category: 'Security', item: 'APIキーがハードコードされていないか' }
  ]
});

console.log(checklist.markdown);
```

## 入力

### プロジェクトパス（必須）

検査対象のプロジェクトルートディレクトリ。以下のファイルを自動検出：

| ファイル | 検出される技術 |
|----------|--------------|
| `package.json` | JavaScript, TypeScript, React, Vue, Angular, Node.js |
| `Gemfile` | Ruby, Rails |
| `requirements.txt` | Python, Django, Flask |
| `pyproject.toml` | Python, FastAPI, Poetry |
| `go.mod` | Go |
| `Cargo.toml` | Rust |
| `pom.xml` | Java, Maven |
| `build.gradle` | Java, Kotlin, Gradle |

### カスタム設定ファイル（オプション）

```yaml
# custom-rules.yaml
custom_rules:
  - category: "プロジェクト固有"
    items:
      - "社内ライブラリの最新版を使用しているか"
      - "ログ出力形式が統一されているか"

disabled_rules:
  - "react/no-deprecated-apis"  # 特定ルールを無効化

severity_overrides:
  "security/sql-injection": "critical"  # 重要度を上書き
```

## 出力

### 生成されるチェックリスト形式

```markdown
# コードレビューチェックリスト

**プロジェクト**: my-project
**検出技術**: React, TypeScript, Node.js
**生成日時**: 2026-01-29T15:35:00

---

## 機能性
- [ ] 要件を満たしているか
- [ ] エッジケースが考慮されているか
- [ ] エラーハンドリングが適切か

## TypeScript
- [ ] `any` 型を使用していないか
- [ ] 適切な型定義がされているか
- [ ] null/undefined チェックがあるか

## React
- [ ] コンポーネントの責務が明確か
- [ ] 不要な再レンダリングがないか
- [ ] useEffect の依存配列が正しいか
- [ ] カスタムフックの分離ができているか

## セキュリティ
- [ ] XSS対策がされているか
- [ ] 入力値のサニタイズがあるか
- [ ] 機密情報がハードコードされていないか

...
```

### 出力オブジェクト

```typescript
interface ChecklistOutput {
  markdown: string;           // Markdown形式のチェックリスト
  detectedStack: string[];    // 検出された技術スタック
  categories: Category[];     // カテゴリ別のチェック項目
  metadata: {
    projectName: string;
    generatedAt: string;
    version: string;
  };
}
```

## 技術スタック別チェック項目

### React

| カテゴリ | チェック項目 |
|----------|------------|
| コンポーネント設計 | 責務の明確さ、適切な分割 |
| Hooks | useEffect依存配列、カスタムフック |
| 状態管理 | 不要な状態の排除、適切な配置 |
| パフォーマンス | 不要な再レンダリング、メモ化 |
| アクセシビリティ | ARIA属性、キーボード操作 |

### TypeScript

| カテゴリ | チェック項目 |
|----------|------------|
| 型定義 | any禁止、適切な型付け |
| null安全性 | null/undefinedチェック |
| 型の再利用 | interfaceの共通化 |
| strictモード | 厳密な型チェック |

### Rails

| カテゴリ | チェック項目 |
|----------|------------|
| N+1クエリ | includesの使用 |
| セキュリティ | Strong Parameters, CSRF |
| バリデーション | モデルバリデーション |
| テスト | RSpec/Minitest |
| マイグレーション | 可逆性、インデックス |

### Python

| カテゴリ | チェック項目 |
|----------|------------|
| 型ヒント | type hints の使用 |
| 例外処理 | 適切なエラーハンドリング |
| PEP8 | コーディング規約準拠 |
| テスト | pytest, カバレッジ |

## 共通チェック項目

全てのプロジェクトに適用される共通項目：

### 機能性
- 要件を満たしているか
- エッジケースが考慮されているか
- エラーハンドリングが適切か

### 可読性
- 変数名・関数名が明確か
- コメントが適切に書かれているか
- 複雑なロジックに説明があるか

### 保守性
- 重複コードがないか
- 適切に分割されているか
- 将来の変更に対応しやすいか

### セキュリティ
- 入力値の検証があるか
- 機密情報がハードコードされていないか
- 脆弱性がないか

### パフォーマンス
- 非効率な処理がないか
- 適切なインデックスが使われているか

### テスト
- ユニットテストがあるか
- テストケースが十分か
- テストが通っているか

## 参考

- このスキルは `multi-agent-GuP` の `instructions/platoon_deputy.md` のレビューチェックリストを参考に設計
- チームメンバー2（副中隊長 instructions 作成時）の提案により作成

## バージョン

- 1.0.0 - 初版作成
