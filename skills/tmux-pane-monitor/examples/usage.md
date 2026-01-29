# tmux-pane-monitor 詳細使用例

## 基本的な使い方

### 1. 単一ペインの状態確認

```bash
# 特定のペインの状態を確認
./check_status.sh panzer-1:0.0
```

**出力例:**
```
panzer-1:0.0    [idle] ❯
```

```
panzer-1:0.0    [busy] thinking...
```

### 2. 全ペインの一括確認

```bash
# 全セッションの全ペインを確認
./check_status.sh --all
```

**出力例:**
```
============================================================
 Panzer Project - Pane Status
============================================================

=== panzer-hq ===
panzer-hq:0.0   [idle] ❯
panzer-hq:0.1   [busy] thinking...
panzer-hq:0.2   [idle] ❯
panzer-hq:0.3   [idle] ❯
panzer-hq:0.4   [busy] Effecting...
panzer-hq:0.5   [idle] ❯

=== panzer-1 ===
panzer-1:0.0    [busy] Running...
panzer-1:0.1    [idle] ❯
panzer-1:0.2    [idle] ❯
panzer-1:0.3    [busy] writing...
panzer-1:0.4    [idle] ❯
panzer-1:0.5    [idle] ❯

=== panzer-2 ===
panzer-2:0.0    [idle] ❯
panzer-2:0.1    [idle] ❯
panzer-2:0.2    [busy] thinking...
panzer-2:0.3    [idle] ❯
panzer-2:0.4    [idle] ❯
panzer-2:0.5    [idle] ❯

=== panzer-3 ===
panzer-3:0.0    [idle] ❯
panzer-3:0.1    [idle] ❯
panzer-3:0.2    [idle] ❯
panzer-3:0.3    [idle] ❯
panzer-3:0.4    [busy] Analyzing...
panzer-3:0.5    [idle] ❯

============================================================
 Summary: Total=24 Busy=6 Idle=18
============================================================
```

### 3. 特定セッションのみ確認

```bash
# 司令部セッションのみ確認
./check_status.sh --session panzer-hq
```

**出力例:**
```
=== panzer-hq ===
panzer-hq:0.0   [idle] ❯
panzer-hq:0.1   [busy] thinking...
panzer-hq:0.2   [idle] ❯
panzer-hq:0.3   [idle] ❯
panzer-hq:0.4   [idle] ❯
panzer-hq:0.5   [idle] ❯
```

---

## JSON形式出力

### 全ペインをJSON形式で出力

```bash
./check_status.sh --all --json
```

**出力例:**
```json
{
  "panes": [
    {"pane": "panzer-hq:0.0", "status": "idle", "activity": null},
    {"pane": "panzer-hq:0.1", "status": "busy", "activity": "thinking"},
    {"pane": "panzer-hq:0.2", "status": "idle", "activity": null},
    {"pane": "panzer-1:0.0", "status": "busy", "activity": "running"},
    {"pane": "panzer-1:0.1", "status": "idle", "activity": null}
  ],
  "summary": {
    "total": 24,
    "busy": 6,
    "idle": 18
  }
}
```

### 単一ペインをJSON形式で出力

```bash
./check_status.sh panzer-1:0.0 --json
```

**出力例:**
```json
{"pane": "panzer-1:0.0", "status": "busy", "activity": "thinking"}
```

---

## 実用的なユースケース

### 1. idle状態のペインを探す

```bash
# idle状態のペインのみ抽出
./check_status.sh --all --json | jq '.panes[] | select(.status == "idle") | .pane'
```

**出力例:**
```
"panzer-hq:0.0"
"panzer-hq:0.2"
"panzer-1:0.1"
...
```

### 2. busy状態のペイン数を確認

```bash
# busy状態のペイン数
./check_status.sh --all --json | jq '.summary.busy'
```

**出力例:**
```
6
```

### 3. 特定のアクティビティを持つペインを探す

```bash
# "thinking" 中のペインを探す
./check_status.sh --all --json | jq '.panes[] | select(.activity == "thinking") | .pane'
```

**出力例:**
```
"panzer-hq:0.1"
"panzer-2:0.2"
```

### 4. タスク割り当て前のチェック

```bash
#!/bin/bash
# idle状態のチームメンバーを探してタスクを割り当てる例

IDLE_PANE=$(./check_status.sh --all --json | jq -r '.panes[] | select(.status == "idle") | .pane' | head -1)

if [ -n "$IDLE_PANE" ]; then
    echo "タスク割り当て先: $IDLE_PANE"
    # tmux send-keys -t "$IDLE_PANE" "新しいタスク"
else
    echo "idle状態のペインがありません"
fi
```

### 5. 監視ループ

```bash
#!/bin/bash
# 5秒ごとに状態を確認

while true; do
    clear
    ./check_status.sh --all
    sleep 5
done
```

### 6. 全員がidle状態になるまで待機

```bash
#!/bin/bash
# 全ペインがidle状態になるまで待機

while true; do
    BUSY_COUNT=$(./check_status.sh --all --json | jq '.summary.busy')

    if [ "$BUSY_COUNT" -eq 0 ]; then
        echo "全ペインがidle状態です"
        break
    fi

    echo "待機中... busy: $BUSY_COUNT"
    sleep 10
done
```

---

## エラーハンドリング

### セッションが存在しない場合

```bash
./check_status.sh panzer-999:0.0
```

**出力例:**
```
[ERROR] panzer-999:0.0 - Pane not found
```

### JSON形式でのエラー

```bash
./check_status.sh panzer-999:0.0 --json
```

**出力例:**
```json
{"pane": "panzer-999:0.0", "status": "error", "message": "Pane not found"}
```

---

## ヒント

1. **カラー出力を無効化**: パイプ処理時は自動でカラーが無効になります
2. **JSON + jq**: 複雑なフィルタリングには `jq` コマンドが便利です
3. **watchコマンド**: `watch -n 5 ./check_status.sh --all` で定期監視
4. **cron連携**: 定期的なステータスログ取得に使用可能
