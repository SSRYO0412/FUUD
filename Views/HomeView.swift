//
//  HomeView.swift
//  AWStest
//
//  ホーム画面 - HTML版完全一致
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var cognitoService: SimpleCognitoService
    @State private var aiInsightIndex = 0

    private let aiInsights = [
        "睡眠効率が前週比12%向上。深睡眠時の成長ホルモン分泌が最適化されています...",
        "腸内細菌の多様性スコアが85点に到達。酪酸産生菌が23%増加しました...",
        "hrv朝測定値が68msに改善。自律神経バランスが最適範囲です..."
    ]

    var body: some View {
        NavigationView {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [Color(hex: "FAFAFA"), Color(hex: "F0F0F0")],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Background Orbs
                OrbBackground()

                ScrollView {
                    VStack(spacing: VirgilSpacing.lg) {
                        // Header
                        VStack(alignment: .leading, spacing: VirgilSpacing.xs) {
                            Text("TUUN")
                                .font(.system(size: 36, weight: .black))

                            Text("body operating system")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.virgilTextSecondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        // AI Core Section
                        AICoreSection(currentInsight: aiInsights[aiInsightIndex])

                        // Bio Age Card
                        BioAgeCard()

                        // Longevity Pace Card
                        LongevityPaceCard()

                        // Weekly Plan Section
                        WeeklyPlanSection()
                    }
                    .padding(.horizontal, VirgilSpacing.md)
                    .padding(.top, VirgilSpacing.lg)
                    .padding(.bottom, 100)
                }
            }
            .navigationBarHidden(true)
            .floatingChatButton()
        }
        .onAppear {
            startAIInsightRotation()
        }
    }

    private func startAIInsightRotation() {
        Timer.scheduledTimer(withTimeInterval: 8.0, repeats: true) { _ in
            withAnimation {
                aiInsightIndex = (aiInsightIndex + 1) % aiInsights.count
            }
        }
    }
}

// MARK: - AI Core Section

struct AICoreSection: View {
    let currentInsight: String

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.lg) {
            // Header
            HStack {
                Text("AI REAL-TIME INSIGHT")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.virgilTextSecondary)

                Spacer()

                Text("ANALYZING...")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(Color(hex: "0088CC"))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(hex: "0088CC").opacity(0.1))
                    .cornerRadius(4)
            }

            // Insight Text
            Text(currentInsight)
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.virgilTextPrimary)
                .lineSpacing(1.8 * 13 - 13)

            // Data Stream (簡略版)
            DataStreamView()

            // Processing Dots
            ProcessingDots()
        }
        .padding(VirgilSpacing.md)
        .virgilGlassCard()
    }
}

// MARK: - Data Stream View

struct DataStreamView: View {
    @State private var animationOffset: CGFloat = 0
    @State private var wavePhase: CGFloat = 0

    private let dataPoints = [
        "hba1c: 5.2%",
        "crp: 0.3mg/l",
        "ferritin: 95ng/ml",
        "hrv: 68ms",
        "vo2max: 42ml",
        "tg: 85mg/dl"
    ]

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .fill(Color.black.opacity(0.02))
                    .frame(height: 50)
                    .cornerRadius(8)

                // Wave Path Background
                WavePath(phase: wavePhase)
                    .stroke(Color(hex: "0088CC").opacity(0.15), lineWidth: 2)
                    .frame(height: 50)

                HStack(spacing: VirgilSpacing.lg) {
                    ForEach(dataPoints, id: \.self) { point in
                        DataPointTag(text: point)
                    }
                }
                .offset(x: animationOffset)
            }
        }
        .frame(height: 50)
        .onAppear {
            withAnimation(.linear(duration: 15).repeatForever(autoreverses: false)) {
                animationOffset = -500
            }
            withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
                wavePhase = .pi * 2
            }
        }
    }
}

// MARK: - Wave Path Shape

struct WavePath: Shape {
    var phase: CGFloat

    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width
        let height = rect.height
        let midHeight = height / 2

        path.move(to: CGPoint(x: 0, y: midHeight))

        for x in stride(from: 0, through: width, by: 1) {
            let relativeX = x / width
            let sine = sin((relativeX * .pi * 4) + phase)
            let y = midHeight + (sine * 8)
            path.addLine(to: CGPoint(x: x, y: y))
        }

        return path
    }
}

struct DataPointTag: View {
    let text: String

    var body: some View {
        Text(text)
            .font(.system(size: 7, weight: .regular))
            .foregroundColor(.virgilGray400)
    }
}

