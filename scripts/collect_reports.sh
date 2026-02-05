#!/bin/bash
# ============================================================
# Panzer Project - Report Collector Script
# ============================================================
# 指定ディレクトリ内の報告YAMLファイルを収集・表示するスクリプト
#
# 使用例:
#   ./scripts/collect_reports.sh queue/platoon1/reports
#   ./scripts/collect_reports.sh queue/hq/reports
#   ./scripts/collect_reports.sh queue/platoon1/reports --json
#
# 引数:
#   $1: 対象ディレクトリ（例: queue/platoon1/reports）
#   $2: オプション（--json: JSON形式で出力）
# ============================================================

set -e

# globパターンがマッチしない場合に空文字列を返す
shopt -s nullglob

# 作業ディレクトリ
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "${SCRIPT_DIR}")"

# 色設定
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# 区切り線
SEPARATOR="════════════════════════════════════════════════════════════════"

# ============================================================
# 使用方法を表示
# ============================================================
usage() {
    echo "Usage: $0 <target_directory> [options]"
    echo ""
    echo "Arguments:"
    echo "  target_directory  報告ファイルがあるディレクトリ"
    echo ""
    echo "Options:"
    echo "  --json           JSON形式で出力（ファイル名とパスを含む）"
    echo "  --summary        サマリのみ表示（ファイル名とstatusのみ）"
    echo "  --help, -h       このヘルプを表示"
    echo ""
    echo "Examples:"
    echo "  $0 queue/platoon1/reports"
    echo "  $0 queue/hq/reports --summary"
    echo "  $0 queue/platoon2/reports --json"
    echo ""
    echo "Common directories:"
    echo "  queue/hq/reports         司令部の報告"
    echo "  queue/platoon1/reports   第1中隊の報告"
    echo "  queue/platoon2/reports   第2中隊の報告"
    echo "  queue/platoon3/reports   第3中隊の報告"
    exit 0
}

# ============================================================
# ファイル名から色を決定
# ============================================================
get_color_for_file() {
    local filename=$1
    case "$filename" in
        *leader*|*commander*) echo "$GREEN" ;;
        *deputy*) echo "$CYAN" ;;
        *error*|*fail*) echo "$RED" ;;
        *warning*) echo "$YELLOW" ;;
        *) echo "$BLUE" ;;
    esac
}

# ============================================================
# ステータスから色を決定
# ============================================================
get_status_color() {
    local status=$1
    case "$status" in
        done|completed|success) echo "$GREEN" ;;
        in_progress|running) echo "$YELLOW" ;;
        failed|error) echo "$RED" ;;
        pending|waiting) echo "$CYAN" ;;
        *) echo "$NC" ;;
    esac
}

# ============================================================
# YAMLファイルからステータスを抽出
# ============================================================
extract_status() {
    local file=$1
    grep -E "^status:" "$file" 2>/dev/null | sed 's/status:[[:space:]]*//' | tr -d '"' | head -1
}

# ============================================================
# YAMLファイルからサマリを抽出
# ============================================================
extract_summary() {
    local file=$1
    # summary: の直後の行（インデントされた行）を取得
    sed -n '/^[[:space:]]*summary:/,/^[[:space:]]*[a-z_]*:/p' "$file" 2>/dev/null | \
        grep -v "^[[:space:]]*summary:" | \
        grep -v "^[[:space:]]*[a-z_]*:" | \
        head -3 | \
        sed 's/^[[:space:]]*/  /'
}

