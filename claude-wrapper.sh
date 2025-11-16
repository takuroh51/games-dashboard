#!/bin/bash
# claude-wrapper.sh - 会話型ゲーム開発エンジン
# Version: 10.6.4 - Practical Distributed Agent System + AI Personality Continuity + Git-Safe Handover Summarization
# Purpose: 分散並列エージェント駆動 + AI人格継承 + 実用最優先 + Git完全版保存 + handover自動要約 + 具体的プロジェクト開発加速

# 設定
SCRIPT_VERSION="10.6.4"
PROJECT_DIR="$(pwd)"
PROJECT_NAME=$(basename "$PROJECT_DIR")
CLAUDE_DIR=".claude"
LOG_DIR="$CLAUDE_DIR/logs"
FULL_TEXT_DIR="$CLAUDE_DIR/full_text_logs"
HANDOVER_FILE="$CLAUDE_DIR/handover.txt"
SESSION_ID="$(date +%Y%m%d_%H%M)"


# v10.0 新規
ENGINES_DIR="$CLAUDE_DIR/engines"
COMMANDS_DIR="$CLAUDE_DIR/commands"

# ディレクトリ作成と初期ファイル生成
initialize() {
    mkdir -p "$LOG_DIR" "$FULL_TEXT_DIR"
    # v10.0 新規ディレクトリ作成
    mkdir -p "$ENGINES_DIR" "$COMMANDS_DIR"

    # v10.2 自動生成機能
    create_engine_profiles
    create_handover_template
    create_handover_command
}

# CLAUDE.md テンプレート確認（簡素版）
create_claude_md() {
    if [ ! -f "CLAUDE.md" ]; then
        echo "⚠️ CLAUDE.mdが見つかりません"
        echo "   最新版を手動で配置するか、過去バージョンから復元してください"
    else
        echo "✅ CLAUDE.mdを確認しました"
    fi
}

# INPUTファイル作成（v7.0互換）
create_input_files() {
    if [ ! -f "ERROR_INPUT.txt" ]; then
        echo "# エラーをここに貼り付けて「エラー出た」" > ERROR_INPUT.txt
    fi

    if [ ! -f "SPEC_INPUT.txt" ]; then
        echo "# 仕様をここに記載して「仕様を固めよう」" > SPEC_INPUT.txt
    fi

    if [ ! -f "TASK_LIST.md" ]; then
        cat > "TASK_LIST.md" << 'EOF'
# タスクリスト

## 分析結果
（分析モードで作成されたタスクを記載）

### 実装タスク
- [ ] タスク1
- [ ] タスク2
- [ ] タスク3
EOF
    fi
}

# エンジンプロファイル自動生成（v10.2 新規）
create_engine_profiles() {
    # claude-sonnet.profile
    if [ ! -f "$ENGINES_DIR/claude-sonnet.profile" ]; then
        echo "claude-sonnet-4-20250514" > "$ENGINES_DIR/claude-sonnet.profile"
        echo "✅ 生成: claude-sonnet.profile"
    fi

    # claude-opus.profile
    if [ ! -f "$ENGINES_DIR/claude-opus.profile" ]; then
        echo "claude-opus-4-20250514" > "$ENGINES_DIR/claude-opus.profile"
        echo "✅ 生成: claude-opus.profile"
    fi

    # claude-haiku.profile
    if [ ! -f "$ENGINES_DIR/claude-haiku.profile" ]; then
        echo "claude-haiku-4-20250514" > "$ENGINES_DIR/claude-haiku.profile"
        echo "✅ 生成: claude-haiku.profile"
    fi
}

# 引き継ぎファイルのテンプレート作成（v10.2 新規）
create_handover_template() {
    if [ ! -f "$HANDOVER_FILE" ]; then
        cat > "$HANDOVER_FILE" << 'EOF'
# 引き継ぎメモ

## 前回のセッション概要
（ここに前回の作業内容を記載）

## 次回の作業予定
- [ ] タスク1
- [ ] タスク2

## 注意事項・制約
（特記事項があればここに）
EOF
        echo "✅ 生成: handover.txt テンプレート"
    fi
}