struct ProcessingDots: View {
    @State private var animationPhase = 0

    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(Color(hex: "0088CC"))
                    .frame(width: 6, height: 6)
                    .opacity(animationPhase == index ? 1.0 : 0.3)
            }
        }
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                withAnimation {
                    animationPhase = (animationPhase + 1) % 3
                }
            }
        }
    }
}

// MARK: - Bio Age Card

struct BioAgeCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            HStack {
                Text("BIOLOGICAL AGE")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.virgilTextSecondary)

                Spacer()

                Text("-6 YEARS")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(hex: "00C853"))
            }

            HStack(spacing: VirgilSpacing.xl) {
                // Current Age
                VStack(spacing: VirgilSpacing.xs) {
                    Text("実年齢")
                        .font(.system(size: 9, weight: .regular))
                        .foregroundColor(.virgilGray400)

                    Text("35")
                        .font(.system(size: 36, weight: .black))
                }

                Text("→")
                    .font(.system(size: 20, weight: .regular))
                    .foregroundColor(Color(hex: "0088CC"))
                    .opacity(0.3)

                // Bio Age
                VStack(spacing: VirgilSpacing.xs) {
                    Text("生物学的年齢")
                        .font(.system(size: 9, weight: .regular))
                        .foregroundColor(.virgilGray400)

                    Text("29")
                        .font(.system(size: 36, weight: .black))
                        .foregroundColor(Color(hex: "00C853"))
                }
            }
            .frame(maxWidth: .infinity)
        }
        .padding(VirgilSpacing.md)
        .virgilGlassCard()
    }
}

// MARK: - Longevity Pace Card

struct LongevityPaceCard: View {
    @State private var isExpanded = false

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: VirgilSpacing.md) {
                // Main Score Section
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        isExpanded.toggle()
                    }
                } label: {
                    HStack {
                        Text("LONGEVITY PACE™")
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.virgilTextSecondary)

                        Spacer()

                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.virgilTextSecondary)

                        Text("0.82")
                            .font(.system(size: 20, weight: .black))
                    }
                }

                Text("あなたの")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.virgilTextPrimary) +
                Text("Longevity Pace 0.82")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.virgilTextPrimary)

                Text("平均より")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.virgilTextSecondary) +
                Text("18%遅い")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(.virgilTextSecondary) +
                Text("老化速度")
                    .font(.system(size: 11, weight: .regular))
                    .foregroundColor(.virgilTextSecondary)

                // Expandable Data Sources
                if isExpanded {
                    Divider()
                        .background(Color.white.opacity(0.2))
                        .padding(.vertical, VirgilSpacing.xs)

                    Text("DATA SOURCES")
                        .font(.system(size: 9, weight: .semibold))
                        .foregroundColor(.virgilTextSecondary)

                    // Genes Section
                    DataSourceSection(
                        icon: "🧬",
                        title: "遺伝子",
                        items: [
                            DataSourceItem(name: "APOE ε3/ε3", value: "長寿型", impact: "+2年"),
                            DataSourceItem(name: "FOXO3 rs2802292", value: "GG型", impact: "+1.5年"),
                            DataSourceItem(name: "CETP rs708272", value: "保護型", impact: "+0.8年")
                        ]
                    )

                    // Blood Markers Section
                    DataSourceSection(
                        icon: "💉",
                        title: "血液マーカー",
                        items: [
                            DataSourceItem(name: "HbA1c", value: "5.2%", impact: "最適"),
                            DataSourceItem(name: "CRP", value: "0.3mg/L", impact: "低炎症"),
                            DataSourceItem(name: "Ferritin", value: "95ng/mL", impact: "良好")
                        ]
                    )

                    // Gut Microbiome Section
                    DataSourceSection(
                        icon: "🦠",
                        title: "腸内細菌",
                        items: [
                            DataSourceItem(name: "Faecalibacterium", value: "18.5%", impact: "優秀"),
                            DataSourceItem(name: "Akkermansia", value: "12.8%", impact: "良好"),
                            DataSourceItem(name: "多様性スコア", value: "85", impact: "高水準")
                        ]
                    )

                    // HealthKit Section
                    DataSourceSection(
                        icon: "📊",
                        title: "HealthKit",
                        items: [
                            DataSourceItem(name: "HRV", value: "68ms", impact: "優秀"),
                            DataSourceItem(name: "VO2max", value: "42ml", impact: "良好"),
                            DataSourceItem(name: "睡眠効率", value: "89%", impact: "最適")
                        ]
                    )
                }
            }
            .padding(VirgilSpacing.md)
            .virgilGlassCard()

            LongPressHint(helpText: "Longevity Paceは、あなたの老化速度を示す独自指標です。1.0が平均で、低いほど老化が遅いことを示します。")
                .padding(8)
        }
    }
}

