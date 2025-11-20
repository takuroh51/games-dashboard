# 📦 データバックアップ・分析環境セットアップ

## 🎯 目的
ダッシュボードのデータをローカルにバックアップし、自由に分析できる環境を整備

---

## ✅ 方法A: シンプルバックアップ（認証不要・即実行可能）

**最も簡単。今すぐ使える。**

```bash
./scripts/backup_simple.sh
```

### 取得データ
- `backups/dashboard_YYYYMMDD_HHMMSS.json` - 集計済みデータ
- `backups/raw_data_YYYYMMDD_HHMMSS.json` - 生データ

### メリット
- 認証不要
- 即座に実行可能
- GitHub Pagesの最新データを取得

### デメリット
- GitHub Actionsの更新タイミング（1時間ごと）に依存
- リアルタイムではない

---

## 🔥 方法B: Firebase直接取得（最新・最詳細）

**生データを直接取得。最新データが手に入る。**

### 初回セットアップ（1回だけ）

#### 1. Firebase認証情報を取得

1. [Firebase Console](https://console.firebase.google.com/) にアクセス
2. プロジェクト選択（Sound Beats）
3. **⚙️ Project Settings** → **Service accounts** タブ
4. **Generate new private key** をクリック
5. ダウンロードしたJSONファイルを以下に保存：
   ```
   scripts/firebase-credentials.json
   ```

#### 2. 実行

```bash
./scripts/backup_firebase.sh
```

### 取得データ
- `backups/raw_data_YYYYMMDD_HHMMSS.json` - Firebase最新データ
- `public/data/raw_data.json` - 上書き保存

### メリット
- 最新データを直接取得
- dashboard.jsonに含まれない詳細データも取得可能
- リアルタイム

### デメリット
- 初回セットアップが必要（認証情報取得）

---

## 🐍 方法C: Python環境での分析

### Jupyter Notebookのセットアップ

```bash
# 仮想環境をアクティベート
source venv/bin/activate

# Jupyter Notebookをインストール
pip install jupyter pandas matplotlib seaborn

# 起動
jupyter notebook
```

### サンプルコード

```python
import json
import pandas as pd
import matplotlib.pyplot as plt

# 生データ読み込み
with open('backups/raw_data_20251120_205809.json') as f:
    data = json.load(f)

# DataFrameに変換（ユーザーIDをキーとして展開）
records = []
for user_id, user_data in data.items():
    if isinstance(user_data, dict) and 'results' in user_data:
        for result in user_data['results']:
            result['userId'] = user_id
            records.append(result)

df = pd.DataFrame(records)

# 基本統計
print(df.describe())

# キャラクター別プレイ回数
df['character'].value_counts().plot(kind='bar', title='Character Distribution')
plt.show()

# 難易度別平均スコア
df.groupby('difficulty')['score'].mean().plot(kind='bar', title='Average Score by Difficulty')
plt.show()
```

---

## 📅 定期バックアップ（オプション）

cronで毎日自動バックアップを設定：

```bash
# crontabを編集
crontab -e

# 以下を追加（毎日3時にバックアップ）
0 3 * * * cd /Users/takurohharada/Projects/games-dashboard && ./scripts/backup_firebase.sh >> backups/backup.log 2>&1
```

---

## 🚨 注意事項

### セキュリティ
- ✅ `.gitignore` に認証情報除外設定済み
- ⚠️ **firebase-credentials.json は絶対にgitにコミットしない**
- ⚠️ **バックアップディレクトリも除外推奨**（個人情報含む可能性）

### データサイズ
- 現在のraw_data.jsonサイズ: 約2-3MB
- 毎日バックアップすると月間90-100MB程度

---

## 📊 どのバックアップ方法を使うべきか？

| 用途 | 推奨方法 |
|------|---------|
| **今すぐデータが欲しい** | 方法A（シンプル） |
| **最新データを研究** | 方法B（Firebase） |
| **定期バックアップ** | 方法A + cron |
| **深い分析** | 方法B + Jupyter Notebook |

---

## 🆘 トラブルシューティング

### firebase-credentials.json not found
→ 方法Bの初回セットアップ（認証情報取得）を実施してください

### Python依存関係エラー
```bash
source venv/bin/activate
pip install -r scripts/requirements.txt
```

### データが古い（方法A）
→ GitHub Actionsの次回実行（1時間ごと）を待つか、方法Bを使用
