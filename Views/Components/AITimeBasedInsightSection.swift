//
//  AITimeBasedInsightSection.swift
//  TUUN
//
//  時間帯別AIインサイトセクション
//  血液検査結果とバイタルデータをもとに、3-4時間ごとにAIがコメントと
//  食事・運動アクションプランを提示
//

import SwiftUI

// MARK: - Time Slot Definition

enum TimeSlot: String, CaseIterable {
    case earlyMorning = "earlyMorning"  // 5:00-8:00
    case morning = "morning"             // 8:00-12:00
    case lunch = "lunch"                 // 12:00-14:00
    case afternoon = "afternoon"         // 14:00-18:00
    case evening = "evening"             // 18:00-21:00
    case night = "night"                 // 21:00-5:00

    var title: String {
        switch self {
        case .earlyMorning: return "朝の目覚め"
        case .morning: return "午前の活動期"
        case .lunch: return "昼食後"
        case .afternoon: return "午後の低迷期"
        case .evening: return "夕方〜夜"
        case .night: return "夜間・睡眠準備"
        }
    }

    static func current() -> TimeSlot {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<8: return .earlyMorning
        case 8..<12: return .morning
        case 12..<14: return .lunch
        case 14..<18: return .afternoon
        case 18..<21: return .evening
        default: return .night
        }
    }
}

// MARK: - AI Insight Data Model (Legacy - for fallback)

struct AIInsightData {
    let timeSlot: TimeSlot
    let mainComment: String
    let dataReference: String
    let foodIcon: String
    let foodTitle: String
    let foodRecommendation: String
    let foodBenefit: String
    let activityIcon: String
    let activityTitle: String
    let activityRecommendation: String
    let activityBenefit: String
}

// MARK: - Demo Data (Fallback)

