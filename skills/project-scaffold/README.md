# project-scaffold

マルチエージェントプロジェクトの雛形ディレクトリ構造を一括作成するスキル。

## 概要

新しいマルチエージェントプロジェクトを開始する際に、必要なディレクトリ構造とテンプレートファイルを自動生成する。設定YAMLに基づいて、プロジェクト固有の構成を柔軟に作成可能。

## 機能

- 設定YAMLからディレクトリ構造を自動生成
- 必要な空ファイル・テンプレートファイルの配置
- `.gitignore` の自動生成
- 中隊（platoon）構成に応じた動的ディレクトリ作成

## 使用方法

### 基本的な使い方

```bash
# スキルを実行
scaffold-project --config project-config.yaml --output ./my-project
```

### 設定ファイル例

```yaml
project:
  name: "my-agent-project"
  type: "multi-agent"

structure:
  platoons: 3  # 中隊数
  include:
    - characters
    - scripts
    - instructions
    - templates
    - logs
    - queue
    - config
    - worktrees
    - status
```

## 生成されるディレクトリ構造

```
{project_name}/
├── characters/          # キャラクター設定
├── scripts/             # スクリプト
├── instructions/        # 指示書
├── templates/           # テンプレート
├── logs/
│   ├── daily/           # 日次ログ
│   └── briefing/             # ミーティングログ
├── queue/
│   ├── hq/              # 本部キュー
│   └── platoon{N}/      # 中隊別キュー
│       ├── tasks/
│       └── reports/
├── config/
│   └── platoons/        # 中隊設定
├── worktrees/
│   └── platoon{N}/      # 中隊別ワークツリー
├── status/              # ステータス管理
├── skills/              # スキル格納
└── .gitignore
```

## 入力

| パラメータ | 型 | 必須 | 説明 |
|-----------|-----|------|------|
| project_name | string | Yes | プロジェクト名 |
| config_yaml | file | Yes | 構成定義YAML |
| output_path | string | No | 出力先パス（デフォルト: カレント） |

## 出力

- 完成したディレクトリ構造
- 生成レポート（作成されたファイル一覧）

## 参考

このスキルは `multi-agent-GuP` の構成を参考に設計された。

## バージョン

- 1.0.0 - 初版作成
