#!/bin/bash
# ============================================================
# worktree.sh - Git Worktree 管理スクリプト（生成例）
# ============================================================
# このファイルは git-worktree-manager スキルが生成する
# スクリプトのサンプルである
#
# 使用例:
#   ./scripts/worktree.sh create team-alpha feature/login
#   ./scripts/worktree.sh list
#   ./scripts/worktree.sh switch team-alpha feature/signup
#   ./scripts/worktree.sh cleanup team-alpha
#   ./scripts/worktree.sh status
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

ensure_worktrees_dir() {
    if [[ ! -d "$WORKTREES_DIR" ]]; then
        mkdir -p "$WORKTREES_DIR"
        print_info "worktrees ディレクトリを作成しました: $WORKTREES_DIR"
    fi
}

cd_project_root() {
    cd "$PROJECT_ROOT"
}

# ============================================================
# サブコマンド: create
# ============================================================
cmd_create() {
    local team="$1"
    local branch="$2"
    local worktree_path="$WORKTREES_DIR/$team"

    ensure_worktrees_dir
    cd_project_root

    if [[ -d "$worktree_path" ]]; then
        print_error "ワークツリーは既に存在します: $worktree_path"
        print_info "削除するには: ./scripts/worktree.sh cleanup $team"
        exit 1
    fi

    if git show-ref --verify --quiet "refs/heads/$branch" 2>/dev/null; then
        print_info "既存ブランチでワークツリーを作成します: $branch"
        git worktree add "$worktree_path" "$branch"
    else
        print_info "新規ブランチを作成してワークツリーを作成します: $branch"
        git worktree add -b "$branch" "$worktree_path"
    fi

    print_success "ワークツリーを作成しました: worktrees/$team ($branch)"
    echo ""
    echo -e "${CYAN}次のステップ:${NC}"
    echo "  cd $worktree_path"
    echo "  # ここで作業を開始"
}

# ============================================================
# サブコマンド: list
# ============================================================
cmd_list() {
    cd_project_root

    echo -e "${CYAN}=== Git Worktree 一覧 ===${NC}"
    echo ""
    printf "%-30s %-30s %-10s\n" "パス" "ブランチ" "状態"
    printf "%s\n" "$(printf '=%.0s' {1..75})"

    git worktree list --porcelain | while read -r line; do
        case "$line" in
            "worktree "*)
                current_path="${line#worktree }"
                ;;
            "HEAD "*)
                current_head="${line#HEAD }"
                ;;
            "branch "*)
                current_branch="${line#branch refs/heads/}"
                display_path="${current_path/$PROJECT_ROOT\//}"
                if [[ "$display_path" == "$current_path" ]]; then
                    display_path="(main)"
                fi
                printf "%-30s %-30s ${GREEN}%-10s${NC}\n" "$display_path" "$current_branch" "active"
                ;;
            "detached")
                display_path="${current_path/$PROJECT_ROOT\//}"
                printf "%-30s %-30s ${YELLOW}%-10s${NC}\n" "$display_path" "(detached)" "detached"
                ;;
        esac
    done

    echo ""
}

# ============================================================
# サブコマンド: switch
# ============================================================
cmd_switch() {
    local team="$1"
    local branch="$2"
    local worktree_path="$WORKTREES_DIR/$team"

    cd_project_root

    if [[ ! -d "$worktree_path" ]]; then
        print_error "ワークツリーが存在しません: $worktree_path"
        print_info "作成するには: ./scripts/worktree.sh create $team <branch>"
        exit 1
    fi

    cd "$worktree_path"

    if ! git diff --quiet || ! git diff --cached --quiet; then
        print_warning "未コミットの変更があります"
        git status --short
        echo ""
        read -p "続行しますか？ (y/N): " confirm
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            print_info "キャンセルしました"
            exit 0
        fi
    fi

    if git show-ref --verify --quiet "refs/heads/$branch" 2>/dev/null; then
        print_info "既存ブランチに切り替えます: $branch"
        git checkout "$branch"
    else
        print_info "新規ブランチを作成して切り替えます: $branch"
        git checkout -b "$branch"
    fi

    print_success "ブランチを切り替えました: $team -> $branch"
}

# ============================================================
# サブコマンド: cleanup
# ============================================================
cmd_cleanup() {
    local team="$1"
    local force="${2:-}"
    local worktree_path="$WORKTREES_DIR/$team"

    cd_project_root

    if [[ ! -d "$worktree_path" ]]; then
        print_error "ワークツリーが存在しません: $worktree_path"
        exit 1
    fi

    if [[ "$force" != "--force" ]]; then
        echo -e "${YELLOW}警告: ワークツリーを削除します${NC}"
        echo "  パス: $worktree_path"
        echo ""

        cd "$worktree_path"
        if ! git diff --quiet || ! git diff --cached --quiet; then
            print_warning "未コミットの変更があります:"
            git status --short
            echo ""
        fi
        cd "$PROJECT_ROOT"

        read -p "本当に削除しますか？ (y/N): " confirm
        if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
            print_info "キャンセルしました"
            exit 0
        fi
    fi

    git worktree remove "$worktree_path" --force
    print_success "ワークツリーを削除しました: worktrees/$team"

    git worktree prune
}

# ============================================================
# サブコマンド: status
# ============================================================
cmd_status() {
    cd_project_root

    echo -e "${CYAN}=== 全ワークツリーの状態 ===${NC}"
    echo ""

    echo -e "${BLUE}[メイン]${NC} $PROJECT_ROOT"
    git -C "$PROJECT_ROOT" status --short --branch
    echo ""

    if [[ -d "$WORKTREES_DIR" ]]; then
        for dir in "$WORKTREES_DIR"/*/; do
            if [[ -d "$dir" ]]; then
                team=$(basename "$dir")
                echo -e "${BLUE}[$team]${NC} $dir"
                git -C "$dir" status --short --branch
                echo ""
            fi
        done
    else
        print_info "ワークツリーはありません"
    fi
}

# ============================================================
# ヘルプ表示
# ============================================================
show_help() {
    cat << 'EOF'
Git Worktree 管理スクリプト

使用法:
  ./scripts/worktree.sh <command> [arguments]

コマンド:
  create <team> <branch>    ワークツリーを作成
  list                      ワークツリー一覧を表示
  switch <team> <branch>    ブランチを切り替え
  cleanup <team> [--force]  ワークツリーを削除
  status                    全ワークツリーの状態を表示
  help                      このヘルプを表示
EOF
}

# ============================================================
# メイン処理
# ============================================================
main() {
    local command="${1:-help}"

    case "$command" in
        create)
            [[ $# -lt 3 ]] && { print_error "引数不足"; exit 1; }
            cmd_create "$2" "$3"
            ;;
        list)
            cmd_list
            ;;
        switch)
            [[ $# -lt 3 ]] && { print_error "引数不足"; exit 1; }
            cmd_switch "$2" "$3"
            ;;
        cleanup)
            [[ $# -lt 2 ]] && { print_error "引数不足"; exit 1; }
            cmd_cleanup "$2" "${3:-}"
            ;;
        status)
            cmd_status
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "不明なコマンド: $command"
            exit 1
            ;;
    esac
}

main "$@"
