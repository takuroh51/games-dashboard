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


def load_ga4_data(input_path='public/data/ga4_data.json'):
    """GA4データを読み込み"""
    if not os.path.exists(input_path):
        print(f"⚠️  Warning: {input_path} not found (GA4 data will be skipped)")
        return None

    with open(input_path, 'r', encoding='utf-8') as f:
        data = json.load(f)

    print(f"✅ Loaded GA4 data from {input_path}")
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
    """カットシーンスキップ率を計算（セッションベース）"""
    total_sessions = 0  # カットシーン開始回数
    skipped_sessions = 0  # スキップされたセッション数
    total_skip_button_presses = 0  # スキップボタン押下回数（参考値）

    for user_id, user_data in users_data.items():
        timestamps = user_data.get('timeStamp', {})

        # タイムスタンプでソートしてカットシーンセッションを追跡
        sorted_events = sorted([(k, v) for k, v in timestamps.items() if 'CutScene_Op' in str(v)])

        in_cutscene = False
        current_session_has_skip = False

        for timestamp, event in sorted_events:
            if 'Start' in str(event):
                # 前のセッションを終了
                if in_cutscene and current_session_has_skip:
                    skipped_sessions += 1
                # 新しいカットシーン開始
                total_sessions += 1
                in_cutscene = True
                current_session_has_skip = False

            elif 'Skip' in str(event):
                current_session_has_skip = True
                total_skip_button_presses += 1

            elif 'End' in str(event):
                if in_cutscene and current_session_has_skip:
                    skipped_sessions += 1
                in_cutscene = False
                current_session_has_skip = False

        # 最後のセッションが終了していない場合
        if in_cutscene and current_session_has_skip:
            skipped_sessions += 1

    skip_rate = (skipped_sessions / total_sessions * 100) if total_sessions > 0 else 0

    return {
        'totalStart': total_sessions,
        'totalSkip': skipped_sessions,
        'skipRate': round(skip_rate, 2),
        'totalSkipButtonPresses': total_skip_button_presses  # デバッグ用
    }


def get_recent_plays(users_data, limit=500):
    """最近のプレイ記録を取得（最大500件）"""
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


def calculate_song_plays_by_difficulty(users_data):
    """楽曲別・難易度別のユニークプレイヤー数を集計"""
    # 楽曲ID × 難易度 → ユニークユーザーIDのセット
    song_difficulty_users = defaultdict(lambda: defaultdict(set))

    for user_id, user_data in users_data.items():
        results = user_data.get('results', {})
        if isinstance(results, dict):
            for result_id, result_data in results.items():
                if isinstance(result_data, dict):
                    game_type = result_data.get('gameType')
                    difficulty = result_data.get('difficulty')

                    if game_type and difficulty:
                        song_difficulty_users[game_type][difficulty].add(user_id)

    # データを整形してリスト化
    song_stats = []
    for game_type, difficulties in song_difficulty_users.items():
        easy_count = len(difficulties.get('Easy', set()))
        normal_count = len(difficulties.get('Normal', set()))
        hard_count = len(difficulties.get('Hard', set()))
        total_count = easy_count + normal_count + hard_count

        song_stats.append({
            'songId': game_type,
            'easy': easy_count,
            'normal': normal_count,
            'hard': hard_count,
            'total': total_count
        })

    # 合計プレイ人数でソート（降順）
    sorted_stats = sorted(song_stats, key=lambda x: x['total'], reverse=True)

    return sorted_stats


def calculate_player_clear_rate_distribution(users_data):
    """プレイヤー別クリアレート分布を計算（clearTypeベース）"""
    import statistics

    user_clear_rates = []

    for user_id, user_data in users_data.items():
        results = user_data.get('results', {})
        if isinstance(results, dict) and len(results) > 0:
            user_total = 0
            user_clears = 0

            for result_id, result_data in results.items():
                if isinstance(result_data, dict):
                    user_total += 1
                    clear_type = result_data.get('clearType', 'Unknown')
                    # Clear, FullCombo, Perfect をクリアとしてカウント
                    if clear_type in ['Clear', 'FullCombo', 'Perfect']:
                        user_clears += 1

            if user_total > 0:
                user_clear_rate = (user_clears / user_total) * 100
                user_clear_rates.append(user_clear_rate)

    # 7区分で集計
    brackets = {
        '0%': 0,
        '1-19%': 0,
        '20-39%': 0,
        '40-59%': 0,
        '60-79%': 0,
        '80-99%': 0,
        '100%': 0
    }

    for rate in user_clear_rates:
        if rate == 0:
            brackets['0%'] += 1
        elif rate < 20:
            brackets['1-19%'] += 1
        elif rate < 40:
            brackets['20-39%'] += 1
        elif rate < 60:
            brackets['40-59%'] += 1
        elif rate < 80:
            brackets['60-79%'] += 1
        elif rate < 100:
            brackets['80-99%'] += 1
        else:
            brackets['100%'] += 1

    # 統計情報を計算
    stats = {
        'mean': round(statistics.mean(user_clear_rates), 2) if user_clear_rates else 0,
        'median': round(statistics.median(user_clear_rates), 2) if user_clear_rates else 0,
        'totalPlayers': len(user_clear_rates)
    }

    return {
        'distribution': brackets,
        'stats': stats
    }


