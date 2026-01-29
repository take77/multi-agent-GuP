#!/bin/bash
# ============================================================
# Panzer Project - Pane Status Checker
# ============================================================
# 各ペインの状態（busy/idle）を確認するスクリプト
#
# 使用例:
#   ./check_status.sh panzer-1:0.0       # 単一ペイン状態確認
#   ./check_status.sh --all              # 全ペイン一括確認
#   ./check_status.sh --json             # JSON形式で出力
#   ./check_status.sh --session panzer-1 # 特定セッションのみ
#   ./check_status.sh --all --json       # 全ペインをJSON形式で
# ============================================================

# セッション一覧
SESSIONS=("panzer-hq" "panzer-1" "panzer-2" "panzer-3")
PANES_PER_SESSION=6

# 色設定
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# busyを示すパターン（正規表現）
BUSY_PATTERNS=(
    "thinking"
    "Thinking"
    "Effecting"
    "reading"
    "Reading"
    "writing"
    "Writing"
    "Searching"
    "Running"
    "Executing"
    "Processing"
    "Loading"
    "Analyzing"
)

# idleを示すパターン
IDLE_PATTERN="❯"

# ============================================================
# ヘルプ表示
# ============================================================
show_help() {
    cat << EOF
Panzer Project - Pane Status Checker

Usage:
  $(basename "$0") [OPTIONS] [PANE]

Options:
  --all, -a           Check all panes in all sessions
  --session, -s NAME  Check all panes in specific session
  --json, -j          Output in JSON format
  --help, -h          Show this help message

Arguments:
  PANE                Specific pane to check (e.g., panzer-1:0.0)

Examples:
  $(basename "$0") panzer-1:0.0       # Check single pane
  $(basename "$0") --all              # Check all panes
  $(basename "$0") --json --all       # All panes in JSON
  $(basename "$0") -s panzer-hq       # Check HQ session only

Sessions:
  panzer-hq  : 司令部（miho, maho, yukari, saori, hana, mako）
  panzer-1   : 第1中隊（kay, nishi, arisa, naomi, tamada, fukuda）
  panzer-2   : 第2中隊（katyusha, mika, klara, nonna, aki, mikko）
  panzer-3   : 第3中隊（darjeeling, erika, orange_pekoe, koume, assam, rukuriri）
EOF
}

