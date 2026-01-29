# role-instructions-generator

キャラクターYAMLから役職別のinstructions.mdを自動生成するスキル。

## 概要

マルチエージェントシステムにおいて、各キャラクターの設定YAML（`characters/*.yaml`）から、役職に応じた詳細な指示書（`instructions/{role}.md`）を自動生成する。YAML Front Matter形式とMarkdown本文を組み合わせた統一フォーマットで出力。

## 機能

- `characters/*.yaml` の情報を読み込み
- 役職に応じた `instructions.md` を生成
- YAML Front Matter + Markdown本文の形式で出力
- 口調設定の自動反映
- 禁止事項・ワークフロー・通信プロトコルの自動構築

## 使用方法

### 基本的な使い方

```bash
# スキルを実行
generate-role-instructions \
  --character characters/miho.yaml \
  --role battalion_commander \
  --output instructions/battalion_commander.md
```

### 一括生成

```bash
# 全キャラクターの指示書を生成
generate-role-instructions --all --input-dir characters/ --output-dir instructions/
```

## 入力

### キャラクターYAML

```yaml
character:
  id: miho
  name:
    japanese: 西住みほ
    romaji: Nishizumi Miho
  role: battalion_commander
  rank: 大隊長

personality:
  traits:
    - 穏やかで優しい
    - 決断時は迷いがない
  leadership_style: サーバントリーダーシップ

speech_patterns:
  greetings:
    - 「みんな、集まって」
  affirmation:
    - 「うん、いいと思う！」
  commands:
    - 「パンツァー・フォー！」

responsibilities:
  primary:
    - 全体方針の決定
    - 最終判断

communication:
  report_to: null
  receives_from:
    - maho
    - yukari
```

### 役職テンプレート

| テンプレート | 対象役職 |
|--------------|----------|
| `battalion_commander` | 大隊長 |
| `chief_of_staff` | 参謀長 |
| `intelligence_officer` | 情報参謀 |
| `communications_officer` | 通信参謀 |
| `records_officer` | 記録参謀 |
| `technical_officer` | 技術参謀 |
| `platoon_leader` | 中隊長 |
| `platoon_deputy` | 副中隊長 |
| `frontend` | フロントエンドエンジニア |
| `backend` | バックエンドエンジニア |
| `design` | デザイナー |
| `tester` | テスター |

## 出力

### 生成されるファイル形式

```markdown
---
# YAML Front Matter
role: battalion_commander
character: miho
version: "1.0"

forbidden_actions:
  - id: F001
    action: direct_coding
    description: "直接コードを書く"

workflow:
  - step: 1
    action: receive_order
    from: human

communication:
  report_to: human
  receives_from:
    - maho

speech_style:
  tone: "穏やかで優しい"
  patterns:
    - 「みんな、集まって」
---

# 役職名（キャラクター名）指示書

## 役割

[自動生成された役割説明]

## 責務

[responsibilitiesから生成]

## 禁止事項

[forbidden_actionsから生成]

## ワークフロー

[workflowから生成]

## 口調設定

[speech_patternsから生成]
```

## 生成ロジック

1. キャラクターYAMLを読み込み
2. 役職テンプレートを選択
3. キャラクター情報をテンプレートにマッピング
4. 禁止事項を役職に応じて生成
5. ワークフローを役職に応じて生成
6. 口調設定をspeech_patternsから抽出
7. YAML Front MatterとMarkdown本文を生成
8. ファイル出力

## 参考

このスキルは `multi-agent-GuP` の `instructions/*.md` と `characters/*.yaml` を参考に設計された。

## バージョン

- 1.0.0 - 初版作成
