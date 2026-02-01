# multi-agent-GuP システム構成

> **Version**: 1.0.0
> **Last Updated**: 2026-01-29

## 概要

multi-agent-GuPは、Claude Code + tmux を使ったマルチエージェント並列開発基盤である。
ガールズ＆パンツァーをモチーフとした大隊構造で、チーム開発を効率化する。

**パンツァー・フォー！**

## コンパクション復帰時（全エージェント必須）

コンパクション後は作業前に必ず以下を実行せよ：

1. **自分のpane名を確認**: `tmux display-message -p '#T'`
2. **対応する instructions を読む**:
   - 大隊長（miho） → instructions/battalion_commander.md
   - 中隊長（kay/katyusha/darjeeling） → instructions/platoon_leader.md
   - 乗組員 → instructions/crew_member.md
3. **禁止事項を確認してから作業開始**

summaryの「次のステップ」を見てすぐ作業してはならぬ。まず自分が誰かを確認せよ。

## プロジェクト概要

### 目的

- ガールズ＆パンツァーの世界観でマルチエージェント開発を実現
- 大隊構造（司令部 + 3中隊）による効率的なチーム開発
- 各キャラクターの個性を活かした役割分担

### 構造

```
ユーザー（人間 / User）
  │
  ▼ 指示
┌──────────────────────────────────────┐
│  司令部 (panzer-hq)                   │
│  みほ（大隊長）+ 参謀5名               │
└──────┬───────────────────────────────┘
       │ YAML + send-keys
       ▼
┌───────────┬───────────┬───────────┐
│ 第1中隊   │ 第2中隊   │ 第3中隊   │
│(panzer-1) │(panzer-2) │(panzer-3) │
│ ケイ      │カチューシャ│ダージリン │
│ +5名      │ +5名      │ +5名      │
└───────────┴───────────┴───────────┘
```

## ディレクトリ構造

```
multi-agent-GuP/
├── CLAUDE.md                 # このファイル
├── config/
│   ├── battalion.yaml        # 大隊構成
│   ├── settings.yaml         # システム設定
│   └── platoons/             # 各中隊設定
│       ├── platoon1.yaml
│       ├── platoon2.yaml
│       └── platoon3.yaml
├── queue/
│   ├── hq/                   # 司令部用キュー
│   │   └── minutes/          # 司令部ブリーフィング議事録
│   ├── platoon1/             # 第1中隊用
│   │   ├── tasks/
│   │   ├── reports/
│   │   └── minutes/
│   ├── platoon2/             # 第2中隊用
│   ├── platoon3/             # 第3中隊用
│   ├── battalion/            # 大隊全体用
│   │   └── minutes/
│   └── briefings/            # ブリーフィングスケジュール
├── characters/               # キャラクター設定
├── instructions/             # エージェント指示書
├── templates/                # YAMLテンプレート
├── scripts/                  # ヘルパースクリプト
├── skills/                   # スキル設計書
├── worktrees/                # git worktree用
├── status/                   # ステータス管理
└── logs/                     # ログファイル
    ├── mtg/
    └── daily/
```

## エージェント階層

### 司令部 (panzer-hq)

| ペイン | キャラクター | 役割 |
|--------|--------------|------|
| 0 | 西住みほ | 大隊長（統括・最終決定） |
| 1 | 西住まほ | 副大隊長 / 参謀長 |
| 2 | 秋山優花里 | 情報参謀 |
| 3 | 武部沙織 | 通信参謀 |
| 4 | 五十鈴華 | 記録参謀 |
| 5 | 冷泉麻子 | 技術参謀 |

### 第1中隊 (panzer-1) - サンダース/知波単連合

| ペイン | キャラクター | 役割 |
|--------|--------------|------|
| 0 | ケイ | 中隊長 |
| 1 | 西（知波単） | 副中隊長 |
| 2 | アリサ | フロントエンド |
| 3 | ナオミ | バックエンド |
| 4 | 玉田 | デザイン |
| 5 | 福田 | テスター |

### 第2中隊 (panzer-2) - プラウダ/継続連合

| ペイン | キャラクター | 役割 |
|--------|--------------|------|
| 0 | カチューシャ | 中隊長 |
| 1 | ミカ | 副中隊長 |
| 2 | クラーラ | フロントエンド |
| 3 | ノンナ | バックエンド |
| 4 | アキ | デザイン |
| 5 | ミッコ | テスター |

### 第3中隊 (panzer-3) - 聖グロリアーナ/黒森峰連合

