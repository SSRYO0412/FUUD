//
//  TodayProgramViewModel.swift
//  FUUD
//
//  今日のプログラム画面用ViewModel
//  Phase 6-UI: TodayProgramView用
//

import Foundation
import Combine

// MARK: - Today Checklist Item

struct TodayChecklistItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    var isCompleted: Bool

    static let defaultItems: [TodayChecklistItem] = [
        TodayChecklistItem(title: "タンパク質を毎食20g以上", icon: "fork.knife", isCompleted: false),
        TodayChecklistItem(title: "野菜を毎食取り入れる", icon: "leaf.fill", isCompleted: false),
        TodayChecklistItem(title: "水分を2L以上摂取", icon: "drop.fill", isCompleted: false),
        TodayChecklistItem(title: "間食は予定通り", icon: "clock.fill", isCompleted: false)
    ]
}

// MARK: - TodayProgramViewModel

@MainActor
class TodayProgramViewModel: ObservableObject {

    // MARK: - Published Properties

    /// 登録中のプログラム
    @Published var enrollment: ProgramEnrollment?

    /// プログラム詳細
    @Published var program: DietProgram?

    /// 現在のフェーズ
    @Published var currentPhase: ProgramPhase?

    /// 朝の問診データ（旧：睡眠・エネルギー・食欲）
    @Published var dayContext: DayContext = .empty

    /// 朝の問診データ（新：食事予定・運動予定）
    @Published var morningPlan: MorningPlan = MorningPlan.loadToday() ?? .empty

    /// 食事プラン
    @Published var mealPlan: DailyMealPlan?

    /// チェックリスト
    @Published var checklist: [TodayChecklistItem] = TodayChecklistItem.defaultItems

    /// ローディング状態
    @Published var isLoading = false

    /// エラーメッセージ
    @Published var errorMessage: String?

    // MARK: - Dependencies

    private let programService = DietProgramService.shared
    private let nutritionPersonalizer = NutritionPersonalizer.shared
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Computed Properties

    /// 現在の日数
    var currentDay: Int {
        enrollment?.currentDay ?? 1
    }

    /// 総期間
    var totalDays: Int {
        enrollment?.duration ?? 45
    }

    /// 現在の週
    var currentWeek: Int {
        enrollment?.currentWeek ?? 1
    }

    /// 進捗率
    var progressPercentage: Double {
        enrollment?.progressPercentage ?? 0
    }

    /// 残り日数
    var daysRemaining: Int {
        enrollment?.daysRemaining ?? totalDays
    }

    /// 調整後カロリー
    var targetCalories: Int {
        let baseCalories = nutritionPersonalizer.adjustedCalories?.adjustedTarget ?? 2100
        let phaseMultiplier = currentPhase?.calorieMultiplier ?? 1.0
        let dayMultiplier = dayContext.calorieMultiplier
        return Int(Double(baseCalories) * phaseMultiplier * dayMultiplier)
    }

    /// PFC（現在のフェーズで上書きがあればそれを使用）
    var currentPFC: PFCRatio {
        currentPhase?.pfcOverride ?? program?.basePFC ?? .balanced
    }

    /// タンパク質（g）
    var proteinGrams: Int {
        Int(Double(targetCalories) * currentPFC.protein / 100 / 4)
    }

    /// 脂質（g）
    var fatGrams: Int {
        Int(Double(targetCalories) * currentPFC.fat / 100 / 9)
    }

    /// 糖質（g）
    var carbsGrams: Int {
        Int(Double(targetCalories) * currentPFC.carbs / 100 / 4)
    }

    /// 朝の問診が完了しているか
    var hasMorningCheckIn: Bool {
        !morningPlan.isEmpty
    }

    /// フォーカスプランがあるか
    var hasFocusPlan: Bool {
        program?.layer == .focus || program?.canStackWithFocus == true
    }

    /// チェックリストの完了数
    var completedChecklistCount: Int {
        checklist.filter { $0.isCompleted }.count
    }

    /// チェックリストの合計数
    var totalChecklistCount: Int {
        checklist.count
    }

    // MARK: - Initialization

    init() {
        setupBindings()
    }

