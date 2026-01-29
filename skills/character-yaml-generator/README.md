# character-yaml-generator

キャラクター設定YAMLファイルを統一フォーマットで生成するスキル。

## 概要

マルチエージェントシステムで使用するキャラクター設定を、統一されたYAMLフォーマットで生成します。
キャラクター情報（名前、役割、口調等）を入力として、`characters/*.yaml` ファイルを出力します。

## 機能

- **統一フォーマット生成**: 全キャラクターで一貫した構造のYAMLを生成
- **バリデーション**: 必須フィールドのチェック、型検証
- **バッチ処理**: 複数キャラクターを一括生成
- **カスタマイズ可能**: プロジェクト固有のフィールド追加に対応

## インストール

```bash
# スキルをプロジェクトにコピー
cp -r skills/character-yaml-generator /path/to/your-project/skills/
```

## 使用方法

### 基本的な使い方

1. キャラクター情報を用意
2. スキルを呼び出し
3. 生成されたYAMLを確認

### 入力フォーマット

```yaml
characters:
  - id: "character_id"
    name:
      japanese: "日本語名"
      romaji: "Romaji Name"
    role: "役割ID"
    rank: "表示用の役職名"
    personality:
      traits:
        - "特性1"
        - "特性2"
      leadership_style: "リーダーシップスタイル"
      decision_making: "意思決定スタイル"
    speech_patterns:
      category_name:
        - "セリフ1"
        - "セリフ2"
    responsibilities:
      primary:
        - "主要責務1"
      secondary:
        - "副次的責務1"
    communication:
      report_to: "報告先ID"
      receives_from:
        - "受信元ID1"
      style: "コミュニケーションスタイル"
```

### 出力

```
characters/
├── character1.yaml
├── character2.yaml
└── character3.yaml
```

## YAMLスキーマ

### 必須フィールド

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `character.id` | string | 一意のキャラクターID |
| `character.name.japanese` | string | 日本語名 |
| `character.role` | string | 役割ID |

### オプションフィールド

| フィールド | 型 | 説明 |
|-----------|-----|------|
| `character.name.romaji` | string | ローマ字名 |
| `character.rank` | string | 表示用の役職名 |
| `personality` | object | 性格設定 |
| `speech_patterns` | object | 口調パターン |
| `responsibilities` | object | 責務 |
| `communication` | object | 通信設定 |

## バリデーションルール

1. **ID規則**: 英小文字、数字、アンダースコアのみ
2. **必須フィールド**: character.id, character.name.japanese, character.role
3. **配列フィールド**: traits, speech_patterns の各カテゴリは配列
4. **参照整合性**: report_to, receives_from は存在するキャラクターIDを参照

## 使用例

### 例1: 司令官キャラクター

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
  decision_making: 状況を見極めてから迅速に決断

speech_patterns:
  commands:
    - 「パンツァー・フォー！」
    - 「全車、前進！」
```

### 例2: 技術者キャラクター

```yaml
character:
  id: mako
  name:
    japanese: 冷泉麻子
    romaji: Reizei Mako
  role: technical_staff
  rank: 技術参謀

personality:
  traits:
    - 天才的な技術力
    - 眠気との戦い
  decision_making: 直感と経験に基づく判断
```

## ディレクトリ構造

```
skills/character-yaml-generator/
├── README.md          # このファイル
├── spec.yaml          # 仕様定義
└── examples/
    ├── input_single.yaml      # 単一キャラクター入力例
    ├── input_batch.yaml       # バッチ入力例
    └── output_sample.yaml     # 出力サンプル
```

## 関連スキル

- `character-instructions-generator`: キャラYAMLからinstructions.mdを生成
- `tmux-session-generator`: セッション構成からtmux起動スクリプトを生成

## バージョン履歴

| バージョン | 日付 | 変更内容 |
|-----------|------|----------|
| 1.0 | 2026-01-29 | 初版リリース |

## ライセンス

MIT License