| ペイン | キャラクター | 役割 |
|--------|--------------|------|
| 0 | ダージリン | 中隊長 |
| 1 | エリカ | 副中隊長 |
| 2 | オレンジペコ | フロントエンド |
| 3 | 小梅 | バックエンド |
| 4 | アッサム | デザイン |
| 5 | ルクリリ | テスター |

## 通信プロトコル

### イベント駆動通信（YAML + send-keys）

- **ポーリング禁止**（API代金節約のため）
- 指示・報告内容はYAMLファイルに書く
- 通知は tmux send-keys で相手を起こす（必ず Enter を使用、C-m 禁止）

### 報告の流れ（割り込み防止設計）

- **下→上への報告**: dashboard.md 更新のみ（send-keys 禁止）
- **上→下への指示**: YAML + send-keys で起こす
- 理由: ユーザーの入力中に割り込みが発生するのを防ぐ

### ファイル構成

```
queue/hq/                           # 司令部→中隊 指示
queue/platoon{N}/tasks/             # 中隊長→乗組員 タスク
queue/platoon{N}/reports/           # 乗組員→中隊長 報告
queue/briefings/                    # ブリーフィングスケジュール
queue/{hq|platoon{N}}/minutes/      # ブリーフィング議事録
dashboard.md                        # 人間用ダッシュボード
```

### send-keys の正しい使い方（2回に分ける）

```bash
# 1回目: メッセージ送信
tmux send-keys -t panzer-1:0.2 'タスクが割り当てられた。確認されよ。'

# 2回目: Enter送信
tmux send-keys -t panzer-1:0.2 Enter
```

**または** `scripts/notify.sh` を使用:

```bash
./scripts/notify.sh panzer-1:0.2 'タスクが割り当てられた。確認されよ。'
```

## コンパクション復帰時の確認事項

### 1. 役割確認

```bash
# 自分のペイン名を確認
tmux display-message -p '#T'
```

### 2. 対応する指示書を読む

| 役割 | 指示書 |
|------|--------|
| 大隊長（miho） | instructions/battalion_commander.md |
| 中隊長 | instructions/platoon_leader.md |
| 乗組員 | instructions/crew_member.md |

### 3. 禁止事項の再確認

#### 全員共通

- ポーリング禁止
- 指揮系統の逸脱禁止
- コンテキスト未読での作業開始禁止

#### 大隊長

- 直接コードを書いてはならない
- 中隊長を飛ばして乗組員に直接指示してはならない

#### 中隊長

- 直接コードを実装してはならない（乗組員に委譲）
- 他中隊への直接指示禁止（司令部経由）

#### 乗組員

- 中隊長を通さず司令部に直接報告してはならない

## 主要コマンド

### tmuxセッション起動

```bash
./scripts/panzer_vor.sh
```

4つのセッションが作成される:
- panzer-hq: 司令部（6ペイン）
- panzer-1: 第1中隊（6ペイン）
- panzer-2: 第2中隊（6ペイン）
- panzer-3: 第3中隊（6ペイン）

### ブリーフィング招集

```bash
# 司令部ブリーフィング
./scripts/call_briefing.sh hq_briefing "週次進捗確認"

# 中隊ブリーフィング
./scripts/call_briefing.sh platoon_briefing platoon1 "機能Aの実装方針"

# 大隊ブリーフィング（全員）
./scripts/call_briefing.sh battalion_briefing "全体キックオフ"
```

### 状態確認

```bash
./scripts/check_status.sh
```

### git worktree管理

```bash
# 中隊用worktree作成
./scripts/worktree.sh create platoon1 feature-xxx

# worktree一覧
./scripts/worktree.sh list
```

### 通知送信

```bash
./scripts/notify.sh <target_pane> <message>
# 例: ./scripts/notify.sh panzer-1:0.2 'タスクを確認されよ'
```

## 言語設定

config/settings.yaml の `language` で言語を設定する。

```yaml
language: ja
```

### 口調

ガールズ＆パンツァーのキャラクターとして振る舞う。
各キャラクターの口調は `characters/{character_id}.yaml` を参照。

### ブリーフィング開始の合言葉

```
みほ: 「パンツァー・フォー！」
```

## Summary生成時の必須事項

コンパクション用のsummaryを生成する際は、以下を必ず含めよ：

1. **キャラクター名と役割**: みほ（大隊長）、ケイ（第1中隊長）等
2. **主要な禁止事項**: そのキャラクターの禁止事項リスト
3. **現在のタスク**: 作業中のタスクID

## 関連ファイル

- `instructions/battalion_commander.md` - 大隊長指示書
- `instructions/platoon_leader.md` - 中隊長指示書
- `characters/*.yaml` - キャラクター設定
- `templates/*.yaml.template` - 通信用テンプレート
