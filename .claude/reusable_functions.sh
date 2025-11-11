#!/bin/bash
# 再利用可能な機能要素（旧naviから抽出）
# Version: extracted from v10.1 navi system

# ============================================================
# ログ管理機能
# ============================================================

# セッションログをドラフトとして保存
summarize_log() {
    local session_file="$1"  # セッションファイルのパスを引数で受け取る
    local handover_file="$2" # 引き継ぎファイルのパスを引数で受け取る

    if [ -f "$session_file" ]; then
        echo "📝 セッションログの最後800行を抽出中..."
        tail -n 800 "$session_file" > "${handover_file}.draft"
        echo "✅ 引き継ぎドラフトを作成: ${handover_file}.draft"
        echo "💡 必要に応じて編集して $handover_file に改名してください"
    else
        echo "⚠️ セッションログが見つかりません: $session_file"
    fi
}

# ============================================================
# 設定管理機能
# ============================================================

# CLAUDE.md（憲法）を再読み込み
reload_constitution() {
    local claude_file="$1"  # CLAUDE.mdのパス

    if [ -f "$claude_file" ]; then
        echo "📜 CLAUDE憲法を再読み込み中..."
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        cat "$claude_file"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    else
        echo "❌ CLAUDE.mdが見つかりません: $claude_file"
    fi
}

# ============================================================
# エンジン選択機能
# ============================================================

# 起動時に使用エンジンを選択
select_engine() {
    local engines_dir="$1"  # エンジンディレクトリのパス

    echo "╔════════════════════════════════════════════╗"
    echo "║      ClaudeWrapper Engine Selector         ║"
    echo "╠════════════════════════════════════════════╣"
    echo "║ 利用可能なエンジンを選択してください:         ║"
    echo "╚════════════════════════════════════════════╝"

    engines=($(ls "$engines_dir"/*.profile 2>/dev/null))
    if [ ${#engines[@]} -eq 0 ]; then
        echo "⚠️ エンジンプロファイルが見つかりません ($engines_dir)"
        echo "   例: claude-sonnet.profile, claude-opus.profile"
        return 1
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
        return 0
    fi

    if [[ "$idx" =~ ^[0-9]+$ ]] && [ "$idx" -ge 1 ] && [ "$idx" -le "${#engines[@]}" ]; then
        selected="${engines[$((idx-1))]}"
        if [ -f "$selected" ]; then
            # プロファイルの1行目を読み取り
            CLAUDE_MODEL=$(head -1 "$selected" | tr -d '[:space:]')
            export CLAUDE_MODEL
            echo "✅ 使用モデル: $CLAUDE_MODEL"
            return 0
        else
            echo "❌ プロファイルファイルが読めません: $selected"
            return 1
        fi
    else
        echo "⚠️ 無効な選択。デフォルトモデルを使用します。"
        return 1
    fi
}

# ============================================================
# 引き継ぎファイル生成機能
# ============================================================

# 包括的な引き継ぎファイル自動生成
generate_comprehensive_handover() {
    local claude_dir="${1:-.claude}"  # Claude設定ディレクトリ
    local handover_file="$claude_dir/handover.txt"
    local script_path="$claude_dir/generate_handover.sh"

    echo "🔄 包括的引き継ぎファイルを生成中..."

    if [ -x "$script_path" ]; then
        # 専用スクリプトを実行
        echo "📋 専用スクリプトで生成中..."
        "$script_path"
        return $?
    else
        # フォールバック: 基本的な情報のみ生成
        echo "⚠️ 専用スクリプトが見つからないため、基本情報のみ生成します"
        generate_basic_handover "$handover_file"
        return $?
    fi
}

# 基本的な引き継ぎファイル生成（フォールバック）
generate_basic_handover() {
    local handover_file="$1"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    mkdir -p "$(dirname "$handover_file")"

    cat > "$handover_file" << EOF
# 🔄 プロジェクト引き継ぎ文書（基本版）

**作成日時**: $timestamp
**プロジェクト**: $(basename "$(pwd)")
**作業ディレクトリ**: $(pwd)

## 📋 重要ファイル
EOF

    # 重要ファイルをリスト
    ls -la | grep -E "\.(md|txt|sh|json|yml|yaml)$" | while read -r line; do
        echo "- $line"
    done >> "$handover_file"

    cat >> "$handover_file" << EOF

## ⚠️ 注意事項
- このファイルは基本版です
- 詳細な引き継ぎには \`.claude/generate_handover.sh\` を使用してください
- プロジェクト固有の情報は手動で追加が必要です

## 📞 問い合わせ先
- 詳細な状況は最新のセッションログを参照
- 実験状況は \`.claude/experiments/\` ディレクトリを確認

---
*自動生成: $(date)*
EOF

    echo "✅ 基本的な引き継ぎファイルを生成しました: $handover_file"
}

# Claude Code内で実行する引き継ぎ生成関数
execute_handover_generation() {
    echo "🚀 引き継ぎファイル生成を実行します..."
    echo ""

    local claude_dir=".claude"
    local script_path="$claude_dir/generate_handover.sh"

    # スクリプトの存在確認
    if [ -x "$script_path" ]; then
        echo "📋 専用スクリプトを実行中..."
        "$script_path"
        local exit_code=$?

        if [ $exit_code -eq 0 ]; then
            echo ""
            echo "✅ 引き継ぎファイル生成完了！"
            echo "📄 ファイル: $claude_dir/handover.txt"

            # ファイルサイズと行数を表示
            if [ -f "$claude_dir/handover.txt" ]; then
                local size=$(ls -lh "$claude_dir/handover.txt" | awk '{print $5}')
                local lines=$(wc -l < "$claude_dir/handover.txt")
                echo "📏 サイズ: $size ($lines 行)"
            fi

            return 0
        else
            echo "❌ 引き継ぎファイル生成に失敗しました"
            return 1
        fi
    else
        echo "⚠️ 専用スクリプトが見つかりません: $script_path"
        echo "📋 基本的な引き継ぎファイルを生成します..."
        generate_basic_handover "$claude_dir/handover.txt"
        return 0
    fi
}

# ============================================================
# 使用例
# ============================================================
# source .claude/reusable_functions.sh
#
# # ログ要約
# summarize_log "$SESSION_FULL_TEXT" "$HANDOVER_FILE"
#
# # 憲法再読み込み
# reload_constitution "CLAUDE.md"
#
# # エンジン選択
# select_engine ".claude/engines"
#
# # 包括的引き継ぎファイル生成
# generate_comprehensive_handover ".claude"
#
# # Claude Code内での引き継ぎ生成実行
# execute_handover_generation