# ============================================================
# ペインの状態を取得
# ============================================================
get_pane_status() {
    local pane=$1
    local output
    local status="unknown"
    local activity=""
    local last_line=""

    # ペインの出力を取得（最新20行）
    output=$(tmux capture-pane -t "$pane" -p -S -20 2>/dev/null)

    if [ $? -ne 0 ]; then
        echo "error|Session/pane not found"
        return 1
    fi

    # 最後の非空行を取得
    last_line=$(echo "$output" | grep -v '^$' | tail -1)

    # busyパターンをチェック
    for pattern in "${BUSY_PATTERNS[@]}"; do
        if echo "$output" | tail -5 | grep -qi "$pattern"; then
            status="busy"
            # アクティビティを特定
            activity=$(echo "$output" | tail -5 | grep -oi "$pattern" | head -1 | tr '[:upper:]' '[:lower:]')
            break
        fi
    done

    # idleパターンをチェック（busyでない場合）
    if [ "$status" = "unknown" ]; then
        if echo "$last_line" | grep -q "$IDLE_PATTERN"; then
            status="idle"
            activity=""
        else
            # 最後の行の内容を確認
            if [ -z "$last_line" ]; then
                status="idle"
                activity=""
            else
                # 何かしらの出力がある場合はbusy扱い
                status="busy"
                activity="working"
            fi
        fi
    fi

    # 最後の行を整形（長すぎる場合は切り詰め）
    if [ ${#last_line} -gt 50 ]; then
        last_line="${last_line:0:47}..."
    fi

    echo "${status}|${activity}|${last_line}"
}

# ============================================================
# 単一ペインの状態を表示
# ============================================================
display_single_pane() {
    local pane=$1
    local json_mode=$2
    local result
    local status
    local activity
    local last_line

    result=$(get_pane_status "$pane")

    if [ $? -ne 0 ]; then
        if [ "$json_mode" = "true" ]; then
            echo "{\"pane\": \"$pane\", \"status\": \"error\", \"message\": \"Pane not found\"}"
        else
            echo -e "${RED}[ERROR]${NC} $pane - Pane not found"
        fi
        return 1
    fi

    IFS='|' read -r status activity last_line <<< "$result"

    if [ "$json_mode" = "true" ]; then
        if [ -z "$activity" ]; then
            echo "{\"pane\": \"$pane\", \"status\": \"$status\", \"activity\": null}"
        else
            echo "{\"pane\": \"$pane\", \"status\": \"$status\", \"activity\": \"$activity\"}"
        fi
    else
        local color
        local status_display
        if [ "$status" = "busy" ]; then
            color=$YELLOW
            status_display="[busy]"
        elif [ "$status" = "idle" ]; then
            color=$GREEN
            status_display="[idle]"
        else
            color=$RED
            status_display="[????]"
        fi
        printf "%-15s ${color}%-8s${NC} %s\n" "$pane" "$status_display" "$last_line"
    fi
}

# ============================================================
# セッション内の全ペインを表示
# ============================================================
display_session_panes() {
    local session=$1
    local json_mode=$2
    local panes_json=()
    local busy_count=0
    local idle_count=0
    local total_count=0

    # セッションが存在するか確認
    if ! tmux has-session -t "$session" 2>/dev/null; then
        if [ "$json_mode" != "true" ]; then
            echo -e "${RED}[ERROR]${NC} Session '$session' not found"
        fi
        return 1
    fi

    for i in $(seq 0 $((PANES_PER_SESSION - 1))); do
        local pane="${session}:0.${i}"
        local result

        result=$(get_pane_status "$pane" 2>/dev/null)

        if [ $? -eq 0 ]; then
            IFS='|' read -r status activity last_line <<< "$result"
            total_count=$((total_count + 1))

            if [ "$status" = "busy" ]; then
                busy_count=$((busy_count + 1))
            else
                idle_count=$((idle_count + 1))
            fi

            if [ "$json_mode" = "true" ]; then
                if [ -z "$activity" ]; then
                    panes_json+=("{\"pane\": \"$pane\", \"status\": \"$status\", \"activity\": null}")
                else
                    panes_json+=("{\"pane\": \"$pane\", \"status\": \"$status\", \"activity\": \"$activity\"}")
                fi
            else
                display_single_pane "$pane" "false"
            fi
        fi
    done

    if [ "$json_mode" = "true" ]; then
        # JSON配列を構築
        local panes_str
        panes_str=$(IFS=,; echo "${panes_json[*]}")
        echo "[${panes_str}]"
    fi
}

# ============================================================
# 全セッションを表示
# ============================================================
display_all_sessions() {
    local json_mode=$1
    local all_panes=()
    local total_busy=0
    local total_idle=0
    local total_count=0

    if [ "$json_mode" != "true" ]; then
        echo "============================================================"
        echo " Panzer Project - Pane Status"
        echo "============================================================"
        echo ""
    fi

    for session in "${SESSIONS[@]}"; do
        if ! tmux has-session -t "$session" 2>/dev/null; then
            if [ "$json_mode" != "true" ]; then
                echo -e "${RED}[SKIP]${NC} Session '$session' not found"
                echo ""
            fi
            continue
        fi

        if [ "$json_mode" != "true" ]; then
            echo -e "${BLUE}=== $session ===${NC}"
        fi

        for i in $(seq 0 $((PANES_PER_SESSION - 1))); do
            local pane="${session}:0.${i}"
            local result

            result=$(get_pane_status "$pane" 2>/dev/null)

            if [ $? -eq 0 ]; then
                IFS='|' read -r status activity last_line <<< "$result"
                total_count=$((total_count + 1))

                if [ "$status" = "busy" ]; then
                    total_busy=$((total_busy + 1))
                else
                    total_idle=$((total_idle + 1))
                fi

                if [ "$json_mode" = "true" ]; then
                    if [ -z "$activity" ]; then
                        all_panes+=("{\"pane\": \"$pane\", \"status\": \"$status\", \"activity\": null}")
                    else
                        all_panes+=("{\"pane\": \"$pane\", \"status\": \"$status\", \"activity\": \"$activity\"}")
                    fi
                else
                    display_single_pane "$pane" "false"
                fi
            fi
        done

        if [ "$json_mode" != "true" ]; then
            echo ""
        fi
    done

    if [ "$json_mode" = "true" ]; then
        # JSON出力を構築
        local panes_str
        panes_str=$(IFS=,; echo "${all_panes[*]}")
        cat << EOF
{
  "panes": [
    ${panes_str}
  ],
  "summary": {
    "total": ${total_count},
    "busy": ${total_busy},
    "idle": ${total_idle}
  }
}
EOF
    else
        echo "============================================================"
        echo -e " Summary: Total=${total_count} ${YELLOW}Busy=${total_busy}${NC} ${GREEN}Idle=${total_idle}${NC}"
        echo "============================================================"
    fi
}

# ============================================================
# メイン処理
# ============================================================
main() {
    local json_mode="false"
    local all_mode="false"
    local target_session=""
    local target_pane=""

    # 引数がない場合はヘルプを表示
    if [ $# -eq 0 ]; then
        show_help
        exit 0
    fi

    # 引数をパース
    while [ $# -gt 0 ]; do
        case "$1" in
            --help|-h)
                show_help
                exit 0
                ;;
            --json|-j)
                json_mode="true"
                shift
                ;;
            --all|-a)
                all_mode="true"
                shift
                ;;
            --session|-s)
                if [ -z "$2" ]; then
                    echo "Error: --session requires a session name"
                    exit 1
                fi
                target_session="$2"
                shift 2
                ;;
            -*)
                echo "Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                target_pane="$1"
                shift
                ;;
        esac
    done

    # 実行モードに応じて処理
    if [ "$all_mode" = "true" ]; then
        display_all_sessions "$json_mode"
    elif [ -n "$target_session" ]; then
        if [ "$json_mode" = "true" ]; then
            display_session_panes "$target_session" "true"
        else
            echo -e "${BLUE}=== $target_session ===${NC}"
            display_session_panes "$target_session" "false"
        fi
    elif [ -n "$target_pane" ]; then
        display_single_pane "$target_pane" "$json_mode"
    else
        show_help
        exit 0
    fi
}

# スクリプト実行
main "$@"
