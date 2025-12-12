# スコアリングエンジン仕様書

最終更新: 2025-11-20

## 概要

TUUNアプリの健康スコアリングエンジン実装仕様。血液検査データとHealthKitデータを統合し、4つの健康ドメインスコアを0-100スケールで算出します。

## 📊 4つの健康ドメイン

### 1. 代謝力 (Metabolic Score)
**説明**: 糖・脂質代謝の健康度を評価

**使用メトリック** (重み付き平均):
- HbA1c (25%) - 糖代謝の長期指標
- TG (20%) - 中性脂肪
- HDL (15%) - 善玉コレステロール
- LDL (15%) - 悪玉コレステロール
- BMI (10%) - 体格指数
- VO2Max (10%) - 最大酸素摂取量
- アクティブカロリー (5%) - 日次運動量

**スコア解釈**:
- 70-100: 高い代謝力
- 40-69: 中程度の代謝力
- 0-39: 低い代謝力

### 2. 炎症レベル (Inflammation Score)
**説明**: 体内の炎症状態を評価

**使用メトリック** (重み付き平均):
- CRP (40%) - C反応性タンパク (炎症マーカー)
- AST (15%) - 肝機能指標
- ALT (15%) - 肝機能指標
- GGT (10%) - 肝機能指標
- HRV (10%) - 心拍変動
- 睡眠時間 (10%) - 日次平均睡眠

**スコア解釈**:
- 70-100: 状態正常
- 40-69: 注意
- 0-39: 高い炎症レベル

### 3. 回復スピード (Recovery Score)
**説明**: 運動・ストレスからの回復能力を評価

**使用メトリック** (重み付き平均):
- CRP (20%) - 炎症マーカー
- CK (20%) - クレアチンキナーゼ (筋肉損傷指標)
- フェリチン (15%) - 鉄貯蔵量
- HRV (15%) - 心拍変動
- 安静時心拍数 (10%) - RHR
- 睡眠時間 (10%) - 日次平均睡眠
- ALB (10%) - アルブミン (栄養状態)

**スコア解釈**:
- 70-100: 準備完了
- 40-69: 回復中
- 0-39: 疲労状態

### 4. 老化速度 (Aging Pace Score)
**説明**: 生物学的老化の速度を評価

**使用メトリック** (重み付き平均):
- HbA1c (20%) - 糖代謝
- CRP (15%) - 炎症マーカー
- ALB (15%) - アルブミン
- CRE (10%) - クレアチニン (腎機能)
- eGFR (10%) - 推定糸球体濾過量 (腎機能)
- HRV (10%) - 心拍変動
- VO2Max (10%) - 有酸素能力
- BMI (10%) - 体格指数

**スコア解釈**:
- スコア70-100 → 0.5-0.8歳/年 (優秀、老化が遅い)
- スコア40-69 → 0.8-1.2歳/年 (標準的な老化)
- スコア0-39 → 1.2-2.0歳/年 (注意、老化が速い)

計算式: `老化速度(歳/年) = 2.0 - (agingPaceScore / 100.0 * 1.5)`

## 🧮 スコアリングアルゴリズム

### 基本原則

すべてのメトリックは0-100スケールに正規化されます。3つの方向性タイプがあります:

#### 1. higherIsBetter (高いほど良い)
例: HRV, VO2Max, HDL, eGFR

```
score = ((value - min) / (max - min)) * 100
```

#### 2. lowerIsBetter (低いほど良い)
例: CRP, HbA1c, LDL, TG, RHR

```
score = ((max - value) / (max - min)) * 100
```

#### 3. rangeIsBest (範囲内が最適)
例: BMI, 睡眠時間, TP, ALB, CRE

```
if idealLow ≤ value ≤ idealHigh:
    score = 100
else if value < idealLow:
    score = ((value - min) / (idealLow - min)) * 100
else:
    score = ((max - value) / (max - idealHigh)) * 100
```

