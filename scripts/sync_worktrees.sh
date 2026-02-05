#!/bin/bash
# ============================================================
# sync_worktrees.sh - Worktree 同期スクリプト
# ============================================================
# ガルパン・マルチエージェントシステム用
# メインブランチの最新コードを各中隊ワークツリーに配信
#
# 使用例:
#   ./scripts/sync_worktrees.sh all
#   ./scripts/sync_worktrees.sh platoon1
#   ./scripts/sync_worktrees.sh status
#   ./scripts/sync_worktrees.sh all --dry-run
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
WORKTREES_DIR="$PROJECT_ROOT/worktrees"

# ドライランフラグ
DRY_RUN=false

# 同期結果の記録用
declare -a SUCCESS_LIST=()
declare -a FAILED_LIST=()
declare -a SKIPPED_LIST=()

# ============================================================
# ヘルパー関数
# ============================================================

print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# プロジェクトルートに移動
cd_project_root() {
    cd "$PROJECT_ROOT"
}

# メインブランチ名を取得
get_main_branch() {
    cd_project_root
    git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'
}

# ============================================================
# サブコマンド: status
# ============================================================
cmd_status() {
    cd_project_root

    local main_branch
    main_branch=$(get_main_branch)

    echo -e "${CYAN}=== Worktree 同期状況 ===${NC}"
    echo ""
    echo -e "${BLUE}メインブランチ:${NC} $main_branch"
    echo ""

    # ヘッダー
    printf "%-20s %-30s %-10s %s\n" "ワークツリー" "現在のブランチ" "状態" "メインとの差分"
    printf "%s\n" "$(printf '=%.0s' {1..90})"

    # 各ワークツリーの状態を確認
    if [[ -d "$WORKTREES_DIR" ]]; then
        for dir in "$WORKTREES_DIR"/*/; do
            if [[ -d "$dir" ]]; then
                local platoon
                platoon=$(basename "$dir")

                # 現在のブランチを取得
                local current_branch
                current_branch=$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

                # 未コミットの変更確認
                local status_indicator
                if ! git -C "$dir" diff --quiet 2>/dev/null || ! git -C "$dir" diff --cached --quiet 2>/dev/null; then
                    status_indicator="${YELLOW}変更あり${NC}"
                else
                    status_indicator="${GREEN}クリーン${NC}"
                fi

                # メインブランチとの差分確認
                local ahead_behind
                cd "$dir"
                git fetch origin "$main_branch" --quiet 2>/dev/null || true
                local base_commit
                base_commit=$(git merge-base HEAD "origin/$main_branch" 2>/dev/null || echo "")

                if [[ -n "$base_commit" ]]; then
                    local ahead
                    local behind
                    ahead=$(git rev-list --count "origin/$main_branch..$base_commit" 2>/dev/null || echo "0")
                    behind=$(git rev-list --count "$base_commit..origin/$main_branch" 2>/dev/null || echo "0")

                    if [[ "$behind" -eq 0 ]]; then
                        ahead_behind="${GREEN}最新${NC}"
                    else
                        ahead_behind="${YELLOW}${behind}件遅れ${NC}"
                    fi
                else
                    ahead_behind="${RED}不明${NC}"
                fi

                cd_project_root

                printf "%-20s %-30s %-22s %s\n" "$platoon" "$current_branch" "$(echo -e "$status_indicator")" "$(echo -e "$ahead_behind")"
            fi
        done
    else
        print_info "ワークツリーはありません"
    fi

    echo ""
}

# ============================================================
# サブコマンド: sync 単一ワークツリー
# ============================================================
sync_single_worktree() {
    local platoon="$1"
    local worktree_path="$WORKTREES_DIR/$platoon"
    local main_branch
    main_branch=$(get_main_branch)

    # ワークツリー存在確認
    if [[ ! -d "$worktree_path" ]]; then
        print_error "ワークツリーが存在しません: $platoon"
        FAILED_LIST+=("$platoon")
        return 1
    fi

    print_info "[$platoon] 同期を開始します..."

    cd "$worktree_path"

    # 未コミットの変更確認
    if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
        print_warning "[$platoon] 未コミットの変更があります"
        git status --short
        echo ""

        if [[ "$DRY_RUN" == false ]]; then
            read -p "このワークツリーの同期をスキップしますか？ (Y/n): " confirm
            if [[ "$confirm" != "n" && "$confirm" != "N" ]]; then
                print_info "[$platoon] スキップしました"
                SKIPPED_LIST+=("$platoon")
                cd_project_root
                return 0
            fi
        else
            print_info "[DRY-RUN] [$platoon] 未コミット変更があるため、実際の同期時にはスキップされる可能性があります"
        fi
    fi

    # メインブランチの最新を取得
    print_info "[$platoon] origin/$main_branch の最新を取得中..."
    if [[ "$DRY_RUN" == false ]]; then
        if ! git fetch origin "$main_branch" 2>&1; then
            print_error "[$platoon] fetch に失敗しました"
            FAILED_LIST+=("$platoon")
            cd_project_root
            return 1
        fi
    else
        print_info "[DRY-RUN] git fetch origin $main_branch"
    fi

    # 現在のブランチを取得
    local current_branch
    current_branch=$(git rev-parse --abbrev-ref HEAD)

    # メインブランチの最新にrebase
    print_info "[$platoon] $current_branch を origin/$main_branch にrebase中..."
    if [[ "$DRY_RUN" == false ]]; then
        if git rebase "origin/$main_branch" 2>&1; then
            print_success "[$platoon] 同期完了 ($current_branch <- origin/$main_branch)"
            SUCCESS_LIST+=("$platoon")
        else
            print_error "[$platoon] rebase に失敗しました"
            print_warning "[$platoon] rebase を中止します..."
            git rebase --abort 2>/dev/null || true
            FAILED_LIST+=("$platoon")
            cd_project_root
            return 1
        fi
    else
        print_info "[DRY-RUN] git rebase origin/$main_branch"
        print_info "[DRY-RUN] [$platoon] 同期が実行される予定です"
        SUCCESS_LIST+=("$platoon (dry-run)")
    fi

    cd_project_root
    return 0
}

# ============================================================
# サブコマンド: sync all
# ============================================================
cmd_sync_all() {
    cd_project_root

    local main_branch
    main_branch=$(get_main_branch)

    echo -e "${CYAN}=== 全ワークツリーの同期 ===${NC}"
    echo -e "${BLUE}メインブランチ:${NC} $main_branch"
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}[DRY-RUN モード] 実際の操作は行いません${NC}"
    fi
    echo ""

    # ワークツリーディレクトリの存在確認
    if [[ ! -d "$WORKTREES_DIR" ]]; then
        print_error "ワークツリーディレクトリが存在しません: $WORKTREES_DIR"
        exit 1
    fi

    # 各ワークツリーを同期
    local count=0
    for dir in "$WORKTREES_DIR"/*/; do
        if [[ -d "$dir" ]]; then
            local platoon
            platoon=$(basename "$dir")

            echo ""
            sync_single_worktree "$platoon" || true
            ((count++))
        fi
    done

    if [[ $count -eq 0 ]]; then
        print_info "同期対象のワークツリーがありません"
        exit 0
    fi

    # サマリ表示
    echo ""
    echo -e "${CYAN}=== 同期結果サマリ ===${NC}"
    echo ""

    if [[ ${#SUCCESS_LIST[@]} -gt 0 ]]; then
        echo -e "${GREEN}✓ 成功 (${#SUCCESS_LIST[@]}件):${NC}"
        for item in "${SUCCESS_LIST[@]}"; do
            echo "  - $item"
        done
        echo ""
    fi

    if [[ ${#SKIPPED_LIST[@]} -gt 0 ]]; then
        echo -e "${YELLOW}⊘ スキップ (${#SKIPPED_LIST[@]}件):${NC}"
        for item in "${SKIPPED_LIST[@]}"; do
            echo "  - $item"
        done
        echo ""
    fi

    if [[ ${#FAILED_LIST[@]} -gt 0 ]]; then
        echo -e "${RED}✗ 失敗 (${#FAILED_LIST[@]}件):${NC}"
        for item in "${FAILED_LIST[@]}"; do
            echo "  - $item"
        done
        echo ""
    fi
}

# ============================================================
# サブコマンド: sync <platoon>
# ============================================================
cmd_sync_single() {
    local platoon="$1"

    cd_project_root

    local main_branch
    main_branch=$(get_main_branch)

    echo -e "${CYAN}=== ワークツリー同期: $platoon ===${NC}"
    echo -e "${BLUE}メインブランチ:${NC} $main_branch"
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}[DRY-RUN モード] 実際の操作は行いません${NC}"
    fi
    echo ""

    sync_single_worktree "$platoon"

    # サマリ表示
    echo ""
    if [[ ${#SUCCESS_LIST[@]} -gt 0 ]]; then
        print_success "同期が完了しました"
    elif [[ ${#SKIPPED_LIST[@]} -gt 0 ]]; then
        print_info "スキップされました"
    elif [[ ${#FAILED_LIST[@]} -gt 0 ]]; then
        print_error "同期に失敗しました"
        exit 1
    fi
}

# ============================================================
# ヘルプ表示
# ============================================================
show_help() {
    cat << 'EOF'
Worktree 同期スクリプト - ガルパン・マルチエージェントシステム

使用法:
  ./scripts/sync_worktrees.sh <command> [options]

コマンド:
  all [--dry-run]          全ワークツリーをメインブランチの最新に同期
                           例: sync_worktrees.sh all
                           例: sync_worktrees.sh all --dry-run

  <platoon> [--dry-run]    指定ワークツリーのみを同期
                           例: sync_worktrees.sh platoon1
                           例: sync_worktrees.sh platoon2 --dry-run

  status                   各ワークツリーとメインの差分状況を表示
                           例: sync_worktrees.sh status

  help                     このヘルプを表示

オプション:
  --dry-run                実際の操作を行わず、実行内容のみを表示

同期の仕組み:
  1. メインブランチ（通常は main）の最新をfetch
  2. 各ワークツリーの現在のブランチを origin/main にrebase
  3. 未コミットの変更がある場合は警告を表示し、スキップ確認

注意事項:
  - 同期前に必ず status で状態を確認することを推奨
  - 未コミットの変更がある場合、同期はスキップされます
  - rebase に失敗した場合は自動的に中止されます
  - --dry-run で事前に動作を確認できます

例:
  # 全ワークツリーの状態を確認
  ./scripts/sync_worktrees.sh status

  # 全ワークツリーを同期（ドライラン）
  ./scripts/sync_worktrees.sh all --dry-run

  # 全ワークツリーを同期（実行）
  ./scripts/sync_worktrees.sh all

  # 特定のワークツリーのみ同期
  ./scripts/sync_worktrees.sh platoon1
EOF
}

# ============================================================
# メイン処理
# ============================================================
main() {
    local command="${1:-help}"
    local dry_run_arg="${2:-}"

    # --dry-run フラグの確認
    if [[ "$dry_run_arg" == "--dry-run" || "$command" == "--dry-run" ]]; then
        DRY_RUN=true
        if [[ "$command" == "--dry-run" ]]; then
            command="${2:-help}"
        fi
    fi

    case "$command" in
        all)
            cmd_sync_all
            ;;
        status)
            cmd_status
            ;;
        help|--help|-h)
            show_help
            ;;
        platoon*)
            cmd_sync_single "$command"
            ;;
        *)
            print_error "不明なコマンド: $command"
            echo "ヘルプを表示: ./scripts/sync_worktrees.sh help"
            exit 1
            ;;
    esac
}

main "$@"
