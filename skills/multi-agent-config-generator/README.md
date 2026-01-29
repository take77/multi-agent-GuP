# multi-agent-config-generator

マルチエージェントシステムの階層的な設定ファイル群を生成するスキル。

## 概要

組織構成（大隊、中隊等）の定義YAMLから、マルチエージェントシステムに必要な設定ファイル一式を自動生成する。

## 機能

- 組織構成（大隊、中隊等）の定義から設定ファイルを生成
- 通信プロトコル設定の自動生成
- 各エージェントの役割定義

## 入力

| 入力 | 型 | 必須 | 説明 |
|------|---|------|------|
| organization_definition | YAML | Yes | 組織構成定義（大隊名、中隊一覧、スタッフ等） |
| settings_template | YAML | No | システム設定テンプレート（言語、ログレベル等） |

### organization_definition の構造

```yaml
battalion:
  name: "panzer-battalion"
  commander: miho
  deputy: maho
  staff:
    - yukari
    - saori
    - hana
    - mako
  platoons:
    - id: platoon1
      name: "Thunder-Chihatan Alliance"
      leader: kay
      deputy: nishi
      members:
        - name: arisa
          role: frontend
        - name: naomi
          role: backend
        ...
```

## 出力

| 出力 | 型 | 説明 |
|------|---|------|
| config/battalion.yaml | YAML | 大隊構成定義 |
| config/settings.yaml | YAML | システム設定 |
| config/platoons/*.yaml | YAML | 各中隊の設定ファイル |

## ワークフロー

```
入力: organization_definition.yaml
         │
         ▼
    ┌────────────────┐
    │ 1. 入力検証     │
    │   - 必須項目確認 │
    │   - 構造チェック │
    └────────┬───────┘
             │
             ▼
    ┌────────────────┐
    │ 2. 大隊設定生成  │
    │   battalion.yaml│
    └────────┬───────┘
             │
             ▼
    ┌────────────────┐
    │ 3. システム設定  │
    │   settings.yaml │
    └────────┬───────┘
             │
             ▼
    ┌────────────────┐
    │ 4. 中隊設定生成  │
    │   platoons/*.yaml│
    └────────┬───────┘
             │
             ▼
出力: config/ ディレクトリ一式
```

## 使用例

### 基本的な使用

```bash
# スキルを実行
/multi-agent-config-generator --input organization.yaml --output config/
```

### 出力例

`examples/` ディレクトリに実際の出力例がある。

## ディレクトリ構成

```
skills/multi-agent-config-generator/
├── README.md          # このファイル
├── spec.yaml          # 仕様定義
└── examples/
    ├── input.yaml     # 入力例
    └── output/        # 出力例
        ├── battalion.yaml
        ├── settings.yaml
        └── platoons/
            ├── platoon1.yaml
            ├── platoon2.yaml
            └── platoon3.yaml
```

## 関連スキル

- `character-instructions-generator`: キャラクター設定からinstructionsを生成
- `project-scaffold`: プロジェクト雛形ディレクトリを作成
