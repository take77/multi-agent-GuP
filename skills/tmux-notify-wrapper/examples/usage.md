# tmux-notify-wrapper 使用例

このドキュメントでは、tmux-notify-wrapper スキルの詳細な使用例を説明する。

## スキル実行（スクリプト生成）

### 1. 基本的な使い方

最もシンプルな使い方。デフォルト設定でスクリプトを生成する。

```bash
# コマンドライン
generate-notify-wrapper --project /path/to/my-project

# 出力
✓ Created: /path/to/my-project/scripts/notify.sh
✓ Created: /path/to/my-project/logs/ (directory)
✓ Script is executable (chmod +x applied)
```

### 2. セッション命名規則を指定

プロジェクト固有のセッション命名規則を設定する。

```bash
generate-notify-wrapper \
  --project /path/to/my-project \
  --session-prefix "panzer" \
  --session-separator "-"
```

### 3. 設定ファイルを使用

詳細な設定を設定ファイルで指定する。

```bash
generate-notify-wrapper --config ./notify-config.yaml
```

設定ファイル例:
```yaml
project_path: "/path/to/my-project"
session_naming:
  prefix: "panzer"
  separator: "-"
config:
  retry_count: 3
  retry_delay: 0.5
  log_level: "DEBUG"
```

### 4. ログ出力先をカスタマイズ

```bash
generate-notify-wrapper \
  --project /path/to/my-project \
  --log-dir /var/log/my-agent
```

## 生成されたスクリプトの使い方

### 基本的な使い方

```bash
# 構文
./scripts/notify.sh <target_pane> <message>

# 例
./scripts/notify.sh panzer-1:0.0 "新しい指示があります"
```

### マルチエージェントシステムでの使用

#### 副大隊長からチームメンバーへの指示

```bash
# チームメンバー1に指示
./scripts/notify.sh panzer-1:0.1 "member1、新しい任務がある。queue/tasks/member1.yaml を確認してください。"

# チームメンバー2に指示
./scripts/notify.sh panzer-1:0.2 "member2、新しい任務がある。queue/tasks/member2.yaml を確認してください。"

# 複数のチームメンバーに一斉指示
for i in {1..8}; do
    ./scripts/notify.sh "panzer-1:0.${i}" "全員集合！新しい指示がある。"
done
```

#### チームメンバーから副大隊長への報告

```bash
# 任務完了報告
./scripts/notify.sh panzer-hq:0.0 "member1、任務完了です。報告書を確認してください。"

# ブロック報告
./scripts/notify.sh panzer-hq:0.0 "member3、任務中断です。ブロック事項あり。"
```

#### 大隊長から副大隊長への指示

```bash
./scripts/notify.sh panzer-hq:0.0 "新しい命令がある。queue/battalion_to_deputy.yaml を確認してください。"
```

### エラーハンドリング

#### セッションが存在しない場合

```bash
$ ./scripts/notify.sh nonexistent:0.0 "テスト"
[ERROR] Session 'nonexistent' does not exist
# 終了コード: 2
```

#### ペインが存在しない場合

```bash
$ ./scripts/notify.sh panzer-1:0.99 "テスト"
[ERROR] Pane 'panzer-1:0.99' does not exist
# 終了コード: 3
```

#### 引数が不足している場合

```bash
$ ./scripts/notify.sh panzer-1:0.0
[ERROR] Missing required arguments
Usage: ./scripts/notify.sh <target_pane> <message>
# 終了コード: 1
```

### スクリプトからの呼び出し

#### Bash スクリプト

```bash
#!/bin/bash
# broadcast.sh - 全チームメンバーに一斉通知

NOTIFY_SCRIPT="./scripts/notify.sh"
SESSION="panzer-1"
MESSAGE="$1"

if [ -z "${MESSAGE}" ]; then
    echo "Usage: $0 <message>"
    exit 1
fi

for pane in {1..8}; do
    echo "Notifying member${pane}..."
    "${NOTIFY_SCRIPT}" "${SESSION}:0.${pane}" "${MESSAGE}"

    if [ $? -ne 0 ]; then
        echo "Warning: Failed to notify member${pane}"
    fi
done

echo "Broadcast complete"
```

