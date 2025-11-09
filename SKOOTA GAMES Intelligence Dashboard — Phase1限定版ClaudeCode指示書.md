SKOOTA GAMES Intelligence Dashboard — Phase 1 限定版 ClaudeCode 指示書 v1.0

目的：
SKOOTA GAMES の販売・SNS・広報活動を統合管理し、
Steam／STOVE の売上推移・SNS反応・カレンダー上の活動を一元可視化する。

🧩 1. 構成概要（Phase 1）
Steam / STOVE API
  ↓
[ Collector Scripts (Python) ]
  ↓
PostgreSQL Database
  ↓
Flask Backend API
  ↓
Next.js Frontend Dashboard
  ↓
(表示: 売上・SNS・カレンダー)

🗄️ 2. データベース設計（限定版）
テーブル名	主なカラム	説明
games	game_id (PK), title, platform, release_date	対象ゲームタイトル情報
sales	id, game_id (FK), date, platform, region, units_sold, revenue, wishlist	Steam/STOVEの販売・Wishリスト情報
sns_posts	id, platform, date, account_name, post_id, text, likes, shares, comments, url	X, FB, Instagram, YouTube投稿
calendar_events	id, date, event_type, title, related_game, url	発売・セール・PR・配信などのイベント情報
config_api_keys	service_name, api_key, last_updated	各APIキーの管理
⚙️ 3. バックエンド仕様（Flask + PostgreSQL）
構成

/app/main.py — Flaskルーティング

/app/models.py — SQLAlchemyモデル定義

/app/api/ — RESTエンドポイント群

/app/tasks/ — データ収集スクリプト

APIエンドポイント例
GET  /api/sales?game_id=1&month=2025-10
GET  /api/sns?platform=x&from=2025-10-01&to=2025-10-31
GET  /api/calendar?from=2025-10-01&to=2025-10-31
POST /api/update/steam
POST /api/update/stove
POST /api/update/sns

📡 4. データ収集スクリプト構成（Python）
/tasks/steam_collector.py

Steamworks Web APIから以下を取得：

GetNumberOfCurrentPlayers

GetAppDetails

Wishリスト・レビュー数（スクレイピング fallback）

/tasks/stove_collector.py

STOVEパートナーダッシュボードAPIまたはHTMLパースで販売データ取得

/tasks/sns_collector.py

X API (v2): post text, like数, RT数

FB / Instagram Graph API: 投稿＋いいね＋コメント

YouTube Data API: チャンネル動画の再生数・コメント

/tasks/calendar_updater.py

各データ更新時に「セール開始／PR／リリース」を自動登録

手動登録UI用のエンドポイント /api/calendar/add も設置

🖥️ 5. フロントエンド仕様（Next.js + Tailwind + Chart.js）
ページ構成
ページ	機能
/dashboard	売上サマリー（Steam＋STOVE）＋SNSハイライト
/calendar	カレンダービュー（FullCalendar.js使用）
/reports	CSV / PDF 出力ボタン（バックエンド連携）
コンポーネント

SalesChart：売上＋Wish推移（折れ線グラフ）

SNSFeed：プラットフォーム別投稿リスト（タブ切替）

CalendarView：発売日・セール・PR日・SNS投稿を色分け表示

KPIHeader：期間中の売上合計・投稿数・エンゲージメント指標

🔒 6. 認証・セキュリティ
要素	方法
管理ログイン	Basic Auth または JWT
APIキー	.envで管理
CORS設定	自社ドメイン（例：dashboard.skoota.jp）のみ許可
🧭 7. デプロイ環境（推奨）
層	推奨環境	備考
フロント	Vercel または VPS (Nginx)	Next.jsビルド自動化可
バック	Xserver VPS or Render	Flask + PostgreSQL
DB	PostgreSQL 15+	永続ストレージ
自動実行	cron or GitHub Actions	日次データ更新
📈 8. レポート出力機能（限定版）

/api/report/monthly
→ Steam/STOVE 売上＋SNS投稿＋イベントを月単位で集計しPDF出力

PDF内容：

売上総額・Wish推移

SNS活動サマリー（投稿数、総エンゲージメント）

月間イベント一覧（リリース、セール、PR）

🧩 9. 実装ステップ（ClaudeCodeタスク順）

Flask + SQLAlchemy 環境を生成し、DB初期化

/models.py に上記4テーブル定義

/api/sales /api/sns /api/calendar をRESTで実装

steam_collector.py stove_collector.py sns_collector.py を作成

/dashboard ページ（Next.js）にChart.js＋FullCalendar組込み

PDFレポート出力（reportlab or jsPDF）追加

テストデータを投入し、UI動作確認

.envにAPIキーを登録（Steam, STOVE, X, FB, IG, YouTube）

🔮 10. 将来拡張（Phase 2 以降）

Twitch / Bilibili API追加

ニュース・プレスリリース自動収集

Unityログ同期（セッション・クラッシュ率など）

Switch, Bluesky, Epic, itch.ioの売上対応

SKOOTA PORTALアカウント連携（SSO）

🧠 Claude向け補足指示

生成時は "use_postgresql": true

Next.jsには "use_tailwind": true

FullCalendar.jsを導入

Chart.jsで売上＋Wishの折れ線グラフ生成

.env.example を出力に含める（APIキー設定用）

コード出力は app/（Flask） と frontend/（Next.js） で分離構成

Claudeは各collectorスクリプトを別ファイルで生成すること

これで、Claudeに：

上記「SKOOTA GAMES Intelligence Dashboard — Phase 1 限定版 ClaudeCode 指示書 v1.0」に基づいて実装コードを生成して

と入力すれば、
バックエンド（Flask＋PostgreSQL）＋フロント（Next.js＋Chart.js＋FullCalendar）＋APIスケルトン が完成します。