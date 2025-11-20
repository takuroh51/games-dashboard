#!/bin/bash
set -e
# generate_handover.sh - 引き継ぎファイル自動生成スクリプト
# Version: 1.0.0
# Purpose: プロジェクトの状態を包括的に収集して引き継ぎファイルを作成

# 設定
PROJECT_DIR="$(pwd)"
PROJECT_NAME=$(basename "$PROJECT_DIR")
CLAUDE_DIR=".claude"
HANDOVER_FILE="$CLAUDE_DIR/handover.txt"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')
SESSION_ID="$(date +%Y%m%d_%H%M)"

# カラー出力
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# ログ関数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# ヘルプメッセージ表示
show_help() {
    cat << 'EOF'
使用方法: generate_handover.sh [オプション]

引き継ぎファイルを自動生成します。

オプション:
  -h, --help              このヘルプメッセージを表示
  -t, --threshold <行数>  要約を実行する閾値（デフォルト: 1400行）
  -s, --summary-lines <行数>  各セッションの要約行数（デフォルト: 10行）
  --no-summarize          要約処理をスキップ

例:
  # 通常実行
  ./generate_handover.sh

  # 閾値を2000行に変更
  ./generate_handover.sh --threshold 2000

  # 要約をスキップ
  ./generate_handover.sh --no-summarize

詳細: CLAUDE.md を参照してください。
EOF
}

