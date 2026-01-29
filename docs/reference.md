# Panzer Project リファレンス

> **Version**: 1.0.0
> **Last Updated**: 2026-01-29
> **パンツァー・フォー！**

---

## 目次

1. [スクリプトリファレンス](#スクリプトリファレンス)
   - [panzer_vor.sh](#panzer_vorsh)
   - [notify.sh](#notifysh)
   - [check_status.sh](#check_statussh)
   - [worktree.sh](#worktreesh)
   - [call_briefing.sh](#call_briefingsh)
   - [record_briefing.sh](#record_briefingsh)
   - [end_briefing.sh](#end_briefingsh)
2. [テンプレートリファレンス](#テンプレートリファレンス)
3. [設定ファイルリファレンス](#設定ファイルリファレンス)

---

## スクリプトリファレンス

### panzer_vor.sh

tmuxセッションを起動し、マルチエージェントシステムを開始する。

#### 概要

| 項目 | 内容 |
|------|------|
| 場所 | `scripts/panzer_vor.sh` |
| 用途 | tmuxセッション起動・エージェント配置 |
| 依存 | tmux |

#### 使用方法

```bash
./scripts/panzer_vor.sh
```

#### セッション構成

| セッション | 説明 | メンバー |
|------------|------|----------|
| panzer-hq | 司令部 | miho, maho, yukari, saori, hana, mako |
| panzer-1 | 第1中隊 | kay, nishi, arisa, naomi, tamada, fukuda |
| panzer-2 | 第2中隊 | katyusha, mika, klara, nonna, aki, mikko |
| panzer-3 | 第3中隊 | darjeeling, erika, orange_pekoe, koume, assam, rukuriri |

#### 戻り値

| Exit Code | 説明 |
|-----------|------|
| 0 | 正常終了 |
| 1 | tmux起動失敗 |

---

### notify.sh

指定したtmuxペインにメッセージを送信する。send-keysを2回に分けて実行（安全な送信方式）。

#### 概要

| 項目 | 内容 |
|------|------|
| 場所 | `scripts/notify.sh` |
| 用途 | ペイン間通知 |
| 依存 | tmux |

#### 使用方法

```bash
./scripts/notify.sh <target_pane> <message>
```

#### 引数

| 引数 | 必須 | 説明 | 例 |
|------|------|------|-----|
| target_pane | ✅ | 対象ペイン（session:window.pane形式） | `panzer-hq:0.0` |
| message | ✅ | 送信メッセージ | `'新しい指示があります'` |

#### 使用例

```bash
# 司令部ペイン0に通知
./scripts/notify.sh panzer-hq:0.0 '新しい指示があります'

# 第1中隊ペイン1に通知
./scripts/notify.sh panzer-1:0.1 '報告書を確認されよ'
```

#### 戻り値

| Exit Code | 説明 |
|-----------|------|
| 0 | 送信成功 |
| 1 | 送信失敗（セッション/ペイン不存在等） |

#### ログ

`logs/notify.log` に送信履歴を記録。

---

### check_status.sh

tmuxペインの状態（アイドル/処理中）を確認する。

#### 概要

| 項目 | 内容 |
|------|------|
| 場所 | `scripts/check_status.sh` |
| 用途 | ペイン状態確認 |
| 依存 | tmux |

#### 使用方法

```bash
./scripts/check_status.sh [OPTIONS] [PANE]
```

#### オプション

| オプション | 説明 |
|------------|------|
| `--all`, `-a` | 全セッションの全ペインを確認 |
| `--session`, `-s NAME` | 指定セッションの全ペインを確認 |
| `--json`, `-j` | JSON形式で出力 |
| `--help`, `-h` | ヘルプ表示 |

#### 使用例

```bash
# 単一ペインの状態確認
./scripts/check_status.sh panzer-1:0.0

# 全ペインの状態確認
./scripts/check_status.sh --all

# JSON形式で全ペイン確認
./scripts/check_status.sh --json --all

# 司令部セッションのみ確認
./scripts/check_status.sh -s panzer-hq
```

#### 戻り値

| Exit Code | 説明 |
|-----------|------|
| 0 | 正常終了 |
| 1 | エラー |

---

### worktree.sh

git worktreeを管理する。中隊ごとに独立したワークツリーを作成・管理。

#### 概要

| 項目 | 内容 |
|------|------|
| 場所 | `scripts/worktree.sh` |
| 用途 | git worktree管理 |
| 依存 | git |

#### 使用方法

```bash
./scripts/worktree.sh <command> [arguments]
```

#### コマンド

| コマンド | 説明 | 書式 |
|----------|------|------|
| `create` | ワークツリー作成 | `create <platoon> <branch>` |
| `list` | 一覧表示 | `list` |
| `switch` | ブランチ切り替え | `switch <platoon> <branch>` |
| `cleanup` | ワークツリー削除 | `cleanup <platoon> [--force]` |
| `status` | 全ワークツリー状態表示 | `status` |
| `help` | ヘルプ表示 | `help` |

#### 使用例

```bash
# 第1中隊用ワークツリー作成
./scripts/worktree.sh create platoon1 feature/auth

# 一覧表示
./scripts/worktree.sh list

# ブランチ切り替え
./scripts/worktree.sh switch platoon1 feature/dashboard

# ワークツリー削除（確認あり）
./scripts/worktree.sh cleanup platoon1

# 強制削除
./scripts/worktree.sh cleanup platoon1 --force

# 全ワークツリー状態確認
./scripts/worktree.sh status
```

#### ディレクトリ構成

```
worktrees/
├── platoon1/   # 第1中隊用
├── platoon2/   # 第2中隊用
└── platoon3/   # 第3中隊用
```

#### 戻り値

| Exit Code | 説明 |
|-----------|------|
| 0 | 正常終了 |
| 1 | エラー（既存ワークツリー、git未初期化等） |

---

### call_briefing.sh

ブリーフィングを招集する。参加者に自動通知。

#### 概要

| 項目 | 内容 |
|------|------|
| 場所 | `scripts/call_briefing.sh` |
| 用途 | ブリーフィング招集・通知 |
| 依存 | tmux, notify.sh |

#### 使用方法

```bash
./scripts/call_briefing.sh <briefing_type> [platoon] <agenda>
```

#### 引数

| 引数 | 必須 | 説明 | 値 |
|------|------|------|-----|
| briefing_type | ✅ | ブリーフィングの種類 | `hq_briefing`, `platoon_briefing`, `battalion_briefing` |
| platoon | ⚠️ | 中隊番号（platoon_briefingのみ必須） | `platoon1`, `platoon2`, `platoon3` |
| agenda | ✅ | 議題 | 文字列 |

#### ブリーフィングタイプ

| タイプ | 説明 | 参加者 |
|--------|------|--------|
| hq_briefing | 司令部ブリーフィング | miho, maho, yukari, saori, hana, mako |
| platoon_briefing | 中隊ブリーフィング | 指定中隊の全員 |
| battalion_briefing | 大隊ブリーフィング | 全員 |

#### 使用例

```bash
# 司令部ブリーフィング
./scripts/call_briefing.sh hq_briefing '週次進捗確認'

# 第1中隊ブリーフィング
./scripts/call_briefing.sh platoon_briefing platoon1 '機能Aの実装方針'

# 大隊ブリーフィング（全員参加）
./scripts/call_briefing.sh battalion_briefing '全体キックオフ'
```

#### 生成ファイル

```
queue/briefings/briefing_{timestamp}.yaml
```

#### 戻り値

| Exit Code | 説明 |
|-----------|------|
| 0 | 招集成功 |
| 1 | エラー（引数不足等） |

---

### record_briefing.sh

ブリーフィング中の議論を記録する。発言、決定事項、アクションアイテムを記録。

#### 概要

| 項目 | 内容 |
|------|------|
| 場所 | `scripts/record_briefing.sh` |
| 用途 | 議論記録 |
| 依存 | なし |

#### 使用方法

```bash
# 発言記録
./scripts/record_briefing.sh BRIEFING_ID SPEAKER "CONTENT"

# 決定事項記録
./scripts/record_briefing.sh BRIEFING_ID --decision "CONTENT"

# アクションアイテム記録
./scripts/record_briefing.sh BRIEFING_ID --action "CONTENT" [OPTIONS]
```

#### オプション（--action用）

| オプション | 説明 | 例 |
|------------|------|-----|
| `--assignee NAME` | 担当者 | `--assignee naomi` |
| `--deadline DATE` | 期限（YYYY-MM-DD） | `--deadline "2026-01-30"` |
| `--priority LEVEL` | 優先度 | `--priority high` |

#### 使用例

```bash
# 発言記録
./scripts/record_briefing.sh briefing_001 miho "パンツァー・フォー！"
./scripts/record_briefing.sh briefing_001 kay "OK! Let's do it!"

# 決定事項記録
./scripts/record_briefing.sh briefing_001 --decision "機能Aはplatoon1が担当"

# アクションアイテム記録
./scripts/record_briefing.sh briefing_001 --action "バグ修正" \
  --assignee naomi \
  --deadline "2026-01-30" \
  --priority high
```

#### 生成ファイル

```
queue/briefings/briefing_{id}/discussion.yaml
```

#### 戻り値

| Exit Code | 説明 |
|-----------|------|
| 0 | 記録成功 |
| 1 | エラー |

---

### end_briefing.sh

ブリーフィングを終了し、議事録を自動生成する。

#### 概要

| 項目 | 内容 |
|------|------|
| 場所 | `scripts/end_briefing.sh` |
| 用途 | ブリーフィング終了・議事録生成 |
| 依存 | notify.sh, yq（推奨） |

#### 使用方法

```bash
./scripts/end_briefing.sh <briefing_id> [options]
```

#### 引数

| 引数 | 必須 | 説明 | 例 |
|------|------|------|-----|
| briefing_id | ✅ | ブリーフィングのID | `briefing_001` |

#### オプション

| オプション | 説明 |
|------------|------|
| `--no-notify` | 参加者への通知をスキップ |
| `--help`, `-h` | ヘルプ表示 |

#### 処理フロー

1. `queue/briefings/<briefing_id>/` の内容を読み込み
2. 議論記録を時系列で整理
3. 決定事項を抽出してリスト化
4. アクションアイテムを抽出してリスト化
5. 完成した議事録を保存先に移動
6. 参加者に通知（--no-notify で省略可）

#### 使用例

```bash
# ブリーフィング終了・議事録生成
./scripts/end_briefing.sh briefing_001

# 通知なしで終了
./scripts/end_briefing.sh briefing_001 --no-notify
```

#### 出力先

| ブリーフィングタイプ | 出力先 |
|-----------|--------|
| hq_briefing | `queue/hq/minutes/` |
| platoon_briefing | `queue/platoon{N}/minutes/` |
| battalion_briefing | `queue/battalion/minutes/` |
| その他 | `queue/briefings/minutes/` |

#### 戻り値

| Exit Code | 説明 |
|-----------|------|
| 0 | 正常終了 |
| 1 | エラー |

---

## テンプレートリファレンス

### テンプレート一覧

| ファイル | 用途 |
|----------|------|
| `dashboard.md.template` | ダッシュボード |
| `briefing_schedule.yaml.template` | ブリーフィングスケジュール |
| `briefing_discussion.yaml.template` | ブリーフィング議事内容 |
| `minutes.yaml.template` | 議事録 |
| `hq_briefing.yaml.template` | 司令部ブリーフィング |
| `platoon_briefing.yaml.template` | 中隊ブリーフィング |
| `battalion_briefing.yaml.template` | 大隊ブリーフィング |
| `order.yaml.template` | 指示書 |
| `report.yaml.template` | 報告書 |
| `task.yaml.template` | タスク |

### プレースホルダー形式

プレースホルダーは `{{PLACEHOLDER_NAME}}` 形式で記述。

### 共通プレースホルダー

| プレースホルダー | 説明 | 例 |
|-----------------|------|-----|
| `{{TIMESTAMP}}` | タイムスタンプ | `2026-01-29T15:00:00` |
| `{{BRIEFING_ID}}` | ブリーフィング ID | `briefing_001` |
| `{{BRIEFING_TYPE}}` | ブリーフィングタイプ | `hq_briefing` |
| `{{ORGANIZER}}` | 主催者 | `miho` |
| `{{AGENDA}}` | 議題 | `週次進捗確認` |

### ブリーフィングテンプレート固有

| プレースホルダー | 説明 |
|-----------------|------|
| `{{PARTICIPANT_N}}` | 参加者N |
| `{{DECISION_N}}` | 決定事項N |
| `{{ACTION_ITEM_N}}` | アクションアイテムN |
| `{{ASSIGNEE_N}}` | 担当者N |
| `{{DEADLINE_N}}` | 期限N |

### 使用例

```yaml
# briefing_schedule.yaml.template の使用例
briefing:
  briefing_id: "{{BRIEFING_ID}}"
  type: "{{BRIEFING_TYPE}}"
  organizer: "{{ORGANIZER}}"
  scheduled_time: "{{TIMESTAMP}}"

participants:
  required:
    - "{{PARTICIPANT_1}}"
    - "{{PARTICIPANT_2}}"

agenda:
  - item: "{{AGENDA}}"
```

---

## 設定ファイルリファレンス

### config/battalion.yaml

大隊構成を定義。

```yaml
# Battalion Configuration
name: "panzer-battalion"
commander: miho          # 大隊長
deputy: maho             # 副大隊長
staff:                   # 司令部スタッフ
  - yukari
  - saori
  - hana
  - mako
platoons:                # 中隊一覧
  - platoon1
  - platoon2
  - platoon3
```

| キー | 型 | 説明 |
|------|-----|------|
| name | string | 大隊名 |
| commander | string | 大隊長ID |
| deputy | string | 副大隊長ID |
| staff | array | 司令部スタッフIDリスト |
| platoons | array | 中隊IDリスト |

### config/settings.yaml

システム設定を定義。

```yaml
# System Settings
language: ja             # 言語設定
log_level: info          # ログレベル
worktree_base: worktrees/  # ワークツリーベースパス

communication:
  polling_disabled: true  # ポーリング禁止
  method: send-keys       # 通信方式
```

| キー | 型 | 説明 | 値 |
|------|-----|------|-----|
| language | string | 言語 | `ja`, `en` |
| log_level | string | ログレベル | `debug`, `info`, `warn`, `error` |
| worktree_base | string | ワークツリーパス | ディレクトリパス |
| communication.polling_disabled | boolean | ポーリング禁止 | `true`/`false` |
| communication.method | string | 通信方式 | `send-keys` |

### config/platoons/

各中隊の構成を定義（platoon1.yaml, platoon2.yaml, platoon3.yaml）。

---

## 付録

### ディレクトリ構成

```
panzer-project/
├── config/              # 設定ファイル
│   ├── battalion.yaml
│   ├── settings.yaml
│   └── platoons/
├── scripts/             # スクリプト
│   ├── panzer_vor.sh
│   ├── notify.sh
│   ├── check_status.sh
│   ├── worktree.sh
│   ├── call_briefing.sh
│   ├── record_briefing.sh
│   └── end_briefing.sh
├── templates/           # テンプレート
├── queue/               # キュー・通信
│   ├── hq/
│   ├── platoon1/
│   ├── platoon2/
│   ├── platoon3/
│   └── briefings/
├── logs/                # ログ
├── worktrees/           # git worktree
└── docs/                # ドキュメント
```

### 関連ドキュメント

- [README.md](../README.md) - プロジェクト概要
- [instructions/](../instructions/) - 役割別指示書

---

*パンツァー・フォー！*
