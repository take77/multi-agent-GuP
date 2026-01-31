#!/bin/bash
# ============================================================
# Panzer Project - Bridge Launcher (Native Window Opener)
# ============================================================
# tmuxセッションをネイティブターミナルウィンドウで開くスクリプト
#
# macOS: Terminal.app (AppleScript経由)
# Linux: konsole / gnome-terminal
#
# 使用例:
#   ./scripts/bridge_launcher.sh panzer-hq miho
#   ./scripts/bridge_launcher.sh panzer-1 kay
#
# 引数:
#   $1: tmuxセッション名 (例: panzer-hq)
#   $2: tmuxウィンドウ名 (例: miho)
# ============================================================

set -e

# 作業ディレクトリ（動的解決）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
WORK_DIR="$(dirname "$SCRIPT_DIR")"

# ============================================================
# ログ関数
# ============================================================
log_info() {
    echo "[bridge_launcher] $1"
}

log_error() {
    echo "[bridge_launcher] ERROR: $1" >&2
}

# ============================================================
# 使用方法を表示
# ============================================================
usage() {
    echo "Usage: $0 <session_name> <window_name>"
    echo ""
    echo "Arguments:"
    echo "  session_name  tmux session name (e.g., panzer-hq)"
    echo "  window_name   tmux window name (e.g., miho)"
    echo ""
    echo "Examples:"
    echo "  $0 panzer-hq miho"
    echo "  $0 panzer-1 kay"
    exit 1
}

# ============================================================
# セッション存在確認
# ============================================================
check_session_exists() {
    local session_name=$1

    if ! tmux has-session -t "${session_name}" 2>/dev/null; then
        log_error "Session '${session_name}' does not exist"
        exit 1
    fi
}

# ============================================================
# macOS: Terminal.app で新しいウィンドウを開く
# ============================================================
open_macos_window() {
    local session_name=$1
    local window_name=$2
    local attach_cmd="tmux attach-session -t ${session_name}"

    osascript <<APPLESCRIPT
tell application "Terminal"
    activate
    do script "${attach_cmd}"
end tell
APPLESCRIPT

    if [ $? -ne 0 ]; then
        log_error "Failed to open Terminal.app window"
        exit 1
    fi
}

# ============================================================
# Linux: konsole または gnome-terminal で新しいウィンドウを開く
# ============================================================
open_linux_window() {
    local session_name=$1
    local window_name=$2
    local attach_cmd="tmux attach-session -t ${session_name}"

    if which konsole >/dev/null 2>&1; then
        konsole --new-tab -e bash -c "${attach_cmd}" &
    elif which gnome-terminal >/dev/null 2>&1; then
        gnome-terminal -- bash -c "${attach_cmd}" &
    else
        log_error "No supported terminal emulator found (tried: konsole, gnome-terminal)"
        exit 1
    fi

    if [ $? -ne 0 ]; then
        log_error "Failed to open terminal window"
        exit 1
    fi
}

# ============================================================
# メイン処理
# ============================================================
main() {
    local session_name=$1
    local window_name=$2

    # 引数チェック
    if [ -z "${session_name}" ] || [ -z "${window_name}" ]; then
        log_error "Missing required arguments"
        usage
    fi

    # セッション存在確認
    check_session_exists "${session_name}"

    # OS判別
    local os_type
    os_type=$(uname)
    log_info "Detected OS: ${os_type}"

    case "${os_type}" in
        Darwin)
            open_macos_window "${session_name}" "${window_name}"
            ;;
        Linux)
            open_linux_window "${session_name}" "${window_name}"
            ;;
        *)
            log_error "Unsupported OS: ${os_type}"
            exit 1
            ;;
    esac

    log_info "Opened native window for ${session_name}:${window_name}"
}

# スクリプト実行
main "$@"
