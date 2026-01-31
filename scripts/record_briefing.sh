#!/bin/bash
# ============================================================
# Panzer Project - Discussion Recorder
# ============================================================
# BRIEFING中の議論を記録するスクリプト
#
# 使用例:
#   ./record_briefing.sh briefing_001 miho "パンツァー・フォー！"
#   ./record_briefing.sh briefing_001 kay "OK! Let's do it!"
#   ./record_briefing.sh briefing_001 --decision "機能Aはplatoon1が担当"
#   ./record_briefing.sh briefing_001 --action "バグ修正" --assignee naomi --deadline "2026-01-30"
# ============================================================

# 作業ディレクトリ
WORK_DIR="/home/take77-ubuntu-2/Developments/products/multi-agent-GuP"
BRIEFINGS_DIR="${WORK_DIR}/queue/briefings"

# 色設定
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ============================================================
# ヘルプ表示
# ============================================================
show_help() {
    cat << EOF
Panzer Project - Discussion Recorder

Usage:
  $(basename "$0") BRIEFING_ID SPEAKER "CONTENT"           Record a comment
  $(basename "$0") BRIEFING_ID --decision "CONTENT"        Record a decision
  $(basename "$0") BRIEFING_ID --action "CONTENT" [OPTIONS]  Record an action item

Options for --action:
  --assignee NAME     Assign to a person
  --deadline DATE     Set deadline (YYYY-MM-DD)
  --priority LEVEL    Set priority (high/medium/low)

Examples:
  $(basename "$0") briefing_001 miho "パンツァー・フォー！"
  $(basename "$0") briefing_001 kay "OK! Let's do it!"
  $(basename "$0") briefing_001 --decision "機能Aはplatoon1が担当"
  $(basename "$0") briefing_001 --action "バグ修正" --assignee naomi --deadline "2026-01-30"

Discussion file location:
  queue/briefings/briefing_{id}/discussion.yaml
EOF
}

# ============================================================
# タイムスタンプ取得（ISO 8601形式）
# ============================================================
get_timestamp() {
    date "+%Y-%m-%dT%H:%M:%S"
}

# ============================================================
# 議事録ディレクトリとファイルの確認・作成
# ============================================================
ensure_discussion_file() {
    local briefing_id=$1
    local briefing_dir="${BRIEFINGS_DIR}/briefing_${briefing_id}"
    local discussion_file="${briefing_dir}/discussion.yaml"

    # ディレクトリ作成
    if [ ! -d "$briefing_dir" ]; then
        mkdir -p "$briefing_dir"
        echo -e "${BLUE}[INFO]${NC} Created briefing directory: ${briefing_dir}" >&2
    fi

    # ファイルが存在しない場合は新規作成
    if [ ! -f "$discussion_file" ]; then
        local timestamp
        timestamp=$(get_timestamp)
        cat > "$discussion_file" << EOF
# ============================================================
# BRIEFING議事録 - ${briefing_id}
# ============================================================
# Created: ${timestamp}

briefing:
  briefing_id: "${briefing_id}"
  created_at: "${timestamp}"
  status: in_progress

discussions: []

decisions: []

action_items: []
EOF
        echo -e "${GREEN}[SUCCESS]${NC} Created discussion file: ${discussion_file}" >&2
    fi

    echo "$discussion_file"
}