struct AIInsightDemoData {
    // [DUMMY] フォールバック用デモデータ
    static let insights: [TimeSlot: AIInsightData] = [
        .earlyMorning: AIInsightData(
            timeSlot: .earlyMorning,
            mainComment: "おはようございます。朝の代謝が始まる時間帯です。空腹時血糖値が安定している今、身体は脂肪燃焼モードに入りやすい状態です。",
            dataReference: "HbA1c 5.4% | 空腹時血糖 95mg/dL | HRV 68ms",
            foodIcon: "🧪",
            foodTitle: "MORNING PROTOCOL",
            foodRecommendation: "MCTオイル 10ml + ブラックコーヒー 200ml",
            foodBenefit: "ケトン体 0.8mmol/L↑ | オートファジー促進",
            activityIcon: "🌅",
            activityTitle: "CORTISOL SYNC",
            activityRecommendation: "起床後30分以内に自然光10分 + 冷水シャワー30秒",
            activityBenefit: "コルチゾール覚醒反応 +40% | 体内時計リセット"
        ),
        .morning: AIInsightData(
            timeSlot: .morning,
            mainComment: "午前中は代謝が最も活発な時間帯です。HRV 68msは良好で、今日の体調は万全です。集中力を維持しながら活動できる最適な時間です。",
            dataReference: "HRV 68ms | RHR 58bpm | 代謝力 85%",
            foodIcon: "💧",
            foodTitle: "HYDRATION STACK",
            foodRecommendation: "水500ml + 電解質（Na 1g, K 200mg, Mg 100mg）",
            foodBenefit: "認知機能維持 | 代謝効率 +15%",
            activityIcon: "🏋️",
            activityTitle: "PEAK PERFORMANCE WINDOW",
            activityRecommendation: "HIIT 20分 or レジスタンストレーニング",
            activityBenefit: "テストステロン +25% | BDNF産生 +300%"
        ),
        .lunch: AIInsightData(
            timeSlot: .lunch,
            mainComment: "昼食後の血糖値管理が重要な時間帯です。食後の血糖スパイクを抑えることで、午後のエネルギーを安定させましょう。",
            dataReference: "HbA1c 5.4% | TG 92mg/dL | 炎症レベル 正常",
            foodIcon: "🥗",
            foodTitle: "GLYCEMIC CONTROL",
            foodRecommendation: "食物繊維→タンパク質→炭水化物の順序で摂取",
            foodBenefit: "血糖スパイク -50% | インスリン感受性最適化",
            activityIcon: "🚶",
            activityTitle: "POST-MEAL PROTOCOL",
            activityRecommendation: "食後10分ウォーキング（100歩/分）",
            activityBenefit: "食後血糖値 -30% | 消化酵素活性化"
        ),
        .afternoon: AIInsightData(
            timeSlot: .afternoon,
            mainComment: "午後のエネルギー低下期に入りました。HbA1c 5.4%の血糖コントロールは良好ですが、この時間帯は自然と血糖値が下がりやすい傾向があります。",
            dataReference: "HbA1c 5.4% | HDL 65mg/dL | 回復力 71%",
            foodIcon: "🧪",
            foodTitle: "AFTERNOON STACK",
            foodRecommendation: "L-テアニン 200mg + カカオニブ 15g + MCT 5ml",
            foodBenefit: "α波増加 | ドーパミン最適化 | ケトン体 0.5mmol/L↑",
            activityIcon: "⚡",
            activityTitle: "METABOLIC REBOOT",
            activityRecommendation: "階段昇降5分 or スクワット20回",
            activityBenefit: "GLUT4発現↑ | 午後の眠気 -60%"
        ),
        .evening: AIInsightData(
            timeSlot: .evening,
            mainComment: "1日の活動が終わりに近づいています。夕食は回復と翌日の準備のために重要です。消化に負担をかけない食事を心がけましょう。",
            dataReference: "本日の歩数 8,500歩 | 消費Cal 420kcal | HRV 65ms",
            foodIcon: "🐟",
            foodTitle: "RECOVERY NUTRITION",
            foodRecommendation: "オメガ3 2g + グリシン 3g + 高タンパク食",
            foodBenefit: "炎症マーカー↓ | 筋タンパク合成 +25%",
            activityIcon: "🧘",
            activityTitle: "PARASYMPATHETIC ACTIVATION",
            activityRecommendation: "4-7-8呼吸法 × 4サイクル + ストレッチ10分",
            activityBenefit: "HRV +15% | コルチゾール -30%"
        ),
        .night: AIInsightData(
            timeSlot: .night,
            mainComment: "睡眠準備の時間です。質の高い睡眠は、明日のパフォーマンスと長期的な健康に直結します。ブルーライトを避け、リラックスモードに入りましょう。",
            dataReference: "睡眠効率 86% | 深睡眠 90分 | HRV夜間平均 72ms",
            foodIcon: "🍵",
            foodTitle: "SLEEP OPTIMIZATION",
            foodRecommendation: "Mg glycinate 400mg + アシュワガンダ 300mg",
            foodBenefit: "入眠潜時 -40% | 深睡眠 +20%",
            activityIcon: "😴",
            activityTitle: "CIRCADIAN PROTOCOL",
            activityRecommendation: "室温18℃ | ブルーライトカット | 22:00就寝",
            activityBenefit: "メラトニン分泌↑ | 成長ホルモン +60%"
        )
    ]

    static func getInsight(for timeSlot: TimeSlot) -> AIInsightData {
        return insights[timeSlot] ?? insights[.afternoon]!
    }
}

// MARK: - Main View

struct AITimeBasedInsightSection: View {
    @StateObject private var intelligenceService = TuuningIntelligenceService.shared
    @State private var currentTimeSlot: TimeSlot = TimeSlot.current()
    @State private var currentTime: String = ""
    @State private var previousTimeSlot: TimeSlot? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            // Header
            HStack {
                HStack(spacing: VirgilSpacing.xs) {
                    Text("🧠")
                        .font(.system(size: 14))
                    Text("TUUNING INTELLIGENCE")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)
                }

                Spacer()

                if intelligenceService.isLoading {
                    ProgressView()
                        .scaleEffect(0.7)
                } else {
                    Text("\(currentTime) 更新")
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(Color(hex: "0088CC"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color(hex: "0088CC").opacity(0.1))
                        .cornerRadius(4)
                }
            }

