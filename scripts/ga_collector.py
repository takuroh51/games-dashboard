#!/usr/bin/env python3
"""
Google Analytics 4 Data Collector
GA4からガイドサイトのアクセスデータを取得してJSONファイルに保存
"""

import json
import os
import sys
from datetime import datetime, timedelta
from google.analytics.data_v1beta import BetaAnalyticsDataClient
from google.analytics.data_v1beta.types import (
    DateRange,
    Dimension,
    Metric,
    RunReportRequest,
)
from google.oauth2 import service_account


def initialize_ga4_client():
    """GA4クライアントを初期化"""
    # 環境変数またはローカルファイルから認証情報を取得
    service_account_json = os.environ.get('GA4_SERVICE_ACCOUNT')

    if service_account_json:
        # GitHub Actions環境（環境変数から取得）
        try:
            service_account_dict = json.loads(service_account_json)
            credentials = service_account.Credentials.from_service_account_info(
                service_account_dict
            )
        except json.JSONDecodeError as e:
            print(f"Error parsing GA4_SERVICE_ACCOUNT: {e}")
            sys.exit(1)
    else:
        # ローカル環境（JSONファイルから取得）
        credentials_path = os.path.join(
            os.path.dirname(__file__),
            'ga4-credentials.json'
        )

        if not os.path.exists(credentials_path):
            print(f"Error: {credentials_path} not found")
            print("Set GA4_SERVICE_ACCOUNT environment variable or place ga4-credentials.json")
            sys.exit(1)

        credentials = service_account.Credentials.from_service_account_file(
            credentials_path
        )

    client = BetaAnalyticsDataClient(credentials=credentials)
    print("✅ GA4 client initialized")
    return client


def fetch_overall_metrics(client, property_id):
    """全体のKPI（総PV、総UU、今日のアクセス）を取得"""
    # 全期間のデータ
    request_all_time = RunReportRequest(
        property=f"properties/{property_id}",
        date_ranges=[DateRange(start_date="2024-01-01", end_date="today")],
        metrics=[
            Metric(name="screenPageViews"),
            Metric(name="totalUsers"),
        ],
    )

    # 今日のデータ
    request_today = RunReportRequest(
        property=f"properties/{property_id}",
        date_ranges=[DateRange(start_date="today", end_date="today")],
        metrics=[
            Metric(name="screenPageViews"),
        ],
    )

    response_all_time = client.run_report(request_all_time)
    response_today = client.run_report(request_today)

    # 全期間の集計
    total_page_views = 0
    total_users = 0
    if response_all_time.rows:
        row = response_all_time.rows[0]
        total_page_views = int(row.metric_values[0].value)
        total_users = int(row.metric_values[1].value)

    # 今日の集計
    today_page_views = 0
    if response_today.rows:
        row = response_today.rows[0]
        today_page_views = int(row.metric_values[0].value)

    print(f"✅ Overall metrics: PV={total_page_views}, Users={total_users}, Today={today_page_views}")

    return {
        'totalPageViews': total_page_views,
        'totalUsers': total_users,
        'todayPageViews': today_page_views,
    }


def fetch_daily_metrics(client, property_id, days=30):
    """過去N日間の日別アクセス数を取得"""
    request = RunReportRequest(
        property=f"properties/{property_id}",
        date_ranges=[DateRange(start_date=f"{days}daysAgo", end_date="today")],
        dimensions=[Dimension(name="date")],
        metrics=[
            Metric(name="screenPageViews"),
            Metric(name="activeUsers"),
        ],
    )

    response = client.run_report(request)

    daily_data = []
    for row in response.rows:
        date_str = row.dimension_values[0].value  # YYYYMMDD形式
        # YYYY-MM-DD形式に変換
        formatted_date = f"{date_str[:4]}-{date_str[4:6]}-{date_str[6:]}"
        page_views = int(row.metric_values[0].value)
        active_users = int(row.metric_values[1].value)

        daily_data.append({
            'date': formatted_date,
            'pageViews': page_views,
            'activeUsers': active_users,
        })

    # 日付順にソート（昇順）
    daily_data.sort(key=lambda x: x['date'])

    print(f"✅ Daily metrics: {len(daily_data)} days")
    return daily_data


def fetch_language_distribution(client, property_id):
    """言語別アクセス分布を取得"""
    request = RunReportRequest(
        property=f"properties/{property_id}",
        date_ranges=[DateRange(start_date="2024-01-01", end_date="today")],
        dimensions=[Dimension(name="language")],
        metrics=[
            Metric(name="screenPageViews"),
            Metric(name="activeUsers"),
        ],
    )

    response = client.run_report(request)

    language_data = []
    for row in response.rows:
        language = row.dimension_values[0].value
        page_views = int(row.metric_values[0].value)
        active_users = int(row.metric_values[1].value)

        language_data.append({
            'language': language,
            'pageViews': page_views,
            'activeUsers': active_users,
        })

    # ページビュー数でソート（降順）
    language_data.sort(key=lambda x: x['pageViews'], reverse=True)

    print(f"✅ Language distribution: {len(language_data)} languages")
    return language_data