// MARK: - Data Source Components

struct DataSourceItem {
    let name: String
    let value: String
    let impact: String
}

struct DataSourceSection: View {
    let icon: String
    let title: String
    let items: [DataSourceItem]

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            HStack(spacing: VirgilSpacing.xs) {
                Text(icon)
                    .font(.system(size: 14))

                Text(title)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.virgilTextPrimary)
            }

            VStack(spacing: VirgilSpacing.xs) {
                ForEach(items.indices, id: \.self) { index in
                    HStack {
                        Text(items[index].name)
                            .font(.system(size: 9, weight: .regular))
                            .foregroundColor(.virgilTextSecondary)

                        Spacer()

                        Text(items[index].value)
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.virgilTextPrimary)

                        Text(items[index].impact)
                            .font(.system(size: 8, weight: .medium))
                            .foregroundColor(Color(hex: "00C853"))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color(hex: "00C853").opacity(0.1))
                            .cornerRadius(4)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, VirgilSpacing.sm)
                    .background(Color.black.opacity(0.02))
                    .cornerRadius(6)
                }
            }
        }
        .padding(.top, VirgilSpacing.xs)
    }
}

// MARK: - Weekly Plan Section

private struct WeeklyPlanCardSizeKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
        if value == .zero { value = nextValue() }
    }
}

