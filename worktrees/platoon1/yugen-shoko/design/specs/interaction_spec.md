# インタラクション仕様書

> **Task ID**: P1-DE-001
> **Designer**: 玉田（第1中隊デザイン担当）
> **対象**: アリサ（FE実装担当）
> **作成日**: 2026-01-30

---

## 1. ジェスチャー一覧（全画面共通）

### 1.1 作品選択モード（/discover）

| ジェスチャー | 動作 | 条件/閾値 | フィードバック | 備考 |
|-------------|------|----------|--------------|------|
| 右スワイプ | お気に入り登録 | `distance > 100px` or `velocity > 0.5px/ms` | 右に飛び出し + ♡アイコン | カードが次に進む |
| 左スワイプ | 興味なし（スキップ） | `distance > 100px` or `velocity > 0.5px/ms` | 左に飛び出し + ✕アイコン | カードが次に進む |
| 閾値未満スワイプ | キャンセル | `distance < 100px` | バネで中央復帰 | 何も起きない |
| ダブルタップ | 即座に読書開始 | `interval < 300ms` | 波紋 + ページめくり遷移 | /read へ遷移 |
| 長押し | 作品詳細プレビュー | `> 500ms` | カード拡大 + 詳細オーバーレイ | オプション機能 |

### 1.2 読書モード（/read/[bookId]/[chapterId]）

| ジェスチャー | 動作 | 条件/閾値 | フィードバック | 備考 |
|-------------|------|----------|--------------|------|
| 縦スワイプ | テキストスクロール | ネイティブ | ネイティブスクロール | 横書き時 |
| 横スワイプ（右→左） | 次の話へ | `distance > 120px` | 確認ダイアログ | 最終話では無効 |
| 横スワイプ（左→右） | 前の話へ | `distance > 120px` | 確認ダイアログ | 第1話では無効 |
| シングルタップ（中央） | UIオーバーレイ切替 | 画面中央50% | ヘッダー/フッター表示・非表示 | |
| シングルタップ（左1/4） | 前へスクロール | 画面左端25% | スムーズスクロール上方向 | |
| シングルタップ（右1/4） | 次へスクロール | 画面右端25% | スムーズスクロール下方向 | |
| ダブルタップ | しおり挿入 | `interval < 300ms` | しおりマーカー + トースト | |
| ピンチアウト | 文字拡大 | 2本指広げ | サイズ1段階アップ + 表示 | 最大28px |
| ピンチイン | 文字縮小 | 2本指縮め | サイズ1段階ダウン + 表示 | 最小14px |

---

## 2. アニメーション仕様

### 2.1 共通イージング

| 名前 | 値 | 用途 |
|------|-----|------|
| ease-out-smooth | `cubic-bezier(0.25, 0.46, 0.45, 0.94)` | カード移動、UI表示 |
| ease-out-bounce | `cubic-bezier(0.34, 1.56, 0.64, 1.0)` | バネ復帰 |
| ease-in-out | `cubic-bezier(0.4, 0, 0.2, 1)` | テーマ切替、ページ遷移 |

### 2.2 カードスワイプ

```
【スワイプ中】
- transform: translateX({dragX}px) rotate({dragX * 0.1}deg)
- 最大回転: ±15deg
- ♡/✕ アイコン opacity: min(|dragX| / 100, 1)

【確定（閾値超え）】
- duration: 300ms
- easing: ease-out-smooth
- translateX: ±150% (画面外へ)
- rotate: ±30deg
- opacity: 0

【キャンセル（閾値未満）】
- duration: 200ms
- easing: ease-out-bounce
- translateX: 0, rotate: 0
```

### 2.3 カードスタック昇格

```
スワイプ確定後、背面カードが前面に昇格：
- 2枚目 → 前面:
  scale: 0.95 → 1.0
  translateY: -8px → 0
  opacity: 0.7 → 1.0
  duration: 350ms, easing: ease-out-smooth

- 3枚目 → 2枚目:
  scale: 0.90 → 0.95
  translateY: -16px → -8px
  opacity: 0.4 → 0.7
  duration: 350ms, easing: ease-out-smooth

- 新規カード → 3枚目:
  scale: 0.85 → 0.90
  translateY: -24px → -16px
  opacity: 0 → 0.4
  duration: 400ms, easing: ease-out-smooth
```

### 2.4 ダブルタップ波紋

```
@keyframes ripple {
  0%   { transform: scale(0); opacity: 0.5; }
  100% { transform: scale(4); opacity: 0; }
}
- 色: rgba(157, 140, 161, 0.3) (light) / rgba(197, 160, 89, 0.3) (dark)
- duration: 500ms
- タップ位置を中心に展開
```

### 2.5 ページめくり遷移（選択→読書）