# プロジェクト基本情報を収集
collect_project_info() {
    # log_info "プロジェクト基本情報を収集中..."  # ファイル出力時は非表示

    cat << EOF
# 🏠 プロジェクト基本情報

**プロジェクト名**: $PROJECT_NAME
**引き継ぎ作成日時**: $TIMESTAMP
**作業ディレクトリ**: $PROJECT_DIR

## 📂 プロジェクト構造
\`\`\`
EOF

    # プロジェクト構造をツリー形式で出力（depth=2）
    if command -v tree >/dev/null 2>&1; then
        tree -L 2 -a -I '.git'
    else
        # treeコマンドが無い場合の代替
        find . -maxdepth 2 -type d -not -path '*/\.*' | sort | sed 's|[^/]*/|  |g'
    fi

    cat << EOF
\`\`\`

## 📋 重要ファイル
EOF

    # 重要ファイルのリスト
    local important_files=(
        "CLAUDE.md"
        "claude-wrapper.sh"
        "SPEC_INPUT.txt"
        "ERROR_INPUT.txt"
        "TASK_LIST.md"
        "*.spec.md"
        "*_implement.md"
    )

    for pattern in "${important_files[@]}"; do
        for file in $pattern; do
            if [ -f "$file" ]; then
                local size=$(ls -lh "$file" | awk '{print $5}')
                local modified=$(ls -l "$file" | awk '{print $6, $7, $8}')
                echo "- \`$file\` ($size) - 最終更新: $modified"
            fi
        done
    done
}

# Git情報を収集
collect_git_info() {
    # log_info "Git情報を収集中..."  # ファイル出力時は非表示

    cat << EOF

# 📁 バージョン管理情報

EOF

    if [ -d ".git" ]; then
        cat << EOF
## Git状態
\`\`\`bash
EOF
        echo "# ブランチ情報"
        git branch -a 2>/dev/null || echo "ブランチ情報を取得できませんでした"
        echo ""

        echo "# ステータス"
        git status --porcelain 2>/dev/null || echo "ステータス情報を取得できませんでした"
        echo ""

        echo "# 最新のコミット (5件)"
        git log --oneline -5 2>/dev/null || echo "コミット履歴を取得できませんでした"

        cat << EOF
\`\`\`

## 変更されたファイル
EOF
        if git status --porcelain >/dev/null 2>&1; then
            git status --porcelain | while read status file; do
                echo "- \`$status $file\`"
            done
        fi
    else
        echo "❌ このプロジェクトはGit管理されていません"
    fi
}

# 設定・環境情報を収集
collect_environment_info() {
    # log_info "環境・設定情報を収集中..."  # ファイル出力時は非表示

    cat << EOF

# ⚙️ 環境・設定情報

## システム情報
- **OS**: $(uname -s)
- **バージョン**: $(uname -r)
- **アーキテクチャ**: $(uname -m)

## Claude Code環境
EOF

    # Claude Codeのバージョン確認
    if command -v claude >/dev/null 2>&1; then
        echo "- **Claude Command**: 利用可能"
        # claude --version 2>/dev/null || echo "  (バージョン情報取得不可)"
    else
        echo "- **Claude Command**: ❌ 利用不可"
    fi

    # エンジン設定
    if [ -d "$CLAUDE_DIR/engines" ] && [ -n "$(ls -A "$CLAUDE_DIR/engines" 2>/dev/null)" ]; then
        cat << EOF

## 🚀 利用可能エンジン
EOF
        ls -1 "$CLAUDE_DIR/engines"/*.profile 2>/dev/null | while read profile; do
            local engine_name=$(basename "$profile" .profile)
            local model=$(head -1 "$profile" 2>/dev/null)
            echo "- **$engine_name**: $model"
        done
    fi

    # 環境変数
    cat << EOF

## 環境変数
EOF

    local env_vars=("CLAUDE_MODEL" "ANTHROPIC_MODEL" "ANTHROPIC_API_KEY")
    for var in "${env_vars[@]}"; do
        if [ -n "${!var}" ]; then
            if [[ "$var" == *"API_KEY"* ]]; then
                echo "- **$var**: [設定済み]"
            else
                echo "- **$var**: ${!var}"
            fi
        else
            echo "- **$var**: 未設定"
        fi
    done
}

# 最新のセッション情報を収集
collect_session_info() {
    # log_info "最新セッション情報を収集中..."  # ファイル出力時は非表示

    cat << EOF

# 💬 最新セッション情報

EOF

    # 最新のセッションログを探す
    if [ -d "$CLAUDE_DIR/full_text_logs" ]; then
        local latest_log=$(ls -t "$CLAUDE_DIR/full_text_logs"/session_*.txt 2>/dev/null | head -1)
        if [ -n "$latest_log" ]; then
            local log_name=$(basename "$latest_log")
            local log_size=$(ls -lh "$latest_log" | awk '{print $5}')
            local log_date=$(ls -l "$latest_log" | awk '{print $6, $7, $8}')

            # セッションログをクリーニング（v10.6.5+）
            local clean_log="${latest_log%.txt}_clean.txt"
            if [ -f "$CLAUDE_DIR/clean_session_log.sh" ]; then
                # クリーニングスクリプト実行（出力は抑制）
                bash "$CLAUDE_DIR/clean_session_log.sh" "$latest_log" "$clean_log" >/dev/null 2>&1 || true
            fi

            cat << EOF
## 📝 最新セッションログ
- **ファイル**: \`$log_name\`
- **サイズ**: $log_size
- **最終更新**: $log_date

### セッション概要（クリーン版・末尾200行）
\`\`\`
EOF
            # クリーンログがあればそれを使用、なければ元のログ
            if [ -f "$clean_log" ]; then
                tail -200 "$clean_log" 2>/dev/null | head -100
            else
                tail -50 "$latest_log" 2>/dev/null | head -30
            fi
            echo '```'
        fi
    fi

    # TODO情報があれば取得
    if [ -f "TASK_LIST.md" ]; then
        cat << EOF

## 📋 タスク状況
\`\`\`markdown
EOF
        cat "TASK_LIST.md"
        echo '```'
    fi
}

