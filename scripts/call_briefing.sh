#!/bin/bash
# ============================================================
# Panzer Project - MTG招集スクリプト (Meeting Call Script)
# ============================================================
# MTGを招集し、参加者に一斉通知を行うスクリプト
#
# 機能:
#   - MTGタイプ指定（hq_meeting, platoon_meeting, battalion_meeting）
#   - 参加者への一斉通知（scripts/notify.sh を使用）
#   - MTGスケジュールYAML自動生成（queue/meetings/ に保存）
#   - 議題の事前共有
#
# 使用例:
#   ./scripts/call_briefing.sh platoon_meeting platoon1 "機能Aの実装方針"
#   ./scripts/call_briefing.sh hq_meeting "週次進捗確認"
#   ./scripts/call_briefing.sh battalion_meeting "全体キックオフ"
#
# 引数:
#   $1: MTGタイプ (hq_meeting / platoon_meeting / battalion_meeting)
#   $2: 対象（platoon_meeting の場合は中隊番号、それ以外は議題）
#   $3: 議題（platoon_meeting の場合のみ）
# ============================================================

set -e

# 作業ディレクトリ
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "${SCRIPT_DIR}")"
NOTIFY_SCRIPT="${SCRIPT_DIR}/notify.sh"
MEETINGS_DIR="${PROJECT_DIR}/queue/meetings"
LOG_DIR="${PROJECT_DIR}/logs"
LOG_FILE="${LOG_DIR}/meeting.log"

# 色設定
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# ============================================================
# メンバー定義
# ============================================================
# 司令部メンバー
HQ_MEMBERS=("miho" "maho" "yukari" "saori" "hana" "mako")
HQ_SESSION="panzer-hq"

# 第1中隊メンバー
PLATOON1_MEMBERS=("kay" "nishi" "arisa" "naomi" "tamada" "fukuda")
PLATOON1_SESSION="panzer-1"

# 第2中隊メンバー
PLATOON2_MEMBERS=("katyusha" "mika" "klara" "nonna" "aki" "mikko")
PLATOON2_SESSION="panzer-2"

# 第3中隊メンバー
PLATOON3_MEMBERS=("darjeeling" "erika" "orange_pekoe" "koume" "assam" "rukuriri")
PLATOON3_SESSION="panzer-3"

# ============================================================
# ログ関数
# ============================================================
log_to_file() {
    local level=$1
    local message=$2
    local timestamp
    timestamp=$(date "+%Y-%m-%dT%H:%M:%S")

    if [ ! -d "${LOG_DIR}" ]; then
        mkdir -p "${LOG_DIR}"
    fi

    echo "[${timestamp}] [${level}] ${message}" >> "${LOG_FILE}"
}

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
    log_to_file "INFO" "$1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
    log_to_file "SUCCESS" "$1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" >&2
    log_to_file "WARN" "$1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    log_to_file "ERROR" "$1"
}

log_meeting() {
    echo -e "${MAGENTA}[MTG]${NC} $1"
    log_to_file "MTG" "$1"
}

# ============================================================
# 使用方法を表示
# ============================================================
usage() {
    echo "Usage: $0 <mtg_type> [platoon] <agenda>"
    echo ""
    echo "MTG Types:"
    echo "  hq_meeting        司令部MTG (miho, maho, yukari, saori, hana, mako)"
    echo "  platoon_meeting   中隊MTG (指定した中隊の全員)"
    echo "  battalion_meeting 大隊MTG (全員)"
    echo ""
    echo "Arguments:"
    echo "  mtg_type  MTGの種類"
    echo "  platoon   中隊番号 (platoon_meeting の場合のみ: platoon1, platoon2, platoon3)"
    echo "  agenda    議題"
    echo ""
    echo "Examples:"
    echo "  $0 hq_meeting '週次進捗確認'"
    echo "  $0 platoon_meeting platoon1 '機能Aの実装方針'"
    echo "  $0 battalion_meeting '全体キックオフ'"
    exit 1
}

# ============================================================
# 参加者への通知
# ============================================================
notify_participant() {
    local session=$1
    local pane=$2
    local member=$3
    local message=$4

    local target="${session}:0.${pane}"

    if "${NOTIFY_SCRIPT}" "${target}" "${message}" 2>/dev/null; then
        log_info "Notified ${member} at ${target}"
        return 0
    else
        log_warn "Failed to notify ${member} at ${target} (session may not exist)"
        return 1
    fi
}

