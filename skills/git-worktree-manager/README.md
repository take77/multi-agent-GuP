# git-worktree-manager

マルチエージェント用 Git Worktree 管理スクリプト生成スキル。

## 概要

マルチエージェントシステムにおいて、チーム/中隊ごとに独立した Git Worktree を管理するためのスクリプトを自動生成する。各エージェントが独立したブランチで作業できる環境を構築する。

## 機能

- ワークツリーの作成・削除
- ブランチ管理（作成、切り替え）
- 一覧表示
- クリーンアップ
- チーム/中隊ごとの独立管理
- 全ワークツリーの状態確認

## サブコマンド

| コマンド | 説明 | 例 |
|----------|------|-----|
| `create` | ワークツリーを作成 | `create platoon1 feature/login` |
| `list` | ワークツリー一覧を表示 | `list` |
| `switch` | ブランチを切り替え | `switch platoon1 feature/signup` |
| `cleanup` | ワークツリーを削除 | `cleanup platoon1 [--force]` |
| `status` | 全ワークツリーの状態を表示 | `status` |

## 使用例

### 入力（worktree-config.yaml）

```yaml
project:
  name: my-project
  path: /home/user/projects/my-project
  worktrees_dir: worktrees

teams:
  - name: platoon1
    description: 第1中隊
  - name: platoon2
    description: 第2中隊
  - name: platoon3
    description: 第3中隊

naming:
  pattern: "{team}"  # worktrees/platoon1, worktrees/platoon2, ...
```

### 出力（worktree.sh）

上記YAMLから、以下のサブコマンドを持つ管理スクリプトが生成される：
- create: 指定チームのワークツリーを作成
- list: 全ワークツリーを一覧表示
- switch: ブランチ切り替え
- cleanup: ワークツリー削除
- status: 状態確認

## インストール

```bash
# スキルディレクトリをコピー
cp -r skills/git-worktree-manager /path/to/your/project/skills/
```

## 使い方

1. `worktree-config.yaml` を作成
2. スキルを実行（Claude Codeに依頼）
3. 生成された `worktree.sh` を使用

```bash
# ワークツリー作成
./scripts/worktree.sh create platoon1 feature/auth

# 一覧表示
./scripts/worktree.sh list

# 状態確認
./scripts/worktree.sh status

# ブランチ切り替え
./scripts/worktree.sh switch platoon1 feature/dashboard

# 削除
./scripts/worktree.sh cleanup platoon1
```

## ファイル構成

```
git-worktree-manager/
├── README.md              # このファイル
├── spec.yaml              # スキル仕様定義
└── examples/
    ├── sample-config.yaml # 入力例
    ├── sample-worktree.sh # 出力例
    └── usage.md           # 詳細な使用例
```

## 前提条件

- Git 2.5以上（worktree サポート）
- Bash 4.0以上

## 仕様

詳細な仕様は `spec.yaml` を参照。

## 関連

- [Git Worktree Documentation](https://git-scm.com/docs/git-worktree)
- panzer-project
- panzer-project
