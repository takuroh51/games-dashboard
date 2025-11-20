#!/bin/bash
# Firebase生データバックアップスクリプト

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
BACKUP_DIR="$PROJECT_DIR/backups"

# タイムスタンプ
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🔄 Firebase Data Backup"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# 認証情報の確認
if [ ! -f "$SCRIPT_DIR/firebase-credentials.json" ]; then
    echo "❌ Error: firebase-credentials.json not found"
    echo ""
    echo "📝 Setup Instructions:"
    echo "1. Firebase Console → Project Settings → Service Accounts"
    echo "2. Generate new private key"
    echo "3. Save as: scripts/firebase-credentials.json"
    echo ""
    exit 1
fi

# Python仮想環境の確認
if [ ! -d "$PROJECT_DIR/venv" ]; then
    echo "⚠️  Creating Python virtual environment..."
    python3 -m venv "$PROJECT_DIR/venv"
fi

# 依存関係のインストール
source "$PROJECT_DIR/venv/bin/activate"
pip install -q -r "$SCRIPT_DIR/requirements.txt"

# 環境変数の設定
export FIREBASE_SERVICE_ACCOUNT=$(cat "$SCRIPT_DIR/firebase-credentials.json")
export FIREBASE_DATABASE_URL="https://soundbeats-default-rtdb.firebaseio.com"

# データ取得
echo "📥 Fetching data from Firebase..."
python3 "$SCRIPT_DIR/firebase_collector.py"

# バックアップコピー
echo "💾 Creating backup..."
cp "$PROJECT_DIR/public/data/raw_data.json" "$BACKUP_DIR/raw_data_${TIMESTAMP}.json"

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Backup completed successfully"
echo "📁 Saved to: backups/raw_data_${TIMESTAMP}.json"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
