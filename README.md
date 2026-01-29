# Panzer Project

[![Multi-Agent](https://img.shields.io/badge/Multi--Agent-24_Agents-blue)](.)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Powered-green)](.)
[![tmux](https://img.shields.io/badge/tmux-Session_Based-orange)](.)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

> **パンツァー・フォー！** 24名の精鋭エージェントが織りなす、マルチエージェント並列開発基盤

---

## 概要

**Panzer Project** は、アニメ『ガールズ＆パンツァー』をモチーフとした、Claude Code + tmux によるマルチエージェント並列開発システムです。

大隊長・みほを頂点とする階層的な指揮系統のもと、24名のエージェントが連携してソフトウェア開発を行います。各エージェントはキャラクターの個性を持ち、YAML通信プロトコルとブリーフィングシステムを通じて自律的に協調作業を進めます。

```
「戦車道、はじめます！」 - 西住みほ
```

---

## 特徴

### 24エージェントによる並列開発
- **司令部（6名）**: 全体統括、情報収集、技術方針決定
- **3個中隊（各6名）**: フロントエンド、バックエンド、デザイン、テスト

### 階層的な指揮系統
```
┌─────────────────────────────────────────────────────────────────┐
│                        司令部 (panzer-hq)                       │
│    みほ(大隊長) → まほ(副大隊長) → 参謀(ゆかり,さおり,華,麻子)   │
└─────────────────────────┬───────────────────────────────────────┘
                          │
        ┌─────────────────┼─────────────────┐
        ▼                 ▼                 ▼
┌───────────────┐ ┌───────────────┐ ┌───────────────┐
│ 第1中隊       │ │ 第2中隊       │ │ 第3中隊       │
│ (panzer-1)    │ │ (panzer-2)    │ │ (panzer-3)    │
│ ケイ指揮      │ │ カチューシャ  │ │ ダージリン    │
│ Thunder-      │ │ Pravda-       │ │ Kuromorimine- │
│ Chihatan      │ │ Continuation  │ │ St.Gloriana   │
└───────────────┘ └───────────────┘ └───────────────┘
```

### git worktree による並列作業
- 各中隊が独立したworktreeで作業
- 競合を避けながら並列開発が可能

### ブリーフィングシステムによる議論
- 司令部ブリーフィング、中隊ブリーフィング、大隊全体ブリーフィング
- YAML形式での議事録自動生成
- 決定事項・アクションアイテムの追跡

---

## クイックスタート

### 前提条件

| ツール | 用途 | インストール |
|--------|------|-------------|
| tmux | セッション管理 | `apt install tmux` / `brew install tmux` |
| Claude Code | AIエージェント | [公式サイト](https://claude.ai/code) |
| yq | YAML処理 | `apt install yq` / `brew install yq` |

### セットアップ手順

```bash
# 1. リポジトリをクローン
git clone https://github.com/yourname/panzer-project.git
cd panzer-project

# 2. スクリプトに実行権限を付与
chmod +x scripts/*.sh

# 3. 設定ファイルを確認
cat config/settings.yaml
```

### 起動方法

```bash
# Panzer Project を起動（24エージェント展開）
./scripts/panzer_vor.sh

# セッション一覧を確認
tmux list-sessions

# 司令部セッションにアタッチ
tmux attach -t panzer-hq
```

---

## ディレクトリ構成

```
panzer-project/
├── characters/          # キャラクター設定（24名分）
│   ├── miho.yaml
│   ├── maho.yaml
│   └── ...
│
├── config/              # システム設定
│   ├── battalion.yaml   # 大隊設定
│   ├── settings.yaml    # 全体設定
│   └── platoons/        # 中隊設定
│       ├── platoon1.yaml
│       ├── platoon2.yaml
│       └── platoon3.yaml
│
├── instructions/        # 役職別指示書
│   ├── battalion_commander.md   # 大隊長（みほ）
│   ├── chief_of_staff.md        # 副大隊長（まほ）
│   ├── platoon_leader.md        # 中隊長
│   ├── platoon_deputy.md        # 副中隊長
│   ├── frontend.md              # フロントエンド担当
│   ├── backend.md               # バックエンド担当
│   ├── design.md                # デザイン担当
│   └── tester.md                # テスト担当
│
├── templates/           # YAMLテンプレート
│   ├── order.yaml.template          # 指令テンプレート
│   ├── report.yaml.template         # 報告テンプレート
│   ├── task.yaml.template           # タスクテンプレート
│   ├── hq_briefing.yaml.template     # 司令部ブリーフィング
│   ├── platoon_briefing.yaml.template # 中隊ブリーフィング
│   └── battalion_briefing.yaml.template # 大隊ブリーフィング
│
├── scripts/             # 運用スクリプト
│   ├── panzer_vor.sh        # システム起動
│   ├── call_briefing.sh     # ブリーフィング開催
│   ├── record_briefing.sh   # 議論記録
│   ├── end_briefing.sh      # ブリーフィング終了・議事録生成
│   ├── notify.sh            # 通知送信
│   └── worktree.sh          # worktree管理
│
├── skills/              # スキル定義（10種類）
│   ├── character-yaml-generator/
│   ├── dashboard-generator/
│   ├── git-worktree-manager/
│   └── ...
│
├── queue/               # タスクキュー
│   ├── hq/              # 司令部キュー
│   ├── platoon1/        # 第1中隊キュー
│   ├── platoon2/        # 第2中隊キュー
│   ├── platoon3/        # 第3中隊キュー
│   ├── battalion/       # 大隊全体キュー
│   └── briefings/       # ブリーフィング関連ファイル
│
├── worktrees/           # git worktree
│   ├── platoon1/
│   ├── platoon2/
│   └── platoon3/
│
├── logs/                # ログファイル
├── docs/                # ドキュメント
└── status/              # ステータス管理
```

---

## 使い方

### 基本的なワークフロー

```
1. みほ（大隊長）がプロジェクト方針を決定
2. まほ（副大隊長）が各中隊にタスクを分配
3. 各中隊長が担当メンバーにサブタスクを割り当て
4. メンバーが実装・テストを実施
5. 副中隊長がコードレビュー
6. 中隊長が進捗を司令部に報告
7. みほが全体進捗を確認、次の方針を決定
```

### ブリーフィングの開催方法

```bash
# 司令部ブリーフィングを開催
./scripts/call_briefing.sh hq "週次進捗確認"

# 第1中隊ブリーフィングを開催
./scripts/call_briefing.sh platoon1 "フロントエンド設計レビュー"

# 大隊全体ブリーフィングを開催
./scripts/call_briefing.sh battalion "マイルストーン1完了報告"
```

### ブリーフィング中の議論記録

```bash
# 発言を記録
./scripts/record_briefing.sh mtg_001 miho "パンツァー・フォー！"
./scripts/record_briefing.sh mtg_001 kay "OK! Let's do it!"

# 決定事項を記録
./scripts/record_briefing.sh mtg_001 --decision "機能Aはplatoon1が担当"

# アクションアイテムを記録
./scripts/record_briefing.sh mtg_001 --action "API設計書作成" \
  --assignee naomi --deadline "2026-01-30"
```

### ブリーフィング終了と議事録生成

```bash
# ブリーフィングを終了し議事録を生成
./scripts/end_briefing.sh mtg_001

# 生成される議事録: queue/hq/minutes/mtg_001_minutes.yaml
```

### タスクの割り当て方法

```bash
# 指令YAMLを作成して配置
cat > queue/platoon1/tasks/task_001.yaml << EOF
task:
  task_id: task_001
  description: "ログイン画面のUI実装"
  assignee: arisa
  deadline: "2026-01-31"
  priority: high
EOF

# 担当者に通知
./scripts/notify.sh panzer-1:0.2 "新しいタスクが割り当てられました"
```

---

## キャラクター一覧

### 司令部 (panzer-hq) - 6名

| セッション | キャラクター | 役職 | 担当 |
|------------|--------------|------|------|
| 0.0 | 西住みほ | 大隊長 | 全体統括・最終決定 |
| 0.1 | 西住まほ | 副大隊長 | タスク管理・調整 |
| 0.2 | 秋山優花里 | 情報参謀 | 情報収集・分析 |
| 0.3 | 武部沙織 | 通信参謀 | 連絡調整・通知管理 |
| 0.4 | 五十鈴華 | 記録参謀 | 議事録・文書管理 |
| 0.5 | 冷泉麻子 | 技術参謀 | 技術方針・アーキテクチャ |

### 第1中隊 (panzer-1) - Thunder-Chihatan Alliance - 6名

| セッション | キャラクター | 役職 | 担当 |
|------------|--------------|------|------|
| 0.0 | ケイ | 中隊長 | 中隊統括 |
| 0.1 | 西絹代 | 副中隊長 | コードレビュー |
| 0.2 | アリサ | 開発メンバー | フロントエンド |
| 0.3 | ナオミ | 開発メンバー | バックエンド |
| 0.4 | 玉田 | 開発メンバー | デザイン |
| 0.5 | 福田 | 開発メンバー | テスト |

### 第2中隊 (panzer-2) - Pravda-Continuation Alliance - 6名

| セッション | キャラクター | 役職 | 担当 |
|------------|--------------|------|------|
| 0.0 | カチューシャ | 中隊長 | 中隊統括 |
| 0.1 | ミカ | 副中隊長 | コードレビュー |
| 0.2 | クラーラ | 開発メンバー | フロントエンド |
| 0.3 | ノンナ | 開発メンバー | バックエンド |
| 0.4 | アキ | 開発メンバー | デザイン |
| 0.5 | ミッコ | 開発メンバー | テスト |

### 第3中隊 (panzer-3) - Kuromorimine-St.Gloriana Alliance - 6名

| セッション | キャラクター | 役職 | 担当 |
|------------|--------------|------|------|
| 0.0 | ダージリン | 中隊長 | 中隊統括 |
| 0.1 | 逸見エリカ | 副中隊長 | コードレビュー |
| 0.2 | オレンジペコ | 開発メンバー | フロントエンド |
| 0.3 | 小梅 | 開発メンバー | バックエンド |
| 0.4 | アッサム | 開発メンバー | デザイン |
| 0.5 | ルクリリ | 開発メンバー | テスト |

---

## ライセンス

MIT License

---

## 謝辞

- **ガールズ＆パンツァー**: キャラクター設定・世界観のインスピレーション元
  - (C) GIRLS und PANZER Projekt
- **Anthropic**: Claude Code の提供
- **tmux**: 優れたターミナルマルチプレクサ

---

```
「諦めたらそこで試合終了ですよ」
「...それは戦車道じゃなくてバスケでは？」

パンツァー・フォー！
```