# 警告・注意事項を生成
generate_warnings_and_notes() {
    # log_info "警告・注意事項を生成中..."  # ファイル出力時は非表示

    cat << EOF

# ⚠️ 引き継ぎ時の注意事項

## 🛡️ 破ってはいけない3つの掟
1. **動作中のコードは変更しない** - 追加のみ、改造禁止
2. **必要最小限の変更** - 指示された機能の追加のみ
3. **Context lowで即中断** - 無理に続けない

## 🔍 重要な確認ポイント
- [ ] アクティブな実験があるか確認
- [ ] 未完了のタスクがないか確認
- [ ] 設定ファイル（CLAUDE.md）の内容を理解
- [ ] 最新のセッションログでトラブルの有無を確認

## 📚 参考資料
- \`CLAUDE.md\` - プロジェクト開発憲法
- \`claude-wrapper.sh\` - メインスクリプト
- \`.claude/alpha_profile.md\` - AI人格プロファイル（アルファの判断指針）
- \`.claude/full_text_logs/\` - 詳細なセッションログ

EOF

    # git管理されていない場合の警告
    if [ ! -d ".git" ]; then
        cat << EOF
## 🚨 重要な警告
このプロジェクトはGit管理されていません。重要な変更前には必ずバックアップを作成してください。

EOF
    fi
}

# セッション検出ロジック（要約対象の最初のセッションを見つける）
detect_first_detailed_session() {
    local history_start="$1"
    local has_summary_section="$2"

    local first_detailed_session_line=""
    if [ "$has_summary_section" -gt 0 ]; then
        # 要約済みセクションの後の最初のセッション
        local summary_end=$(grep -n "^## 📦 過去のセッション（要約版）" "$HANDOVER_FILE" | head -1 | cut -d: -f1)
        first_detailed_session_line=$(sed -n "${summary_end},\$p" "$HANDOVER_FILE" | grep -n "^## 💬 セッション" | head -1 | cut -d: -f1)
        first_detailed_session_line=$((summary_end + first_detailed_session_line - 1))
    else
        # 要約セクションがない場合、履歴開始後の最初のセッション
        first_detailed_session_line=$(sed -n "${history_start},\$p" "$HANDOVER_FILE" | grep -n "^## 💬 セッション" | head -1 | cut -d: -f1)
        first_detailed_session_line=$((history_start + first_detailed_session_line - 1))
    fi

    # セッション検出の検証
    if [ -z "$first_detailed_session_line" ] || ! [[ "$first_detailed_session_line" =~ ^[0-9]+$ ]]; then
        log_error "要約対象のセッションが見つかりません（セッション検出失敗）"
        log_error "対処法: handover.txt のセッション履歴を確認してください"
        echo ""  # 空の結果を返してエラー伝播
        return 1
    fi

    # 次のセッション開始位置を見つける（または末尾）
    local next_session_line=$(sed -n "$((first_detailed_session_line + 1)),\$p" "$HANDOVER_FILE" | grep -n "^## 💬 セッション" | head -1 | cut -d: -f1)
    if [ -n "$next_session_line" ]; then
        next_session_line=$((first_detailed_session_line + next_session_line - 1))
    else
        next_session_line=$(wc -l < "$HANDOVER_FILE")
        next_session_line=$((next_session_line + 1))
    fi

    # 結果を返す
    echo "$first_detailed_session_line $next_session_line"
}

# プレビューと承認処理
preview_and_confirm() {
    local session_title="$1"
    local session_content="$2"
    local summary_lines="$3"

    # プレビュー表示
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📋 要約プレビュー"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "【要約されるセッション（${summary_lines}行に圧縮）】"
    echo "$session_title"
    echo ""
    echo "【要約後の内容】"
    echo "$session_content"
    echo "..."
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # ユーザー承認待ち
    echo -n "この要約を実行しますか？ [y/N]: "
    read -r response

    if [[ ! "$response" =~ ^[Yy]$ ]]; then
        return 1  # キャンセル
    fi

    return 0  # 承認
}

# 要約実行処理
apply_summarization() {
    local history_start="$1"
    local has_summary_section="$2"
    local first_detailed_session_line="$3"
    local next_session_line="$4"
    local session_content="$5"

    # 一時ファイル作成
    local TEMP_FILE=$(mktemp "${CLAUDE_DIR}/.handover_summarize.XXXXXX") || {
        log_error "一時ファイルの作成に失敗しました"
        return 1
    }
    log_info "要約ファイルを作成中..."

    # 要約版を作成
    {
        # 1. セッション履歴開始まで（静的部分）
        sed -n "1,$((history_start))p" "$HANDOVER_FILE"

        echo ""
        echo "# 📚 セッション履歴"
        echo ""
        echo "_ここに各セッションの作業記録が追記されます。_"
        echo "_新しいセッション記録を追加するには \`/handover\` を使用してください。_"
        echo ""

        # 2. 要約済みセクション（存在すれば保持、なければ作成）
        if [ "$has_summary_section" -gt 0 ]; then
            # 既存の要約済みセクションを保持
            local summary_start=$(grep -n "^## 📦 過去のセッション（要約版）" "$HANDOVER_FILE" | head -1 | cut -d: -f1)
            sed -n "${summary_start},$((first_detailed_session_line - 1))p" "$HANDOVER_FILE"
        else
            # 新規作成
            echo "## 📦 過去のセッション（要約版）"
            echo ""
            echo "以下は古いセッションの要約です（各セッション約${SUMMARY_LINES}行）。"
            echo "完全版は \`git log\` でコミット履歴を参照してください。"
            echo ""
        fi

        # 3. 今回要約するセッション（10行）
        echo "$session_content"
        echo ""
        echo "---"
        echo ""

        # 4. 残りの詳細セッション
        sed -n "${next_session_line},\$p" "$HANDOVER_FILE"

    } > "$TEMP_FILE"

    # 置き換え
    mv "$TEMP_FILE" "$HANDOVER_FILE"

    # 要約後の整合性検証
    if ! grep -q "<!-- SESSION_HISTORY_START -->" "$HANDOVER_FILE"; then
        log_error "要約後のファイルが破損しています（マーカー消失）"
        log_error "対処法: git で前のバージョンに戻してください"
        return 1
    fi
    log_info "要約後のファイル検証: OK"

    # 結果表示
    local total_lines=$(wc -l < "$HANDOVER_FILE")  # 要約前の行数は呼び出し元で保存
    local new_lines=$(wc -l < "$HANDOVER_FILE")
    echo ""
    log_success "要約完了！"
    log_info "要約後: ${new_lines}行"
    log_info "完全版は git コミット履歴に保存されています"
    echo ""
}

# セッション履歴要約機能（v10.6.5 - 段階的圧縮）
# セッションログ差分解析（v10.6.6 - 行番号システム）
analyze_session_log_incremental() {
    local state_file="$CLAUDE_DIR/handover_state.txt"
    local session_log_dir="$CLAUDE_DIR/full_text_logs"

    # セッションログディレクトリが存在しない場合はスキップ
    if [ ! -d "$session_log_dir" ]; then
        log_info "セッションログディレクトリが見つかりません。スキップします。"
        return 0
    fi

    # 最新のセッションログを特定
    local latest_log=$(ls -t "$session_log_dir"/session_*.txt 2>/dev/null | head -1)
    if [ -z "$latest_log" ]; then
        log_info "セッションログが見つかりません。スキップします。"
        return 0
    fi

    log_info "セッションログ差分解析を開始..."
    log_info "ログファイル: $(basename "$latest_log")"

    # 前回処理済み行番号を読み込み（ファイル名:行番号 形式）
    local last_processed_line=0
    local last_processed_file=""
    if [ -f "$state_file" ]; then
        last_processed_file=$(head -1 "$state_file" | cut -d':' -f1)
        last_processed_line=$(head -1 "$state_file" | cut -d':' -f2)
    fi

    # 現在のログファイル名
    local current_file=$(basename "$latest_log")

    # ファイルが変わった場合（新しいセッション）は0からスタート
    if [ "$last_processed_file" != "$current_file" ]; then
        log_info "新しいセッションログを検出: $current_file"
        last_processed_line=0
    fi

    # 現在の総行数
    local total_lines=$(wc -l < "$latest_log")
    local new_lines=$((total_lines - last_processed_line))

    log_info "前回処理: $last_processed_line 行"
    log_info "現在の総行数: $total_lines 行"
    log_info "新規追加: $new_lines 行"

    # 新しい行がない場合はスキップ
    if [ "$new_lines" -le 0 ]; then
        log_info "新しいログがありません。スキップします。"
        return 0
    fi

    # 差分が大きすぎる場合は警告
    if [ "$new_lines" -gt 50000 ]; then
        log_warning "差分が $new_lines 行と非常に大きいです。"
        log_warning "自動解析は困難なため、手動要約を推奨します。"
        echo ""
        echo "💡 推奨アクション:"
        echo "  1. このセッションを終了"
        echo "  2. handover.txt に手動で要約を追記"
        echo "  3. 次回から1-2時間ごとに /handover 実行"
        echo ""
        # 状態ファイルを更新（次回からは全体を処理しない）
        echo "$current_file:$total_lines" > "$state_file"
        return 0
    fi

    log_info "差分解析を Claude Code に依頼します..."
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📋 Claude Code への依頼"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "以下のコマンドをClaude Codeで実行して、セッション記録を追記してください："
    echo ""
    echo "  tail -n $new_lines \"$latest_log\" > /tmp/session_diff.txt"
    echo ""
    echo "そして、/tmp/session_diff.txt の内容を解析して、"
    echo "handover.txt の「# 📚 セッション履歴」セクションに追記してください。"
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    # 状態ファイルを更新
    echo "$current_file:$total_lines" > "$state_file"
    log_success "状態ファイルを更新しました: $current_file:$total_lines"
    echo ""
}

summarize_old_sessions() {
    # LINE_THRESHOLD と SUMMARY_LINES は環境変数として main から受け取る

    # 行数チェック
    local total_lines=$(wc -l < "$HANDOVER_FILE")
    if [ "$total_lines" -le "$LINE_THRESHOLD" ]; then
        log_info "handover.txt は ${total_lines}行 (閾値: ${LINE_THRESHOLD}行)"
        log_info "要約は不要です"
        return 0
    fi

    log_warning "handover.txt が ${total_lines}行 (閾値: ${LINE_THRESHOLD}行超過)"
    log_info "一番古いセッション1件を${SUMMARY_LINES}行に要約します..."

    # セッション履歴開始位置を検出
    local history_start=$(grep -n "<!-- SESSION_HISTORY_START -->" "$HANDOVER_FILE" | head -1 | cut -d: -f1)
    if [ -z "$history_start" ]; then
        log_error "セッション履歴マーカーが見つかりません"
        log_error "対処法: handover.txt に '<!-- SESSION_HISTORY_START -->' を手動で追加してください"
        log_error "要約をスキップします"
        return 1
    fi

    # 要約済みセクションの存在確認
    local has_summary_section=$(grep -c "^## 📦 過去のセッション（要約版）" "$HANDOVER_FILE")

    log_info "セッション検出を開始..."

    # 関数呼び出し（セッション検出）
    local session_data=$(detect_first_detailed_session "$history_start" "$has_summary_section")
    if [ -z "$session_data" ]; then
        return 1  # エラー（detect_first_detailed_session内でログ出力済み）
    fi
    read first_detailed_session_line next_session_line <<< "$session_data"

    # セッションタイトルを抽出
    local session_title=$(sed -n "${first_detailed_session_line}p" "$HANDOVER_FILE")
    log_info "要約対象: $session_title"

    # セッション内容を抽出（最初のSUMMARY_LINES行）
    local session_content=$(sed -n "${first_detailed_session_line},$((first_detailed_session_line + SUMMARY_LINES))p" "$HANDOVER_FILE")

    # プレビューと承認
    if ! preview_and_confirm "$session_title" "$session_content" "$SUMMARY_LINES"; then
        log_info "要約をキャンセルしました"
        return 0
    fi

    # 要約実行
    apply_summarization "$history_start" "$has_summary_section" \
        "$first_detailed_session_line" "$next_session_line" "$session_content"

    # 結果表示（要約後の行数比較）
    local new_lines=$(wc -l < "$HANDOVER_FILE")
    local reduced=$((total_lines - new_lines))
    log_info "要約前: ${total_lines}行 → 要約後: ${new_lines}行（-${reduced}行）"
}

# メイン処理
main() {
    # デフォルト値
    local LINE_THRESHOLD=1400
    local SUMMARY_LINES=10
    local ENABLE_SUMMARIZE=true

    # 引数パース
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help)
                show_help
                exit 0
                ;;
            -t|--threshold)
                LINE_THRESHOLD="$2"
                shift 2
                ;;
            -s|--summary-lines)
                SUMMARY_LINES="$2"
                shift 2
                ;;
            --no-summarize)
                ENABLE_SUMMARIZE=false
                shift
                ;;
            *)
                log_error "不明なオプション: $1"
                show_help
                exit 1
                ;;
        esac
    done

    # clearコマンドを削除: Claude Codeの会話履歴を保持するため
    echo ""
    echo "╔════════════════════════════════════════════════════╗"
    echo "║           引き継ぎファイル自動生成               ║"
    echo "║            Claude Wrapper v10.6.5                ║"
    echo "╚════════════════════════════════════════════════════╝"
    echo ""

    log_info "引き継ぎファイル生成開始..."
    log_info "プロジェクト: $PROJECT_NAME"
    log_info "出力先: $HANDOVER_FILE"
    echo ""

    # 出力ディレクトリ作成
    mkdir -p "$CLAUDE_DIR"

    # 既存のセッション履歴を保存
    TEMP_SESSIONS=$(mktemp "${CLAUDE_DIR}/.handover_sessions.XXXXXX") || {
        log_error "一時ファイルの作成に失敗しました"
        exit 1
    }
    if [ -f "$HANDOVER_FILE" ]; then
        log_info "既存のセッション履歴を保存中..."
        # "# 📚 セッション履歴" 以降を保存
        if grep -q "# 📚 セッション履歴" "$HANDOVER_FILE"; then
            sed -n '/# 📚 セッション履歴/,$p' "$HANDOVER_FILE" > "$TEMP_SESSIONS"
        fi
    fi

    # 引き継ぎファイル生成（ログメッセージを除外）
    {
        echo "# 🔄 プロジェクト引き継ぎ文書"
        echo ""
        echo "**最終更新日時**: $TIMESTAMP"
        echo "**生成スクリプト**: generate_handover.sh v1.0.0"
        echo ""
        echo "---"
        echo ""

        # 各情報を収集して出力（ログメッセージを抑制）
        collect_project_info 2>/dev/null || true
        collect_git_info 2>/dev/null || true
        collect_environment_info 2>/dev/null || true
        collect_session_info 2>/dev/null || true
        generate_warnings_and_notes 2>/dev/null || true

        echo ""
        echo "---"
        echo ""
        echo "*このドキュメントの静的情報部分は自動生成されました。*"
        echo ""
        echo "**生成コマンド**: \`.claude/generate_handover.sh\`"
        echo "**Claude Code統合**: \`「引き継ぎファイルを .claude/handover.txt に作成してください」\`"
        echo ""
        echo "---"
        echo "<!-- STATIC_SECTION_END -->"
        echo "<!-- SESSION_HISTORY_START -->"

    } > "$HANDOVER_FILE" 2>/dev/null

    # セッション履歴を復元または新規作成
    if [ -f "$TEMP_SESSIONS" ]; then
        log_info "セッション履歴を復元中..."
        echo "" >> "$HANDOVER_FILE"
        cat "$TEMP_SESSIONS" >> "$HANDOVER_FILE"
        rm "$TEMP_SESSIONS"
    else
        # 初回の場合はセッション履歴セクションを追加
        cat << EOF >> "$HANDOVER_FILE"

---

# 📚 セッション履歴

_ここに各セッションの作業記録が追記されます。_
_新しいセッション記録を追加するには `/handover-full` を使用してください。_

EOF
    fi

    # 結果表示
    echo ""
    log_success "引き継ぎファイルを生成しました！"
    echo ""
    echo "📄 ファイル: $HANDOVER_FILE"
    echo "📏 サイズ: $(ls -lh "$HANDOVER_FILE" | awk '{print $5}')"
    echo "📅 生成時刻: $TIMESTAMP"
    echo ""

    # ファイル内容のサマリー
    local total_lines=$(wc -l < "$HANDOVER_FILE")
    log_info "内容サマリー: $total_lines 行"

    # プレビューの表示
    echo ""
    echo "📋 プレビュー（先頭20行）:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    head -20 "$HANDOVER_FILE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""

    log_info "完了！引き継ぎファイルの全体は以下で確認できます:"
    echo "  cat $HANDOVER_FILE"
    echo "  または"
    echo "  less $HANDOVER_FILE"
    echo ""

    # Claude Code で確認する方法も案内
    echo "💡 Claude Code での確認方法:"
    echo "  「引き継ぎファイルの内容を表示してください」"
    echo ""

    # gitコミット（要約前のバックアップ - v10.6.5）
    if [ -d ".git" ]; then
        log_info "handover.txtをgitコミット中..."
        git add "$HANDOVER_FILE" 2>/dev/null
        if git diff --cached --quiet "$HANDOVER_FILE" 2>/dev/null; then
            log_info "gitコミットをスキップ（変更なし）"
        else
            git commit -m "chore: update handover.txt ($total_lines lines)" 2>/dev/null
            if [ $? -eq 0 ]; then
                log_success "gitコミット完了（静的情報更新 + セッション履歴復元）"
            else
                log_warning "gitコミット失敗"
            fi
        fi
    else
        log_warning "gitリポジトリではありません。gitコミットをスキップします。"
    fi
    echo ""

    # セッションログ差分解析（v10.6.6 - 行番号システム）
    analyze_session_log_incremental

    # セッション履歴要約チェック（v10.6.5 - 段階的圧縮）
    if [ "$ENABLE_SUMMARIZE" = true ]; then
        export LINE_THRESHOLD SUMMARY_LINES  # サブ関数で使用
        summarize_old_sessions
    fi
}

# スクリプト実行
main "$@"