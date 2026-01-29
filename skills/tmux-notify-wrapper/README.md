# tmux-notify-wrapper

tmux send-keys の2回分割送信を自動化するヘルパースクリプト生成スキル。

## 概要

マルチエージェントシステムにおいて、エージェント間の通知（tmux send-keys）を安全かつ確実に行うためのラッパースクリプトを生成する。Claude Codeの制約（send-keysでメッセージとEnterを1回で送れない問題）を解決し、エラーハンドリングとログ機能を備えたスクリプトを自動生成。

## 背景・動機

Claude Codeでtmux send-keysを使用する際、以下の問題がある：

```bash
# ❌ これは動作しない（Claude Codeの制約）
tmux send-keys -t session:0.0 'メッセージ' Enter

# ✅ 2回に分けて実行する必要がある
tmux send-keys -t session:0.0 'メッセージ'
tmux send-keys -t session:0.0 Enter
```

このスキルは、この2回分割送信を自動化し、さらに以下の機能を追加したスクリプトを生成する：

- 対象ペインの存在確認
- エラーハンドリング
- ログ出力
- カスタマイズ可能な設定

## 機能

- **2回分割送信の自動化**: メッセージ送信 + Enter送信を1コマンドで実行
- **ペイン存在確認**: 送信前に対象ペインの存在を確認
- **セッション存在確認**: 送信前に対象セッションの存在を確認
- **エラーハンドリング**: 送信失敗時の適切なエラー処理
- **ログ出力**: 送信履歴をログファイルに記録
- **カラー出力**: ターミナルでの視認性向上

## 使用方法

### スキル実行（スクリプト生成）

```bash
# 基本的な使い方
generate-notify-wrapper --project /path/to/project

# セッション命名規則を指定
generate-notify-wrapper \
  --project /path/to/project \
  --session-prefix "panzer"

# ログ出力先を指定
generate-notify-wrapper \
  --project /path/to/project \
  --log-dir "./logs"
```

### 生成されたスクリプトの使い方

```bash
# 基本的な使い方
./scripts/notify.sh <target_pane> <message>

# 例: panzer-1:0.0 にメッセージを送信
./scripts/notify.sh panzer-1:0.0 "新しい指示があります"

# 例: panzer-hq:0.1 にメッセージを送信
./scripts/notify.sh panzer-hq:0.1 "報告書を確認されよ"
```

## 入力

### project_path（必須）

スクリプトを生成するプロジェクトのルートディレクトリ。

### session_naming（オプション）

tmuxセッションの命名規則。

| 設定 | 説明 | 例 |
|------|------|-----|
| prefix | セッション名のプレフィックス | `panzer`, `battalion` |
| separator | セッションとウィンドウの区切り文字 | `:`, `-` |
| pane_format | ペイン指定形式 | `window.pane`, `window:pane` |

### log_dir（オプション）

ログファイルの出力先ディレクトリ。デフォルトは `./logs`。

### config（オプション）

詳細設定を含む設定ファイルパス。

```yaml
# config.yaml
notify:
  wait_after_message: 0.1    # メッセージ送信後の待機時間（秒）
  retry_count: 3             # 失敗時のリトライ回数
  retry_delay: 0.5           # リトライ間隔（秒）
  log_level: "INFO"          # ログレベル (DEBUG, INFO, WARN, ERROR)
  color_output: true         # カラー出力の有効/無効
```

## 出力

### notify_script

生成されるメインスクリプト。以下の機能を含む：

| 関数 | 説明 |
|------|------|
| `log_info` | 情報ログ出力 |
| `log_success` | 成功ログ出力 |
| `log_warn` | 警告ログ出力 |
| `log_error` | エラーログ出力 |
| `check_session_exists` | セッション存在確認 |
| `check_pane_exists` | ペイン存在確認 |
| `send_message` | 2回分割送信の実行 |
| `main` | メイン処理 |

### generation_report

生成レポート。以下を含む：

```yaml
generation_report:
  script_path: "/path/to/scripts/notify.sh"
  log_dir: "/path/to/logs"
  features_enabled:
    - session_check
    - pane_check
    - logging
    - color_output
    - retry
  config_applied:
    wait_after_message: 0.1
    retry_count: 3
```

## 生成されるスクリプトの詳細

### ディレクトリ構造

```
project/
├── scripts/
│   └── notify.sh         # メインスクリプト
└── logs/
    └── notify.log        # ログファイル
```

### スクリプトの動作フロー

```
1. 引数チェック
   ↓
2. セッション存在確認
   ↓ (存在しない場合はエラー終了)
3. ペイン存在確認
   ↓ (存在しない場合はエラー終了)
4. メッセージ送信（1回目）
   ↓
5. 待機（0.1秒）
   ↓
6. Enter送信（2回目）
   ↓
7. ログ出力
   ↓
8. 終了
```

### エラーコード

| コード | 意味 |
|--------|------|
| 0 | 成功 |
| 1 | 引数不足 |
| 2 | セッションが存在しない |
| 3 | ペインが存在しない |
| 4 | メッセージ送信失敗 |
| 5 | Enter送信失敗 |

## 使用例

### マルチエージェントシステムでの使用

```bash
# 副大隊長からチームメンバーへの指示
./scripts/notify.sh panzer-1:0.1 "member1、新しい任務がある。queue/tasks/member1.yaml を確認してください。"

# チームメンバーから副大隊長への報告
./scripts/notify.sh panzer-hq:0.0 "member1、任務完了です。報告書を確認してください。"
```

### スクリプトからの呼び出し

```bash
#!/bin/bash
# 複数のペインに通知を送信

TARGETS=("panzer-1:0.1" "panzer-1:0.2" "panzer-1:0.3")
MESSAGE="全員集合！新しい指示がある。"

for target in "${TARGETS[@]}"; do
    ./scripts/notify.sh "${target}" "${MESSAGE}"
done
```

### CI/CDでの使用

```yaml
# GitHub Actions
- name: Notify Agent
  run: |
    ./scripts/notify.sh ${{ env.TARGET_PANE }} "デプロイ完了: ${{ github.sha }}"
```

## 参考

- このスキルは `multi-agent-GuP` の `scripts/notify.sh` を参考に設計
- チームメンバー1（D1作業中）の提案により作成
- `multi-agent-GuP` の指示書で定義された2回分割送信ルールに準拠

## バージョン

- 1.0.0 - 初版作成
