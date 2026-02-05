#!/bin/bash
# ============================================================
# merge_request.sh - PR作成支援スクリプト
# ============================================================
# ガルパン・マルチエージェントシステム用
# 副中隊長が中隊の成果をメインに統合するためのPR作成を支援
#
# 使用例:
#   ./scripts/merge_request.sh check platoon1
#   ./scripts/merge_request.sh create platoon1 --title "ログイン機能実装"
#   ./scripts/merge_request.sh status platoon1
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

# プロジェクトルートに移動
cd_project_root() {
    cd "$PROJECT_ROOT"
}

# gh CLI の存在確認
check_gh_cli() {
    if ! command -v gh &> /dev/null; then
        return 1
    fi
    return 0
}

# ============================================================
# サブコマンド: check
# ============================================================
cmd_check() {
    local platoon="$1"
    local worktree_path="$WORKTREES_DIR/$platoon"

    cd_project_root

    # ワークツリー存在確認
    if [[ ! -d "$worktree_path" ]]; then
        print_error "ワークツリーが存在しません: $worktree_path"
        print_info "作成するには: ./scripts/worktree.sh create $platoon <branch>"
        exit 1
    fi

    print_info "マージ可能性をチェックしています: $platoon"
    echo ""

    # ワークツリーに移動
    cd "$worktree_path"

    # 1. 現在のブランチ取得
    local current_branch
    current_branch=$(git branch --show-current)
    print_info "現在のブランチ: $current_branch"

    # 2. 未コミットの変更確認
    echo ""
    echo -e "${CYAN}[1/3] 未コミット変更の確認${NC}"
    if ! git diff --quiet || ! git diff --cached --quiet; then
        print_warning "未コミットの変更があります:"
        git status --short
        echo ""
        print_error "マージ前にコミットしてください"
        exit 1
    else
        print_success "未コミット変更なし"
    fi

    # 3. メインブランチとの差分確認
    echo ""
    echo -e "${CYAN}[2/3] メインブランチとの差分確認${NC}"
    git fetch origin main --quiet
    local ahead behind
    ahead=$(git rev-list --count origin/main.."$current_branch")
    behind=$(git rev-list --count "$current_branch"..origin/main)

    echo "  コミット数（このブランチのみ）: $ahead"
    echo "  コミット数（メインのみ）: $behind"

    if [[ "$ahead" -eq 0 ]]; then
        print_warning "このブランチには新しいコミットがありません"
    fi

    # 4. コンフリクト確認
    echo ""
    echo -e "${CYAN}[3/3] コンフリクト確認${NC}"
    git merge-base "$current_branch" origin/main &> /dev/null || {
        print_error "共通の祖先コミットが見つかりません"
        exit 1
    }

    # 試しにマージを実行（dry-run的な処理）
    if git merge-tree "$(git merge-base "$current_branch" origin/main)" origin/main "$current_branch" | grep -q "^<<<<<"; then
        print_error "マージコンフリクトが検出されました"
        echo ""
        echo -e "${YELLOW}コンフリクトが予想されるファイル:${NC}"
        git merge-tree "$(git merge-base "$current_branch" origin/main)" origin/main "$current_branch" | grep -A 3 "^<<<<<" | head -20
        exit 1
    else
        print_success "コンフリクトなし"
    fi

    echo ""
    print_success "マージ可能です！"
    echo ""
    echo -e "${CYAN}次のステップ:${NC}"
    echo "  ./scripts/merge_request.sh create $platoon --title \"PR タイトル\""
}

