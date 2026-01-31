#!/bin/bash
# ============================================================
# Panzer Project - tmux send-keys Helper Script
# ============================================================
# tmux send-keys を安全に実行するヘルパースクリプト
#
# 機能:
#   - 2回分割送信の自動化（メッセージ送信 + Enter送信）
#   - 対象ペインの存在確認
#   - エラーハンドリング
#   - ログ出力（logs/ ディレクトリに記録）
#
# 使用例:
#   ./scripts/notify.sh panzer-1:0.0 "新しい指示があります"
#   ./scripts/notify.sh panzer-hq:0.1 "報告書を確認されよ"
#
# 引数:
#   $1: 対象ペイン（session:window.pane 形式）
#   $2: 送信するメッセージ
# ============================================================

# 作業ディレクトリ
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "${SCRIPT_DIR}")"
LOG_DIR="${PROJECT_DIR}/logs"
LOG_FILE="${LOG_DIR}/notify.log"
RETRY_LOG_FILE="${LOG_DIR}/notify_retry.log"

# 色設定（ターミナル出力用）
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ============================================================
# ログ関数
# ============================================================
log_to_file() {
    local level=$1
    local message=$2
    local timestamp
    timestamp=$(date "+%Y-%m-%dT%H:%M:%S")

    # ログディレクトリがなければ作成
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

# ============================================================
# 使用方法を表示
# ============================================================
usage() {
    echo "Usage: $0 <target_pane> <message>"
    echo ""
    echo "Arguments:"
    echo "  target_pane  Target pane in format: session:window.pane"
    echo "               Examples: panzer-1:0.0, panzer-hq:0.1"
    echo "  message      Message to send to the pane"
    echo ""
    echo "Examples:"
    echo "  $0 panzer-1:0.0 '新しい指示があります'"
    echo "  $0 panzer-hq:0.1 '報告書を確認されよ'"
    exit 1
}

# ============================================================
# セッション存在確認
# ============================================================
check_session_exists() {
    local target=$1
    local session_name

    # session:window.pane からセッション名を抽出
    session_name=$(echo "${target}" | cut -d':' -f1)

    if ! tmux has-session -t "${session_name}" 2>/dev/null; then
        log_error "Session '${session_name}' does not exist"
        return 1
    fi

    return 0
}

# ============================================================
# ペイン存在確認
# ============================================================
check_pane_exists() {
    local target=$1

    # ペインが存在するか確認（list-panes でエラーが出なければ存在）
    if ! tmux list-panes -t "${target}" >/dev/null 2>&1; then
        log_error "Pane '${target}' does not exist"
        return 1
    fi

    return 0
}

# ============================================================
# リトライ失敗ログ記録
# ============================================================
log_retry_failed() {
    local target=$1
    local message=$2
    local reason=$3
    local timestamp
    timestamp=$(date "+%Y-%m-%dT%H:%M:%S")

    # ログディレクトリがなければ作成
    if [ ! -d "${LOG_DIR}" ]; then
        mkdir -p "${LOG_DIR}"
    fi

    echo "[${timestamp}] [RETRY_FAILED] target=${target} message=${message} reason=${reason}" >> "${RETRY_LOG_FILE}"
    log_to_file "RETRY_FAILED" "target=${target} message=${message} reason=${reason}"
}

# ============================================================
# ペインのidle/busy状態チェック（プレチェック機能）
# ============================================================
# return 0: idle（送信可能）
# return 1: busy（送信すべきでない）
check_pane_idle() {
    local target=$1
    local pane_output
    local last_lines

    # capture-pane で最終5行を取得
    pane_output=$(tmux capture-pane -t "${target}" -p -S -5 2>/dev/null)
    if [ $? -ne 0 ]; then
        # キャプチャ失敗時は送って問題ないと判定
        return 0
    fi

    last_lines="${pane_output}"

    # busyパターンの検出
    local busy_patterns=("thinking" "Thinking" "Effecting" "Reading" "Writing" "Searching" "Running" "Executing" "Processing" "Loading" "Analyzing")
    for pattern in "${busy_patterns[@]}"; do
        if echo "${last_lines}" | grep -q "${pattern}"; then
            log_info "Pane '${target}' is busy (detected: ${pattern})"
            return 1
        fi
    done

    # idleパターンの検出（❯ がプロンプト）
    if echo "${last_lines}" | grep -q "❯"; then
        return 0
    fi

    # 判定不能 → 送って問題ない
    return 0
}

# ============================================================
# send-keys を2回に分けて実行
# ============================================================
send_message() {
    local target=$1
    local message=$2

    # 1回目: メッセージを送信
    if ! tmux send-keys -t "${target}" "${message}"; then
        log_error "Failed to send message to '${target}'"
        return 1
    fi

    # 少し待機（安定性向上のため）
    sleep 0.1

    # 2回目: Enter を送信（C-m ではなく Enter を使用）
    if ! tmux send-keys -t "${target}" Enter; then
        log_error "Failed to send Enter to '${target}'"
        return 1
    fi

    return 0
}

# ============================================================
# メイン処理
# ============================================================
main() {
    local target_pane=$1
    local message=$2

    # 引数チェック
    if [ -z "${target_pane}" ] || [ -z "${message}" ]; then
        log_error "Missing required arguments"
        usage
    fi

    # セッション存在確認
    if ! check_session_exists "${target_pane}"; then
        exit 1
    fi

    # ペイン存在確認
    if ! check_pane_exists "${target_pane}"; then
        exit 1
    fi

    # プレチェック: 相手がidle状態か確認
    log_info "Pre-check: checking if '${target_pane}' is idle..."

    if ! check_pane_idle "${target_pane}"; then
        # ビジー → 1回だけリトライ（sleep 3 後）
        log_warn "Pane '${target_pane}' is busy. Retrying once after 3 seconds..."
        sleep 3

        if ! check_pane_idle "${target_pane}"; then
            # まだビジー → 送信断念
            log_warn "Pane '${target_pane}' is still busy. Giving up."
            log_retry_failed "${target_pane}" "${message}" "busy"
            exit 2
        fi
    fi

    # メッセージ送信
    log_info "Sending message to '${target_pane}'"

    if send_message "${target_pane}" "${message}"; then
        log_success "Message sent successfully to '${target_pane}': ${message}"
        exit 0
    else
        log_error "Failed to send message to '${target_pane}'"
        exit 1
    fi
}

# スクリプト実行
main "$@"
