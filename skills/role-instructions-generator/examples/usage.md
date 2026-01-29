# role-instructions-generator 使用例

## 1. 基本的な使用方法

### 単一キャラクターの指示書生成

```bash
# 大隊長（みほ）の指示書を生成
generate-role-instructions \
  --character characters/miho.yaml \
  --role battalion_commander \
  --output instructions/battalion_commander.md
```

### 出力例

```
[INFO] Loading character: miho
[INFO] Using template: battalion_commander
[INFO] Generating YAML Front Matter...
[INFO] Generating Markdown body...
[INFO] Writing to: instructions/battalion_commander.md
[SUCCESS] Generated: instructions/battalion_commander.md
  - Sections: 8
  - Forbidden actions: 4
  - Workflow steps: 6
```

## 2. 一括生成

### 全キャラクターの指示書を一括生成

```bash
generate-role-instructions \
  --all \
  --input-dir characters/ \
  --output-dir instructions/ \
  --verbose
```

### 出力例

```
[INFO] Found 25 character files
[INFO] Processing miho.yaml → battalion_commander.md
[INFO] Processing maho.yaml → chief_of_staff.md
...
[SUCCESS] Generated 25 instruction files
[SUMMARY]
  - Total: 25
  - Success: 25
  - Warnings: 2
    - yukari.yaml: Missing 'encouragement' in speech_patterns
    - mako.yaml: Missing 'leadership_style' in personality
```

## 3. オプション

### ワークフロー図を省略

```bash
generate-role-instructions \
  --character characters/miho.yaml \
  --role battalion_commander \
  --no-workflow-diagram
```

### 口調例を省略

```bash
generate-role-instructions \
  --character characters/miho.yaml \
  --role battalion_commander \
  --no-speech-examples
```

### カスタム出力パス

```bash
generate-role-instructions \
  --character characters/miho.yaml \
  --role battalion_commander \
  --output custom/path/miho_instructions.md
```

## 4. バリデーションのみ

### 入力ファイルの検証

```bash
generate-role-instructions \
  --validate-only \
  --character characters/miho.yaml \
  --role battalion_commander
```

### 出力例

```
[VALIDATE] characters/miho.yaml
  ✓ character.id: miho
  ✓ character.name.japanese: 西住みほ
  ✓ character.role: battalion_commander
  ✓ personality.traits: 5 items
  ✓ speech_patterns: 4 categories
  ✓ responsibilities.primary: 3 items
  ✓ communication.receives_from: 5 items
[RESULT] Valid - ready for generation
```

## 5. トラブルシューティング

### 必須フィールドが不足している場合

```
[ERROR] Missing required field: character.role
  File: characters/broken.yaml
  Solution: Add 'role' field under 'character'
```

### テンプレートが見つからない場合

```
[ERROR] Unknown role template: unknown_role
  Available templates:
    - battalion_commander
    - chief_of_staff
    - platoon_leader
    - frontend
    - backend
    - design
    - tester
```