            // Content based on API response or fallback
            if let insight = intelligenceService.currentInsight {
                // API Response Content
                Text(insight.mainComment)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.virgilTextPrimary)
                    .lineSpacing(4)

                Text(insight.dataReference)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.virgilTextSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.03))
                    .cornerRadius(6)

                // Food Recommendation Card
                AIInsightActionCard(
                    icon: insight.food.icon,
                    title: insight.food.title,
                    recommendation: insight.food.recommendation,
                    benefit: insight.food.benefit,
                    accentColor: Color(hex: "00C853")
                )

                // Activity Recommendation Card
                AIInsightActionCard(
                    icon: insight.activity.icon,
                    title: insight.activity.title,
                    recommendation: insight.activity.recommendation,
                    benefit: insight.activity.benefit,
                    accentColor: Color(hex: "0088CC")
                )

                // Next Update
                HStack {
                    Spacer()
                    Text("次の更新: \(insight.nextUpdate)")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.virgilTextSecondary)
                    Spacer()
                }
                .padding(.top, VirgilSpacing.xs)
            } else {
                // Fallback to Demo Data
                let demoInsight = AIInsightDemoData.getInsight(for: currentTimeSlot)

                Text(demoInsight.mainComment)
                    .font(.system(size: 13, weight: .regular))
                    .foregroundColor(.virgilTextPrimary)
                    .lineSpacing(4)

                Text(demoInsight.dataReference)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.virgilTextSecondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 6)
                    .background(Color.black.opacity(0.03))
                    .cornerRadius(6)

                AIInsightActionCard(
                    icon: demoInsight.foodIcon,
                    title: demoInsight.foodTitle,
                    recommendation: demoInsight.foodRecommendation,
                    benefit: demoInsight.foodBenefit,
                    accentColor: Color(hex: "00C853")
                )

                AIInsightActionCard(
                    icon: demoInsight.activityIcon,
                    title: demoInsight.activityTitle,
                    recommendation: demoInsight.activityRecommendation,
                    benefit: demoInsight.activityBenefit,
                    accentColor: Color(hex: "0088CC")
                )

                HStack {
                    Spacer()
                    Text("次の更新: \(demoInsight.timeSlot.nextUpdateTime)")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.virgilTextSecondary)
                    Spacer()
                }
                .padding(.top, VirgilSpacing.xs)
            }
        }
        .padding(VirgilSpacing.md)
        .liquidGlassCard()
        .onAppear {
            updateCurrentTime()
            currentTimeSlot = TimeSlot.current()
            fetchInsightIfNeeded()
        }
        .onChange(of: currentTimeSlot) { newTimeSlot in
            // 時間帯が変わったら再取得
            if previousTimeSlot != newTimeSlot {
                previousTimeSlot = newTimeSlot
                fetchInsightIfNeeded()
            }
        }
    }

    private func updateCurrentTime() {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        currentTime = formatter.string(from: Date())
    }

    private func fetchInsightIfNeeded() {
        Task {
            do {
                _ = try await intelligenceService.fetchInsight(for: currentTimeSlot)
                await MainActor.run {
                    updateCurrentTime()
                }
            } catch {
                print("[AITimeBasedInsightSection] Error fetching insight: \(error)")
                // エラー時はデモデータにフォールバック（自動的に表示される）
            }
        }
    }
}

// MARK: - AI Insight Action Card Component

private struct AIInsightActionCard: View {
    let icon: String
    let title: String
    let recommendation: String
    let benefit: String
    let accentColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.xs) {
            HStack(spacing: VirgilSpacing.xs) {
                Text(icon)
                    .font(.system(size: 14))
                Text(title)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.virgilTextPrimary)
            }

            Text(recommendation)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.virgilTextPrimary)

            HStack(spacing: 4) {
                Text("→")
                    .font(.system(size: 10))
                    .foregroundColor(accentColor)
                Text(benefit)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(accentColor)
            }
        }
        .padding(VirgilSpacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.02))
        .cornerRadius(8)
    }
}

// MARK: - Preview

#if DEBUG
struct AITimeBasedInsightSection_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(.secondarySystemBackground)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    AITimeBasedInsightSection()
                }
                .padding()
            }
        }
    }
}
#endif