struct WeeklyPlanSection: View {
    @State private var isExpanded = false
    @State private var cardSize: CGSize = .zero

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            Text("WEEKLY PLAN")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.virgilTextSecondary)

            ZStack(alignment: .top) {
                // 7. 日曜日（最背面）
                ZStack {
                    EmptyPlanCard(size: cardSize)
                        .scaleEffect(0.88)
                        .offset(y: 20)
                        .opacity(isExpanded ? 0 : 1)
                        .blur(radius: isExpanded ? 5 : 0)
                        .animation(.spring(response: 0.55, dampingFraction: 0.825).delay(isExpanded ? 0.00 : 0.35), value: isExpanded)

                    WeeklyPlanCard(
                        day: "日曜日",
                        phase: "回復日",
                        phaseColor: Color(hex: "9C27B0"),
                        calories: "2,050 kcal",
                        protein: "154g",
                        fat: "68g",
                        carbs: "205g",
                        exercise: "軽いウォーク or ストレッチ",
                        note: "自律神経リセット"
                    )
                    .scaleEffect(isExpanded ? 1.0 : 0.91)
                    .offset(y: isExpanded ? 1080 : 20)
                    .padding(.horizontal, isExpanded ? 0 : 12)
                    .opacity(isExpanded ? 1.0 : 0)
                    .blur(radius: isExpanded ? 0 : 5)
                    .animation(.spring(response: 0.55, dampingFraction: 0.825).delay(isExpanded ? 0.00 : 0.35), value: isExpanded)
                }
                .zIndex(0)

                // 6. 土曜日
                ZStack {
                    EmptyPlanCard(size: cardSize)
                        .scaleEffect(0.90)
                        .offset(y: 20)
                        .opacity(isExpanded ? 0 : 1)
                        .blur(radius: isExpanded ? 5 : 0)
                        .animation(.spring(response: 0.55, dampingFraction: 0.825).delay(isExpanded ? 0.05 : 0.30), value: isExpanded)

                    WeeklyPlanCard(
                        day: "土曜日",
                        phase: "ロングラン日②",
                        phaseColor: Color(hex: "00C853"),
                        calories: "2,250 kcal",
                        protein: "150g",
                        fat: "90g",
                        carbs: "210g",
                        exercise: "10kmラン or 散歩＋サウナ",
                        note: "状況に応じて"
                    )
                    .scaleEffect(isExpanded ? 1.0 : 0.91)
                    .offset(y: isExpanded ? 900 : 20)
                    .padding(.horizontal, isExpanded ? 0 : 12)
                    .opacity(isExpanded ? 1.0 : 0)
                    .blur(radius: isExpanded ? 0 : 5)
                    .animation(.spring(response: 0.55, dampingFraction: 0.825).delay(isExpanded ? 0.05 : 0.30), value: isExpanded)
                }
                .zIndex(1)

                // 5. 金曜日
                ZStack {
                    EmptyPlanCard(size: cardSize)
                        .scaleEffect(0.92)
                        .offset(y: 20)
                        .opacity(isExpanded ? 0 : 1)
                        .blur(radius: isExpanded ? 5 : 0)
                        .animation(.spring(response: 0.55, dampingFraction: 0.825).delay(isExpanded ? 0.10 : 0.25), value: isExpanded)

                    WeeklyPlanCard(
                        day: "金曜日",
                        phase: "燃焼期③",
                        phaseColor: Color(hex: "0088CC"),
                        calories: "1,850 kcal",
                        protein: "139g",
                        fat: "62g",
                        carbs: "185g",
                        exercise: "筋トレ（全身 or 上半身）＋HIIT20分",
                        note: "代謝維持日"
                    )
                    .scaleEffect(isExpanded ? 1.0 : 0.91)
                    .offset(y: isExpanded ? 720 : 20)
                    .padding(.horizontal, isExpanded ? 0 : 12)
                    .opacity(isExpanded ? 1.0 : 0)
                    .blur(radius: isExpanded ? 0 : 5)
                    .animation(.spring(response: 0.55, dampingFraction: 0.825).delay(isExpanded ? 0.10 : 0.25), value: isExpanded)
                }
                .zIndex(2)

                // 4. 木曜日
                ZStack {
                    EmptyPlanCard(size: cardSize)
                        .scaleEffect(0.94)
                        .offset(y: 20)
                        .opacity(isExpanded ? 0 : 1)
                        .blur(radius: isExpanded ? 5 : 0)
                        .animation(.spring(response: 0.55, dampingFraction: 0.825).delay(isExpanded ? 0.15 : 0.20), value: isExpanded)

                    WeeklyPlanCard(
                        day: "木曜日",
                        phase: "リフィード",
                        phaseColor: Color(hex: "FFCB05"),
                        calories: "2,400 kcal",
                        protein: "150g",
                        fat: "67g",
                        carbs: "300g",
                        exercise: "休養 or 軽ウォーク",
                        note: "グリコーゲン再補充"
                    )
                    .scaleEffect(isExpanded ? 1.0 : 0.91)
                    .offset(y: isExpanded ? 540 : 20)
                    .padding(.horizontal, isExpanded ? 0 : 12)
                    .opacity(isExpanded ? 1.0 : 0)
                    .blur(radius: isExpanded ? 0 : 5)
                    .animation(.spring(response: 0.55, dampingFraction: 0.825).delay(isExpanded ? 0.15 : 0.20), value: isExpanded)
                }
                .zIndex(3)

                // 3. 水曜日
                ZStack {
                    EmptyPlanCard(size: cardSize)
                        .scaleEffect(0.96)
                        .offset(y: 10)
                        .opacity(isExpanded ? 0 : 1)
                        .blur(radius: isExpanded ? 5 : 0)
                        .animation(.spring(response: 0.55, dampingFraction: 0.825).delay(isExpanded ? 0.20 : 0.15), value: isExpanded)

                    WeeklyPlanCard(
                        day: "水曜日",
                        phase: "燃焼期②",
                        phaseColor: Color(hex: "0088CC"),
                        calories: "1,850 kcal",
                        protein: "139g",
                        fat: "62g",
                        carbs: "185g",
                        exercise: "下半身トレ",
                        note: "代謝刺激"
                    )
                    .scaleEffect(isExpanded ? 1.0 : 0.94)
                    .offset(y: isExpanded ? 360 : 10)
                    .padding(.horizontal, isExpanded ? 0 : 8)
                    .opacity(isExpanded ? 1.0 : 0)
                    .blur(radius: isExpanded ? 0 : 5)
                    .animation(.spring(response: 0.55, dampingFraction: 0.825).delay(isExpanded ? 0.20 : 0.15), value: isExpanded)
                }
                .zIndex(4)

                // 2. 火曜日
                ZStack {
                    EmptyPlanCard(size: cardSize)
                        .scaleEffect(0.98)
                        .offset(y: 3)
                        .opacity(isExpanded ? 0 : 1)
                        .blur(radius: isExpanded ? 5 : 0)
                        .animation(.spring(response: 0.55, dampingFraction: 0.825).delay(isExpanded ? 0.25 : 0.10), value: isExpanded)

                    WeeklyPlanCard(
                        day: "火曜日",
                        phase: "ロングラン日①",
                        phaseColor: Color(hex: "00C853"),
                        calories: "2,200 kcal",
                        protein: "150g",
                        fat: "80g",
                        carbs: "220g",
                        exercise: "10kmラン",
                        note: "炭水化物200〜230gで筋分解防止"
                    )
                    .scaleEffect(isExpanded ? 1.0 : 0.97)
                    .offset(y: isExpanded ? 180 : 3)
                    .padding(.horizontal, isExpanded ? 0 : 4)
                    .opacity(isExpanded ? 1.0 : 0)
                    .blur(radius: isExpanded ? 0 : 5)
                    .animation(.spring(response: 0.55, dampingFraction: 0.825).delay(isExpanded ? 0.25 : 0.10), value: isExpanded)
                }
                .zIndex(5)

                // 1. 月曜日（最前面・固定）
                WeeklyPlanCard(
                    day: "月曜日",
                    phase: "燃焼期①",
                    phaseColor: Color(hex: "0088CC"),
                    calories: "1,850 kcal",
                    protein: "139g",
                    fat: "62g",
                    carbs: "185g",
                    exercise: "筋トレ（上半身）＋有酸素5km",
                    note: "通常燃焼日"
                )
                .background(
                    GeometryReader { proxy in
                        Color.clear.preference(key: WeeklyPlanCardSizeKey.self, value: proxy.size)
                    }
                )
                .offset(y: 0)
                .animation(.spring(response: 0.55, dampingFraction: 0.825).delay(isExpanded ? 0.30 : 0.05), value: isExpanded)
                .zIndex(6)
            }
            .onTapGesture {
                isExpanded.toggle()
            }
            .onPreferenceChange(WeeklyPlanCardSizeKey.self) { size in
                cardSize = size
            }

            // 展開時のスクロール用スペース確保
            Spacer()
                .frame(height: isExpanded ? 1080 : 0)
                .animation(.spring(response: 0.55, dampingFraction: 0.825).delay(isExpanded ? 0.35 : 0.00), value: isExpanded)
        }
    }
}

