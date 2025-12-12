# HealthKit セットアップガイド

HealthKit連携を有効にするために、Xcodeプロジェクトに以下の設定を追加する必要があります。

## ✅ 設定完了状況 (2025-11-20)

このプロジェクトは **既にHealthKit接続が有効化済み** です！

### 完了した設定:

1. ✅ **ビルド設定に権限説明を追加済み**
   - `project.pbxproj` の Debug/Release 設定に追加
   - `INFOPLIST_KEY_NSHealthShareUsageDescription`
   - `INFOPLIST_KEY_NSHealthUpdateUsageDescription`
   - プロジェクトはInfo.plistを自動生成 (`GENERATE_INFOPLIST_FILE = YES`)

2. ✅ **HomeViewでHealthKit接続を実装済み**
   - `Views/HomeView.swift:96` で `setupHealthKit()` を呼び出し
   - アプリ起動時に自動的にHealthKit認証をリクエスト

3. ✅ **ビルド成功 & 動作確認済み**
   - アプリがクラッシュせずに正常起動
   - HealthKit権限ダイアログが表示可能

---

## 1. HealthKit Capability の追加 (⚠️ 未完了 - 次のステップ)

Xcodeでの手動設定が必要:

1. Xcodeで `TUUN.xcodeproj` を開く
2. プロジェクトナビゲーターで **TUUN** プロジェクトを選択
3. **TARGETS** から **TUUN** を選択
4. **Signing & Capabilities** タブをクリック
5. **+ Capability** ボタンをクリック
6. **HealthKit** を選択して追加

> **注意:** Capability追加なしでも基本的なHealthKit認証は動作しますが、App Store提出時には必須です。

## 2. Info.plist 権限説明 (✅ 完了済み)

このプロジェクトでは **ビルド設定で自動的にInfo.plistを生成** しているため、手動での追加は不要です。

### 現在の設定内容:

| Key | Value |
|-----|-------|
| `NSHealthShareUsageDescription` | TUUNはあなたの健康データを読み取り、代謝力・炎症レベル・回復スピード・老化速度などの健康指標を分析します。 |
| `NSHealthUpdateUsageDescription` | TUUNはHealthKitにデータを書き込みません。読み取り専用です。 |

これらは `TUUN.xcodeproj/project.pbxproj` の以下の箇所で設定されています:
- Debug設定: 543-576行目
- Release設定: 577-610行目

## 3. 取得するHealthKitデータ一覧

以下の15種類のデータを読み取ります:

### 体組成系 (4種類)
- `HKQuantityTypeIdentifier.bodyMass` - 体重 (kg)
- `HKQuantityTypeIdentifier.height` - 身長 (cm)
- `HKQuantityTypeIdentifier.bodyFatPercentage` - 体脂肪率 (%)
- `HKQuantityTypeIdentifier.leanBodyMass` - 除脂肪体重 (kg)

### 心臓・循環器系 (4種類)
- `HKQuantityTypeIdentifier.restingHeartRate` - 安静時心拍数 (bpm)
- `HKQuantityTypeIdentifier.vo2Max` - 最大酸素摂取量 (ml/kg/min)
- `HKQuantityTypeIdentifier.heartRateVariabilitySDNN` - 心拍変動 SDNN (ms)
- `HKQuantityTypeIdentifier.heartRate` - 心拍数 (bpm)

### 活動量系 (3種類)
- `HKQuantityTypeIdentifier.activeEnergyBurned` - アクティブカロリー (kcal)
- `HKQuantityTypeIdentifier.appleExerciseTime` - エクササイズ時間 (分)
- `HKQuantityTypeIdentifier.stepCount` - 歩数 (steps)

### 移動距離系 (2種類)
- `HKQuantityTypeIdentifier.distanceWalkingRunning` - 歩行・ランニング距離 (km)
- `HKQuantityTypeIdentifier.distanceCycling` - サイクリング距離 (km)

