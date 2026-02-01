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

# 作業ディレクトリ（動的解決）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$(dirname "$SCRIPT_DIR")"
cd "$WORK_DIR"

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

    # セッションを作成（サイズを指定して十分な領域を確保）
    tmux new-session -d -s "${session_name}" -c "${WORK_DIR}" -x 200 -y 60

    # 最初のペインに名前を設定
    tmux select-pane -t "${session_name}:0.0" -T "${pane_names[0]}"

    # 残りのペインを作成（5つ追加で合計6ペイン）
    for i in {1..5}; do
        tmux split-window -t "${session_name}:0" -c "${WORK_DIR}"
        
        # 【重要修正】分割のたびにレイアウトを「タイル状（均等）」に整え直す
        # これによりペインが極端に狭くなるのを防ぎ、「no space」エラーを回避します
        tmux select-layout -t "${session_name}:0" tiled
        
        tmux select-pane -t "${session_name}:0.${i}" -T "${pane_names[$i]}"
    done

    # 最後に念のためもう一度整える
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

    # ============================================================
    # 通信インフラ初期化
    # ============================================================
    log_info "📡 通信インフラを初期化中..."

    # 司令部用ディレクトリ
    mkdir -p queue/hq/orders queue/hq/reports queue/hq/minutes

    # 中隊用ディレクトリ
    for i in 1 2 3; do
        mkdir -p "queue/platoon${i}/tasks" "queue/platoon${i}/reports"
    done

    # 初期ファイル作成
    if [ ! -f "queue/hq/pending_reports.yaml" ]; then
        echo "reports: []" > queue/hq/pending_reports.yaml
    fi

    log_success "✅ 通信インフラ初期化完了"

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

    # ============================================================
    # Claude Code CLI 起動
    # ============================================================
    log_info "🔥 全軍に Claude Code を召喚中..."

    local sessions=("panzer-hq" "panzer-1" "panzer-2" "panzer-3")

    for session in "${sessions[@]}"; do
        for pane in {0..5}; do
            tmux send-keys -t "${session}:0.${pane}" "claude --dangerously-skip-permissions"
            tmux send-keys -t "${session}:0.${pane}" Enter
        done
        log_info "  └─ ${session} 召喚完了"
        sleep 1
    done

    log_success "✅ 全軍 Claude Code 起動完了"
    echo ""

    # ============================================================
    # 役割定義の読み込み
    # ============================================================
    log_info "📜 各キャラに指示書を伝達中..."

    echo "  Claude Code の起動を待機中（最大30秒）..."

    # panzer-hq の起動を確認（最大30秒待機）
    for i in {1..30}; do
        if tmux capture-pane -t "panzer-hq:0.0" -p | grep -q "bypass permissions"; then
            echo "  └─ panzer-hq 起動確認完了（${i}秒）"
            break
        fi
        sleep 1
    done

    # ------------------------------------------------------------
    # panzer-hq: 司令部（大隊本部）
    # ------------------------------------------------------------
    log_info "  └─ panzer-hq（司令部）に指示書を伝達中..."

    # pane 0 (miho): 大隊長
    tmux send-keys -t "panzer-hq:0.0" "instructions/battalion_commander.md を読んで役割を理解せよ。"
    tmux send-keys -t "panzer-hq:0.0" Enter
    sleep 0.5

    # pane 1 (maho): 参謀長
    tmux send-keys -t "panzer-hq:0.1" "instructions/chief_of_staff.md を読んで役割を理解せよ。"
    tmux send-keys -t "panzer-hq:0.1" Enter
    sleep 0.5

    # pane 2 (yukari): 情報参謀
    tmux send-keys -t "panzer-hq:0.2" "instructions/intelligence_officer.md を読んで役割を理解せよ。"
    tmux send-keys -t "panzer-hq:0.2" Enter
    sleep 0.5

    # pane 3 (saori): 通信参謀
    tmux send-keys -t "panzer-hq:0.3" "instructions/communications_officer.md を読んで役割を理解せよ。"
    tmux send-keys -t "panzer-hq:0.3" Enter
    sleep 0.5

    # pane 4 (hana): 記録参謀
    tmux send-keys -t "panzer-hq:0.4" "instructions/records_officer.md を読んで役割を理解せよ。"
    tmux send-keys -t "panzer-hq:0.4" Enter
    sleep 0.5

    # pane 5 (mako): 技術参謀
    tmux send-keys -t "panzer-hq:0.5" "instructions/technical_officer.md を読んで役割を理解せよ。"
    tmux send-keys -t "panzer-hq:0.5" Enter

    log_success "  └─ panzer-hq 指示書伝達完了"
    sleep 1

    # ------------------------------------------------------------
    # panzer-1, panzer-2, panzer-3: 中隊（共通）
    # ------------------------------------------------------------
    local platoons=("panzer-1" "panzer-2" "panzer-3")
    local platoon_instructions=(
        "instructions/platoon_leader.md"
        "instructions/platoon_deputy.md"
        "instructions/frontend.md"
        "instructions/backend.md"
        "instructions/design.md"
        "instructions/tester.md"
    )

    # 中隊ごとのキャラクター名定義（ペイン0~5に対応）
    declare -A platoon_members
    platoon_members["panzer-1"]="kay nishi arisa naomi tamada fukuda"
    platoon_members["panzer-2"]="katyusha mika klara nonna aki mikko"
    platoon_members["panzer-3"]="darjeeling erika orange_pekoe koume assam rukuriri"

    for platoon in "${platoons[@]}"; do
        log_info "  └─ ${platoon}（中隊）に指示書を伝達中..."

        # キャラクター名配列を展開
        local members=(${platoon_members[$platoon]})

        for pane in {0..5}; do
            local instruction="${platoon_instructions[$pane]}"
            local char_name="${members[$pane]}"
            local target="${platoon}:0.${pane}"

            # 1. キャラクター設定ファイルを読み込ませる
            tmux send-keys -t "${target}" "characters/${char_name}.yaml を読んで、あなたの性格と設定を完全にインストールしてください。"
            tmux send-keys -t "${target}" Enter
            sleep 0.5

            # 2. 役職ごとの指示書を読み込ませる
            tmux send-keys -t "${target}" "${instruction} を読んで、業務上の役割を理解してください。"
            tmux send-keys -t "${target}" Enter
            sleep 0.5

            # 3. キャラクター名を自己認識させる
            tmux send-keys -t "${target}" "あなたの名前は ${char_name} です。所属は ${platoon} です。これ以降、この人格として振る舞い、タスクを実行してください。"
            tmux send-keys -t "${target}" Enter
            sleep 0.3
        done
        log_success "  └─ ${platoon} 指示書伝達完了"
        sleep 1
    done

    log_success "✅ 全軍に指示書伝達完了"
    echo ""

    # ============================================================
    # 完了メッセージ
    # ============================================================
    echo "============================================================"
    echo " パンツァー・フォー！全軍、戦闘準備完了！"
    echo "============================================================"
    echo ""
}

# スクリプト実行
main "$@"