// MARK: - Weekly Plan Card

struct WeeklyPlanCard: View {
    let day: String
    let phase: String
    let phaseColor: Color
    let calories: String
    let protein: String
    let fat: String
    let carbs: String
    let exercise: String
    let note: String

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            HStack {
                Text(day)
                    .font(.system(size: 14, weight: .bold))

                Spacer()

                Text(phase)
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(phaseColor)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(phaseColor.opacity(0.1))
                    .cornerRadius(4)
            }

            Text(calories)
                .font(.system(size: 20, weight: .black))

            HStack(spacing: VirgilSpacing.md) {
                PFCBadge(label: "P", value: protein)
                PFCBadge(label: "F", value: fat)
                PFCBadge(label: "C", value: carbs)
            }

            Text(exercise)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.virgilTextPrimary)

                Text(note)
                    .font(.system(size: 9, weight: .regular))
                    .foregroundColor(.virgilTextSecondary)
            }
            .padding(VirgilSpacing.md)
            .virgilGlassCard()

            LongPressHint(helpText: "\(day)の栄養プランと運動メニューです。体調に合わせて調整できます。")
                .padding(6)
        }
    }
}

struct PFCBadge: View {
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(.virgilTextSecondary)

            Text(value)
                .font(.system(size: 11, weight: .bold))
        }
    }
}

// MARK: - Empty Plan Card (Placeholder)

private struct EmptyPlanCard: View {
    let size: CGSize

    var body: some View {
        let fallbackWidth: CGFloat = 350
        let fallbackHeight: CGFloat = 180
        let actualWidth = size.width > 0 ? size.width : fallbackWidth
        let actualHeight = size.height > 0 ? size.height : fallbackHeight

        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(.clear)
            .frame(width: actualWidth, height: actualHeight)
            .background(.ultraThinMaterial)
            .mask(
                VStack(spacing: 0) {
                    Spacer()
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .frame(height: max(actualHeight * 0.35, 40))
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.6),
                                Color.white.opacity(0.25)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        lineWidth: 0.5
                    )
            )
            .shadow(color: Color.black.opacity(0.12), radius: 2, x: 0, y: 1)
            .allowsHitTesting(false)
    }
}

// MARK: - Preview

#if DEBUG
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .environmentObject(SimpleCognitoService.shared)
    }
}
#endif
