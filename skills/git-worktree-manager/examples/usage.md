# Git Worktree Manager 詳細使用例

## 概要

このドキュメントでは、git-worktree-manager スキルで生成されるスクリプトの詳細な使用例を説明する。

## 基本的なワークフロー

### 1. ワークツリーの作成

各チームが独立したワークツリーで作業を開始する。

```bash
# チームAlphaのワークツリーを作成（新規ブランチ）
./scripts/worktree.sh create team-alpha feature/user-auth

# チームBetaのワークツリーを作成（既存ブランチ）
./scripts/worktree.sh create team-beta develop

# チームGammaのワークツリーを作成
./scripts/worktree.sh create team-gamma feature/ci-pipeline
```

ディレクトリ構造:
```
my-project/
├── scripts/
│   └── worktree.sh
├── worktrees/
│   ├── team-alpha/    # feature/user-auth ブランチ
│   ├── team-beta/     # develop ブランチ
│   └── team-gamma/    # feature/ci-pipeline ブランチ
└── src/               # メインワークツリー (main ブランチ)
```

### 2. 一覧表示

現在のワークツリー状況を確認する。

```bash
./scripts/worktree.sh list
```

出力例:
```
=== Git Worktree 一覧 ===

パス                           ブランチ                       状態
===========================================================================
(main)                         main                           active
worktrees/team-alpha           feature/user-auth              active
worktrees/team-beta            develop                        active
worktrees/team-gamma           feature/ci-pipeline            active
```

### 3. 状態確認

全ワークツリーの git status を確認する。

```bash
./scripts/worktree.sh status
```

出力例:
```
=== 全ワークツリーの状態 ===

[メイン] /home/user/my-project
## main...origin/main

[team-alpha] /home/user/my-project/worktrees/team-alpha/
## feature/user-auth
 M src/auth/login.ts
 A src/auth/logout.ts

[team-beta] /home/user/my-project/worktrees/team-beta/
## develop...origin/develop

[team-gamma] /home/user/my-project/worktrees/team-gamma/
## feature/ci-pipeline
 M .github/workflows/ci.yml
```

### 4. ブランチ切り替え

作業中のワークツリーで別のブランチに切り替える。

```bash
# 既存ブランチに切り替え
./scripts/worktree.sh switch team-alpha feature/user-profile

# 新規ブランチを作成して切り替え
./scripts/worktree.sh switch team-beta feature/api-refactor
```

未コミットの変更がある場合:
```
[WARNING] 未コミットの変更があります
 M src/auth/login.ts

続行しますか？ (y/N):
```

### 5. クリーンアップ

不要になったワークツリーを削除する。

```bash
# 確認プロンプトあり
./scripts/worktree.sh cleanup team-gamma

# 確認をスキップ
./scripts/worktree.sh cleanup team-gamma --force
```

## マルチエージェント開発での活用

### シナリオ: 3チーム並列開発

```bash
# 1. 各中隊のワークツリーを作成
./scripts/worktree.sh create panzer-1 feature/auth
./scripts/worktree.sh create panzer-2 feature/dashboard
./scripts/worktree.sh create panzer-3 feature/reports

# 2. 各中隊が独立して作業
cd worktrees/panzer-1  # 第1中隊
# ... 認証機能を実装 ...

cd worktrees/panzer-2  # 第2中隊
# ... ダッシュボードを実装 ...

cd worktrees/panzer-3  # 第3中隊
# ... レポート機能を実装 ...

# 3. 進捗確認
./scripts/worktree.sh status

# 4. 作業完了後、クリーンアップ
./scripts/worktree.sh cleanup panzer-1
./scripts/worktree.sh cleanup panzer-2
./scripts/worktree.sh cleanup panzer-3
```

## 注意事項

### 同一ブランチの制限

Git Worktree では、同一ブランチを複数のワークツリーで同時に開くことはできない。

```bash
# これはエラーになる
./scripts/worktree.sh create team-alpha feature/login
./scripts/worktree.sh create team-beta feature/login  # エラー！
```

### 未コミットの変更

ワークツリー削除時に未コミットの変更がある場合、警告が表示される。
重要な変更は必ずコミットまたはスタッシュしてから削除すること。

### ブランチの残存

ワークツリーを削除しても、ブランチは残る。
不要なブランチは別途削除が必要。

```bash
# ワークツリー削除
./scripts/worktree.sh cleanup team-alpha

# ブランチも削除する場合（別途実行）
git branch -d feature/user-auth
```

## トラブルシューティング

### ワークツリーが見つからない

```
[ERROR] ワークツリーが存在しません: /path/to/worktrees/team-x
```

→ `./scripts/worktree.sh list` で現在のワークツリーを確認

### ワークツリーの残骸

強制終了などで残骸が残った場合:

```bash
git worktree prune
```

### ロックされたワークツリー

別プロセスがワークツリーを使用中の場合:

```bash
# ロック解除（注意して使用）
git worktree unlock /path/to/worktree
```
