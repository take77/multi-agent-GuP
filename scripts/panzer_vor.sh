#!/bin/bash
# ============================================================
# Panzer Project - Multi-Agent tmux Session Launcher
# ============================================================
# ガルパン・マルチエージェントシステム起動スクリプト
#
# セッション構成（README仕様準拠）:
#   - panzer-hq : 司令部（大隊本部）6ペイン
#   - panzer-1  : 第1中隊（サンダース/知波単）6ペイン
#   - panzer-2  : 第2中隊（プラウダ/継続）6ペイン
#   - panzer-3  : 第3中隊（聖グロ/黒森峰）6ペイン
#
# 各セッションは1ウィンドウ（ウィンドウ0）・6ペイン構成
# アクセス例: panzer-hq:0.0, panzer-1:0.0, panzer-2:0.0, panzer-3:0.0
# ============================================================

set -e

# 作業ディレクトリ（動的解決）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$(dirname "$SCRIPT_DIR")"
cd "$WORK_DIR"

# セッション名（4セッション構成）
SESSION_HQ="panzer-hq"
SESSION_1="panzer-1"
SESSION_2="panzer-2"
SESSION_3="panzer-3"

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
# セッション作成関数（6ペイン構成）
# ============================================================
# 引数: session_name member1 member2 member3 member4 member5 member6
create_session_with_panes() {
    local session_name=$1
    shift
    local members=("$@")

    # セッション作成（ウィンドウ0が自動生成）
    tmux new-session -d -s "${session_name}" -c "${WORK_DIR}" -x 240 -y 80

    log_info "  └─ Session ${session_name}: ${members[0]} (pane 0)"

    # 残り5名のペインを split-window で追加（ペイン1〜5）
    for i in {1..5}; do
        tmux split-window -t "${session_name}:0" -c "${WORK_DIR}"
        # 分割直後に毎回tiledで空間均等化 → 次のsplitでno spaceを防止
        tmux select-layout -t "${session_name}:0" tiled
        log_info "  └─ Session ${session_name}: ${members[$i]} (pane ${i})"
    done

    log_success "  Session ${session_name} created with ${#members[@]} panes"
}

# ============================================================
# キーバインド設定関数
# ============================================================
setup_keybindings() {
    log_info "⌨️  キーバインドを設定中..."

    # Alt+Left/Right でウィンドウ切り替え
    tmux bind-key -n M-Right next-window
    tmux bind-key -n M-Left previous-window

    # Alt+数字 でウィンドウ直接選択
    tmux bind-key -n M-1 select-window -t :=1
    tmux bind-key -n M-2 select-window -t :=2
    tmux bind-key -n M-3 select-window -t :=3
    tmux bind-key -n M-4 select-window -t :=4
    tmux bind-key -n M-5 select-window -t :=5
    tmux bind-key -n M-6 select-window -t :=6
    tmux bind-key -n M-7 select-window -t :=7
    tmux bind-key -n M-8 select-window -t :=8
    tmux bind-key -n M-9 select-window -t :=9

    log_success "✅ キーバインド設定完了"
}

# ============================================================
# 既存セッション存在チェック（二重起動防止）
# ============================================================
check_existing_sessions() {
    local existing_sessions=""
    local has_existing=false

    for session in "${SESSION_HQ}" "${SESSION_1}" "${SESSION_2}" "${SESSION_3}"; do
        if tmux has-session -t "${session}" 2>/dev/null; then
            existing_sessions="${existing_sessions} ${session}"
            has_existing=true
        fi
    done

    if [ "$has_existing" = false ]; then
        return 0
    fi

    log_info "既存セッションを検出:${existing_sessions}"
    echo ""
    echo "  [R] 既存セッションをkillしてクリーン再起動"
    echo "  [A] 起動を中止（Abort）"
    echo ""

    while true; do
        read -r -p "選択してください [R/A]: " choice
        case "${choice}" in
            [Rr])
                log_info "クリーン再起動を選択しました"
                cleanup_existing_sessions
                return 0
                ;;
            [Aa])
                log_info "起動を中止します"
                exit 0
                ;;
            *)
                echo "  R または A を入力してください"
                ;;
        esac
    done
}

