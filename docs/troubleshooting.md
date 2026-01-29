# Panzer Project トラブルシューティングガイド

このドキュメントでは、Panzer Projectで発生しやすい問題とその解決方法を説明します。

---

## 目次

1. [よくある問題と解決方法](#1-よくある問題と解決方法)
2. [エラーメッセージ一覧](#2-エラーメッセージ一覧)
3. [デバッグ方法](#3-デバッグ方法)
4. [環境設定](#4-環境設定)
5. [FAQ](#5-faq)

---

## 1. よくある問題と解決方法

### 1.1 tmuxセッションが起動しない

**症状:**
```
$ ./scripts/panzer_vor.sh
Error: Work directory does not exist: /path/to/project
```

**原因:**
- 作業ディレクトリが存在しない
- panzer_vor.sh 内の `WORK_DIR` 設定が間違っている

**解決方法:**
```bash
# 1. 作業ディレクトリの存在確認
ls -la /path/to/project

# 2. panzer_vor.sh の設定確認
vim scripts/panzer_vor.sh
# WORK_DIR を正しいパスに修正

# 3. 再実行
./scripts/panzer_vor.sh
```

---

### 1.2 send-keysが効かない

**症状:**
- `notify.sh` でメッセージを送っても反応しない
- ペインにメッセージが表示されない

**原因:**
1. セッション/ペインが存在しない
2. ペインIDの指定が間違っている
3. ペインがビジー状態（処理中）

**解決方法:**

```bash
# 1. セッション一覧を確認
tmux list-sessions

# 2. ペイン一覧を確認
tmux list-panes -t panzer-hq

# 3. 正しい形式で指定
# 形式: セッション名:ウィンドウ番号.ペイン番号
./scripts/notify.sh panzer-hq:0.0 "テストメッセージ"

# 4. ペインの状態確認
./scripts/check_status.sh panzer-hq:0.0
```

**ポイント:**
- send-keysは「Enter」を送らないとコマンドが実行されない
- notify.sh は自動でEnterを送信する設計

---

### 1.3 エージェントが応答しない

**症状:**
- メッセージを送っても返答がない
- ペインが「idle」状態のまま動かない

**原因:**
1. Claude Codeが起動していない
2. ペインがフリーズしている
3. 入力待ち状態になっている

**解決方法:**

```bash
# 1. ペインの状態確認
./scripts/check_status.sh --all

# 2. 特定のペインの最新出力を確認
tmux capture-pane -t panzer-hq:0.0 -p | tail -20

# 3. ペインにアタッチして直接確認
tmux attach -t panzer-hq

# 4. 必要に応じてペインを再起動
tmux send-keys -t panzer-hq:0.0 C-c  # 処理をキャンセル
tmux send-keys -t panzer-hq:0.0 "claude" Enter  # 再起動
```

---

### 1.4 yqがインストールされていない

**症状:**
```
./scripts/worktree.sh: line XX: yq: command not found
```

**原因:**
- yq（YAML処理ツール）がインストールされていない

**解決方法:**

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install -y yq

# または、バイナリを直接インストール（推奨）
VERSION=v4.35.1
BINARY=yq_linux_amd64
wget https://github.com/mikefarah/yq/releases/download/${VERSION}/${BINARY} -O /tmp/yq
chmod +x /tmp/yq
sudo mv /tmp/yq /usr/local/bin/yq

# 確認
yq --version
```

---

## 2. エラーメッセージ一覧

### check_status.sh

| エラーメッセージ | 原因 | 対処法 |
|------------------|------|--------|
| `[ERROR] Session/pane not found` | 指定したセッション/ペインが存在しない | `tmux list-sessions` で存在確認 |
| `[ERROR] Session 'xxx' not found` | セッションが起動していない | `./scripts/panzer_vor.sh` で起動 |
| `Error: --session requires a session name` | `-s` オプションに引数がない | `-s panzer-hq` のように指定 |

### notify.sh

| エラーメッセージ | 原因 | 対処法 |
|------------------|------|--------|
| `[ERROR] Target pane is required` | ペイン指定がない | `notify.sh panzer-hq:0.0 "msg"` |
| `[ERROR] Message is required` | メッセージ指定がない | 第2引数にメッセージを指定 |
| `[ERROR] Session/pane not found` | ペインが存在しない | セッション起動を確認 |

### worktree.sh

| エラーメッセージ | 原因 | 対処法 |
|------------------|------|--------|
| `[ERROR] Not a git repository` | Gitリポジトリではない | `git init` または正しいディレクトリへ移動 |
| `[ERROR] Branch name required` | ブランチ名指定がない | `worktree.sh create feature/xxx` |
| `[ERROR] Worktree already exists` | 既にワークツリーが存在 | `worktree.sh list` で確認 |

### record_briefing.sh

| エラーメッセージ | 原因 | 対処法 |
|------------------|------|--------|
| `[ERROR] --decision requires content` | 決定内容が空 | `--decision "内容"` を指定 |
| `[ERROR] --action requires --assignee` | 担当者指定がない | `--assignee "名前"` を追加 |
| `[ERROR] --action requires --deadline` | 期限指定がない | `--deadline "2026-01-30"` を追加 |

### panzer_vor.sh

| エラーメッセージ | 原因 | 対処法 |
|------------------|------|--------|
| `Error: Work directory does not exist` | 作業ディレクトリがない | パスを確認、ディレクトリを作成 |

---

## 3. デバッグ方法

### 3.1 ログの確認方法

```bash
# ログディレクトリ構造
logs/
├── daily/          # 日次ログ
│   └── 2026-01-29.log
└── briefing/       # ブリーフィングログ
    └── briefing_xxx.log

# 最新のログを確認
tail -f logs/daily/$(date +%Y-%m-%d).log

# 特定日のログを検索
grep "ERROR" logs/daily/2026-01-29.log
```

### 3.2 ペインの状態確認

```bash
# 全ペインの状態確認
./scripts/check_status.sh --all

# 特定セッションのみ
./scripts/check_status.sh --session panzer-hq

# JSON形式で取得（スクリプト連携用）
./scripts/check_status.sh --all --json

# busy状態のペインのみ抽出
./scripts/check_status.sh --all --json | jq '.panes[] | select(.status == "busy")'
```

### 3.3 tmux操作のヒント

```bash
# セッション一覧
tmux list-sessions

# ウィンドウ一覧
tmux list-windows -t panzer-hq

# ペイン一覧（詳細）
tmux list-panes -t panzer-hq -F "#{pane_index}: #{pane_current_command} #{pane_pid}"

# ペインにアタッチ
tmux attach -t panzer-hq

# 特定ペインを選択（アタッチ中）
# Ctrl+b → q → ペイン番号

# ペイン間移動
# Ctrl+b → 矢印キー

# セッションからデタッチ
# Ctrl+b → d

# ペインの出力をキャプチャ
tmux capture-pane -t panzer-hq:0.0 -p -S -100 > /tmp/pane_output.txt

# ペインをkill
tmux kill-pane -t panzer-hq:0.5
```

### 3.4 リアルタイム監視

```bash
# 5秒ごとに状態を更新表示
watch -n 5 ./scripts/check_status.sh --all

# 特定ペインの出力を監視
while true; do
    clear
    tmux capture-pane -t panzer-hq:0.0 -p | tail -20
    sleep 2
done
```

---

## 4. 環境設定

### 4.1 必要なツール

| ツール | 用途 | インストール方法 |
|--------|------|------------------|
| tmux | セッション管理 | `sudo apt install tmux` |
| yq | YAML処理 | 上記参照 |
| jq | JSON処理 | `sudo apt install jq` |
| Claude Code | AIエージェント | `npm install -g @anthropic-ai/claude-code` |

### 4.2 推奨環境

```
OS: Ubuntu 22.04 LTS 以上
Shell: Bash 5.0 以上
tmux: 3.0 以上
Node.js: 18.0 以上（Claude Code用）
```

### 4.3 環境確認スクリプト

```bash
#!/bin/bash
echo "=== 環境確認 ==="
echo -n "tmux: "; tmux -V 2>/dev/null || echo "未インストール"
echo -n "yq: "; yq --version 2>/dev/null || echo "未インストール"
echo -n "jq: "; jq --version 2>/dev/null || echo "未インストール"
echo -n "claude: "; claude --version 2>/dev/null || echo "未インストール"
echo -n "bash: "; bash --version | head -1
```

### 4.4 初期セットアップ

```bash
# 1. リポジトリをクローン
git clone <repository-url> panzer-project
cd panzer-project

# 2. 必要なツールをインストール
sudo apt update
sudo apt install -y tmux jq

# yq のインストール
VERSION=v4.35.1
wget https://github.com/mikefarah/yq/releases/download/${VERSION}/yq_linux_amd64 -O /tmp/yq
chmod +x /tmp/yq
sudo mv /tmp/yq /usr/local/bin/yq

# 3. スクリプトに実行権限を付与
chmod +x scripts/*.sh

# 4. セッションを起動
./scripts/panzer_vor.sh
```

---

## 5. FAQ

### Q1: セッションを全て終了するには？

```bash
# 特定セッションを終了
tmux kill-session -t panzer-hq

# 全セッションを終了
tmux kill-server
```

### Q2: ペインのレイアウトが崩れた

```bash
# アタッチしてから
tmux attach -t panzer-hq

# レイアウトを均等に
# Ctrl+b → :
# select-layout tiled

# または even-horizontal / even-vertical
```

### Q3: 特定のペインだけ再起動したい

```bash
# ペインの処理をキャンセル
tmux send-keys -t panzer-hq:0.0 C-c

# 少し待ってからClaude Codeを再起動
sleep 1
tmux send-keys -t panzer-hq:0.0 "claude" Enter
```

### Q4: メッセージが文字化けする

```bash
# ロケール確認
locale

# UTF-8に設定
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# .bashrc に追加して永続化
echo 'export LANG=en_US.UTF-8' >> ~/.bashrc
```

### Q5: check_status.sh が遅い

```bash
# 特定セッションのみ確認（高速）
./scripts/check_status.sh --session panzer-hq

# 単一ペインのみ確認（最速）
./scripts/check_status.sh panzer-hq:0.0
```

### Q6: ログが大きくなりすぎた

```bash
# 古いログを削除（7日以上前）
find logs/daily/ -name "*.log" -mtime +7 -delete

# ログをローテーション
gzip logs/daily/2026-01-*.log
```

### Q7: worktreeが壊れた

```bash
# ワークツリー一覧
git worktree list

# 壊れたワークツリーを修復
git worktree prune

# 強制削除
git worktree remove --force worktrees/platoon1
```

---

## サポート

問題が解決しない場合は、以下の情報を添えて報告してください：

1. 実行したコマンド
2. エラーメッセージ全文
3. `./scripts/check_status.sh --all` の出力
4. `tmux list-sessions` の出力
5. 環境情報（OS、tmuxバージョン等）

---

*最終更新: 2026-01-29*
