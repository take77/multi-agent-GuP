#!/bin/bash
# ============================================================
# end_briefing.sh - BRIEFING終了・議事録生成スクリプト
# ============================================================
# ガルパン・マルチエージェントシステム用
# BRIEFINGを終了し、議事録を生成・配布する
#
# 使用例:
#   ./scripts/end_briefing.sh briefing_001
#   ./scripts/end_briefing.sh briefing_001 --no-notify
#
# 処理フロー:
#   1. queue/briefings/briefing_{id}/ の内容を読み込み
#   2. 議論記録を時系列で整理
#   3. 決定事項・アクションアイテムを抽出
#   4. 完成した議事録を保存先に移動
#   5. 参加者に通知（オプション）
# ============================================================

set -euo pipefail

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
BRIEFINGS_DIR="$PROJECT_ROOT/queue/briefings"
LOG_DIR="$PROJECT_ROOT/logs"
LOG_FILE="$LOG_DIR/end_briefing.log"

# ============================================================
# ヘルパー関数
# ============================================================

log_to_file() {
    local level=$1
    local message=$2
    local timestamp
    timestamp=$(date "+%Y-%m-%dT%H:%M:%S")

    mkdir -p "$LOG_DIR"
    echo "[$timestamp] [$level] $message" >> "$LOG_FILE"
}

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
    log_to_file "INFO" "$1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    log_to_file "SUCCESS" "$1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
    log_to_file "WARNING" "$1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    log_to_file "ERROR" "$1"
}

print_header() {
    echo -e "${CYAN}$1${NC}"
}

# ============================================================
# yq存在チェック関数
# ============================================================

# yqが必要な処理を実行する前にチェック
check_yq() {
    if ! command -v yq &> /dev/null; then
        print_error "yq is not installed. / yq がインストールされていません。"
        print_error "Please install yq: https://github.com/mikefarah/yq"
        print_error "  Ubuntu/Debian: sudo apt install yq"
        print_error "  macOS: brew install yq"
        print_error "  または: pip install yq"
        return 1
    fi
    return 0
}

# yqチェック（警告モード - フォールバック使用時）
check_yq_warn() {
    if ! command -v yq &> /dev/null; then
        print_warning "yq is not installed. Using fallback mode. / yq が未導入のためフォールバックモードを使用します。"
        print_warning "For better YAML parsing, install yq: https://github.com/mikefarah/yq"
        return 1
    fi
    return 0
}

# ============================================================
# YAMLパース用関数（簡易版）
# ============================================================

# YAMLから値を取得（yqがあれば使用、なければgrep）
get_yaml_value() {
    local file=$1
    local key=$2

    if command -v yq &> /dev/null; then
        yq -r ".$key // empty" "$file" 2>/dev/null
    else
        # 簡易的なgrep抽出
        grep -E "^${key}:" "$file" 2>/dev/null | sed 's/^[^:]*: *//' | tr -d '"'
    fi
}

# YAMLから配列を取得
get_yaml_array() {
    local file=$1
    local key=$2

    if command -v yq &> /dev/null; then
        yq -r ".${key}[]? // empty" "$file" 2>/dev/null
    else
        # 簡易的な抽出（インデントされた - 行）
        awk "/^${key}:/,/^[^ ]/" "$file" 2>/dev/null | grep '^ *-' | sed 's/^ *- *//' | tr -d '"'
    fi
}

# ============================================================
# BRIEFINGディレクトリ構造の確認
# ============================================================

validate_briefing_dir() {
    local briefing_id=$1
    local briefing_dir="$BRIEFINGS_DIR/$briefing_id"

    if [[ ! -d "$briefing_dir" ]]; then
        print_error "BRIEFINGディレクトリが見つかりません: $briefing_dir"
        return 1
    fi

    # 必要なファイルの確認
    if [[ ! -f "$briefing_dir/schedule.yaml" ]]; then
        print_warning "schedule.yaml が見つかりません（スキップ）"
    fi

    return 0
}

# ============================================================
# BRIEFING情報の読み込み
# ============================================================

