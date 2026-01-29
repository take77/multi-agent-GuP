# yaml-template-generator

プロジェクト通信用YAMLテンプレートを自動生成するスキル。

## 概要

マルチエージェントシステムで使用する通信用YAMLテンプレート群を、プロジェクト設定から自動生成する。指示（order）、報告（report）、タスク（task）、MTG関連など、様々なテンプレートを統一的なフォーマットで生成できる。

提案者: チームメンバー2（D2作業中に提案）

## 機能

- 指示テンプレート生成（order）
- 報告テンプレート生成（report）
- タスクテンプレート生成（task）
- MTGテンプレート生成（mtg_schedule, mtg_discussion）
- `{{PLACEHOLDER}}` 形式のプレースホルダー
- YAMLコメントでの使用方法説明

## 入力

| 入力 | 型 | 必須 | 説明 |
|------|---|------|------|
| project_config | YAML | Yes | プロジェクト設定（名前、役割構成） |
| protocol_spec | YAML | No | 通信プロトコル仕様 |
| custom_fields | YAML | No | カスタムフィールド定義 |

### project_config の構造

```yaml
project:
  name: "panzer-project"
  description: "ガルパン・マルチエージェントシステム"

roles:
  hierarchy:
    - level: 1
      name: battalion_commander
      can_send_to: [platoon_leader]
    - level: 2
      name: platoon_leader
      can_send_to: [deputy, crew]
    - level: 3
      name: crew
      can_send_to: [deputy]

queue_structure:
  hq: "queue/hq/"
  platoon: "queue/platoon{{N}}/"
  reports: "queue/platoon{{N}}/reports/"
  tasks: "queue/platoon{{N}}/tasks/"
```

## 出力

| 出力 | 型 | 説明 |
|------|---|------|
| templates/ | Directory | テンプレートファイル群 |
| order.yaml.template | YAML | 指示テンプレート |
| report.yaml.template | YAML | 報告テンプレート |
| task.yaml.template | YAML | タスクテンプレート |
| mtg_schedule.yaml.template | YAML | MTGスケジュールテンプレート |
| mtg_discussion.yaml.template | YAML | MTG議事録テンプレート |

## ワークフロー

```
入力: project_config.yaml
         │
         ▼
    ┌────────────────┐
    │ 1. 入力検証     │
    │   - 必須項目確認 │
    │   - 役割構成検証 │
    └────────┬───────┘
             │
             ▼
    ┌────────────────┐
    │ 2. 指示テンプレ │
    │   order.yaml   │
    └────────┬───────┘
             │
             ▼
    ┌────────────────┐
    │ 3. 報告テンプレ │
    │   report.yaml  │
    └────────┬───────┘
             │
             ▼
    ┌────────────────┐
    │ 4. タスクテンプレ│
    │   task.yaml    │
    └────────┬───────┘
             │
             ▼
    ┌────────────────┐
    │ 5. MTGテンプレ  │
    │   mtg_*.yaml   │
    └────────┬───────┘
             │
             ▼
出力: templates/ ディレクトリ
```

## 使用例

### 基本的な使用

```bash
# スキルを実行
/yaml-template-generator --input project_config.yaml --output templates/
```

### 出力例

`examples/` ディレクトリに実際の出力例がある。

## テンプレートの特徴

### プレースホルダー形式

```yaml
# {{PLACEHOLDER}} 形式で可変部分を定義
order_id: "{{ORDER_ID}}"
timestamp: "{{TIMESTAMP}}"
```

### YAMLコメントでの説明

```yaml
# ============================================================
# 指示テンプレート (Order Template)
# ============================================================
# 用途: 司令部→中隊、中隊長→乗組員への指示
#
# 使用方法:
#   1. このテンプレートをコピー
#   2. {{PLACEHOLDER}} を実際の値に置換
#   3. 指示先の queue ディレクトリに配置
```

## ディレクトリ構成

```
skills/yaml-template-generator/
├── README.md              # このファイル
├── spec.yaml              # 仕様定義
└── examples/
    ├── sample-config.yaml # 入力例
    ├── sample-templates/  # 出力例
    │   ├── order.yaml.template
    │   ├── report.yaml.template
    │   └── task.yaml.template
    └── usage.md           # 詳細な使用例
```

## 関連スキル

- `multi-agent-config-generator`: 組織構成からconfig一式を生成
- `character-instructions-generator`: キャラクター設定からinstructionsを生成
