//
//  TuuningIntelligenceService.swift
//  TUUN
//
//  Created by Claude on 2025/12/01.
//  TUUNING Intelligence API連携サービス
//

import Foundation

/// TUUNING Intelligence サービス
class TuuningIntelligenceService: ObservableObject {
    static let shared = TuuningIntelligenceService()

    // MARK: - Published Properties
    @Published var currentInsight: AIInsightResponse?
    @Published var isLoading = false
    @Published var errorMessage = ""
    @Published var debugData: IntelligenceDebugData?

    // MARK: - Cache
    private var cachedTimeSlot: TimeSlot?
    private var cachedDate: Date?

    private init() {}

    // MARK: - Public Methods

    /// インサイトを取得（時間帯別）
    func fetchInsight(for timeSlot: TimeSlot) async throws -> AIInsightResponse {
        // キャッシュチェック（同じ時間帯・同じ日付なら再取得しない）
        if let cached = currentInsight,
           cachedTimeSlot == timeSlot,
           let cachedDate = cachedDate,
           Calendar.current.isDate(cachedDate, inSameDayAs: Date()) {
            return cached
        }

        await MainActor.run {
            isLoading = true
            errorMessage = ""
        }

        do {
            // データ収集
            let collectedData = await collectUserData()

            // デバッグデータを保存
            await MainActor.run {
                debugData = IntelligenceDebugData(
                    bloodData: collectedData.blood,
                    vitalData: collectedData.vital,
                    geneData: collectedData.gene,
                    timeSlot: timeSlot.rawValue,
                    timestamp: Date()
                )
            }

            // TODO: Phase 3で本番API呼び出しに切り替え
            // 現在はモックレスポンスを返す
            let response = generateMockResponse(for: timeSlot, data: collectedData)

            await MainActor.run {
                currentInsight = response
                cachedTimeSlot = timeSlot
                cachedDate = Date()
                isLoading = false
            }

            return response
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                isLoading = false
            }
            throw error
        }
    }

    /// キャッシュをクリア
    func clearCache() {
        currentInsight = nil
        cachedTimeSlot = nil
        cachedDate = nil
    }

    // MARK: - Data Collection

    /// ユーザーデータを収集（血液10 + HealthKit10 + 遺伝子5）
    func collectUserData() async -> (blood: IntelligenceBloodData?, vital: IntelligenceVitalData?, gene: IntelligenceGeneData?) {
        async let bloodData = collectBloodData()
        async let vitalData = collectVitalData()
        async let geneData = collectGeneData()

        return await (bloodData, vitalData, geneData)
    }

    /// 血液データ収集（10項目）
    private func collectBloodData() async -> IntelligenceBloodData? {
        guard let bloodData = BloodTestService.shared.bloodData else {
            return nil
        }

        let items = bloodData.bloodItems

        func findValue(_ key: String) -> Double? {
            guard let item = items.first(where: { $0.key == key }),
                  let value = Double(item.value) else {
                return nil
            }
            return value
        }

        return IntelligenceBloodData(
            hbA1c: findValue("HbA1c"),
            fpg: findValue("FPG"),
            tg: findValue("TG"),
            hdl: findValue("HDL"),
            ldl: findValue("LDL"),
            crp: findValue("CRP"),
            ferritin: findValue("Ferritin"),
            ast: findValue("AST"),
            ua: findValue("UA"),
            ins: findValue("INS")
        )
    }

    /// HealthKitデータ収集（10項目）
    private func collectVitalData() async -> IntelligenceVitalData? {
        guard let healthData = HealthKitService.shared.healthData else {
            return nil
        }

        // 睡眠データの集計
        var sleepTotal: Double = 0
        var sleepDeep: Double = 0
        var sleepRem: Double = 0

        if let sleepSamples = healthData.sleepData {
            for sample in sleepSamples {
                let hours = sample.duration / 3600.0
                switch sample.value {
                case .asleep, .core:
                    sleepTotal += hours
                case .deep:
                    sleepDeep += hours
                    sleepTotal += hours
                case .rem:
                    sleepRem += hours
                    sleepTotal += hours
                default:
                    break
                }
            }
        }

        // 直近ワークアウトの種類
        var recentWorkout: String? = nil
        if let workouts = healthData.workouts, let latest = workouts.first {
            recentWorkout = latest.workoutType.displayName
        }

        return IntelligenceVitalData(
            hrv: healthData.heartRateVariability,
            restingHeartRate: healthData.restingHeartRate,
            vo2Max: healthData.vo2Max,
            sleepTotal: sleepTotal > 0 ? sleepTotal : nil,
            sleepDeep: sleepDeep > 0 ? sleepDeep : nil,
            sleepRem: sleepRem > 0 ? sleepRem : nil,
            stepCount: healthData.stepCount,
            activeEnergyBurned: healthData.activeEnergyBurned,
            recentWorkout: recentWorkout,
            bodyMass: healthData.bodyMass
        )
    }

    /// 遺伝子データ収集（5項目）
    private func collectGeneData() async -> IntelligenceGeneData? {
        guard let geneData = GeneDataService.shared.geneData else {
            return nil
        }

        let markers = geneData.geneticMarkersWithGenotypes

        func findMarker(_ title: String) -> GeneMarkerResult? {
            // 全カテゴリーを検索
            for (_, categoryMarkers) in markers {
                if let marker = categoryMarkers.first(where: { $0.title == title }),
                   let impact = marker.cachedImpact {
                    return GeneMarkerResult(
                        score: impact.score,
                        scoreLevel: impact.scoreLevel.rawValue,
                        protective: impact.protective,
                        risk: impact.risk
                    )
                }
            }
            return nil
        }

        return IntelligenceGeneData(
            caffeine: findMarker("カフェイン代謝"),
            circadianRhythm: findMarker("概日リズム"),
            highFatDiet: findMarker("高脂肪ダイエット効果"),
            highProteinDiet: findMarker("高たんぱくダイエット効果"),
            sleepDepth: findMarker("眠りの深さ")
        )
    }

    // MARK: - Mock Response (Phase 1用)

    /// モックレスポンス生成（Phase 3で削除予定）
    private func generateMockResponse(
        for timeSlot: TimeSlot,
        data: (blood: IntelligenceBloodData?, vital: IntelligenceVitalData?, gene: IntelligenceGeneData?)
    ) -> AIInsightResponse {
        // データ参照文字列を生成
        var dataRefs: [String] = []
        if let hrv = data.vital?.hrv {
            dataRefs.append("HRV \(Int(hrv))ms")
        }
        if let sleep = data.vital?.sleepTotal {
            dataRefs.append("睡眠 \(String(format: "%.1f", sleep))h")
        }
        if let hba1c = data.blood?.hbA1c {
            dataRefs.append("HbA1c \(String(format: "%.1f", hba1c))%")
        }
        let dataReference = dataRefs.isEmpty ? "データ取得中..." : dataRefs.joined(separator: " | ")

        // 時間帯別のモックコンテンツ
        let content = getMockContent(for: timeSlot)

        return AIInsightResponse(
            timeSlot: timeSlot.rawValue,
            mainComment: content.comment,
            dataReference: dataReference,
            food: content.food,
            activity: content.activity,
            nextUpdate: timeSlot.nextUpdateTime,
            timestamp: ISO8601DateFormatter().string(from: Date())
        )
    }

    /// 時間帯別モックコンテンツ
    private func getMockContent(for timeSlot: TimeSlot) -> (comment: String, food: ActionRecommendation, activity: ActionRecommendation) {
        switch timeSlot {
        case .earlyMorning:
            return (
                comment: "おはようございます。朝の代謝が始まる時間帯です。空腹状態を活かしてケトン体を上げましょう。",
                food: ActionRecommendation(
                    icon: "☕",
                    title: "MORNING FUEL",
                    recommendation: "MCTオイル10ml + ブラックコーヒー",
                    benefit: "ケトン体0.8mmol/L↑ 認知機能向上"
                ),
                activity: ActionRecommendation(
                    icon: "🌅",
                    title: "CORTISOL SYNC",
                    recommendation: "起床後30分以内に自然光10分",
                    benefit: "コルチゾール正常化、概日リズム調整"
                )
            )
        case .morning:
            return (
                comment: "午前中は集中力がピークの時間帯。タンパク質で脳のパフォーマンスを維持しましょう。",
                food: ActionRecommendation(
                    icon: "🥚",
                    title: "PROTEIN BOOST",
                    recommendation: "卵2個 + アボカド半分",
                    benefit: "血糖値安定、午前中の集中力維持"
                ),
                activity: ActionRecommendation(
                    icon: "🏃",
                    title: "PEAK PERFORMANCE",
                    recommendation: "軽い有酸素運動20分",
                    benefit: "BDNF増加、認知機能30%向上"
                )
            )
        case .lunch:
            return (
                comment: "昼食後の血糖スパイクを抑えることが午後のパフォーマンスの鍵です。",
                food: ActionRecommendation(
                    icon: "🥗",
                    title: "GLUCOSE CONTROL",
                    recommendation: "野菜→タンパク質→炭水化物の順",
                    benefit: "血糖スパイク40%抑制"
                ),
                activity: ActionRecommendation(
                    icon: "🚶",
                    title: "POST-MEAL WALK",
                    recommendation: "食後15分のウォーキング",
                    benefit: "血糖値上昇を抑制、消化促進"
                )
            )
        case .afternoon:
            return (
                comment: "午後の眠気対策。カフェインは16時までに。水分補給を忘れずに。",
                food: ActionRecommendation(
                    icon: "🫖",
                    title: "AFTERNOON BOOST",
                    recommendation: "緑茶 + ダークチョコレート10g",
                    benefit: "カテキン+テオブロミンで穏やかな覚醒"
                ),
                activity: ActionRecommendation(
                    icon: "🧘",
                    title: "MICRO RECOVERY",
                    recommendation: "5分間の深呼吸またはストレッチ",
                    benefit: "副交感神経活性化、集中力リセット"
                )
            )
        case .evening:
            return (
                comment: "夕食は就寝3時間前までに。消化しやすいものを選びましょう。",
                food: ActionRecommendation(
                    icon: "🐟",
                    title: "OMEGA DINNER",
                    recommendation: "魚料理 + 温野菜",
                    benefit: "Omega-3で炎症抑制、睡眠の質向上"
                ),
                activity: ActionRecommendation(
                    icon: "🌙",
                    title: "WIND DOWN",
                    recommendation: "軽いストレッチ15分",
                    benefit: "副交感神経優位、睡眠準備"
                )
            )
        case .night:
            return (
                comment: "睡眠準備の時間。ブルーライトを避け、体温を下げていきましょう。",
                food: ActionRecommendation(
                    icon: "🍵",
                    title: "SLEEP PREP",
                    recommendation: "カモミールティー または マグネシウム400mg",
                    benefit: "GABA活性化、入眠潜時短縮"
                ),
                activity: ActionRecommendation(
                    icon: "📵",
                    title: "DIGITAL DETOX",
                    recommendation: "就寝1時間前からスクリーンオフ",
                    benefit: "メラトニン分泌促進"
                )
            )
        }
    }
}