load_briefing_info() {
    local briefing_id=$1
    local briefing_dir="$BRIEFINGS_DIR/$briefing_id"

    # デフォルト値
    BRIEFING_TYPE="general_briefing"
    BRIEFING_ORGANIZER="unknown"
    BRIEFING_RECORDER="hana"
    BRIEFING_DATETIME=$(date "+%Y-%m-%dT%H:%M:%S")
    BRIEFING_TOPIC="BRIEFING"

    # schedule.yaml から読み込み
    if [[ -f "$briefing_dir/schedule.yaml" ]]; then
        local type_val
        type_val=$(get_yaml_value "$briefing_dir/schedule.yaml" "briefing.type")
        [[ -n "$type_val" ]] && BRIEFING_TYPE="$type_val"

        local org_val
        org_val=$(get_yaml_value "$briefing_dir/schedule.yaml" "briefing.organizer")
        [[ -n "$org_val" ]] && BRIEFING_ORGANIZER="$org_val"

        local topic_val
        topic_val=$(get_yaml_value "$briefing_dir/schedule.yaml" "briefing.topic")
        [[ -n "$topic_val" ]] && BRIEFING_TOPIC="$topic_val"
    fi

    print_info "BRIEFING情報を読み込みました: $briefing_id (type: $BRIEFING_TYPE)"
}

# ============================================================
# 参加者リストの取得
# ============================================================

