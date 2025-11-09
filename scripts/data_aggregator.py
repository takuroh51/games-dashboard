#!/usr/bin/env python3
"""
Data Aggregator
Firebaseから取得した生データを集計してダッシュボード用JSONを生成
"""

import json
import os
from datetime import datetime, date
from collections import defaultdict, Counter


def convert_buddhist_era_to_christian_era(date_string):
    """
    タイ仏暦（Buddhist Era）を西暦（Christian Era）に変換
    2568年 → 2025年 (2568 - 543 = 2025)
    """
    try:
        parts = date_string.split('-')
        year = int(parts[0])

        # 2500年以上の年は仏暦と判断して変換
        if year >= 2500:
            year = year - 543
            parts[0] = str(year)
            return '-'.join(parts)

        return date_string
    except:
        return date_string


def load_raw_data(input_path='public/data/raw_data.json'):
    """生データを読み込み"""
    if not os.path.exists(input_path):
        print(f"Error: {input_path} not found")
        return None

    with open(input_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    print(f"✅ Loaded raw data from {input_path}")
    return data


def calculate_excluded_data_stats(users_data):
    """除外データ（異常年、未来日付）の統計を計算"""
    total_count = 0
    excluded_count = 0
    today = date.today()

    for user_id, user_data in users_data.items():
        # timestampから集計
        timestamps = user_data.get('timeStamp', {})
        for timestamp_key in timestamps.keys():
            total_count += 1
            try:
                year = int(timestamp_key.split('-')[0])
                date_part = '-'.join(timestamp_key.split('-')[:3])

                # 2025年でない、または未来の日付の場合は除外
                if year != 2025:
                    excluded_count += 1
                else:
                    date_obj = datetime.strptime(date_part, '%Y-%m-%d').date()
                    if date_obj > today:
                        excluded_count += 1
            except:
                excluded_count += 1

        # resultsから集計
        results = user_data.get('results', {})
        if isinstance(results, dict):
            for result_id in results.keys():
                total_count += 1
                try:
                    year = int(result_id.split('-')[0])
                    date_part = '-'.join(result_id.split('-')[:3])

                    if year != 2025:
                        excluded_count += 1
                    else:
                        date_obj = datetime.strptime(date_part, '%Y-%m-%d').date()
                        if date_obj > today:
                            excluded_count += 1
                except:
                    excluded_count += 1

    excluded_rate = (excluded_count / total_count * 100) if total_count > 0 else 0

    return {
        'totalCount': total_count,
        'excludedCount': excluded_count,
        'excludedRate': round(excluded_rate, 2)
    }


def calculate_kpi(users_data):
    """KPI（総ユーザー数、総起動回数、総プレイ回数、平均スコア）を計算"""
    total_users = len(users_data)
    total_launches = 0
    total_plays = 0
    all_scores = []

    for user_id, user_data in users_data.items():
        # 起動回数
        launch_count = user_data.get('launch_count', 0)
        total_launches += launch_count

        # プレイ回数とスコア
        results = user_data.get('results', {})
        if isinstance(results, dict):
            total_plays += len(results)

            for result_id, result_data in results.items():
                # result_dataが辞書であることを確認
                if isinstance(result_data, dict):
                    score = result_data.get('score')
                    if score is not None:
                        try:
                            # スコアを数値に変換
                            all_scores.append(float(score))
                        except (ValueError, TypeError):
                            pass  # 変換できない場合はスキップ

    average_score = sum(all_scores) / len(all_scores) if all_scores else 0

    return {
        'totalUsers': total_users,
        'totalLaunches': total_launches,
        'totalPlays': total_plays,
        'averageScore': round(average_score, 2)
    }


def calculate_daily_active_users(users_data):
    """日別アクティブユーザー数を計算"""
    daily_activity = defaultdict(set)
    today = date.today()

    for user_id, user_data in users_data.items():
        timestamps = user_data.get('timeStamp', {})
        for timestamp_key, event_type in timestamps.items():
            if event_type == 'launch':
                # タイムスタンプから日付を抽出（YYYY-MM-DD-HH-MM-SS-MS形式）
                try:
                    date_part = '-'.join(timestamp_key.split('-')[:3])  # YYYY-MM-DD
                    year = int(timestamp_key.split('-')[0])

                    # 異常な年を除外（2025年のみ許可）
                    if year != 2025:
                        continue

                    # 未来の日付を除外
                    date_obj = datetime.strptime(date_part, '%Y-%m-%d').date()
                    if date_obj > today:
                        continue

                    daily_activity[date_part].add(user_id)
                except:
                    continue

    # 日付順にソート
    sorted_daily = sorted(
        [{'date': date, 'users': len(users)} for date, users in daily_activity.items()],
        key=lambda x: x['date']
    )

    return sorted_daily


def calculate_character_distribution(users_data):
    """キャラクター別プレイ回数を集計"""
    character_counter = Counter()

    for user_id, user_data in users_data.items():
        results = user_data.get('results', {})
        if isinstance(results, dict):
            for result_id, result_data in results.items():
                if isinstance(result_data, dict):
                    character = result_data.get('character')
                    if character:
                        character_counter[character] += 1

    return dict(character_counter)


def calculate_difficulty_distribution(users_data):
    """難易度別プレイ回数を集計"""
    difficulty_counter = Counter()

    for user_id, user_data in users_data.items():
        results = user_data.get('results', {})
        if isinstance(results, dict):
            for result_id, result_data in results.items():
                if isinstance(result_data, dict):
                    difficulty = result_data.get('difficulty')
                    if difficulty:
                        difficulty_counter[difficulty] += 1

    return dict(difficulty_counter)


def calculate_clear_rank_distribution(users_data):
    """クリアランク分布を集計"""
    rank_counter = Counter()

    for user_id, user_data in users_data.items():
        results = user_data.get('results', {})
        if isinstance(results, dict):
            for result_id, result_data in results.items():
                if isinstance(result_data, dict):
                    rank = result_data.get('clearRank')
                    if rank:
                        rank_counter[rank] += 1

    return dict(rank_counter)


def calculate_language_distribution(users_data):
    """言語分布を集計（最新の設定言語を使用）"""
    language_counter = Counter()

    for user_id, user_data in users_data.items():
        options = user_data.get('option', {})
        if options:
            # 最新のオプション設定を取得
            latest_option_key = sorted(options.keys())[-1] if options else None
            if latest_option_key:
                latest_option = options[latest_option_key]
                language = latest_option.get('settingLanguage')
                if language:
                    language_counter[language] += 1

    return dict(language_counter)


def calculate_cutscene_skip_rate(users_data):
    """カットシーンスキップ率を計算"""
    cutscene_start = 0
    cutscene_skip = 0

    for user_id, user_data in users_data.items():
        timestamps = user_data.get('timeStamp', {})
        for timestamp_key, event_type in timestamps.items():
            if 'CutScene_Op_Start' in str(event_type):
                cutscene_start += 1
            elif 'CutScene_Op_Skip' in str(event_type):
                cutscene_skip += 1

    skip_rate = (cutscene_skip / cutscene_start * 100) if cutscene_start > 0 else 0

    return {
        'totalStart': cutscene_start,
        'totalSkip': cutscene_skip,
        'skipRate': round(skip_rate, 2)
    }


def get_recent_plays(users_data, limit=10):
    """最近のプレイ記録を取得"""
    all_plays = []
    today = date.today()

    for user_id, user_data in users_data.items():
        results = user_data.get('results', {})
        if isinstance(results, dict):
            for result_id, result_data in results.items():
                if isinstance(result_data, dict):
                    # タイムスタンプを抽出（result_idの最初の部分）
                    timestamp_part = result_id.split('_')[0]

                    # 異常な年を除外（2025年のみ許可）
                    try:
                        year = int(timestamp_part.split('-')[0])
                        if year != 2025:
                            continue

                        # 未来の日付を除外
                        date_part = '-'.join(timestamp_part.split('-')[:3])
                        date_obj = datetime.strptime(date_part, '%Y-%m-%d').date()
                        if date_obj > today:
                            continue
                    except:
                        continue

                    all_plays.append({
                        'timestamp': timestamp_part,
                        'character': result_data.get('character', 'Unknown'),
                        'difficulty': result_data.get('difficulty', 'Unknown'),
                        'score': result_data.get('score', 0),
                        'clearRank': result_data.get('clearRank', '-'),
                        'clearType': result_data.get('clearType', 'Unknown')
                    })

    # タイムスタンプでソート（降順）
    sorted_plays = sorted(all_plays, key=lambda x: x['timestamp'], reverse=True)

    return sorted_plays[:limit]


def aggregate_dashboard_data(users_data):
    """全ての集計を実行してダッシュボード用データを生成"""
    print("=" * 60)
    print("Aggregating dashboard data...")
    print("=" * 60)

    dashboard_data = {
        'lastUpdated': datetime.now().isoformat(),
        'kpi': calculate_kpi(users_data),
        'dailyActiveUsers': calculate_daily_active_users(users_data),
        'characterDistribution': calculate_character_distribution(users_data),
        'difficultyDistribution': calculate_difficulty_distribution(users_data),
        'clearRankDistribution': calculate_clear_rank_distribution(users_data),
        'languageDistribution': calculate_language_distribution(users_data),
        'cutsceneSkipRate': calculate_cutscene_skip_rate(users_data),
        'excludedDataStats': calculate_excluded_data_stats(users_data),
        'recentPlays': get_recent_plays(users_data)
    }

    print("✅ KPI calculated")
    print("✅ Daily active users calculated")
    print("✅ Character distribution calculated")
    print("✅ Difficulty distribution calculated")
    print("✅ Clear rank distribution calculated")
    print("✅ Language distribution calculated")
    print("✅ Cutscene skip rate calculated")
    print("✅ Excluded data stats calculated")
    print("✅ Recent plays extracted")

    return dashboard_data


def save_dashboard_data(data, output_path='public/data/dashboard.json'):
    """ダッシュボード用データをJSONファイルに保存"""
    os.makedirs(os.path.dirname(output_path), exist_ok=True)

    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"✅ Dashboard data saved to {output_path}")


def main():
    """メイン処理"""
    print("=" * 60)
    print("Data Aggregator")
    print(f"Started at: {datetime.now().isoformat()}")
    print("=" * 60)

    # 生データ読み込み
    users_data = load_raw_data()
    if not users_data:
        return

    # データ集計
    dashboard_data = aggregate_dashboard_data(users_data)

    # 保存
    save_dashboard_data(dashboard_data)

    print("=" * 60)
    print("✅ Aggregation completed successfully")
    print("=" * 60)


if __name__ == '__main__':
    main()
