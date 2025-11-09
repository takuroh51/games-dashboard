#!/usr/bin/env python3
"""
Firebase Realtime Database Data Collector
Firebaseからゲームデータを取得してJSONファイルに保存
"""

import json
import os
import sys
from datetime import datetime
import firebase_admin
from firebase_admin import credentials, db


def initialize_firebase():
    """Firebase Admin SDKを初期化"""
    # 環境変数からサービスアカウント情報を取得
    service_account_json = os.environ.get('FIREBASE_SERVICE_ACCOUNT')
    database_url = os.environ.get('FIREBASE_DATABASE_URL')

    if not service_account_json or not database_url:
        print("Error: FIREBASE_SERVICE_ACCOUNT and FIREBASE_DATABASE_URL must be set")
        sys.exit(1)

    # JSON文字列をdictに変換
    try:
        service_account_dict = json.loads(service_account_json)
    except json.JSONDecodeError as e:
        print(f"Error parsing FIREBASE_SERVICE_ACCOUNT: {e}")
        sys.exit(1)

    # Firebase初期化
    cred = credentials.Certificate(service_account_dict)
    firebase_admin.initialize_app(cred, {
        'databaseURL': database_url
    })

    print(f"✅ Firebase initialized: {database_url}")


def fetch_all_users_data():
    """users/配下の全データを取得"""
    ref = db.reference('users')
    data = ref.get()

    if not data:
        print("⚠️  No data found in 'users' node")
        return {}

    user_count = len(data)
    print(f"✅ Fetched {user_count} users")

    return data


def save_raw_data(data, output_path='public/data/raw_data.json'):
    """取得した生データをJSONファイルに保存"""
    os.makedirs(os.path.dirname(output_path), exist_ok=True)

    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

    print(f"✅ Raw data saved to {output_path}")


def main():
    """メイン処理"""
    print("=" * 60)
    print("Firebase Data Collector")
    print(f"Started at: {datetime.now().isoformat()}")
    print("=" * 60)

    # Firebase初期化
    initialize_firebase()

    # データ取得
    users_data = fetch_all_users_data()

    # 生データ保存
    save_raw_data(users_data)

    print("=" * 60)
    print("✅ Collection completed successfully")
    print("=" * 60)


if __name__ == '__main__':
    main()
