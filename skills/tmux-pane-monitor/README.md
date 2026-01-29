# tmux-pane-monitor

tmuxセッション/ペインの状態監視スクリプトを生成するスキル。

## 概要

マルチエージェントシステムにおいて、各ペイン（エージェント）の状態（busy/idle）を監視するためのスクリプトを自動生成します。設定YAMLに基づいてセッション構成やbusy判定キーワードをカスタマイズできます。

## 機能

- **ペイン状態取得**: `tmux capture-pane` を使用した最新出力の取得
- **busy/idle判定**: キーワードベースのステータス判定
- **一括ステータス表示**: 全セッション/ペインの状態を一覧表示
- **JSON形式出力**: プログラム連携用のJSON出力オプション
- **セッション絞り込み**: 特定セッションのみの確認

## 使用方法

### 1. 設定YAMLを作成

```yaml
# config.yaml
sessions:
  - name: "panzer-hq"
    panes_count: 6
  - name: "panzer-1"
    panes_count: 6

busy_keywords:
  - thinking
  - Effecting
  - Running

idle_indicator: "❯"
```

### 2. スキルを実行

```bash
# スキルに設定YAMLを渡して監視スクリプトを生成
claude --skill tmux-pane-monitor --input config.yaml --output ./scripts/
```

### 3. 生成されたスクリプトを使用

```bash
# 単一ペインの状態確認
./scripts/check_status.sh panzer-1:0.0

# 全ペインの状態確認
./scripts/check_status.sh --all

# JSON形式で出力
./scripts/check_status.sh --all --json

# 特定セッションのみ
./scripts/check_status.sh --session panzer-hq
```

## 入力仕様

| パラメータ | 型 | 必須 | デフォルト | 説明 |
|------------|-----|------|------------|------|
| session_config | file | ✅ | - | セッション構成YAML |
| busy_keywords | array | - | (後述) | busy判定キーワード |
| idle_indicator | string | - | `❯` | idle判定キーワード |
| output_path | string | - | `./` | 出力先パス |
| include_colors | boolean | - | true | カラー出力を含めるか |

### デフォルトbusyキーワード

```
thinking, Thinking, Effecting, reading, Reading, writing, Writing,
Searching, Running, Executing, Processing, Loading, Analyzing
```

## 出力仕様

### 生成ファイル

| ファイル | 説明 |
|----------|------|
| `check_status.sh` | メイン監視スクリプト |

### 出力形式（CLI）

```
============================================================
 Project Name - Pane Status
============================================================

=== panzer-hq ===
panzer-hq:0.0   [idle]   ❯
panzer-hq:0.1   [busy]   thinking...
panzer-hq:0.2   [idle]   ❯

=== panzer-1 ===
panzer-1:0.0    [busy]   Effecting...
panzer-1:0.1    [idle]   ❯

============================================================
 Summary: Total=10 Busy=2 Idle=8
============================================================
```

### 出力形式（JSON）

```json
{
  "panes": [
    {"pane": "panzer-hq:0.0", "status": "idle", "activity": null},
    {"pane": "panzer-hq:0.1", "status": "busy", "activity": "thinking"}
  ],
  "summary": {
    "total": 10,
    "busy": 2,
    "idle": 8
  }
}
```

## ユースケース

1. **副大隊長がタスク割り当て前に確認**: idle状態のチームメンバーを探す
2. **大隊長が進捗確認**: 全体の稼働状況を把握
3. **自動化スクリプトとの連携**: JSON出力を解析してタスク自動割り当て
4. **デバッグ**: 特定ペインの最新出力を確認

## 関連スキル

- `tmux-session-generator`: tmuxセッション構成スクリプトの生成
- `tmux-notify-wrapper`: send-keysヘルパースクリプトの生成

## バージョン履歴

| バージョン | 日付 | 変更内容 |
|------------|------|----------|
| 1.0 | 2026-01-29 | 初版リリース |
