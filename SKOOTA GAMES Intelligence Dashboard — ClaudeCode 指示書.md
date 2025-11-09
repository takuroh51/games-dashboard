🎛️ SKOOTA GAMES Intelligence Dashboard — ClaudeCode 指示書 v0.1

目的：
Steam・STOVE・SNS・動画・プレス・ニュース・自社サイト・Unityデータなどを統合し、
活動ログと売上を時系列で可視化。月次レポートを自動生成する。

🧩 1. 全体アーキテクチャ構成図
                    ┌──────────────┐
                    │ 外部API群     │
                    │──────────────│
                    │ Steamworks    │
                    │ STOVE         │
                    │ Twitch        │
                    │ YouTube       │
                    │ Bilibili      │
                    │ X / FB / IG   │
                    │ Google News   │
                    │ 自社WEB RSS   │
                    │ Unity Telemetry│
                    └──────┬─────────┘
                           │
                           ▼
              ┌────────────────────────┐
              │ Data Collector (Python) │
              │ - 各APIスクリプト       │
              │ - CRON定期実行         │
              └────────┬──────────────┘
                           │
                           ▼
          ┌──────────────────────────────┐
          │ PostgreSQL (VPS or CloudSQL) │
          │ - tables: sales, sns, video, │
          │   news, calendar, unity_log  │
          │ - 拡張: switch, bluesky等   │
          └────────┬────────────────────┘
                           │
                           ▼
             ┌────────────────────────┐
             │ Dashboard Backend (Flask)│
             │ - REST API / JSON出力    │
             │ - 認証（JWT or Google） │
             └────────┬──────────────┘
                           │
                           ▼
          ┌─────────────────────────────┐
          │ Frontend Dashboard (Next.js) │
          │ - Activity Calendar View     │
          │ - KPI Cards / Graphs         │
          │ - Article / Video Timeline   │
          │ - Export: PDF / CSV / Google │
          └─────────────────────────────┘

🗄️ 2. データベース構造（スキーマ設計）
テーブル名	主なカラム	説明
games	game_id, title, platform, release_date, developer, publisher	管理対象ゲームタイトル情報
sales	game_id, date, platform, region, units_sold, revenue, wishlist	Steam/STOVEなど売上とWish
sns_posts	platform, date, account_name, post_id, text, engagement, url	X, FB, Instagramなどの投稿記録
videos	platform, date, channel, video_id, views, likes, comments, url	YouTube, Bilibili, Twitchなど
news_articles	date, source, title, excerpt, url, related_game	PR, 記事、ニュースメディア情報
calendar_events	date, event_type, title, related_game, url	発売・セール・配信・PR等の主要イベント
unity_metrics	date, game_id, active_users, session_time, crash_rate, revenue_inapp	Unityゲーム内テレメトリーデータ
distribution_rules	partner_name, rate, start_date, end_date, notes	収益分配ルール管理
platforms_future	platform_name, api_endpoint, status, notes	今後追加予定のプラットフォーム拡張用
⚙️ 3. バックエンド仕様（Python / Flask）
機能ブロック
モジュール	役割
steam_collector.py	Steamworks APIから販売・Wish・レビュー情報取得
stove_collector.py	STOVE販売情報を取得
sns_collector.py	X, FB, Instagram Graph API連携（非同期）
video_collector.py	YouTube Data API + Bilibili/Twitch 解析
news_collector.py	Google News API + Webスクレイピング
unity_collector.py	Unity Analyticsや自社サーバ送信ログ受信
calendar_updater.py	イベント・セール・PR日を自動登録
report_generator.py	月次PDF/CSVレポート生成（Google Drive同期）
APIエンドポイント例
GET /api/sales?game_id=123&month=2025-10
GET /api/sns?platform=x&from=2025-10-01&to=2025-10-31
GET /api/video?channel=skootagames
GET /api/calendar?game=momocrash
POST /api/report/monthly

🖥️ 4. フロントエンド仕様（Next.js）
コンポーネント	機能
DashboardHome	全体のサマリー（KPIカード）
SalesChart	売上・Wish推移グラフ（日・月・国別切替）
SNSActivityFeed	SNS投稿タイムライン＋エンゲージメント可視化
VideoPanel	各動画プラットフォーム統合ビュー
CalendarView	カレンダー上で全イベント（PR, 配信, 発売等）を表示
NewsPanel	記事タイトル＋引用＋リンクリスト
ReportButton	月次PDF/CSVを生成ボタン
Settings	APIキー管理、分配ルール設定、テーマ切替
表示モード

「カレンダービュー」：活動・記事・動画・売上を時系列で可視化

「分析ビュー」：売上とSNS活動の相関をグラフ化

「メディアビュー」：ニュース・プレス・動画・配信情報を一覧

「月次レポート」：指定月の全指標をまとめたPDF自動生成

🔐 5. 認証・セキュリティ
要素	方法
管理者アクセス	Google OAuth 2.0 or JWT
外部APIキー管理	.env or Secrets Manager
一般公開用	公開可能指標のみを /public エンドポイントで提供
将来的統合	SKOOTA PORTALログイン連携（SSO想定）
🌐 6. 環境構築方針
レイヤー	推奨技術	備考
フロント	Next.js + Tailwind + Chart.js + FullCalendar	反応的UI
バック	Python Flask + SQLAlchemy + Celery	スケジューラ・API管理
DB	PostgreSQL (VPS / CloudSQL)	永続データ
ストレージ	Google Drive / AWS S3	レポート出力先
ホスティング	Xserver VPS / Render / Fly.io / Firebase Hosting	段階的拡張可
自動化	cron or GitHub Actions	日次収集・月次レポート
🧭 7. 将来拡張対応（Switch / Bluesky / 他ストア）
項目	想定APIまたはデータソース
Nintendo Switch eShop	非公式API or 手動CSV同期
Bluesky	AT Protocol API
TikTok	Public Data Scraper (合法範囲)
Epic / itch.io	各API連携予定
OpenAI / Gemini	記事要約・コメント解析の自動生成
📈 8. 出力（レポート仕様）

形式：PDF / CSV / JSON

内容例：

売上サマリー（Steam/STOVE合算）

SNSエンゲージメント

配信/動画視聴推移

記事・PRリスト（引用元リンク）

カレンダーイベント概要

分配結果表（自動計算）

✅ 9. 実装ステップ（ClaudeCode用）

バックエンド雛形生成（Flask＋PostgreSQL＋APIルーティング）

Steam/STOVE収集スクリプト作成

SNS & Video収集モジュール統合

ニュース・カレンダー・Unity連携追加

Next.jsフロント構築

PDFレポート生成（reportlabまたはjsPDF）

認証・環境変数設定

デプロイ＆定期ジョブ設定

Phase 2：公開ビュー構築（/public）

🧠 備考

Claudeの各サブエージェントを分けると効率的：

Analyst：データモデル設計

Implementer：API実装

Critic：構造検証

Archivist：構成ログ管理

今後、「SKOOTA PORTAL Analytics」 のサブモジュール化を想定。

このままClaudeCodeに：

「上記の SKOOTA GAMES Intelligence Dashboard — ClaudeCode 指示書 v0.1 をもとにPhase1実装を生成して」

と渡せば、
バックエンド雛形＋DBスキーマ＋APIの最初のテンプレートが出力されるはずです。