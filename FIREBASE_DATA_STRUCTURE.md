# Firebase Realtime Database データ構造仕様

**最終更新日**: 2025-11-12
**バージョン**: 1.0
**総ユーザー数**: 4,387人（2025-11-12時点）

---

## 📊 概要

SKOOTA GAMESのFirebase Realtime Databaseに保存されているユーザーデータの完全な構造仕様書です。

---

## 🗂️ トップレベル構造

```
users/
  └── {user_id}/              # ランダム生成されたユーザーID（例: -Lv_4yMsehUDXCj-kvpL）
      ├── launch_count        # 起動回数（int）
      ├── systemLanguage      # システム言語（string）
      ├── results/            # プレイ結果（dict）
      ├── option/             # ゲーム設定（dict）
      └── timeStamp/          # イベント履歴（dict）
```

---

## 📝 results/ - プレイ結果データ

各楽曲のプレイ結果を保存。

### キー形式
```
{タイムスタンプ}_{楽曲ID}_{難易度}
```

**例**: `2025-09-25-23-57-10-903_D01ihuu_Normal`

### フィールド一覧（20種類）

| フィールド名 | 型 | 説明 | 値の範囲/例 |
|------------|-----|------|------------|
| **clearRate** | int | 楽曲のクリア達成率（%） | 0-100 |
| **clearType** | string | クリア種別 | "Clear", "FullCombo", "Perfect", "Failed" |
| **clearRank** | string | クリアランク | "MMM", "MM", "M", "A", "B", "C", "D", "None" |
| **score** | int | 今回のスコア | 0-99999 |
| **maxScore** | int | これまでの最高スコア | 0-99999 |
| **character** | string | 使用キャラクター | "Daia", "Seika", "Hikaru" |
| **difficulty** | string | 難易度 | "Easy", "Normal", "Hard" |
| **gameType** | string | 楽曲ID | "D01ihuu", "S01suyo", "H01uiri" など |
| **playMode** | string | プレイモード | "Story" など |
| **playCount** | int | この楽曲のプレイ回数 | 1, 2, 3, ... |
| **totalPlayCount** | int | 全楽曲の累積プレイ回数 | 1, 2, 3, ... |
| **affinityLevel** | int | 親密度レベル | 1, 2, 3, ... |
| **affinityMidLevel** | int | 親密度中間レベル | 1, 2, 3, ... |

#### 重要な違い

- **clearRate**: 各プレイでの達成率（0-100%）- 楽曲の何%をクリアしたか
- **clearType**: クリア成功/失敗の種別 - Clear, FullCombo, Perfect, Failed

### 楽曲ID一覧

**Daiaの楽曲**:
- D01ihuu
- D02krmi
- D03trko
- D04angr

**Seikaの楽曲**:
- S01suyo
- S02arru
- S03unmi
- S04haku

**Hikaruの楽曲**:
- H01uiri
- H02moon
- H03gara
- H04hiso

**その他**:
- Allkank
- Allkank_Destroy
- Music_Tutorial
- unmi_dummy

---

## ⚙️ option/ - ゲーム設定データ

ユーザーのゲーム設定を保存。タイムスタンプごとに保存され、最新設定を使用。

### キー形式
```
{タイムスタンプ}
```

**例**: `2019-12-08-10-40-06-792`

### フィールド一覧（7種類）

| フィールド名 | 型 | 説明 | 値の範囲/例 |
|------------|-----|------|------------|
| **settingLanguage** | string | 設定言語 | "en", "ja", "es" など |
| **Resolution** | string | 画面解像度 | "1920x1080", "1280x720" など |
| **isFullScreen** | bool | フルスクリーン | true, false |
| **bgm** | int | BGM音量 | 0-10 |
| **se** | int | SE音量 | 0-10 |
| **voice** | int | ボイス音量 | 0-10 |
| **movie** | int | ムービー音量 | 0-10 |

---

## ⏱️ timeStamp/ - イベント履歴

ゲーム内の全イベントをタイムスタンプと共に記録。

### キー形式
```
{タイムスタンプ} → {イベントタイプ}
```

**例**: `2025-09-25-23-57-10-902 → GameEnd_D01ihuu`

### イベントタイプ一覧（109種類）

#### 基本イベント
- **launch** - アプリ起動
- **AppStart** - アプリ開始
- **OptionExit** - 設定画面終了

#### ゲーム終了イベント
```
GameEnd_{楽曲ID}
```
- GameEnd_D01ihuu
- GameEnd_S01suyo
- GameEnd_H01uiri
- ... （楽曲ごとに存在）

#### カットシーンイベント（パターン1）
```
CutScene_{キャラクター}_{番号}_{Start|Skip|End}
```

**Daiaのカットシーン**:
- CutScene_Daia_1_Start
- CutScene_Daia_1_Skip
- CutScene_Daia_1_End
- ... （Daia_2, Daia_3, Daia_4, Daia_5）