### ドメインスコア計算

各ドメインスコアは、複数メトリックの重み付け平均として計算されます:

```
domainScore = Σ(metricScore_i × weight_i) / Σ(weight_i)
```

## 📋 メトリック範囲定義

### 血液検査メトリック (27種類)

#### 糖代謝 (3種類)
| ID | 名称 | 単位 | 方向 | 範囲 | 理想範囲 |
|----|------|------|------|------|----------|
| HbA1c | ヘモグロビンA1c | % | lowerIsBetter | 4.0-10.0 | - |
| FBG | 空腹時血糖 | mg/dL | lowerIsBetter | 70-200 | - |
| insulin | インスリン | μU/mL | rangeIsBest | 2-30 | 3-15 |

#### 脂質代謝 (6種類)
| ID | 名称 | 単位 | 方向 | 範囲 | 理想範囲 |
|----|------|------|------|------|----------|
| TG | 中性脂肪 | mg/dL | lowerIsBetter | 30-300 | - |
| TC | 総コレステロール | mg/dL | rangeIsBest | 120-280 | 150-220 |
| HDL | HDLコレステロール | mg/dL | higherIsBetter | 20-100 | - |
| LDL | LDLコレステロール | mg/dL | lowerIsBetter | 40-200 | - |
| nonHDL | 非HDLコレステロール | mg/dL | lowerIsBetter | 50-220 | - |
| LH_ratio | LDL/HDL比 | - | lowerIsBetter | 1.0-5.0 | - |

#### 炎症マーカー (1種類)
| ID | 名称 | 単位 | 方向 | 範囲 | 理想範囲 |
|----|------|------|------|------|----------|
| CRP | C反応性タンパク | mg/dL | lowerIsBetter | 0.0-2.0 | - |

#### 腎機能 (3種類)
| ID | 名称 | 単位 | 方向 | 範囲 | 理想範囲 |
|----|------|------|------|------|----------|
| CRE | クレアチニン | mg/dL | rangeIsBest | 0.4-2.0 | 0.6-1.2 |
| eGFR | 推定GFR | mL/min/1.73m² | higherIsBetter | 15-120 | - |
| UA | 尿酸 | mg/dL | rangeIsBest | 2.0-10.0 | 3.0-7.0 |

#### 肝機能 (5種類)
| ID | 名称 | 単位 | 方向 | 範囲 | 理想範囲 |
|----|------|------|------|------|----------|
| AST | AST | U/L | lowerIsBetter | 10-100 | - |
| ALT | ALT | U/L | lowerIsBetter | 5-100 | - |
| GGT | γ-GTP | U/L | lowerIsBetter | 10-150 | - |
| ALP | ALP | U/L | rangeIsBest | 50-400 | 100-330 |
| TBIL | 総ビリルビン | mg/dL | rangeIsBest | 0.2-3.0 | 0.3-1.2 |

#### タンパク質 (3種類)
| ID | 名称 | 単位 | 方向 | 範囲 | 理想範囲 |
|----|------|------|------|------|----------|
| TP | 総タンパク | g/dL | rangeIsBest | 5.0-9.0 | 6.5-8.2 |
| ALB | アルブミン | g/dL | rangeIsBest | 2.5-5.5 | 4.0-5.0 |
| AG_ratio | A/G比 | - | rangeIsBest | 0.8-2.5 | 1.2-2.0 |

#### 電解質 (3種類)
| ID | 名称 | 単位 | 方向 | 範囲 | 理想範囲 |
|----|------|------|------|------|----------|
| Na | ナトリウム | mEq/L | rangeIsBest | 130-150 | 136-145 |
| K | カリウム | mEq/L | rangeIsBest | 2.5-6.0 | 3.5-5.0 |
| Cl | クロール | mEq/L | rangeIsBest | 90-115 | 98-108 |

