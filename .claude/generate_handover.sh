#!/bin/bash
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

            cat << EOF
## 📝 最新セッションログ
- **ファイル**: \`$log_name\`
- **サイズ**: $log_size
- **最終更新**: $log_date

### セッション概要（末尾50行）
\`\`\`
EOF
            tail -50 "$latest_log" 2>/dev/null | head -30
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

# メイン処理
main() {
    # clearコマンドを削除: Claude Codeの会話履歴を保持するため
    echo ""
    echo "╔════════════════════════════════════════════════════╗"
    echo "║           引き継ぎファイル自動生成               ║"
    echo "║            Claude Wrapper v10.2                  ║"
    echo "╚════════════════════════════════════════════════════╝"
    echo ""

    log_info "引き継ぎファイル生成開始..."
    log_info "プロジェクト: $PROJECT_NAME"
    log_info "出力先: $HANDOVER_FILE"
    echo ""

    # 出力ディレクトリ作成
    mkdir -p "$CLAUDE_DIR"

    # 既存のセッション履歴を保存
    TEMP_SESSIONS="$CLAUDE_DIR/.handover_sessions.tmp"
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
        collect_project_info 2>/dev/null
        collect_git_info 2>/dev/null
        collect_environment_info 2>/dev/null
        collect_session_info 2>/dev/null
        generate_warnings_and_notes 2>/dev/null

        echo ""
        echo "---"
        echo ""
        echo "*このドキュメントの静的情報部分は自動生成されました。*"
        echo ""
        echo "**生成コマンド**: \`.claude/generate_handover.sh\`"
        echo "**Claude Code統合**: \`「引き継ぎファイルを .claude/handover.txt に作成してください」\`"

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
}

# スクリプト実行
main "$@"