**Seikaのカットシーン**:
- CutScene_Seika_1_Start
- CutScene_Seika_1_Skip
- CutScene_Seika_1_End
- ... （Seika_2, Seika_3, Seika_4, Seika_5）

**Hikaruのカットシーン**:
- CutScene_Hiakru_1_Start （※表記ゆれあり: Hiakru）
- CutScene_Hiakru_1_Skip
- CutScene_Hiakru_1_End
- ... （Hiakru_2, Hiakru_3, Hiakru_4, Hiakru_5）

**その他のカットシーン**:
- CutScene_Op_Start/Skip/End （オープニング）
- CutScene_Ed1_Start/Skip/End （エンディング1）
- CutScene_Ed2_Start/Skip/End （エンディング2）

#### カットシーンイベント（パターン2 - 旧形式）
```
CutSceneStart_{キャラクター}_{番号}
CutSceneSkip_{キャラクター}_{番号}
CutSceneEnd_{キャラクター}_{番号}
```

**注意**: 表記ゆれあり
- `CutScene_Hiakru` と `CutSceneStart_Hiakru` の両方が存在
- データ集計時は両パターンを考慮する必要あり

---

## 📐 データサンプル

### サンプル1: 完全なユーザーデータ

```json
{
  "-Lv_4yMsehUDXCj-kvpL": {
    "launch_count": 1,
    "systemLanguage": "Spanish",
    "option": {
      "2019-12-08-10-40-06-792": {
        "Resolution": "1920x1080",
        "bgm": 8,
        "isFullScreen": true,
        "movie": 8,
        "se": 8,
        "settingLanguage": "en",
        "voice": 8
      }
    },
    "results": {
      "2025-09-25-23-57-10-903_D01ihuu_Normal": {
        "affinityLevel": 1,
        "affinityMidLevel": 1,
        "character": "Daia",
        "clearRank": "A",
        "clearRate": 89,
        "clearType": "Clear",
        "difficulty": "Normal",
        "gameType": "D01ihuu",
        "maxScore": 17800,
        "playCount": 1,
        "playMode": "Story",
        "score": 15850,
        "totalPlayCount": 1
      }
    },
    "timeStamp": {
      "2019-12-08-10-39-39-130": "launch",
      "2025-09-25-23-57-10-902": "GameEnd_D01ihuu",
      "2025-09-25-23-57-33-822": "CutScene_Daia_2_Start",
      "2025-09-25-23-57-36-625": "CutScene_Daia_2_Skip"
    }
  }
}
```

---

## 🔍 データ収集方法

### 収集スクリプト
`scripts/firebase_collector.py`

```python
# Firebase Realtime Databaseから全ユーザーデータを取得
ref = db.reference('users')
data = ref.get()
```

### 保存先
- **生データ**: `public/data/raw_data.json` （4,387ユーザー）
- **集計データ**: `public/data/dashboard.json` （ダッシュボード用）

### 自動更新
GitHub Actionsで1時間ごとに自動実行（cron: '0 * * * *'）

---

## 📊 データ品質

### タイムスタンプの異常値

**異常パターン**:
1. **2019年のデータ**: 18件（おそらくテストデータ）
2. **2568年のデータ**: 485件（タイ仏暦の誤入力）
3. **未来日付**: 21件（デバイスの時刻設定ミス）

**合計除外データ**: 524件（全体の0.26%）

### フィルタリング処理
`scripts/data_aggregator.py`で以下を除外：
```python
# 2025年のみ許可
if year != 2025:
    continue

# 未来日付を除外
if date_obj > today:
    continue
```

---

## 🚨 注意事項

### 表記ゆれ
- **Hikaru**: `Hiakru` と表記される場合あり
- **CutSceneイベント**: アンダースコアの位置が異なる場合あり
  - `CutScene_Op_Start` vs `CutSceneStart_Op`

### clearRateとclearTypeの違い

| 項目 | clearRate | clearType |
|------|-----------|-----------|
| 意味 | 楽曲の達成率（%） | クリア成功/失敗 |
| 値 | 0-100 (int) | Clear/FullCombo/Perfect/Failed |
| 用途 | プレイの質を評価 | プレイの成否を判定 |
| 例 | 89 → 楽曲の89%をクリア | "Clear" → クリア成功 |

**重要**:
- `clearRate=89` + `clearType="Failed"` も存在する（89%達成したが失敗）
- `clearRate=100` + `clearType="Clear"` も存在する（完全クリアだがフルコンボではない）

---

## 📚 関連ドキュメント

- **プロジェクト開発憲法**: `CLAUDE.md`
- **引き継ぎ文書**: `.claude/handover.txt`
- **集計スクリプト**: `scripts/data_aggregator.py`
- **収集スクリプト**: `scripts/firebase_collector.py`

---

**このドキュメントは定期的に更新されます。データ構造に変更があった場合は必ず反映してください。**