# ============================================================
# 既存セッションのクリーンアップ
# ============================================================
cleanup_existing_sessions() {
    for session in "${SESSION_HQ}" "${SESSION_1}" "${SESSION_2}" "${SESSION_3}"; do
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

    # 既存セッションの二重起動チェック（存在すればユーザーに選択肢を提示）
    check_existing_sessions

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

    # ============================================================
    # キーバインド設定（グローバル設定なので1回のみ）
    # ============================================================
    setup_keybindings

    # ============================================================
    # 4セッション作成（各セッション1ウィンドウ・6ペイン）
    # ============================================================
    log_info "🏗️  4セッションを構築中..."

    # ------------------------------------------------------------
    # panzer-hq: 司令部（大隊本部）
    # ------------------------------------------------------------
    create_session_with_panes "${SESSION_HQ}" \
        "miho" "maho" "yukari" "saori" "hana" "mako"

    # ------------------------------------------------------------
    # panzer-1: 第1中隊（サンダース/知波単）
    # ------------------------------------------------------------
    create_session_with_panes "${SESSION_1}" \
        "kay" "nishi" "arisa" "naomi" "tamada" "fukuda"

    # ------------------------------------------------------------
    # panzer-2: 第2中隊（プラウダ/継続）
    # ------------------------------------------------------------
    create_session_with_panes "${SESSION_2}" \
        "katyusha" "mika" "klara" "nonna" "aki" "mikko"

    # ------------------------------------------------------------
    # panzer-3: 第3中隊（聖グロ/黒森峰）
    # ------------------------------------------------------------
    create_session_with_panes "${SESSION_3}" \
        "darjeeling" "erika" "orange_pekoe" "koume" "assam" "rukuriri"

    echo ""
    echo "============================================================"
    echo " Sessions created successfully!"
    echo "============================================================"
    echo ""
    echo "Sessions:"
    echo "  - ${SESSION_HQ} : 司令部（miho, maho, yukari, saori, hana, mako）"
    echo "  - ${SESSION_1}  : 第1中隊（kay, nishi, arisa, naomi, tamada, fukuda）"
    echo "  - ${SESSION_2}  : 第2中隊（katyusha, mika, klara, nonna, aki, mikko）"
    echo "  - ${SESSION_3}  : 第3中隊（darjeeling, erika, orange_pekoe, koume, assam, rukuriri）"
    echo ""
    echo "To attach to sessions:"
    echo "  tmux attach -t ${SESSION_HQ}"
    echo "  tmux attach -t ${SESSION_1}"
    echo "  tmux attach -t ${SESSION_2}"
    echo "  tmux attach -t ${SESSION_3}"
    echo ""
    echo "Keybindings:"
    echo "  Alt+Left/Right : Switch windows"
    echo "  Alt+1-9        : Select window by number"
    echo ""

    # ============================================================
    # Claude Code CLI 起動
    # ============================================================
    log_info "🔥 全軍に Claude Code を召喚中..."

    for session in "${SESSION_HQ}" "${SESSION_1}" "${SESSION_2}" "${SESSION_3}"; do
        # セッション内の全ペイン（0.0〜0.5）に対して send-keys
        for pane_idx in {0..5}; do
            tmux send-keys -t "${session}:0.${pane_idx}" "claude --dangerously-skip-permissions"
            tmux send-keys -t "${session}:0.${pane_idx}" Enter
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
        if tmux capture-pane -t "${SESSION_HQ}:0.0" -p | grep -q "bypass permissions"; then
            echo "  └─ ${SESSION_HQ} 起動確認完了（${i}秒）"
            break
        fi
        sleep 1
    done

    # ------------------------------------------------------------
    # panzer-hq: 司令部（大隊本部）
    # ------------------------------------------------------------
    log_info "  └─ ${SESSION_HQ}（司令部）に指示書を伝達中..."

    # pane 0: miho（大隊長）
    tmux send-keys -t "${SESSION_HQ}:0.0" "instructions/battalion_commander.md を読んで役割を理解せよ。"
    tmux send-keys -t "${SESSION_HQ}:0.0" Enter
    sleep 0.5

    # pane 1: maho（参謀長）
    tmux send-keys -t "${SESSION_HQ}:0.1" "instructions/chief_of_staff.md を読んで役割を理解せよ。"
    tmux send-keys -t "${SESSION_HQ}:0.1" Enter
    sleep 0.5

    # pane 2: yukari（情報参謀）
    tmux send-keys -t "${SESSION_HQ}:0.2" "instructions/intelligence_officer.md を読んで役割を理解せよ。"
    tmux send-keys -t "${SESSION_HQ}:0.2" Enter
    sleep 0.5

    # pane 3: saori（通信参謀）
    tmux send-keys -t "${SESSION_HQ}:0.3" "instructions/communications_officer.md を読んで役割を理解せよ。"
    tmux send-keys -t "${SESSION_HQ}:0.3" Enter
    sleep 0.5

    # pane 4: hana（記録参謀）
    tmux send-keys -t "${SESSION_HQ}:0.4" "instructions/records_officer.md を読んで役割を理解せよ。"
    tmux send-keys -t "${SESSION_HQ}:0.4" Enter
    sleep 0.5

    # pane 5: mako（技術参謀）
    tmux send-keys -t "${SESSION_HQ}:0.5" "instructions/technical_officer.md を読んで役割を理解せよ。"
    tmux send-keys -t "${SESSION_HQ}:0.5" Enter

    log_success "  └─ ${SESSION_HQ} 指示書伝達完了"
    sleep 1

    # ------------------------------------------------------------
    # panzer-1, panzer-2, panzer-3: 中隊（共通）
    # ------------------------------------------------------------
    local platoon_sessions=("${SESSION_1}" "${SESSION_2}" "${SESSION_3}")
    local platoon_instructions=(
        "instructions/platoon_leader.md"
        "instructions/platoon_deputy.md"
        "instructions/frontend.md"
        "instructions/backend.md"
        "instructions/design.md"
        "instructions/tester.md"
    )

    for platoon_session in "${platoon_sessions[@]}"; do
        log_info "  └─ ${platoon_session}（中隊）に指示書を伝達中..."

        # キャラクター名を中隊ごとに取得（Bash 3.2互換 - case文でマッピング）
        local members_str
        case "${platoon_session}" in
            "${SESSION_1}") members_str="kay nishi arisa naomi tamada fukuda" ;;
            "${SESSION_2}") members_str="katyusha mika klara nonna aki mikko" ;;
            "${SESSION_3}") members_str="darjeeling erika orange_pekoe koume assam rukuriri" ;;
        esac
        local members=(${members_str})

        for idx in {0..5}; do
            local instruction="${platoon_instructions[$idx]}"
            local char_name="${members[$idx]}"
            local target="${platoon_session}:0.${idx}"

            # 1. キャラクター設定ファイルを読み込ませる
            tmux send-keys -t "${target}" "characters/${char_name}.yaml を読んで、あなたの性格と設定を完全にインストールしてください。"
            tmux send-keys -t "${target}" Enter
            sleep 0.5

            # 2. 役職ごとの指示書を読み込ませる
            tmux send-keys -t "${target}" "${instruction} を読んで、業務上の役割を理解してください。"
            tmux send-keys -t "${target}" Enter
            sleep 0.5

            # 3. キャラクター名を自己認識させる
            tmux send-keys -t "${target}" "あなたの名前は ${char_name} です。所属は ${platoon_session} です。これ以降、この人格として振る舞い、タスクを実行してください。"
            tmux send-keys -t "${target}" Enter
            sleep 0.3
        done
        log_success "  └─ ${platoon_session} 指示書伝達完了"
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
