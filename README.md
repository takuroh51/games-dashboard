# SKOOTA GAMES Intelligence Dashboard

Firebaseに保存されたゲームデータを自動で集計し、可視化するダッシュボード。

## 🎯 機能

### KPI表示
- 総ユーザー数
- 総起動回数
- 総プレイ回数
- 平均スコア

### グラフ
- 日別アクティブユーザー数（折れ線グラフ）
- キャラクター別プレイ回数（円グラフ）
- 難易度別プレイ回数（棒グラフ）
- クリアランク分布（棒グラフ）
- 言語分布（円グラフ）

### その他
- カットシーンスキップ率
- 最近のプレイ記録（テーブル）

## 🏗️ アーキテクチャ

```
GitHub Actions（1時間に1回実行）
  ↓
1. Firebaseからデータ取得（Python）
2. データ集計してJSON生成
3. JSONをGitにコミット
  ↓
GitHub Pages
  ↓
Next.jsダッシュボードで可視化
```

## 📋 セットアップ手順

### 1. リポジトリのクローン

```bash
git clone https://github.com/YOUR_USERNAME/games-dashboard.git
cd games-dashboard
```

### 2. Firebase設定

#### サービスアカウントキーの取得

1. [Firebase Console](https://console.firebase.google.com/) にアクセス
2. 対象プロジェクト（skoota-momocrash）を選択
3. **⚙️ → プロジェクトの設定 → サービスアカウント**
4. **新しい秘密鍵の生成** をクリック
5. ダウンロードされたJSONファイルの内容をコピー

### 3. GitHub Secretsの設定

1. GitHubリポジトリページで **Settings → Secrets and variables → Actions**
2. 以下の2つのSecretを追加：

#### `FIREBASE_SERVICE_ACCOUNT`
- 上記でコピーしたJSONファイルの**全内容**を貼り付け

#### `FIREBASE_DATABASE_URL`
- 値: `https://skoota-momocrash-default-rtdb.firebaseio.com`

### 4. GitHub Pagesの有効化

1. **Settings → Pages**
2. **Source**: `GitHub Actions` を選択
3. 保存

### 5. 手動で最初のデータ収集を実行

1. **Actions** タブに移動
2. **Update Dashboard Data** ワークフローを選択
3. **Run workflow** をクリック

### 6. デプロイの確認

1. **Actions** タブで **Deploy to GitHub Pages** が自動実行されるのを確認
2. 完了後、`https://YOUR_USERNAME.github.io/games-dashboard/` でアクセス

## 🛠️ ローカル開発

### Python スクリプトのテスト

```bash
# 仮想環境作成
python3 -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 依存関係インストール
pip install -r scripts/requirements.txt

# 環境変数設定
export FIREBASE_SERVICE_ACCOUNT='{ ... }'
export FIREBASE_DATABASE_URL='https://skoota-momocrash-default-rtdb.firebaseio.com'

# データ収集
python scripts/firebase_collector.py

# データ集計
python scripts/data_aggregator.py
```

### Next.js ダッシュボードの開発

```bash
cd frontend

# 依存関係インストール
npm install

# 開発サーバー起動
npm run dev
```

ブラウザで http://localhost:3000 にアクセス

### ビルド

```bash
cd frontend
npm run build
```

## 📁 プロジェクト構造

```
games-dashboard/
├─ .github/
│   └─ workflows/
│       ├─ update-data.yml      # データ収集（1時間に1回）
│       └─ deploy-pages.yml     # GitHub Pagesデプロイ
├─ scripts/
│   ├─ firebase_collector.py    # Firebaseからデータ取得
│   ├─ data_aggregator.py       # データ集計
│   └─ requirements.txt         # Python依存関係
├─ public/
│   └─ data/
│       └─ dashboard.json       # 集計結果JSON（自動生成）
├─ frontend/
│   ├─ src/
│   │   ├─ pages/
│   │   │   └─ index.tsx        # メインページ
│   │   ├─ components/
│   │   │   ├─ KPICards.tsx
│   │   │   ├─ ChartsPanel.tsx
│   │   │   └─ RecentPlaysTable.tsx
│   │   └─ types/
│   │       └─ dashboard.ts
│   ├─ package.json
│   └─ next.config.js
├─ .env.example
└─ README.md
```

## 🔄 更新頻度

- **データ収集**: 1時間に1回（GitHub Actions cron）
- **ダッシュボード更新**: データコミット後、自動デプロイ

## 🚨 トラブルシューティング

### データが表示されない

1. `public/data/dashboard.json` が存在するか確認
2. GitHub Actions の実行ログを確認
3. GitHub Secrets が正しく設定されているか確認

### ビルドエラー

```bash
cd frontend
rm -rf node_modules package-lock.json
npm install
npm run build
```

### Firebase接続エラー

- サービスアカウントキーのJSON形式が正しいか確認
- Database URLが正しいか確認
- Firebase側でRealtime Databaseのルールを確認

## 📝 カスタマイズ

### basePath の変更

リポジトリ名を変更した場合、`frontend/next.config.js` の `basePath` を更新：

```js
basePath: process.env.NODE_ENV === 'production' ? '/YOUR-REPO-NAME' : '',
```

### データ収集頻度の変更

`.github/workflows/update-data.yml` の cron を編集：

```yaml
schedule:
  - cron: '0 * * * *'  # 1時間に1回
  # - cron: '*/30 * * * *'  # 30分に1回
  # - cron: '0 */6 * * *'  # 6時間に1回
```

## 📄 ライセンス

MIT

## 👤 作成者

SKOOTA GAMES