```
/* 選択画面が退場 */
@keyframes card-exit {
  to {
    transform: scale(0.9);
    opacity: 0;
    filter: blur(4px);
  }
}

/* 読書画面が入場 */
@keyframes page-turn-enter {
  from {
    transform: perspective(1200px) rotateY(-90deg);
    transform-origin: left center;
    opacity: 0;
  }
  to {
    transform: perspective(1200px) rotateY(0deg);
    transform-origin: left center;
    opacity: 1;
  }
}
- 全体: 500ms, ease-in-out
```

### 2.6 UIオーバーレイ

```
/* ヘッダー */
表示: translateY(-100%) → translateY(0), opacity 0→1, 200ms
非表示: translateY(0) → translateY(-100%), opacity 1→0, 150ms

/* フッター */
表示: translateY(100%) → translateY(0), opacity 0→1, 200ms
非表示: translateY(0) → translateY(100%), opacity 1→0, 150ms
```

### 2.7 しおりトースト

```
表示: translateY(-20px) → translateY(0), opacity 0→1, 200ms
保持: 1.5s
非表示: opacity 1→0, 300ms
```

### 2.8 テーマ切替

```
全画面: background-color, color のトランジション
duration: 300ms
easing: ease-in-out
```

---

## 3. 状態遷移図

### 3.1 作品選択モード

```
[初期表示]
    │
    ▼
[カード表示] ──(右スワイプ)──→ [お気に入り登録] → [次のカード]
    │                                                   │
    ├──(左スワイプ)──→ [スキップ] ────────────────────→ │
    │                                                   │
    ├──(ダブルタップ)──→ [読書モードへ遷移]               │
    │                                                   │
    ├──(長押し)──→ [詳細プレビュー] → [戻る/読書開始]     │
    │                                                   │
    └──(カード枯渇)──→ [空状態] ──(リフレッシュ)──→ ────┘
```

### 3.2 読書モード

```
[テキスト表示 / 没入モード]
    │
    ├──(中央タップ)──→ [UIオーバーレイ表示]
    │                       │
    │                       ├──(中央タップ)──→ [没入モードに戻る]
    │                       ├──(設定変更)──→ [設定反映] → [UIオーバーレイ]
    │                       └──(戻るボタン)──→ [作品選択/本棚へ]
    │
    ├──(左タップ)──→ [上方向スクロール]
    ├──(右タップ)──→ [下方向スクロール]
    │
    ├──(ダブルタップ)──→ [しおり挿入] → [トースト表示]
    │
    ├──(ピンチ)──→ [文字サイズ変更] → [サイズ表示]
    │
    ├──(横スワイプ)──→ [確認ダイアログ] → [話移動 or キャンセル]
    │
    └──(縦スワイプ)──→ [テキストスクロール]
```

---

## 4. ジェスチャー競合解決

### 4.1 スワイプの方向判定

```
タッチ開始時の最初の移動方向（30ms以内）で判定:
- |deltaX| > |deltaY| → 横スワイプとしてロック
- |deltaY| > |deltaX| → 縦スワイプとしてロック

一度方向がロックされたら、そのジェスチャー中は変更しない。
```

### 4.2 タップ vs ダブルタップ

```
1回目のタップ後、300ms 待機:
- 300ms以内に2回目タップ → ダブルタップ処理
- 300ms経過 → シングルタップ処理

注意: シングルタップに300msの遅延が発生する。
読書モードではこの遅延は許容範囲（UIオーバーレイ切替に即応性不要）。
```

### 4.3 ピンチ vs スクロール

```
2本指検出 → ピンチモードに入る（スクロール無効化）
1本指に戻った時点でピンチモード解除
```

---

## 5. ハプティクスフィードバック（オプション/PWA対応時）

| アクション | バイブレーション | 備考 |
|-----------|----------------|------|
| スワイプ確定 | `10ms` light | Vibration API |
| しおり挿入 | `15ms` medium | |
| 話移動 | `20ms` strong | |
| 文字サイズ変更 | `5ms` light | 段階ごとに |

```typescript
// Vibration API 呼び出し
if ('vibrate' in navigator) {
  navigator.vibrate(duration);
}
```

---

## 6. `prefers-reduced-motion` 対応

モーション低減が有効な場合の代替:

| 通常 | 代替 |
|------|------|
| カードスワイプ飛び出し | opacity フェードアウトのみ (200ms) |
| カードスタック昇格 | 即座に切り替え (0ms) |
| ページめくり遷移 | クロスフェード (300ms) |
| 波紋エフェクト | 無効化 |
| UIオーバーレイ | opacity のみ (150ms) |
| しおりトースト | opacity のみ |

```css
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
  }
}
```
実際にはコンポーネント単位でフックで制御する方が望ましい:
```typescript
const prefersReducedMotion = useMediaQuery('(prefers-reduced-motion: reduce)');
```