#### 筋肉・エネルギー (3種類)
| ID | 名称 | 単位 | 方向 | 範囲 | 理想範囲 |
|----|------|------|------|------|----------|
| CK | クレアチンキナーゼ | U/L | rangeIsBest | 20-500 | 50-250 |
| LDH | 乳酸脱水素酵素 | U/L | rangeIsBest | 100-500 | 120-240 |
| ferritin | フェリチン | ng/mL | rangeIsBest | 10-500 | 30-250 |

### HealthKitメトリック (7種類)

| ID | 名称 | 単位 | 方向 | 範囲 | 理想範囲 |
|----|------|------|------|------|----------|
| bmi | BMI | - | rangeIsBest | 15-40 | 18.5-24.9 |
| hrv | 心拍変動 (SDNN) | ms | higherIsBetter | 20-200 | - |
| rhr | 安静時心拍数 | bpm | lowerIsBetter | 40-100 | - |
| vo2max | 最大酸素摂取量 | ml/kg/min | higherIsBetter | 20-70 | - |
| dailySteps | 日次歩数 | steps | higherIsBetter | 0-20000 | - |
| activeCalories | アクティブカロリー | kcal | higherIsBetter | 0-1500 | - |
| sleepHours | 睡眠時間 | hours | rangeIsBest | 3-12 | 7-9 |

## 🏗️ アーキテクチャ

### ファイル構成

```
ScoreEngine/
├── MetricConfig.swift          # 型定義 (MetricDirection, MetricConfig, DomainScoreConfig)
├── ScoreEngine.swift           # コアスコアリングロジック
├── MetricConfigs.swift         # 全メトリック範囲定義 (34メトリック + 4ドメイン)
├── HealthKitBridge.swift       # HealthKitデータ変換
└── HealthScoreService.swift    # 統合サービス (ObservableObject)
```

### データフロー

```
1. HealthKitService.shared.healthData (HealthKitData?)
   └─> HealthKitBridge.convertToMetricValues()
       └─> [String: Double] (7 HealthKitメトリック)

2. BloodTestService.shared.bloodData (BloodTestData?)
   └─> HealthScoreService.collectBloodTestValues()
       └─> [String: Double] (27血液検査メトリック)

3. 統合データ: [String: Double] (34メトリック)
   └─> ScoreEngine.computeDomainScore()
       ├─> metabolicScore (0-100)
       ├─> inflammationScore (0-100)
       ├─> recoveryScore (0-100)
       └─> agingPaceScore (0-100)

4. UI表示
   └─> HealthMetricsGridSection
       ├─> 代謝力: metabolicScore / 100 (0-1)
       ├─> 炎症レベル: inflammationScore / 100 (0-1)
       ├─> 回復スピード: recoveryScore / 100 (0-1)
       └─> 老化速度: 2.0 - (agingPaceScore / 100 * 1.5) 歳/年
```

## 🔧 使用方法

### 1. スコア計算のトリガー

```swift
Task {
    await HealthScoreService.shared.calculateAllScores()
}
```

### 2. スコア取得

```swift
let healthScoreService = HealthScoreService.shared

// 各ドメインスコア (0-100スケール)
if let metabolicScore = healthScoreService.metabolicScore {
    print("代謝力: \(metabolicScore)/100")
}

if let inflammationScore = healthScoreService.inflammationScore {
    print("炎症レベル: \(inflammationScore)/100")
}

if let recoveryScore = healthScoreService.recoveryScore {
    print("回復スピード: \(recoveryScore)/100")
}

if let agingPaceScore = healthScoreService.agingPaceScore {
    print("老化速度: \(agingPaceScore)/100")

    // 老化速度を歳/年に変換
    let agingRate = 2.0 - (agingPaceScore / 100.0 * 1.5)
    print("老化速度: \(agingRate)歳/年")
}
```

### 3. UIでの使用

