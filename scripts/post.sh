#!/bin/bash
# ============================================================
# Panzer Project - Simple Post Script
# ============================================================
# アドレス帳を参照して簡単にメッセージを送信するスクリプト
#
# 使用例:
#   ./scripts/post.sh maho "作戦会議を開始します"
#   ./scripts/post.sh platoon1.leader "タスクを確認せよ"
#   ./scripts/post.sh hq.miho "報告があります"
#
# 引数:
#   $1: 宛先名（例: maho, platoon1.leader, hq.yukari）
#   $2: 送信するメッセージ
#
# 宛先の指定方法:
#   - 名前のみ: maho, kay, darjeeling 等
#   - セクション.名前: hq.miho, platoon1.leader, platoon2.katyusha 等
# ============================================================

set -e

# 作業ディレクトリ
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "${SCRIPT_DIR}")"
ADDRESS_BOOK="${PROJECT_DIR}/config/address_book.yaml"

# 色設定
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ============================================================
# 使用方法を表示
# ============================================================
usage() {
    echo "Usage: $0 <recipient> <message>"
    echo ""
    echo "Arguments:"
    echo "  recipient  宛先名（例: maho, platoon1.leader, hq.yukari）"
    echo "  message    送信するメッセージ"
    echo ""
    echo "Examples:"
    echo "  $0 maho '作戦会議を開始します'"
    echo "  $0 platoon1.leader 'タスクを確認せよ'"
    echo "  $0 hq.miho '報告があります'"
    echo ""
    echo "Available recipients:"
    echo "  HQ: miho, maho, saori, hana, mako, yukari"
    echo "  Platoon1: kay, nishi, arisa, naomi, tamada, fukuda (or leader, deputy, crew1-4)"
    echo "  Platoon2: katyusha, mika, klara, nonna, aki, mikko (or leader, deputy, crew1-4)"
    echo "  Platoon3: darjeeling, erika, orange_pekoe, koume, assam, rukuriri (or leader, deputy, crew1-4)"
    exit 1
}

# ============================================================
# YAMLからペインIDを取得（yqがない場合はgrep/sedで代替）
# ============================================================
get_pane_id() {
    local recipient=$1
    local section=""
    local name=""
    local pane_id=""

    # セクション.名前 形式の場合は分解
    if [[ "$recipient" == *.* ]]; then
        section=$(echo "$recipient" | cut -d'.' -f1)
        name=$(echo "$recipient" | cut -d'.' -f2)
    else
        name="$recipient"
    fi

    # yqが使える場合は使用
    if command -v yq &> /dev/null; then
        if [ -n "$section" ]; then
            # セクション指定あり: .section.name
            pane_id=$(yq -r ".${section}.${name} // empty" "${ADDRESS_BOOK}" 2>/dev/null)
        else
            # セクション指定なし: 全セクションを検索
            for sec in hq platoon1 platoon2 platoon3; do
                pane_id=$(yq -r ".${sec}.${name} // empty" "${ADDRESS_BOOK}" 2>/dev/null)
                if [ -n "$pane_id" ]; then
                    break
                fi
            done
        fi
    else
        # yqがない場合: grep/sed でフォールバック
        pane_id=$(grep_pane_id "$section" "$name")
    fi

    echo "$pane_id"
}

# ============================================================
# grep/sedによるフォールバック実装
# ============================================================
grep_pane_id() {
    local section=$1
    local name=$2
    local pane_id=""

    if [ -n "$section" ]; then
        # セクション指定あり: そのセクション内を検索
        # sedでセクション内を抽出し、名前を検索
        pane_id=$(sed -n "/^${section}:/,/^[a-z]/p" "${ADDRESS_BOOK}" | \
                  grep -E "^  ${name}:" | \
                  sed 's/.*"\([^"]*\)".*/\1/' | head -1)
    else
        # セクション指定なし: 全体から検索
        pane_id=$(grep -E "^  ${name}:" "${ADDRESS_BOOK}" | \
                  sed 's/.*"\([^"]*\)".*/\1/' | head -1)
    fi

    echo "$pane_id"
}

# ============================================================
# メイン処理
# ============================================================
main() {
    # 引数チェック
    if [ $# -lt 2 ]; then
        usage
    fi

    local recipient=$1
    local message=$2

    # アドレス帳の存在確認
    if [ ! -f "${ADDRESS_BOOK}" ]; then
        echo -e "${RED}[ERROR]${NC} アドレス帳が見つかりません: ${ADDRESS_BOOK}" >&2
        exit 1
    fi

    # ペインIDを取得
    local pane_id
    pane_id=$(get_pane_id "$recipient")

    if [ -z "$pane_id" ]; then
        echo -e "${RED}[ERROR]${NC} 宛先が見つかりません: ${recipient}" >&2
        echo -e "${YELLOW}[HINT]${NC} $0 --help で利用可能な宛先を確認できます" >&2
        exit 1
    fi

    echo -e "${BLUE}[INFO]${NC} 送信先: ${recipient} (${pane_id})"
    echo -e "${BLUE}[INFO]${NC} メッセージ: ${message}"

    # notify.sh を使ってメッセージ送信
    if [ -x "${SCRIPT_DIR}/notify.sh" ]; then
        "${SCRIPT_DIR}/notify.sh" "${pane_id}" "${message}"
    else
        echo -e "${RED}[ERROR]${NC} notify.sh が見つからないか実行権限がありません" >&2
        exit 1
    fi

    echo -e "${GREEN}[SUCCESS]${NC} メッセージを送信しました: ${recipient}"
}

# --help オプション
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    usage
fi

# スクリプト実行
main "$@"
