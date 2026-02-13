#!/bin/bash
# ============================================================
# alert_all_staff.sh - 全参謀への一斉通知
# ============================================================
# 全参謀（maho, yukari, saori, hana, mako）に一斉通知を送信する
#
# 使用例:
#   ./scripts/alert_all_staff.sh "緊急連絡があります"
#   ./scripts/alert_all_staff.sh "作戦会議を開始します"
#
# 引数:
#   $1: 送信するメッセージ（省略時はデフォルトメッセージ）
# ============================================================

set -e

# 作業ディレクトリ
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# デフォルトメッセージ
MESSAGE="${1:-緊急連絡があります}"

# 全参謀リスト
STAFF_MEMBERS=("maho" "yukari" "saori" "hana" "mako")

# 各参謀に通知を送信
for member in "${STAFF_MEMBERS[@]}"; do
    "${SCRIPT_DIR}/post.sh" "$member" "$MESSAGE"
done

echo "全参謀への通知完了"
