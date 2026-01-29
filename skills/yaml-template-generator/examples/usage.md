# yaml-template-generator 使用例

## 基本的な使用方法

### 1. 入力ファイルの準備

`sample-config.yaml` を参考に、プロジェクト設定ファイルを作成する。

```yaml
project:
  name: "my-project"
  description: "プロジェクトの説明"

roles:
  hierarchy:
    - level: 1
      name: manager
      can_send_to: [worker]
    - level: 2
      name: worker
      can_send_to: []

queue_structure:
  tasks: "queue/tasks/"
  reports: "queue/reports/"
```

### 2. スキルの実行

```bash
/yaml-template-generator --input my-config.yaml --output templates/
```

### 3. 生成されたテンプレートの使用

生成されたテンプレートは `templates/` ディレクトリに配置される。

## テンプレートの使い方

### 指示テンプレート（order.yaml.template）

司令部から中隊への指示を作成する場合：

```bash
# テンプレートをコピー
cp templates/order.yaml.template queue/hq_to_platoon/platoon1.yaml

# プレースホルダーを置換（エディタで編集）
# {{ORDER_ID}} → ord_20260129_001
# {{FROM_ID}} → miho
# {{TO_ID}} → kay
# ...

# 通知
./scripts/notify.sh panzer-1:0.0 "新しい指示があります"
```

### 報告テンプレート（report.yaml.template）

タスク完了時の報告を作成する場合：

```bash
# テンプレートをコピー
cp templates/report.yaml.template queue/platoon1/reports/arisa_report.yaml

# プレースホルダーを置換
# {{WORKER_ID}} → arisa
# {{TASK_ID}} → task_20260129_001
# {{STATUS}} → done
# ...

# 通知
./scripts/notify.sh panzer-1:0.1 "報告書を確認してください"
```

### タスクテンプレート（task.yaml.template）

乗組員へのタスク割り当てを作成する場合：

```bash
# テンプレートをコピー
cp templates/task.yaml.template queue/platoon1/tasks/arisa.yaml

# プレースホルダーを置換
# {{TASK_ID}} → subtask_A1
# {{PARENT_CMD_ID}} → cmd_001
# {{TASK_DESCRIPTION}} → フロントエンド実装
# ...

# 通知
./scripts/notify.sh panzer-1:0.2 "タスクが割り当てられた"
```

## プレースホルダー一覧

| プレースホルダー | 説明 | 取得方法 |
|-----------------|------|----------|
| `{{ORDER_ID}}` | 指示ID | `ord_YYYYMMDD_NNN` 形式 |
| `{{TASK_ID}}` | タスクID | `task_YYYYMMDD_NNN` 形式 |
| `{{TIMESTAMP}}` | タイムスタンプ | `date "+%Y-%m-%dT%H:%M:%S"` |
| `{{FROM_ID}}` | 発信者ID | キャラクターID |
| `{{TO_ID}}` | 宛先ID | キャラクターID |
| `{{PRIORITY}}` | 優先度 | critical/high/medium/low |
| `{{STATUS}}` | ステータス | テンプレート種別による |
| `{{WORKER_ID}}` | 作業者ID | キャラクターID |

## カスタマイズ

### カスタムフィールドの追加

`custom_fields` で追加フィールドを定義できる：

```yaml
custom_fields:
  report:
    - name: skill_candidate
      required: true
      description: "スキル化候補の検討結果"
  task:
    - name: acceptance_criteria
      required: false
      description: "受け入れ条件"
```

### プロトコル設定

`protocol` でID形式やステータス値をカスタマイズ可能：

```yaml
protocol:
  id_formats:
    order: "ORD-{YYYYMMDD}-{NNN}"
  status_values:
    task:
      - todo
      - doing
      - done
      - blocked
```