# handover slash command作成（v10.2 新規）
create_handover_command() {
    # 軽量版: handover.md（日常的なセッション引き継ぎ用）
    if [ ! -f "$COMMANDS_DIR/handover.md" ]; then
        cat > "$COMMANDS_DIR/handover.md" << 'EOF'
# セッション引き継ぎ（軽量版）

このセッションの作業内容と次回予定を `.claude/handover.txt` に簡潔に記録してください。

## 実行指示（重要）

**このコマンドは軽量・高速実行版です:**
- 思考プロセス（<thinking>タグ）を表示しない
- ファイル読み込みは最小限（TASK_LIST.md のみ）
- 詳細な分析は不要、結果だけを簡潔に記録
- 30秒以内で完了すること

## 記録内容

1. **本セッションの実施内容**
   - 完了したタスク
   - 変更したファイル（主要なもののみ）

2. **発見事項・注意点**
   - 気づいたこと
   - 重要な決定事項

3. **次回セッション予定**
   - 残タスク
   - 次にやること

4. **即座に対応すべき課題**
   - あれば記載、なければスキップ

## 出力形式

- **サイズ**: 10〜30行程度の簡潔な記録
- **形式**: Markdown形式
EOF
        echo "✅ 生成: .claude/commands/handover.md"
    fi
}


# 動作モードプロンプト（簡素版）
show_mode_prompt() {
    cat << 'EOF'
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎮 動作モード - 分析と実装の分離
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

## 🔍 分析モード
- 実装環境とコード構造の理解
- エラー原因の特定
- 必要作業のリストアップ

## 📝 仕様モード
- 要件の明確化と深掘り
- 実装可能レベルまで具体化
- 拡張性の高い構造設計

## 🔨 実装モード
- 指定タスクのみ実行
- 余計な改善は一切しない
- 変更内容の報告

## ✅ 検証モード
- 仕様と実装の差分照合
- 達成度評価

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
EOF
}


# メイン処理
main() {
    clear
    echo "╔════════════════════════════════════════════════════╗"
    echo "║    会話型ゲーム開発エンジン v10.6.4              ║"
    echo "║    - 分散並列エージェント + AI人格継承            ║"
    echo "╠════════════════════════════════════════════════════╣"
    echo "║ Project: $PROJECT_NAME"
    echo "║ Session: $SESSION_ID"
    echo "║ Feature: 分散並列エージェント・実用最優先"
    echo "╚════════════════════════════════════════════════════╝"
    echo ""
    
    # 初期化
    initialize
    create_claude_md
    create_input_files

    # 認証方式選択（v10.3: 新規追加）
    select_auth_mode

    # エンジン選択（v10.3: CLI版の場合のみ実行）
    if [ "$USE_API_KEY" = true ]; then
        select_engine
    fi

    # CLAUDE.md読み込み
    echo "📋 開発憲法を読み込み中..."
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    cat "CLAUDE.md"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # 引き継ぎファイル（あれば）
    if [ -f "$HANDOVER_FILE" ]; then
        echo "📋 前回の引き継ぎ"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        cat "$HANDOVER_FILE"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
    fi
    
    
    # 動作モード表示
    show_mode_prompt
    
    # ログファイル設定（簡素版）
    SESSION_FULL_TEXT="$FULL_TEXT_DIR/session_${SESSION_ID}_full.txt"

    # 全文記録の初期化
    cat > "$SESSION_FULL_TEXT" << EOF
# Full Text Log - Session: $SESSION_ID
# Started: $(date '+%Y-%m-%d %H:%M:%S')
# Project: $PROJECT_NAME
EOF
    
    # Claude起動
    echo "🚀 Claude Code を起動します..."
    echo "💡 起動後に /load-context でコンテキスト読み込み"
    echo "📝 全文記録: $SESSION_FULL_TEXT"
    
    # モデル確認（環境変数またはconfigから）
    if [ -n "$CLAUDE_MODEL" ]; then
        echo "🤖 モデル: $CLAUDE_MODEL"
        export ANTHROPIC_MODEL="$CLAUDE_MODEL"
    elif [ -n "$ANTHROPIC_MODEL" ]; then
        echo "🤖 モデル: $ANTHROPIC_MODEL"
    elif [ -f "$HOME/.config/claude/config.json" ]; then
        MODEL=$(grep -o '"model"[[:space:]]*:[[:space:]]*"[^"]*"' "$HOME/.config/claude/config.json" | cut -d'"' -f4)
        [ -n "$MODEL" ] && echo "🤖 モデル: $MODEL"
    fi
    
    echo ""

    # Claude起動
    if ! command -v claude > /dev/null 2>&1; then
        echo "❌ Error: 'claude' command not found"
        exit 1
    fi

    # Claude起動（ログファイルに記録）
    if [[ "$OSTYPE" == "darwin"* ]]; then
        script -F "$SESSION_FULL_TEXT" claude
    else
        script -f "$SESSION_FULL_TEXT" -c "claude"
    fi

    
    # 終了処理
    echo ""
    echo "✅ セッション終了"
    echo ""
    echo "💡 引き継ぎ作成:"
    echo "   方法1: セッション中に「引き継ぎ文書を作成」"
    echo "   方法2: echo '引き継ぎ内容' > $HANDOVER_FILE"
    echo ""
}