def calculate_play_clear_rate_distribution(users_data):
    """プレイ別クリアレート分布を計算（clearRateフィールドベース）"""
    import statistics

    all_clear_rates = []

    for user_id, user_data in users_data.items():
        results = user_data.get('results', {})
        if isinstance(results, dict):
            for result_id, result_data in results.items():
                if isinstance(result_data, dict):
                    clear_rate = result_data.get('clearRate')
                    # clearRateフィールドが存在する場合のみ集計
                    if clear_rate is not None:
                        try:
                            rate_value = int(clear_rate)
                            # 0-100の範囲内のみ有効
                            if 0 <= rate_value <= 100:
                                all_clear_rates.append(rate_value)
                        except (ValueError, TypeError):
                            pass  # 数値に変換できない場合はスキップ

    # 7区分で集計
    brackets = {
        '0%': 0,
        '1-19%': 0,
        '20-39%': 0,
        '40-59%': 0,
        '60-79%': 0,
        '80-99%': 0,
        '100%': 0
    }

    for rate in all_clear_rates:
        if rate == 0:
            brackets['0%'] += 1
        elif rate < 20:
            brackets['1-19%'] += 1
        elif rate < 40:
            brackets['20-39%'] += 1
        elif rate < 60:
            brackets['40-59%'] += 1
        elif rate < 80:
            brackets['60-79%'] += 1
        elif rate < 100:
            brackets['80-99%'] += 1
        else:
            brackets['100%'] += 1

    # 統計情報を計算
    stats = {
        'mean': round(statistics.mean(all_clear_rates), 2) if all_clear_rates else 0,
        'median': round(statistics.median(all_clear_rates), 2) if all_clear_rates else 0,
        'totalPlays': len(all_clear_rates)
    }

    return {
        'distribution': brackets,
        'stats': stats
    }


def calculate_platform_distribution(users_data):
    """Platform別の統計を計算"""
    platform_plays = Counter()
    platform_users = defaultdict(set)

    for user_id, user_data in users_data.items():
        results = user_data.get('results', {})
        if not isinstance(results, dict):
            continue

        for result_id, result_data in results.items():
            if not isinstance(result_data, dict):
                continue

            platform = result_data.get('platform')
            if platform:
                platform_plays[platform] += 1
                platform_users[platform].add(user_id)

    # 分布データを作成
    distribution = []
    for platform, plays in platform_plays.most_common():
        distribution.append({
            'platform': platform,
            'plays': plays,
            'users': len(platform_users[platform])
        })

    return distribution


def calculate_costume_distribution(users_data):
    """Costume別の統計を計算"""
    costume_plays = Counter()

    for user_id, user_data in users_data.items():
        results = user_data.get('results', {})
        if not isinstance(results, dict):
            continue

        for result_id, result_data in results.items():
            if not isinstance(result_data, dict):
                continue

            costume = result_data.get('costume')
            if costume:
                costume_plays[costume] += 1

    # 分布データを作成（Top 20）
    distribution = []
    for costume, plays in costume_plays.most_common(20):
        distribution.append({
            'costume': costume,
            'plays': plays
        })

    return distribution


def calculate_platform_costume_cross(users_data):
    """Platform × Costume のクロス集計"""
    cross_data = defaultdict(lambda: defaultdict(int))

    for user_id, user_data in users_data.items():
        results = user_data.get('results', {})
        if not isinstance(results, dict):
            continue

        for result_id, result_data in results.items():
            if not isinstance(result_data, dict):
                continue

            platform = result_data.get('platform')
            costume = result_data.get('costume')

            if platform and costume:
                cross_data[platform][costume] += 1

    # テーブル形式に変換
    table = []
    for platform, costumes in cross_data.items():
        row = {'platform': platform}
        total = 0
        for costume, count in costumes.items():
            row[costume] = count
            total += count
        row['total'] = total
        table.append(row)

    # 合計でソート
    table.sort(key=lambda x: x['total'], reverse=True)

    return table


def aggregate_dashboard_data(users_data, ga4_data=None):
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
        'recentPlays': get_recent_plays(users_data),
        'songPlaysByDifficulty': calculate_song_plays_by_difficulty(users_data),
        'playerClearRateDistribution': calculate_player_clear_rate_distribution(users_data),
        'playClearRateDistribution': calculate_play_clear_rate_distribution(users_data),
        'platformDistribution': calculate_platform_distribution(users_data),
        'costumeDistribution': calculate_costume_distribution(users_data),
        'platformCostumeCross': calculate_platform_costume_cross(users_data)
    }

    # GA4データを統合
    if ga4_data:
        daily_metrics = ga4_data.get('dailyMetrics', [])
        dashboard_data['ga4'] = {
            'overallMetrics': ga4_data.get('overallMetrics', {}),
            'dailyMetrics': daily_metrics,
            'languageDistribution': ga4_data.get('languageDistribution', []),
            'guidelineMonthlyStats': ga4_data.get('guidelineMonthlyStats', []),
            'dailyMetricsPeriod': len(daily_metrics)  # データの日数を追加
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
    print("✅ Song plays by difficulty calculated")
    print("✅ Player clear rate distribution calculated")
    print("✅ Play clear rate distribution calculated")
    print("✅ Platform distribution calculated")
    print("✅ Costume distribution calculated")
    print("✅ Platform × Costume cross calculated")
    if ga4_data:
        print("✅ GA4 data integrated")

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

    # GA4データ読み込み（オプション）
    ga4_data = load_ga4_data()

    # データ集計
    dashboard_data = aggregate_dashboard_data(users_data, ga4_data)

    # 保存
    save_dashboard_data(dashboard_data)

    print("=" * 60)
    print("✅ Aggregation completed successfully")
    print("=" * 60)


if __name__ == '__main__':
    main()
