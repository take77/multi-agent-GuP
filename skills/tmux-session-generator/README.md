# tmux-session-generator

YAMLで定義したセッション構成からtmux起動スクリプトを自動生成するスキル。

## 概要

マルチエージェントシステムやマルチペイン開発環境において、tmuxセッションの構成をYAMLで宣言的に定義し、起動スクリプトを自動生成する。

## 機能

- セッション名、ペイン数、ペイン名をYAMLで定義
- 起動スクリプト（.sh）を自動生成
- クリーンアップ機能も含む
- 複数セッションの一括作成に対応

## 使用例

### 入力（session_config.yaml）

```yaml
project:
  name: my-project
  work_dir: /home/user/projects/my-project

sessions:
  - name: main
    panes:
      - name: editor
      - name: terminal
      - name: logs
  - name: services
    panes:
      - name: api
      - name: db
      - name: redis
```

### 出力（start_my-project.sh）

上記YAMLから、以下を含む起動スクリプトが生成される：
- セッション作成関数
- ペイン作成・命名ロジック
- クリーンアップ関数
- 接続方法の表示

## インストール

```bash
# スキルディレクトリをコピー
cp -r skills/tmux-session-generator /path/to/your/project/skills/
```

## 使い方

1. `session_config.yaml` を作成
2. スキルを実行（Claude Codeに依頼）
3. 生成された `start_xxx.sh` を実行

```bash
chmod +x start_my-project.sh
./start_my-project.sh
```

## ファイル構成

```
tmux-session-generator/
├── README.md       # このファイル
├── spec.yaml       # スキル仕様定義
└── examples/       # 使用例
    ├── simple_session.yaml
    └── multi_session.yaml
```

## 仕様

詳細な仕様は `spec.yaml` を参照。

## 関連

- [tmux documentation](https://github.com/tmux/tmux/wiki)
- multi-agent-GuP
- multi-agent-GuP