# ============================================================
# v10.3 新機能: 認証方式選択機能
# ============================================================

# 認証方式を選択
select_auth_mode() {
    echo "╔════════════════════════════════════════════╗"
    echo "║      認証方式を選択してください            ║"
    echo "╚════════════════════════════════════════════╝"
    echo "1) サブスクリプション版（デフォルト）"
    echo "2) CLI版（API Key使用・モデル選択可能）"
    echo ""

    read -p "番号を入力 (Enter=1): " choice
    echo ""

    case "$choice" in
        2)
            if [ -z "$ANTHROPIC_API_KEY" ]; then
                echo "⚠️ ANTHROPIC_API_KEY が設定されていません"
                echo "   Claude起動時にエラーになる可能性があります"
                echo ""
                echo "設定方法: export ANTHROPIC_API_KEY='your-key'"
                echo ""
            fi
            echo "✅ CLI版（API Key）を使用します"
            echo "   → モデル選択画面に進みます"
            echo ""
            USE_API_KEY=true
            ;;
        *)
            echo "✅ サブスクリプション版を使用します"
            echo ""
            USE_API_KEY=false
            ;;
    esac
}


# ============================================================
# v10.0 新機能: エンジン選択機能
# ============================================================

# 起動時に使用エンジンを選択
select_engine() {
    echo "╔════════════════════════════════════════════╗"
    echo "║      ClaudeWrapper v10.0 Engine Selector   ║"
    echo "╠════════════════════════════════════════════╣"
    echo "║ 利用可能なエンジンを選択してください:         ║"
    echo "╚════════════════════════════════════════════╝"

    engines=($(ls "$ENGINES_DIR"/*.profile 2>/dev/null))
    if [ ${#engines[@]} -eq 0 ]; then
        echo "⚠️ エンジンプロファイルが見つかりません (.claude/engines)"
        echo "   例: claude-sonnet.profile, claude-opus.profile"
        return
    fi

    i=1
    for e in "${engines[@]}"; do
        echo "$i) $(basename "$e" .profile)"
        ((i++))
    done
    echo ""

    read -p "番号を入力 (Enter=スキップ): " idx

    if [ -z "$idx" ]; then
        echo "⏭️ モデル選択をスキップしました（デフォルトを使用）"
        return
    fi

    if [[ "$idx" =~ ^[0-9]+$ ]] && [ "$idx" -ge 1 ] && [ "$idx" -le "${#engines[@]}" ]; then
        selected="${engines[$((idx-1))]}"
        if [ -f "$selected" ]; then
            # プロファイルの1行目を読み取り
            CLAUDE_MODEL=$(head -1 "$selected" | tr -d '[:space:]')
            export CLAUDE_MODEL
            echo "✅ 使用モデル: $CLAUDE_MODEL"
        else
            echo "❌ プロファイルファイルが読めません: $selected"
        fi
    else
        echo "⚠️ 無効な選択。デフォルトモデルを使用します。"
    fi
    echo ""
}



# ============================================================
# メイン実行部: v10.2
# ============================================================

# 実行（v10.2: select_engineはmain内で実行）
main "$@"