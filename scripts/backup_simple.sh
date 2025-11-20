#!/bin/bash
# シンプルバックアップスクリプト（認証不要）
# GitHub Pagesから公開データをダウンロード

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$PROJECT_DIR/backups"

# タイムスタンプ
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔄 Simple Backup (from GitHub Pages)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# バックアップディレクトリ作成
mkdir -p "$BACKUP_DIR"

# dashboard.json（集計済みデータ）
echo "📥 Downloading dashboard.json..."
curl -s https://takuroh51.github.io/games-dashboard/data/dashboard.json > "$BACKUP_DIR/dashboard_${TIMESTAMP}.json"

# raw_data.json（生データ）
echo "📥 Downloading raw_data.json..."
curl -s https://takuroh51.github.io/games-dashboard/data/raw_data.json > "$BACKUP_DIR/raw_data_${TIMESTAMP}.json"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Backup completed successfully"
echo "📁 Saved to: backups/"
echo "   - dashboard_${TIMESTAMP}.json"
echo "   - raw_data_${TIMESTAMP}.json"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