def fetch_page_distribution(client, property_id):
    """ページパス別アクセス分布を取得"""
    request = RunReportRequest(
        property=f"properties/{property_id}",
        date_ranges=[DateRange(start_date="2024-01-01", end_date="today")],
        dimensions=[
            Dimension(name="pagePath"),
            Dimension(name="pageTitle"),
        ],
        metrics=[
            Metric(name="screenPageViews"),
            Metric(name="activeUsers"),
        ],
    )

    response = client.run_report(request)

    page_data = []
    for row in response.rows:
        page_path = row.dimension_values[0].value
        page_title = row.dimension_values[1].value
        page_views = int(row.metric_values[0].value)
        active_users = int(row.metric_values[1].value)

        page_data.append({
            'pagePath': page_path,
            'pageTitle': page_title,
            'pageViews': page_views,
            'activeUsers': active_users,
        })

    # ページビュー数でソート（降順）
    page_data.sort(key=lambda x: x['pageViews'], reverse=True)

    print(f"✅ Page distribution: {len(page_data)} pages")
    return page_data


def fetch_guideline_monthly_stats(client, property_id):
    """ガイドラインページの月別言語別アクセス統計を取得"""
    request = RunReportRequest(
        property=f"properties/{property_id}",
        date_ranges=[DateRange(start_date="2024-01-01", end_date="today")],
        dimensions=[
            Dimension(name="pagePath"),
            Dimension(name="yearMonth"),
        ],
        metrics=[
            Metric(name="screenPageViews"),
        ],
        dimension_filter={
            "filter": {
                "field_name": "pagePath",
                "string_filter": {
                    "match_type": "CONTAINS",
                    "value": "guideline"
                }
            }
        }
    )

    response = client.run_report(request)

    # 月別言語別に集計
    from collections import defaultdict
    monthly_lang_data = defaultdict(lambda: defaultdict(int))

    for row in response.rows:
        page_path = row.dimension_values[0].value
        year_month = row.dimension_values[1].value  # YYYYMM形式
        page_views = int(row.metric_values[0].value)

        # 年月をYYYY-MM形式に変換
        formatted_month = f"{year_month[:4]}-{year_month[4:]}"

        # ページパスから言語を判定
        # 実際に存在する9言語のみ判定（日本語、英語、韓国語、簡体中国語、繁体中国語、フランス語、スペイン語、ポルトガル語、ロシア語）
        path_lower = page_path.lower()

        if '/zh-hans' in path_lower or '/guideline/zh-hans' in path_lower:
            lang = 'zh-hans'
        elif '/zh-hant' in path_lower or '/guideline/zh-hant' in path_lower:
            lang = 'zh-hant'
        elif '/en' in path_lower or '/guideline/en' in path_lower:
            lang = 'en'
        elif '/ko' in path_lower or '/guideline/ko' in path_lower or 'ko/' in path_lower:
            lang = 'ko'
        elif '/fr' in path_lower or '/guideline/fr' in path_lower:
            lang = 'fr'
        elif '/es' in path_lower or '/guideline/es' in path_lower:
            lang = 'es'
        elif '/pt' in path_lower or '/guideline/pt' in path_lower:
            lang = 'pt'
        elif '/ru' in path_lower or '/guideline/ru' in path_lower:
            lang = 'ru'
        else:
            lang = 'ja'  # デフォルトは日本語

        monthly_lang_data[formatted_month][lang] += page_views

    # 結果を整形
    result = []
    for month in sorted(monthly_lang_data.keys()):
        month_data = {'month': month}
        month_data.update(monthly_lang_data[month])
        result.append(month_data)

    print(f"✅ Guideline monthly stats: {len(result)} months")
    return result


def save_ga4_data(data, output_path='public/data/ga4_data.json'):
    """GA4データをJSONファイルに保存"""
    os.makedirs(os.path.dirname(output_path), exist_ok=True)

    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"✅ GA4 data saved to {output_path}")


def main():
    """メイン処理"""
    print("=== GA4 Data Collector ===")

    # Property IDを環境変数から取得
    property_id = os.environ.get('GA4_PROPERTY_ID', '358776412')
    print(f"Property ID: {property_id}")

    # 日別メトリクスの日数を環境変数から取得（デフォルト: 30日）
    daily_metrics_days = int(os.environ.get('GA4_DAILY_METRICS_DAYS', '30'))
    print(f"Daily metrics period: {daily_metrics_days} days")

    # GA4クライアント初期化
    client = initialize_ga4_client()

    # データ取得
    overall_metrics = fetch_overall_metrics(client, property_id)
    daily_metrics = fetch_daily_metrics(client, property_id, days=daily_metrics_days)
    language_distribution = fetch_language_distribution(client, property_id)
    page_distribution = fetch_page_distribution(client, property_id)
    guideline_monthly_stats = fetch_guideline_monthly_stats(client, property_id)

    # データをまとめる
    ga4_data = {
        'lastUpdated': datetime.now().isoformat(),
        'overallMetrics': overall_metrics,
        'dailyMetrics': daily_metrics,
        'languageDistribution': language_distribution,
        'pageDistribution': page_distribution,
        'guidelineMonthlyStats': guideline_monthly_stats,
    }

    # JSONファイルに保存
    save_ga4_data(ga4_data)

    print("=== GA4 Data Collection Complete ===")


if __name__ == '__main__':
    main()