```swift
struct HealthMetricsGridSection: View {
    @StateObject private var healthScoreService = HealthScoreService.shared

    var body: some View {
        VStack {
            // カード表示
        }
        .onAppear {
            Task {
                await healthScoreService.calculateAllScores()
            }
        }
    }

    private var metabolicScore: Double {
        // 0-100スケールを0-1に変換
        if let score = healthScoreService.metabolicScore {
            return score / 100.0
        }
        return 0.35 // デフォルト値
    }
}
```

## 📝 注意事項

### データ不足時の動作

- メトリック値が不足している場合、そのメトリックはスコア計算から除外されます
- ドメインスコアは、利用可能なメトリックの重み付け平均として計算されます
- すべてのメトリックが不足している場合、ドメインスコアは`nil`を返します

### デフォルト値

UIでは、スコアが`nil`の場合にデフォルト値を使用します:
- 代謝力: 0.35 (35%)
- 炎症レベル: 0.4 (40%)
- 回復スピード: 0.71 (71%)
- 老化速度: 0.43 (43%) → 1.36歳/年

### デバッグ出力

`HealthScoreService.calculateAllScores()`を実行すると、以下のデバッグ情報がコンソールに出力されます:

1. 収集されたメトリック値 (血液検査 + HealthKit)
2. 各ドメインスコアの計算結果
3. 不足しているメトリックの警告

## 🧪 テスト

### 単体テスト例

```swift
import XCTest

class ScoreEngineTests: XCTestCase {

    func testHigherIsBetter() {
        let config = MetricConfig(
            id: "hrv",
            units: "ms",
            direction: .higherIsBetter,
            min: 20.0,
            max: 200.0
        )

        let score = ScoreEngine.scoreMetric(value: 110.0, config: config)
        XCTAssertEqual(score, 50.0, accuracy: 0.1)
    }

    func testLowerIsBetter() {
        let config = MetricConfig(
            id: "crp",
            units: "mg/dL",
            direction: .lowerIsBetter,
            min: 0.0,
            max: 2.0
        )

        let score = ScoreEngine.scoreMetric(value: 0.5, config: config)
        XCTAssertEqual(score, 75.0, accuracy: 0.1)
    }

    func testRangeIsBest() {
        let config = MetricConfig(
            id: "bmi",
            units: "",
            direction: .rangeIsBest,
            min: 15.0,
            max: 40.0,
            idealLow: 18.5,
            idealHigh: 24.9
        )

        // 理想範囲内
        let score1 = ScoreEngine.scoreMetric(value: 22.0, config: config)
        XCTAssertEqual(score1, 100.0)

        // 理想範囲より低い
        let score2 = ScoreEngine.scoreMetric(value: 17.0, config: config)
        XCTAssertTrue(score2 < 100.0 && score2 > 0.0)

        // 理想範囲より高い
        let score3 = ScoreEngine.scoreMetric(value: 30.0, config: config)
        XCTAssertTrue(score3 < 100.0 && score3 > 0.0)
    }
}
```

## 🚀 今後の拡張

### フェーズ2: TypeScript実装 (将来)
- Web/バックエンドで同じスコアリングロジックを使用
- API経由でスコア計算を提供

### フェーズ3: Python実装 (将来)
- データ分析・機械学習用
- 大規模データセットでのスコア計算

### フェーズ4: 機能拡張
- [ ] 時系列スコア追跡 (履歴グラフ)
- [ ] スコア推移の予測
- [ ] パーソナライズされた推奨事項
- [ ] 複数デバイス間のデータ同期

## 📚 参考資料

- [HealthKit Framework Documentation](https://developer.apple.com/documentation/healthkit)
- [Swift Concurrency](https://docs.swift.org/swift-book/LanguageGuide/Concurrency.html)
- [SwiftUI ObservableObject](https://developer.apple.com/documentation/combine/observableobject)

---

**実装完了**: 2025-11-20
**バージョン**: 1.0.0
**言語**: Swift 5.9+
**プラットフォーム**: iOS 15.0+