#### Python スクリプト

```python
#!/usr/bin/env python3
import subprocess
import sys

def notify(target_pane: str, message: str) -> bool:
    """tmux send-keys ヘルパーを呼び出す"""
    result = subprocess.run(
        ["./scripts/notify.sh", target_pane, message],
        capture_output=True,
        text=True
    )

    if result.returncode != 0:
        print(f"Error: {result.stderr}", file=sys.stderr)
        return False

    print(result.stdout)
    return True

# 使用例
notify("panzer-1:0.1", "Pythonからの通知テスト")
```

### ログの確認

```bash
# 最新のログを確認
tail -f logs/notify.log

# 特定期間のログを検索
grep "2026-01-29" logs/notify.log

# エラーログのみ表示
grep "\[ERROR\]" logs/notify.log

# 成功した送信のみ表示
grep "\[SUCCESS\]" logs/notify.log
```

ログ出力例:
```
[2026-01-29T15:47:00] [INFO] Sending message to 'panzer-1:0.1'
[2026-01-29T15:47:00] [SUCCESS] Message sent successfully to 'panzer-1:0.1': 新しい指示があります
[2026-01-29T15:47:05] [INFO] Sending message to 'panzer-1:0.99'
[2026-01-29T15:47:05] [ERROR] Pane 'panzer-1:0.99' does not exist
```

## 高度な使用例

### リトライ機能の活用

ネットワーク不安定時やtmuxの一時的な問題に対応:

```yaml
# config.yaml
config:
  retry_count: 5      # 最大5回リトライ
  retry_delay: 1.0    # 1秒間隔でリトライ
```

### デバッグモード

問題調査時に詳細なログを出力:

```yaml
# config.yaml
config:
  log_level: "DEBUG"
```

### サイレントモード

標準出力を抑制し、ファイルログのみ:

```yaml
# config.yaml
config:
  log_to_stdout: false
  log_to_file: true
```

### CI/CD との統合

#### GitHub Actions

```yaml
# .github/workflows/notify.yml
name: Notify Agent

on:
  workflow_dispatch:
    inputs:
      target:
        description: 'Target pane'
        required: true
      message:
        description: 'Message'
        required: true

jobs:
  notify:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v4

      - name: Send notification
        run: |
          ./scripts/notify.sh "${{ inputs.target }}" "${{ inputs.message }}"
```

### 監視スクリプトとの統合

```bash
#!/bin/bash
# health-check.sh - エージェントの死活監視

check_agent() {
    local pane=$1
    local name=$2

    # ペインが存在するか確認
    if tmux list-panes -t "${pane}" >/dev/null 2>&1; then
        echo "[OK] ${name} is alive"
    else
        echo "[NG] ${name} is down"
        # 管理者に通知
        ./scripts/notify.sh "admin:0.0" "警告: ${name} がダウンしています"
    fi
}

check_agent "panzer-1:0.0" "deputy"
check_agent "panzer-1:0.1" "member1"
check_agent "panzer-1:0.2" "member2"
```

## トラブルシューティング

### よくある問題と解決策

| 問題 | 原因 | 解決策 |
|------|------|--------|
| `Session does not exist` | セッションが起動していない | `tmux new-session -d -s <name>` で作成 |
| `Pane does not exist` | ペイン番号が間違っている | `tmux list-panes -t <session>` で確認 |
| メッセージが途中で切れる | 特殊文字を含んでいる | シングルクォートで囲む |
| ログファイルが作成されない | 権限がない | `chmod +x scripts/notify.sh` を実行 |

### デバッグ方法

```bash
# スクリプトのデバッグモード実行
bash -x ./scripts/notify.sh panzer-1:0.0 "テスト"

# tmux の状態確認
tmux list-sessions
tmux list-windows -t <session>
tmux list-panes -t <session>:<window>
```

---

*このドキュメントは tmux-notify-wrapper v1.0 に基づいて作成されました。*