get_participants() {
    local briefing_id=$1
    local briefing_dir="$BRIEFINGS_DIR/$briefing_id"

    PARTICIPANTS=()

    if [[ -f "$briefing_dir/schedule.yaml" ]]; then
        while IFS= read -r participant; do
            [[ -n "$participant" ]] && PARTICIPANTS+=("$participant")
        done < <(get_yaml_array "$briefing_dir/schedule.yaml" "briefing.participants")
    fi

    # デフォルト参加者（空の場合）
    if [[ ${#PARTICIPANTS[@]} -eq 0 ]]; then
        PARTICIPANTS=("miho" "maho" "yukari" "hana" "saori")
    fi
}

# ============================================================
# 議論記録の収集
# ============================================================

collect_discussions() {
    local briefing_id=$1
    local briefing_dir="$BRIEFINGS_DIR/$briefing_id"

    DISCUSSIONS=""

    # discussion*.yaml ファイルを収集
    if [[ -d "$briefing_dir" ]]; then
        for disc_file in "$briefing_dir"/discussion*.yaml "$briefing_dir"/disc*.yaml; do
            if [[ -f "$disc_file" ]]; then
                print_info "議論記録を読み込み: $(basename "$disc_file")"
                DISCUSSIONS+="$(cat "$disc_file")\n---\n"
            fi
        done
    fi
}

# ============================================================
# 決定事項の抽出
# ============================================================

extract_decisions() {
    local briefing_id=$1
    local briefing_dir="$BRIEFINGS_DIR/$briefing_id"

    DECISIONS=()
    local dec_count=0

    # decision*.yaml または discussion 内の decisions を抽出
    for file in "$briefing_dir"/*.yaml; do
        if [[ -f "$file" ]]; then
            while IFS= read -r decision; do
                if [[ -n "$decision" ]]; then
                    dec_count=$((dec_count + 1))
                    DECISIONS+=("D$(printf '%03d' $dec_count)|$decision")
                fi
            done < <(get_yaml_array "$file" "decisions[].description" 2>/dev/null || true)
        fi
    done

    print_info "決定事項を抽出: ${#DECISIONS[@]}件"
}

# ============================================================
# アクションアイテムの抽出
# ============================================================

extract_action_items() {
    local briefing_id=$1
    local briefing_dir="$BRIEFINGS_DIR/$briefing_id"

    ACTION_ITEMS=()
    local ai_count=0

    # action_items を抽出
    for file in "$briefing_dir"/*.yaml; do
        if [[ -f "$file" ]]; then
            while IFS= read -r action; do
                if [[ -n "$action" ]]; then
                    ai_count=$((ai_count + 1))
                    ACTION_ITEMS+=("A$(printf '%03d' $ai_count)|$action")
                fi
            done < <(get_yaml_array "$file" "action_items[].description" 2>/dev/null || true)
        fi
    done

    print_info "アクションアイテムを抽出: ${#ACTION_ITEMS[@]}件"
}

# ============================================================
# 議事録YAMLの生成
# ============================================================

generate_minutes_yaml() {
    local briefing_id=$1
    local output_file=$2
    local end_time
    end_time=$(date "+%Y-%m-%dT%H:%M:%S")

    # 所要時間計算（簡易）
    local duration=30

    cat > "$output_file" << EOF
# ============================================================
# 議事録 (Briefing Minutes)
# Generated by end_briefing.sh
# ============================================================

minutes:
  briefing_id: "$briefing_id"
  type: "$BRIEFING_TYPE"
  datetime: "$BRIEFING_DATETIME"
  end_time: "$end_time"
  duration_minutes: $duration
  organizer: "$BRIEFING_ORGANIZER"
  recorder: "$BRIEFING_RECORDER"
  topic: "$BRIEFING_TOPIC"

  participants:
    attended:
EOF

    # 参加者リスト
    for participant in "${PARTICIPANTS[@]}"; do
        echo "      - $participant" >> "$output_file"
    done

    cat >> "$output_file" << EOF
    absent: []

  summary: |
    $BRIEFING_TOPIC に関するBRIEFINGを実施。
    決定事項 ${#DECISIONS[@]}件、アクションアイテム ${#ACTION_ITEMS[@]}件。

  decisions:
EOF

    # 決定事項
    if [[ ${#DECISIONS[@]} -gt 0 ]]; then
        for decision in "${DECISIONS[@]}"; do
            local dec_id="${decision%%|*}"
            local dec_desc="${decision#*|}"
            cat >> "$output_file" << EOF
    - id: "$dec_id"
      description: "$dec_desc"
      decided_by: "$BRIEFING_ORGANIZER"
EOF
        done
    else
        echo "    []  # 決定事項なし" >> "$output_file"
    fi

    cat >> "$output_file" << EOF

  action_items:
EOF

    # アクションアイテム
    if [[ ${#ACTION_ITEMS[@]} -gt 0 ]]; then
        local tomorrow
        tomorrow=$(date -d "+1 day" "+%Y-%m-%d" 2>/dev/null || date -v+1d "+%Y-%m-%d" 2>/dev/null || echo "TBD")

        for action in "${ACTION_ITEMS[@]}"; do
            local ai_id="${action%%|*}"
            local ai_desc="${action#*|}"
            cat >> "$output_file" << EOF
    - id: "$ai_id"
      description: "$ai_desc"
      assignee: "TBD"
      deadline: "$tomorrow"
      status: pending
EOF
        done
    else
        echo "    []  # アクションアイテムなし" >> "$output_file"
    fi

    cat >> "$output_file" << EOF

  next_briefing:
    date: "TBD"
    agenda: "進捗確認"

# ============================================================
# Generated at: $end_time
# ============================================================
EOF

    print_success "議事録を生成しました: $output_file"
}

# ============================================================
# 保存先ディレクトリの決定
# ============================================================

get_destination_dir() {
    local briefing_type=$1
    local dest_dir=""

    case "$briefing_type" in
        hq_briefing|commander_briefing)
            dest_dir="$PROJECT_ROOT/queue/hq/minutes"
            ;;
        platoon_briefing|platoon1_briefing)
            dest_dir="$PROJECT_ROOT/queue/platoon1/minutes"
            ;;
        platoon2_briefing)
            dest_dir="$PROJECT_ROOT/queue/platoon2/minutes"
            ;;
        platoon3_briefing)
            dest_dir="$PROJECT_ROOT/queue/platoon3/minutes"
            ;;
        battalion_briefing)
            dest_dir="$PROJECT_ROOT/queue/battalion/minutes"
            ;;
        *)
            dest_dir="$PROJECT_ROOT/queue/briefings/minutes"
            ;;
    esac

    echo "$dest_dir"
}

# ============================================================
# 参加者への通知
# ============================================================

notify_participants() {
    local briefing_id=$1
    local minutes_path=$2

    print_header "=== 参加者への通知 ==="

    local notify_script="$SCRIPT_DIR/notify.sh"

    if [[ ! -x "$notify_script" ]]; then
        print_warning "notify.sh が見つからないか実行できません"
        return 1
    fi

    # 各参加者に通知（セッション名は推測）
    local message="議事録が完成しました: $briefing_id - $minutes_path"

    # HQ（司令部）への通知
    if "$notify_script" "panzer-hq:0.0" "$message" 2>/dev/null; then
        print_info "HQに通知しました"
    else
        print_warning "HQへの通知に失敗（セッションが存在しない可能性）"
    fi

    print_success "通知処理が完了しました"
}

# ============================================================
# アクションアイテム一覧の表示
# ============================================================

display_action_items() {
    print_header "=== アクションアイテム一覧 ==="

    if [[ ${#ACTION_ITEMS[@]} -eq 0 ]]; then
        echo "アクションアイテムはありません"
        return
    fi

    printf "%-6s %-40s %-10s\n" "ID" "説明" "状態"
    printf "%s\n" "$(printf '=%.0s' {1..60})"

    for action in "${ACTION_ITEMS[@]}"; do
        local ai_id="${action%%|*}"
        local ai_desc="${action#*|}"
        # 説明を40文字に切り詰め
        local short_desc="${ai_desc:0:38}"
        [[ ${#ai_desc} -gt 38 ]] && short_desc="${short_desc}.."
        printf "%-6s %-40s ${YELLOW}%-10s${NC}\n" "$ai_id" "$short_desc" "pending"
    done

    echo ""
}

# ============================================================
# ヘルプ表示
# ============================================================

show_help() {
    cat << 'EOF'
BRIEFING終了・議事録生成スクリプト - ガルパン・マルチエージェントシステム

使用法:
  ./scripts/end_briefing.sh <briefing_id> [options]

引数:
  briefing_id          BRIEFINGのID（例: briefing_001）

オプション:
  --no-notify     参加者への通知をスキップ
  --help, -h      このヘルプを表示

処理フロー:
  1. queue/briefings/<briefing_id>/ の内容を読み込み
  2. 議論記録を時系列で整理
  3. 決定事項を抽出してリスト化
  4. アクションアイテムを抽出してリスト化
  5. 完成した議事録を保存先に移動
  6. 参加者に通知（--no-notify で省略可）

出力:
  - 議事録YAML: queue/{hq|platoon{N}|battalion}/minutes/<briefing_id>_minutes.yaml

例:
  # BRIEFINGを終了して議事録を生成
  ./scripts/end_briefing.sh briefing_001

  # 通知なしで終了
  ./scripts/end_briefing.sh briefing_001 --no-notify
EOF
}

# ============================================================
# メイン処理
# ============================================================

main() {
    local briefing_id=""
    local no_notify=false

    # 引数パース
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --no-notify)
                no_notify=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            -*)
                print_error "不明なオプション: $1"
                show_help
                exit 1
                ;;
            *)
                briefing_id="$1"
                shift
                ;;
        esac
    done

    # 引数チェック
    if [[ -z "$briefing_id" ]]; then
        print_error "BRIEFING IDが指定されていません"
        echo "使用法: ./scripts/end_briefing.sh <briefing_id>"
        exit 1
    fi

    print_header "=== BRIEFING終了処理開始: $briefing_id ==="
    echo ""

    # 1. BRIEFINGディレクトリの検証
    if ! validate_briefing_dir "$briefing_id"; then
        # ディレクトリがなくてもデモ用に続行
        print_warning "BRIEFINGディレクトリがないためデモモードで実行"
        mkdir -p "$BRIEFINGS_DIR/$briefing_id"
    fi

    # 2. BRIEFING情報の読み込み
    load_briefing_info "$briefing_id"

    # 3. 参加者リストの取得
    get_participants "$briefing_id"
    print_info "参加者: ${PARTICIPANTS[*]}"

    # 4. 議論記録の収集
    collect_discussions "$briefing_id"

    # 5. 決定事項の抽出
    extract_decisions "$briefing_id"

    # 6. アクションアイテムの抽出
    extract_action_items "$briefing_id"

    # 7. 保存先の決定と作成
    local dest_dir
    dest_dir=$(get_destination_dir "$BRIEFING_TYPE")
    mkdir -p "$dest_dir"

    local minutes_file="$dest_dir/${briefing_id}_minutes.yaml"

    # 8. 議事録YAMLの生成
    echo ""
    generate_minutes_yaml "$briefing_id" "$minutes_file"

    # 9. アクションアイテム一覧の表示
    echo ""
    display_action_items

    # 10. 参加者への通知
    if [[ "$no_notify" == false ]]; then
        notify_participants "$briefing_id" "$minutes_file"
    else
        print_info "通知はスキップされました（--no-notify）"
    fi

    echo ""
    print_header "=== BRIEFING終了処理完了 ==="
    echo -e "議事録: ${GREEN}$minutes_file${NC}"
    echo ""
}

main "$@"