# ============================================================
# サブコマンド: create
# ============================================================
cmd_create() {
    local platoon="$1"
    local title="${2:-}"
    local worktree_path="$WORKTREES_DIR/$platoon"

    cd_project_root

    # ワークツリー存在確認
    if [[ ! -d "$worktree_path" ]]; then
        print_error "ワークツリーが存在しません: $worktree_path"
        print_info "作成するには: ./scripts/worktree.sh create $platoon <branch>"
        exit 1
    fi

    # ワークツリーに移動
    cd "$worktree_path"

    # 現在のブランチ取得
    local current_branch
    current_branch=$(git branch --show-current)

    # タイトルが未指定の場合はブランチ名から生成
    if [[ -z "$title" ]]; then
        title="Merge: $current_branch"
        print_info "PRタイトルを自動生成しました: $title"
    fi

    # 事前チェック実行
    print_info "事前チェックを実行しています..."
    if ! git diff --quiet || ! git diff --cached --quiet; then
        print_error "未コミットの変更があります。先にコミットしてください"
        exit 1
    fi

    # リモートにプッシュ
    print_info "リモートにプッシュしています..."
    git push origin "$current_branch" --set-upstream

    # 差分サマリ生成
    echo ""
    echo -e "${CYAN}=== PR差分サマリ ===${NC}"
    echo ""
    echo "変更ファイル数: $(git diff --name-only origin/main..."$current_branch" | wc -l)"
    echo ""
    echo "変更されたファイル:"
    git diff --name-status origin/main..."$current_branch"
    echo ""

    # gh CLI が使える場合
    if check_gh_cli; then
        print_info "gh CLI を使用してPRを作成しています..."

        # PR本文を生成
        local body
        body=$(cat <<EOF
## 変更内容

$(git log origin/main.."$current_branch" --pretty=format:"- %s" | head -10)

## 変更ファイル

\`\`\`
$(git diff --name-status origin/main..."$current_branch")
\`\`\`

---
作成者: $platoon（副中隊長）
ツール: merge_request.sh
EOF
)

        # PR作成
        if gh pr create --base main --head "$current_branch" --title "$title" --body "$body"; then
            print_success "PRを作成しました！"
            echo ""

            # PR URL取得
            local pr_url
            pr_url=$(gh pr view "$current_branch" --json url -q .url 2>/dev/null || echo "")
            if [[ -n "$pr_url" ]]; then
                echo -e "${GREEN}PR URL:${NC} $pr_url"
            fi
        else
            print_error "PR作成に失敗しました"
            exit 1
        fi
    else
        # gh CLI がない場合は手動手順を表示
        print_warning "gh CLI が見つかりません"
        echo ""
        echo -e "${CYAN}手動でPRを作成してください:${NC}"
        echo ""
        echo "1. ブラウザで以下のURLを開く:"
        echo "   https://github.com/$(git remote get-url origin | sed -e 's|.*github.com[:/]||' -e 's|\.git$||')/compare/main...$current_branch"
        echo ""
        echo "2. PRタイトル: $title"
        echo ""
        echo "3. PR本文（以下をコピー）:"
        echo ""
        echo "---"
        echo "## 変更内容"
        echo ""
        git log origin/main.."$current_branch" --pretty=format:"- %s" | head -10
        echo ""
        echo ""
        echo "## 変更ファイル"
        echo ""
        echo '```'
        git diff --name-status origin/main..."$current_branch"
        echo '```'
        echo ""
        echo "---"
        echo "作成者: $platoon（副中隊長）"
        echo "ツール: merge_request.sh"
        echo "---"
        echo ""
        print_info "gh CLI をインストールすると自動作成できます: brew install gh"
    fi
}

# ============================================================
# サブコマンド: status
# ============================================================
cmd_status() {
    local platoon="$1"
    local worktree_path="$WORKTREES_DIR/$platoon"

    cd_project_root

    # ワークツリー存在確認
    if [[ ! -d "$worktree_path" ]]; then
        print_error "ワークツリーが存在しません: $worktree_path"
        print_info "作成するには: ./scripts/worktree.sh create $platoon <branch>"
        exit 1
    fi

    # ワークツリーに移動
    cd "$worktree_path"

    # 現在のブランチ取得
    local current_branch
    current_branch=$(git branch --show-current)

    print_info "PRステータスを確認しています: $platoon ($current_branch)"
    echo ""

    # gh CLI が使える場合
    if check_gh_cli; then
        # このブランチのPRを検索
        local pr_list
        pr_list=$(gh pr list --head "$current_branch" --json number,title,state,url 2>/dev/null || echo "[]")

        if [[ "$pr_list" == "[]" ]]; then
            print_warning "このブランチに関連するPRが見つかりません"
            echo ""
            echo -e "${CYAN}PRを作成するには:${NC}"
            echo "  ./scripts/merge_request.sh create $platoon --title \"PR タイトル\""
        else
            echo -e "${CYAN}=== PR一覧 ===${NC}"
            echo ""
            echo "$pr_list" | jq -r '.[] | "PR #\(.number): \(.title)\n  状態: \(.state)\n  URL: \(.url)\n"'
        fi
    else
        # gh CLI がない場合
        print_warning "gh CLI が見つかりません"
        echo ""
        echo "GitHub上で手動確認してください:"
        echo "  https://github.com/$(git remote get-url origin | sed -e 's|.*github.com[:/]||' -e 's|\.git$||')/pulls"
        echo ""
        print_info "gh CLI をインストールすると自動確認できます: brew install gh"
    fi
}

# ============================================================
# ヘルプ表示
# ============================================================
show_help() {
    cat << 'EOF'
PR作成支援スクリプト - ガルパン・マルチエージェントシステム

使用法:
  ./scripts/merge_request.sh <command> [arguments]

コマンド:
  check <platoon>                 マージ可能性をチェック
                                  - 未コミット変更確認
                                  - メインとの差分確認
                                  - コンフリクト検出
                                  例: check platoon1

  create <platoon> [--title "..."] PRを作成
                                  - 事前チェック実行
                                  - リモートにプッシュ
                                  - PR差分サマリ生成
                                  - gh CLI でPR作成（または手動手順表示）
                                  例: create platoon1 --title "ログイン機能実装"

  status <platoon>                既存PRのステータス確認
                                  例: status platoon1

  help                            このヘルプを表示

前提条件:
  - ワークツリーが作成済みであること
  - gh CLI がインストール済みの場合は自動作成
  - gh CLI がない場合は手動手順を表示

例:
  # マージ前チェック
  ./scripts/merge_request.sh check platoon1

  # PR作成
  ./scripts/merge_request.sh create platoon1 --title "認証機能実装"

  # PRステータス確認
  ./scripts/merge_request.sh status platoon1

gh CLI のインストール:
  brew install gh
  gh auth login
EOF
}

# ============================================================
# メイン処理
# ============================================================
main() {
    local command="${1:-help}"

    case "$command" in
        check)
            if [[ $# -lt 2 ]]; then
                print_error "引数が不足しています"
                echo "使用法: ./scripts/merge_request.sh check <platoon>"
                exit 1
            fi
            cmd_check "$2"
            ;;
        create)
            if [[ $# -lt 2 ]]; then
                print_error "引数が不足しています"
                echo "使用法: ./scripts/merge_request.sh create <platoon> [--title \"タイトル\"]"
                exit 1
            fi
            local title=""
            if [[ $# -ge 4 ]] && [[ "$3" == "--title" ]]; then
                title="$4"
            fi
            cmd_create "$2" "$title"
            ;;
        status)
            if [[ $# -lt 2 ]]; then
                print_error "引数が不足しています"
                echo "使用法: ./scripts/merge_request.sh status <platoon>"
                exit 1
            fi
            cmd_status "$2"
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "不明なコマンド: $command"
            echo "ヘルプを表示: ./scripts/merge_request.sh help"
            exit 1
            ;;
    esac
}

main "$@"