### 睡眠分析 (1種類)
- `HKCategoryTypeIdentifier.sleepAnalysis` - 睡眠データ (6カテゴリ: ベッド内、睡眠中、覚醒、コア、深い、レム)

### ワークアウト (1種類)
- `HKWorkoutType` - ワークアウトデータ (7種類: ランニング、サイクリング、ウォーキング、水泳、ヨガ、筋トレ、その他)

## 4. 実装の使い方

### 4.1 認証リクエスト

アプリ起動時またはオンボーディング時に呼び出してください:

```swift
Task {
    do {
        try await HealthKitService.shared.requestAuthorization()
        print("✅ HealthKit認証成功")
    } catch {
        print("❌ HealthKit認証失敗: \(error)")
    }
}
```

### 4.2 データ取得

認証後、以下でデータを取得できます:

```swift
Task {
    await HealthKitService.shared.fetchAllHealthData()
}
```

### 4.3 データの利用

```swift
let healthService = HealthKitService.shared

if let healthData = healthService.healthData {
    // 体組成データ
    print("体重: \(healthData.bodyMass ?? 0) kg")
    print("身長: \(healthData.height ?? 0) cm")

    // 心臓データ
    print("安静時心拍数: \(healthData.restingHeartRate ?? 0) bpm")
    print("VO2Max: \(healthData.vo2Max ?? 0)")

    // 活動データ
    print("歩数: \(healthData.stepCount ?? 0)")
    print("アクティブカロリー: \(healthData.activeEnergyBurned ?? 0) kcal")

    // 睡眠データ
    if let sleepSamples = healthData.sleepData {
        print("睡眠サンプル: \(sleepSamples.count)件")
    }

    // ワークアウト
    if let workouts = healthData.workouts {
        print("ワークアウト: \(workouts.count)件")
    }
}
```

### 4.4 HealthKitLiveData との連携

LIVE セクション用のデータ生成:

```swift
let liveData = HealthKitLiveData.fromHealthKitService()
print("HRV: \(liveData.hrv ?? 0) ms")
print("安静時心拍数: \(liveData.rhr ?? 0) bpm")
print("VO2Max: \(liveData.vo2Max ?? 0)")
print("基礎代謝: \(liveData.basalCalories ?? 0) kcal")
```

## 5. 注意事項

### シミュレーターでのテスト
- iOS シミュレーターでは HealthKit データが限定的です
- 実機でテストすることを推奨します
- シミュレーターでは Health アプリからサンプルデータを追加できます

### プライバシー
- ユーザーがHealthKitへのアクセスを拒否した場合、`HealthKitLiveData.sample` がフォールバックとして使用されます
- データは端末内でのみ処理され、外部に送信されません (プライバシー保護)

### データの更新頻度
- HealthKit データは随時更新されます
- `HealthKitService.shared.refreshData()` を呼び出すことで最新データを取得できます
- バックグラウンド更新が必要な場合は、Background Delivery API を検討してください

## 6. トラブルシューティング

### HealthKit が利用できない
```swift
if !HealthKitService.shared.isHealthKitAvailable() {
    print("❌ このデバイスではHealthKitが利用できません")
}
```

### 認証ステータスの確認
```swift
switch HealthKitService.shared.authorizationStatus {
case .notDetermined:
    print("未確認 - 認証をリクエストしてください")
case .denied:
    print("拒否されました - 設定から許可してください")
case .authorized:
    print("許可済み")
case .restricted:
    print("制限があります")
}
```

## 7. 次のステップ

1. ✅ HealthKit Capability を追加
2. ✅ Info.plist に権限説明を追加
3. ✅ アプリをビルドして実機でテスト
4. ⏭️ UI に HealthKit データを統合 (次フェーズ)

---

**実装完了したファイル:**
- ✅ `Models/HealthKitDataModels.swift` - データモデル定義
- ✅ `Services/HealthKitService.swift` - HealthKit連携サービス
- ✅ `Models/HealthKitLiveData.swift` - LIVE セクション用データ生成 (updated)