    private func setupBindings() {
        // ProgramServiceの変更を監視
        programService.$enrolledProgram
            .sink { [weak self] enrollment in
                self?.enrollment = enrollment
                if let enrollment = enrollment {
                    self?.loadProgram(for: enrollment)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Data Loading

    /// すべてのデータを読み込む
    func loadAllData() async {
        isLoading = true
        errorMessage = nil

        // 登録中のプログラムを取得
        await programService.fetchEnrolledProgram()

        // 栄養パーソナライズを計算
        await nutritionPersonalizer.calculatePersonalization()

        // プログラム情報をセット
        if let enrollment = programService.enrolledProgram {
            self.enrollment = enrollment
            loadProgram(for: enrollment)
        }

        // 食事プランを生成
        generateMealPlan()

        // チェックリストをプログラムに合わせて更新
        updateChecklist()

        isLoading = false
    }

    /// プログラム詳細を読み込む
    private func loadProgram(for enrollment: ProgramEnrollment) {
        program = programService.getProgram(by: enrollment.programId)
        currentPhase = programService.getCurrentPhase(for: enrollment)
    }

    /// 食事プランを生成
    func generateMealPlan() {
        mealPlan = MealRecommendationGenerator.generate(
            targetCalories: targetCalories,
            pfc: PFCBalance(
                protein: currentPFC.protein,
                fat: currentPFC.fat,
                carbs: currentPFC.carbs
            ),
            program: program,
            dayContext: dayContext
        )
    }

    // MARK: - Day Context

    /// 朝の問診を更新（旧：DayContext）
    func updateDayContext(_ context: DayContext) {
        dayContext = context
        // 問診データに基づいて食事プランを再生成
        generateMealPlan()
    }

    /// 朝の問診を更新（新：MorningPlan）
    func updateMorningPlan(_ plan: MorningPlan) {
        morningPlan = plan
        // 問診データに基づいて食事プランを再生成
        generateMealPlan()
    }

    // MARK: - Checklist

    /// チェックリストをプログラムに合わせて更新
    private func updateChecklist() {
        var items = TodayChecklistItem.defaultItems

        // プログラムカテゴリに基づいてカスタマイズ
        if let category = program?.category {
            switch category {
            case .fasting:
                items = [
                    TodayChecklistItem(title: "断食時間を守る（16時間）", icon: "clock.fill", isCompleted: false),
                    TodayChecklistItem(title: "食事ウィンドウ内で食べる", icon: "fork.knife", isCompleted: false),
                    TodayChecklistItem(title: "水分を2L以上摂取", icon: "drop.fill", isCompleted: false),
                    TodayChecklistItem(title: "空腹時に軽い運動", icon: "figure.walk", isCompleted: false)
                ]
            case .highProtein:
                items = [
                    TodayChecklistItem(title: "タンパク質を毎食30g以上", icon: "fork.knife", isCompleted: false),
                    TodayChecklistItem(title: "運動後30分以内にタンパク質", icon: "figure.strengthtraining.traditional", isCompleted: false),
                    TodayChecklistItem(title: "野菜を毎食取り入れる", icon: "leaf.fill", isCompleted: false),
                    TodayChecklistItem(title: "水分を2.5L以上摂取", icon: "drop.fill", isCompleted: false)
                ]
            case .lowCarb:
                items = [
                    TodayChecklistItem(title: "糖質を1食20g以下に", icon: "chart.pie.fill", isCompleted: false),
                    TodayChecklistItem(title: "良質な脂質を摂取", icon: "drop.fill", isCompleted: false),
                    TodayChecklistItem(title: "野菜は葉物中心に", icon: "leaf.fill", isCompleted: false),
                    TodayChecklistItem(title: "電解質を意識的に摂取", icon: "bolt.fill", isCompleted: false)
                ]
            case .biohacking:
                items = [
                    TodayChecklistItem(title: "MCTオイルを摂取", icon: "drop.fill", isCompleted: false),
                    TodayChecklistItem(title: "抗炎症食品を取り入れる", icon: "flame.fill", isCompleted: false),
                    TodayChecklistItem(title: "発酵食品を1食以上", icon: "leaf.fill", isCompleted: false),
                    TodayChecklistItem(title: "睡眠8時間を確保", icon: "moon.zzz.fill", isCompleted: false)
                ]
            case .balanced:
                break // デフォルトを使用
            }
        }

        checklist = items
    }

    /// チェックリストのアイテムをトグル
    func toggleChecklistItem(_ item: TodayChecklistItem) {
        if let index = checklist.firstIndex(where: { $0.id == item.id }) {
            checklist[index].isCompleted.toggle()
        }
    }

    // MARK: - Actions

    /// プログラムをキャンセル
    func cancelProgram() async -> Bool {
        return await programService.cancelEnrollment()
    }
}

// MARK: - Preview Helper

extension TodayProgramViewModel {
    /// プレビュー用のデモデータをセット
    func setupDemoData() {
        programService.createDemoEnrollment()
        enrollment = programService.enrolledProgram
        if let enrollment = enrollment {
            loadProgram(for: enrollment)
        }
        generateMealPlan()
        updateChecklist()
    }
}