# ============================================================
# 通常表示モード
# ============================================================
display_normal() {
    local target_dir=$1
    local count=0

    echo -e "${CYAN}${SEPARATOR}${NC}"
    echo -e "${CYAN}  報告収集: ${target_dir}${NC}"
    echo -e "${CYAN}${SEPARATOR}${NC}"
    echo ""

    for file in "${target_dir}"/*.yaml "${target_dir}"/*.yml ; do
        if [[ -f "$file" ]]; then
            local filename
            filename=$(basename "$file")
            local color
            color=$(get_color_for_file "$filename")

            echo -e "${color}┌─ ${filename} ─────────────────────────────────────${NC}"
            echo -e "${color}│${NC}"

            # ファイル内容を表示（インデント付き）
            while IFS= read -r line; do
                echo -e "${color}│${NC} $line"
            done < "$file"

            echo -e "${color}│${NC}"
            echo -e "${color}└────────────────────────────────────────────────────${NC}"
            echo ""

            ((count++))
        fi
    done

    if [[ $count -eq 0 ]]; then
        echo -e "${YELLOW}[INFO]${NC} 報告ファイルがありません: ${target_dir}"
        echo ""
    else
        echo -e "${GREEN}[SUMMARY]${NC} ${count} 件の報告を表示しました"
    fi
}

# ============================================================
# サマリ表示モード
# ============================================================
display_summary() {
    local target_dir=$1
    local count=0

    echo -e "${CYAN}${SEPARATOR}${NC}"
    echo -e "${CYAN}  報告サマリ: ${target_dir}${NC}"
    echo -e "${CYAN}${SEPARATOR}${NC}"
    echo ""

    printf "%-30s %-12s %s\n" "ファイル名" "ステータス" "概要"
    printf "%s\n" "$(printf '─%.0s' {1..70})"

    for file in "${target_dir}"/*.yaml "${target_dir}"/*.yml ; do
        if [[ -f "$file" ]]; then
            local filename
            filename=$(basename "$file")
            local status
            status=$(extract_status "$file")
            local status_color
            status_color=$(get_status_color "$status")

            # サマリの最初の行を取得
            local summary_line
            summary_line=$(extract_summary "$file" | head -1 | sed 's/^[[:space:]]*//')

            printf "%-30s ${status_color}%-12s${NC} %s\n" "$filename" "${status:-N/A}" "${summary_line:0:40}"

            ((count++))
        fi
    done

    echo ""
    if [[ $count -eq 0 ]]; then
        echo -e "${YELLOW}[INFO]${NC} 報告ファイルがありません"
    else
        echo -e "${GREEN}[SUMMARY]${NC} ${count} 件の報告"
    fi
}

# ============================================================
# JSON表示モード
# ============================================================
display_json() {
    local target_dir=$1
    local first=true

    echo "["

    for file in "${target_dir}"/*.yaml "${target_dir}"/*.yml ; do
        if [[ -f "$file" ]]; then
            if [[ "$first" == true ]]; then
                first=false
            else
                echo ","
            fi

            local filename
            filename=$(basename "$file")
            local content
            content=$(cat "$file" | sed 's/\\/\\\\/g' | sed 's/"/\\"/g' | tr '\n' '\\n' | sed 's/\\n$//')

            echo "  {"
            echo "    \"filename\": \"${filename}\","
            echo "    \"path\": \"${file}\","
            echo "    \"content\": \"${content}\""
            echo -n "  }"
        fi
    done

    echo ""
    echo "]"
}

# ============================================================
# メイン処理
# ============================================================
main() {
    local target_dir=""
    local mode="normal"

    # 引数解析
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help|-h)
                usage
                ;;
            --json)
                mode="json"
                shift
                ;;
            --summary)
                mode="summary"
                shift
                ;;
            *)
                if [[ -z "$target_dir" ]]; then
                    target_dir="$1"
                fi
                shift
                ;;
        esac
    done

    # 引数チェック
    if [[ -z "$target_dir" ]]; then
        echo -e "${RED}[ERROR]${NC} 対象ディレクトリを指定してください" >&2
        echo "Usage: $0 <target_directory> [--json|--summary]" >&2
        exit 1
    fi

    # 相対パスの場合はプロジェクトルートからの相対パスとして解釈
    if [[ "$target_dir" != /* ]]; then
        target_dir="${PROJECT_DIR}/${target_dir}"
    fi

    # ディレクトリ存在確認
    if [[ ! -d "$target_dir" ]]; then
        echo -e "${RED}[ERROR]${NC} ディレクトリが存在しません: ${target_dir}" >&2
        exit 1
    fi

    # モードに応じて表示
    case "$mode" in
        normal)
            display_normal "$target_dir"
            ;;
        summary)
            display_summary "$target_dir"
            ;;
        json)
            display_json "$target_dir"
            ;;
    esac
}

# スクリプト実行
main "$@"