# ============================================================
# セッションの全メンバーに通知
# ============================================================
notify_session() {
    local session=$1
    shift
    local members=("$@")
    local message=$1
    local notified=0

    # 最後の引数がメッセージ
    message="${@: -1}"

    for i in "${!members[@]}"; do
        if notify_participant "${session}" "${i}" "${members[$i]}" "${message}"; then
            ((notified++))
        fi
    done

    echo "${notified}"
}

# ============================================================
# MTGスケジュールYAML生成
# ============================================================
generate_meeting_yaml() {
    local mtg_type=$1
    local organizer=$2
    local agenda=$3
    shift 3
    local participants=("$@")

    local timestamp
    timestamp=$(date "+%Y%m%d_%H%M%S")
    local mtg_id="mtg_${timestamp}"
    local created_at
    created_at=$(date "+%Y-%m-%dT%H:%M:%S")
    local yaml_file="${MEETINGS_DIR}/${mtg_id}.yaml"

    # ディレクトリ確認
    if [ ! -d "${MEETINGS_DIR}" ]; then
        mkdir -p "${MEETINGS_DIR}"
    fi

    # 参加者リストを生成
    local participants_yaml=""
    for p in "${participants[@]}"; do
        participants_yaml="${participants_yaml}    - \"${p}\"\n"
    done

    # YAML生成
    cat > "${yaml_file}" << EOF
# ============================================================
# MTGスケジュール (Meeting Schedule)
# ============================================================
# Generated by: call_briefing.sh
# Created at: ${created_at}
# ============================================================

meeting:
  mtg_id: "${mtg_id}"
  type: "${mtg_type}"
  organizer: "${organizer}"
  scheduled_time: "${created_at}"
  duration_minutes: 30

participants:
  required:
$(echo -e "${participants_yaml}")

agenda:
  - item: "${agenda}"
    duration_minutes: 25
    presenter: "${organizer}"

  - item: "質疑応答・議論"
    duration_minutes: 5
    presenter: "all"

metadata:
  status: scheduled
  created_at: "${created_at}"
EOF

    echo "${yaml_file}"
}

# ============================================================
# 司令部MTG
# ============================================================
call_hq_meeting() {
    local agenda=$1
    local organizer="miho"

    log_meeting "=== 司令部MTG招集 ==="
    log_meeting "議題: ${agenda}"
    log_meeting "主催: ${organizer}"
    log_meeting "参加者: ${HQ_MEMBERS[*]}"

    # YAML生成
    local yaml_file
    yaml_file=$(generate_meeting_yaml "hq_meeting" "${organizer}" "${agenda}" "${HQ_MEMBERS[@]}")
    log_info "MTGスケジュール生成: ${yaml_file}"

    # 通知メッセージ
    local message="【MTG招集】司令部会議を開始します。議題: ${agenda}"

    # 全メンバーに通知
    local notified=0
    for i in "${!HQ_MEMBERS[@]}"; do
        if notify_participant "${HQ_SESSION}" "${i}" "${HQ_MEMBERS[$i]}" "${message}"; then
            ((notified++))
        fi
    done

    log_success "司令部MTG招集完了: ${notified}/${#HQ_MEMBERS[@]} 名に通知"
}

# ============================================================
# 中隊MTG
# ============================================================
call_platoon_meeting() {
    local platoon=$1
    local agenda=$2
    local session=""
    local members=()
    local organizer=""

    case "${platoon}" in
        platoon1|1)
            session="${PLATOON1_SESSION}"
            members=("${PLATOON1_MEMBERS[@]}")
            organizer="kay"
            ;;
        platoon2|2)
            session="${PLATOON2_SESSION}"
            members=("${PLATOON2_MEMBERS[@]}")
            organizer="katyusha"
            ;;
        platoon3|3)
            session="${PLATOON3_SESSION}"
            members=("${PLATOON3_MEMBERS[@]}")
            organizer="darjeeling"
            ;;
        *)
            log_error "Unknown platoon: ${platoon}"
            log_error "Valid options: platoon1, platoon2, platoon3"
            exit 1
            ;;
    esac

    log_meeting "=== 中隊MTG招集 (${platoon}) ==="
    log_meeting "議題: ${agenda}"
    log_meeting "主催: ${organizer}"
    log_meeting "参加者: ${members[*]}"

    # YAML生成
    local yaml_file
    yaml_file=$(generate_meeting_yaml "platoon_meeting" "${organizer}" "${agenda}" "${members[@]}")
    log_info "MTGスケジュール生成: ${yaml_file}"

    # 通知メッセージ
    local message="【MTG招集】中隊会議を開始します。議題: ${agenda}"

    # 全メンバーに通知
    local notified=0
    for i in "${!members[@]}"; do
        if notify_participant "${session}" "${i}" "${members[$i]}" "${message}"; then
            ((notified++))
        fi
    done

    log_success "中隊MTG招集完了: ${notified}/${#members[@]} 名に通知"
}

