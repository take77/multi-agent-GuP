#!/bin/bash
# ============================================================
# Panzer Project - Multi-Agent tmux Session Launcher
# ============================================================
# ガルパン・マルチエージェントシステム起動スクリプト
#
# セッション構成:
#   - panzer-hq: 司令部（大隊本部）
#   - panzer-1:  第1中隊（サンダース/知波単）
#   - panzer-2:  第2中隊（プラウダ/継続）
#   - panzer-3:  第3中隊（聖グロ/黒森峰）
# ============================================================

set -e

# 作業ディレクトリ
WORK_DIR="/home/take77-ubuntu-2/Developments/products/multi-agent-GuP"

# 色設定（ログ用）
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# ============================================================
# セッション作成関数
# ============================================================
create_session_with_panes() {
    local session_name=$1
    shift
    local pane_names=("$@")

    log_info "Creating session: ${session_name}"

    # セッションを作成（最初のペインは自動作成される）
    tmux new-session -d -s "${session_name}" -c "${WORK_DIR}"

    # 最初のペインに名前を設定
    tmux select-pane -t "${session_name}:0.0" -T "${pane_names[0]}"

    # 残りのペインを作成（5つ追加で合計6ペイン）
    for i in {1..5}; do
        tmux split-window -t "${session_name}:0" -c "${WORK_DIR}"
        tmux select-pane -t "${session_name}:0.${i}" -T "${pane_names[$i]}"
    done

    # レイアウトを整える（tiled: 均等配置）
    tmux select-layout -t "${session_name}:0" tiled

    log_success "Session ${session_name} created with ${#pane_names[@]} panes"
}

# ============================================================
# 既存セッションのクリーンアップ
# ============================================================
cleanup_existing_sessions() {
    local sessions=("panzer-hq" "panzer-1" "panzer-2" "panzer-3")

    for session in "${sessions[@]}"; do
        if tmux has-session -t "${session}" 2>/dev/null; then
            log_info "Killing existing session: ${session}"
            tmux kill-session -t "${session}"
        fi
    done
}

# ============================================================
# メイン処理
# ============================================================
main() {
    echo "============================================================"
    echo " Panzer Project - Multi-Agent System"
    echo " パンツァー・フォー！"
    echo "============================================================"
    echo ""

    # 作業ディレクトリ確認
    if [ ! -d "${WORK_DIR}" ]; then
        echo "Error: Work directory does not exist: ${WORK_DIR}"
        exit 1
    fi

    # 既存セッションをクリーンアップ
    cleanup_existing_sessions

    # ------------------------------------------------------------
    # panzer-hq: 司令部（大隊本部）
    # ------------------------------------------------------------
    create_session_with_panes "panzer-hq" \
        "miho" \
        "maho" \
        "yukari" \
        "saori" \
        "hana" \
        "mako"

    # ------------------------------------------------------------
    # panzer-1: 第1中隊（サンダース/知波単）
    # ------------------------------------------------------------
    create_session_with_panes "panzer-1" \
        "kay" \
        "nishi" \
        "arisa" \
        "naomi" \
        "tamada" \
        "fukuda"

    # ------------------------------------------------------------
    # panzer-2: 第2中隊（プラウダ/継続）
    # ------------------------------------------------------------
    create_session_with_panes "panzer-2" \
        "katyusha" \
        "mika" \
        "klara" \
        "nonna" \
        "aki" \
        "mikko"

    # ------------------------------------------------------------
    # panzer-3: 第3中隊（聖グロ/黒森峰）
    # ------------------------------------------------------------
    create_session_with_panes "panzer-3" \
        "darjeeling" \
        "erika" \
        "orange_pekoe" \
        "koume" \
        "assam" \
        "rukuriri"

    echo ""
    echo "============================================================"
    echo " All sessions created successfully!"
    echo "============================================================"
    echo ""
    echo "Sessions:"
    echo "  - panzer-hq  : 司令部（miho, maho, yukari, saori, hana, mako）"
    echo "  - panzer-1   : 第1中隊（kay, nishi, arisa, naomi, tamada, fukuda）"
    echo "  - panzer-2   : 第2中隊（katyusha, mika, klara, nonna, aki, mikko）"
    echo "  - panzer-3   : 第3中隊（darjeeling, erika, orange_pekoe, koume, assam, rukuriri）"
    echo ""
    echo "To attach to a session:"
    echo "  tmux attach -t panzer-hq"
    echo "  tmux attach -t panzer-1"
    echo "  tmux attach -t panzer-2"
    echo "  tmux attach -t panzer-3"
    echo ""
}

# スクリプト実行
main "$@"