# ============================================================
# 発言を追記
# ============================================================
record_comment() {
    local briefing_id=$1
    local speaker=$2
    local content=$3
    local discussion_file
    local timestamp

    discussion_file=$(ensure_discussion_file "$briefing_id")
    timestamp=$(get_timestamp)

    # YAML形式で追記（discussions配列に追加）
    # 既存の discussions: [] を検出して追記
    local temp_file="${discussion_file}.tmp"

    # discussions配列に新しいエントリを追加
    if grep -q "^discussions: \[\]$" "$discussion_file"; then
        # 空の配列の場合、最初のエントリを追加
        sed "s/^discussions: \[\]$/discussions:\n  - timestamp: \"${timestamp}\"\n    speaker: \"${speaker}\"\n    content: \"${content}\"/" "$discussion_file" > "$temp_file"
        mv "$temp_file" "$discussion_file"
    else
        # 既存エントリがある場合、discussions:の直後に追加
        # 最後のdiscussionsエントリの後に追加
        awk -v ts="$timestamp" -v sp="$speaker" -v ct="$content" '
        /^discussions:/ { in_discussions=1; print; next }
        in_discussions && /^[a-z]/ {
            # 次のセクションに到達
            printf "  - timestamp: \"%s\"\n", ts
            printf "    speaker: \"%s\"\n", sp
            printf "    content: \"%s\"\n\n", ct
            in_discussions=0
        }
        { print }
        END {
            if (in_discussions) {
                printf "  - timestamp: \"%s\"\n", ts
                printf "    speaker: \"%s\"\n", sp
                printf "    content: \"%s\"\n", ct
            }
        }
        ' "$discussion_file" > "$temp_file"
        mv "$temp_file" "$discussion_file"
    fi

    echo -e "${GREEN}[RECORDED]${NC} ${CYAN}${speaker}${NC}: \"${content}\""
    echo -e "${BLUE}[TIME]${NC} ${timestamp}"
}

# ============================================================
# 決定事項を追記
# ============================================================
record_decision() {
    local briefing_id=$1
    local content=$2
    local discussion_file
    local timestamp
    local decision_id

    discussion_file=$(ensure_discussion_file "$briefing_id")
    timestamp=$(get_timestamp)

    # 決定事項のIDを生成（連番）
    local count
    count=$(grep -c "^  - id: \"dec_" "$discussion_file" 2>/dev/null) || count=0
    decision_id="dec_$(printf "%03d" $((count + 1)))"

    # decisions配列に追加
    local temp_file="${discussion_file}.tmp"

    if grep -q "^decisions: \[\]$" "$discussion_file"; then
        # 空の配列の場合
        sed "s/^decisions: \[\]$/decisions:\n  - id: \"${decision_id}\"\n    timestamp: \"${timestamp}\"\n    description: \"${content}\"\n    status: confirmed/" "$discussion_file" > "$temp_file"
        mv "$temp_file" "$discussion_file"
    else
        # 既存エントリがある場合
        awk -v ts="$timestamp" -v did="$decision_id" -v ct="$content" '
        /^decisions:/ { in_decisions=1; print; next }
        in_decisions && /^[a-z]/ {
            printf "  - id: \"%s\"\n", did
            printf "    timestamp: \"%s\"\n", ts
            printf "    description: \"%s\"\n", ct
            printf "    status: confirmed\n\n"
            in_decisions=0
        }
        { print }
        END {
            if (in_decisions) {
                printf "  - id: \"%s\"\n", did
                printf "    timestamp: \"%s\"\n", ts
                printf "    description: \"%s\"\n", ct
                printf "    status: confirmed\n"
            }
        }
        ' "$discussion_file" > "$temp_file"
        mv "$temp_file" "$discussion_file"
    fi

    echo -e "${YELLOW}[DECISION]${NC} ${decision_id}: \"${content}\""
    echo -e "${BLUE}[TIME]${NC} ${timestamp}"
}