# ============================================================
# 大隊MTG（全員）
# ============================================================
call_battalion_meeting() {
    local agenda=$1
    local organizer="miho"

    log_meeting "=== 大隊MTG招集（全員）==="
    log_meeting "議題: ${agenda}"
    log_meeting "主催: ${organizer}"

    # 全参加者リスト
    local all_members=()
    all_members+=("${HQ_MEMBERS[@]}")
    all_members+=("${PLATOON1_MEMBERS[@]}")
    all_members+=("${PLATOON2_MEMBERS[@]}")
    all_members+=("${PLATOON3_MEMBERS[@]}")

    log_meeting "参加者: ${#all_members[@]} 名"

    # YAML生成
    local yaml_file
    yaml_file=$(generate_meeting_yaml "battalion_meeting" "${organizer}" "${agenda}" "${all_members[@]}")
    log_info "MTGスケジュール生成: ${yaml_file}"

    # 通知メッセージ
    local message="【大隊MTG招集】全体会議を開始します。パンツァー・フォー！議題: ${agenda}"

    local total_notified=0

    # 司令部に通知
    for i in "${!HQ_MEMBERS[@]}"; do
        if notify_participant "${HQ_SESSION}" "${i}" "${HQ_MEMBERS[$i]}" "${message}"; then
            ((total_notified++))
        fi
    done

    # 第1中隊に通知
    for i in "${!PLATOON1_MEMBERS[@]}"; do
        if notify_participant "${PLATOON1_SESSION}" "${i}" "${PLATOON1_MEMBERS[$i]}" "${message}"; then
            ((total_notified++))
        fi
    done

    # 第2中隊に通知
    for i in "${!PLATOON2_MEMBERS[@]}"; do
        if notify_participant "${PLATOON2_SESSION}" "${i}" "${PLATOON2_MEMBERS[$i]}" "${message}"; then
            ((total_notified++))
        fi
    done

    # 第3中隊に通知
    for i in "${!PLATOON3_MEMBERS[@]}"; do
        if notify_participant "${PLATOON3_SESSION}" "${i}" "${PLATOON3_MEMBERS[$i]}" "${message}"; then
            ((total_notified++))
        fi
    done

    log_success "大隊MTG招集完了: ${total_notified}/${#all_members[@]} 名に通知"
}

# ============================================================
# メイン処理
# ============================================================
main() {
    local mtg_type=$1
    local arg2=$2
    local arg3=$3

    # 引数チェック
    if [ -z "${mtg_type}" ]; then
        log_error "MTG type is required"
        usage
    fi

    # notify.sh の存在確認
    if [ ! -x "${NOTIFY_SCRIPT}" ]; then
        log_error "notify.sh not found or not executable: ${NOTIFY_SCRIPT}"
        exit 1
    fi

    echo ""
    echo "============================================================"
    echo " Panzer Project - MTG招集"
    echo " パンツァー・フォー！"
    echo "============================================================"
    echo ""

    case "${mtg_type}" in
        hq_meeting)
            if [ -z "${arg2}" ]; then
                log_error "Agenda is required for hq_meeting"
                usage
            fi
            call_hq_meeting "${arg2}"
            ;;
        platoon_meeting)
            if [ -z "${arg2}" ] || [ -z "${arg3}" ]; then
                log_error "Platoon and agenda are required for platoon_meeting"
                usage
            fi
            call_platoon_meeting "${arg2}" "${arg3}"
            ;;
        battalion_meeting)
            if [ -z "${arg2}" ]; then
                log_error "Agenda is required for battalion_meeting"
                usage
            fi
            call_battalion_meeting "${arg2}"
            ;;
        *)
            log_error "Unknown MTG type: ${mtg_type}"
            log_error "Valid types: hq_meeting, platoon_meeting, battalion_meeting"
            usage
            ;;
    esac

    echo ""
    echo "============================================================"
    log_success "MTG招集完了！"
    echo "============================================================"
    echo ""
}

# スクリプト実行
main "$@"