# ============================================================
# アクションアイテムを追記
# ============================================================
record_action() {
    local briefing_id=$1
    local content=$2
    local assignee=$3
    local deadline=$4
    local priority=${5:-medium}
    local discussion_file
    local timestamp
    local action_id

    discussion_file=$(ensure_discussion_file "$briefing_id")
    timestamp=$(get_timestamp)

    # アクションIDを生成
    local count
    count=$(grep -c "^  - id: \"ai_" "$discussion_file" 2>/dev/null) || count=0
    action_id="ai_$(printf "%03d" $((count + 1)))"

    # action_items配列に追加
    local temp_file="${discussion_file}.tmp"

    if grep -q "^action_items: \[\]$" "$discussion_file"; then
        # 空の配列の場合
        cat > "$temp_file" << EOF
$(sed "s/^action_items: \[\]$/action_items:\n  - id: \"${action_id}\"\n    timestamp: \"${timestamp}\"\n    description: \"${content}\"\n    assignee: \"${assignee}\"\n    deadline: \"${deadline}\"\n    priority: \"${priority}\"\n    status: pending/" "$discussion_file")
EOF
        mv "$temp_file" "$discussion_file"
    else
        # 既存エントリがある場合
        awk -v ts="$timestamp" -v aid="$action_id" -v ct="$content" -v as="$assignee" -v dl="$deadline" -v pr="$priority" '
        /^action_items:/ { in_actions=1; print; next }
        in_actions && /^[a-z]/ && !/^  / {
            printf "  - id: \"%s\"\n", aid
            printf "    timestamp: \"%s\"\n", ts
            printf "    description: \"%s\"\n", ct
            printf "    assignee: \"%s\"\n", as
            printf "    deadline: \"%s\"\n", dl
            printf "    priority: \"%s\"\n", pr
            printf "    status: pending\n\n"
            in_actions=0
        }
        { print }
        END {
            if (in_actions) {
                printf "  - id: \"%s\"\n", aid
                printf "    timestamp: \"%s\"\n", ts
                printf "    description: \"%s\"\n", ct
                printf "    assignee: \"%s\"\n", as
                printf "    deadline: \"%s\"\n", dl
                printf "    priority: \"%s\"\n", pr
                printf "    status: pending\n"
            }
        }
        ' "$discussion_file" > "$temp_file"
        mv "$temp_file" "$discussion_file"
    fi

    echo -e "${RED}[ACTION]${NC} ${action_id}: \"${content}\""
    echo -e "${CYAN}[ASSIGNEE]${NC} ${assignee}"
    echo -e "${YELLOW}[DEADLINE]${NC} ${deadline}"
    echo -e "${BLUE}[PRIORITY]${NC} ${priority}"
    echo -e "${BLUE}[TIME]${NC} ${timestamp}"
}

# ============================================================
# メイン処理
# ============================================================
main() {
    # 引数がない場合はヘルプを表示
    if [ $# -lt 2 ]; then
        show_help
        exit 1
    fi

    local briefing_id=$1
    shift

    # 2番目の引数を確認
    case "$1" in
        --help|-h)
            show_help
            exit 0
            ;;
        --decision)
            if [ -z "$2" ]; then
                echo -e "${RED}[ERROR]${NC} --decision requires content"
                exit 1
            fi
            record_decision "$briefing_id" "$2"
            ;;
        --action)
            if [ -z "$2" ]; then
                echo -e "${RED}[ERROR]${NC} --action requires content"
                exit 1
            fi
            local content=$2
            local assignee=""
            local deadline=""
            local priority="medium"
            shift 2

            # 追加オプションをパース
            while [ $# -gt 0 ]; do
                case "$1" in
                    --assignee)
                        assignee=$2
                        shift 2
                        ;;
                    --deadline)
                        deadline=$2
                        shift 2
                        ;;
                    --priority)
                        priority=$2
                        shift 2
                        ;;
                    *)
                        echo -e "${RED}[ERROR]${NC} Unknown option: $1"
                        exit 1
                        ;;
                esac
            done

            if [ -z "$assignee" ]; then
                echo -e "${RED}[ERROR]${NC} --action requires --assignee"
                exit 1
            fi
            if [ -z "$deadline" ]; then
                echo -e "${RED}[ERROR]${NC} --action requires --deadline"
                exit 1
            fi

            record_action "$briefing_id" "$content" "$assignee" "$deadline" "$priority"
            ;;
        -*)
            echo -e "${RED}[ERROR]${NC} Unknown option: $1"
            show_help
            exit 1
            ;;
        *)
            # 通常の発言（speaker content形式）
            local speaker=$1
            local content=$2

            if [ -z "$content" ]; then
                echo -e "${RED}[ERROR]${NC} Missing content"
                show_help
                exit 1
            fi

            record_comment "$briefing_id" "$speaker" "$content"
            ;;
    esac
}

# スクリプト実行
main "$@"
