//
//  DietProgram.swift
//  FUUD
//
//  Diet Program models for v1 implementation
//

import Foundation

// MARK: - Program Layer

enum ProgramLayer: String, Codable, CaseIterable {
    case base          // 1日の総カロリー/PFC・食事スタイルを決めるベースプラン
    case timing        // 断食・5:2・6:1など「いつ食べるか」を決める時間ルール
    case focus         // 炎症・腸・脳・ホルモン・長寿などのフォーカス
    case calibration   // キャリブレーション（前座フェーズ）

    var displayNameJa: String {
        switch self {
        case .base: return "ベース"
        case .timing: return "タイミング"
        case .focus: return "フォーカス"
        case .calibration: return "キャリブレーション"
        }
    }

    var displayNameEn: String {
        switch self {
        case .base: return "Base"
        case .timing: return "Timing"
        case .focus: return "Focus"
        case .calibration: return "Calibration"
        }
    }
}

// MARK: - Program Category

enum ProgramCategory: String, Codable, CaseIterable, Identifiable {
    case biohacking = "BIOHACKING"
    case balanced = "BALANCED"
    case fasting = "FASTING"
    case highProtein = "HIGH_PROTEIN"
    case lowCarb = "LOW_CARB"

    var id: String { rawValue }

    var displayNameJa: String {
        switch self {
        case .biohacking: return "バイオハッキング"
        case .balanced: return "バランス"
        case .fasting: return "ファスティング"
        case .highProtein: return "高タンパク"
        case .lowCarb: return "低糖質"
        }
    }

    var displayNameEn: String {
        switch self {
        case .biohacking: return "Biohacking"
        case .balanced: return "Balanced"
        case .fasting: return "Fasting"
        case .highProtein: return "High Protein"
        case .lowCarb: return "Low Carb"
        }
    }

    var iconName: String {
        switch self {
        case .biohacking: return "brain.head.profile"
        case .balanced: return "scale.3d"
        case .fasting: return "clock.arrow.circlepath"
        case .highProtein: return "figure.strengthtraining.traditional"
        case .lowCarb: return "leaf.fill"
        }
    }
}

// MARK: - Program Difficulty

enum ProgramDifficulty: String, Codable, CaseIterable {
    case beginner = "beginner"
    case intermediate = "intermediate"
    case advanced = "advanced"

    var displayNameJa: String {
        switch self {
        case .beginner: return "初心者向け"
        case .intermediate: return "中級者向け"
        case .advanced: return "上級者向け"
        }
    }

    var displayNameEn: String {
        switch self {
        case .beginner: return "Beginner"
        case .intermediate: return "Intermediate"
        case .advanced: return "Advanced"
        }
    }
}

// MARK: - Goal Type

enum GoalType: String, Codable, CaseIterable {
    case lose = "lose"
    case maintain = "maintain"
    case gain = "gain"

    var displayNameJa: String {
        switch self {
        case .lose: return "減量"
        case .maintain: return "維持"
        case .gain: return "増量"
        }
    }

    var displayNameEn: String {
        switch self {
        case .lose: return "Lose Weight"
        case .maintain: return "Maintain"
        case .gain: return "Gain Weight"
        }
    }
}

// MARK: - PFC Ratio

struct PFCRatio: Codable, Equatable {
    let protein: Double  // percentage (0-100)
    let fat: Double      // percentage (0-100)
    let carbs: Double    // percentage (0-100)

    var isValid: Bool {
        abs(protein + fat + carbs - 100) < 0.1
    }

    static let balanced = PFCRatio(protein: 25, fat: 30, carbs: 45)
    static let highProtein = PFCRatio(protein: 35, fat: 30, carbs: 35)
    static let lowCarb = PFCRatio(protein: 30, fat: 45, carbs: 25)
    static let keto = PFCRatio(protein: 25, fat: 70, carbs: 5)
}

// MARK: - Program Phase

struct ProgramPhase: Codable, Identifiable {
    let id: String
    let weekNumber: Int
    let name: String
    let nameEn: String
    let description: String
    let focusPoints: [String]
    let calorieMultiplier: Double  // 1.0 = TDEE, 0.8 = -20% deficit
    let pfcOverride: PFCRatio?

    init(
        id: String,
        weekNumber: Int,
        name: String,
        nameEn: String = "",
        description: String = "",
        focusPoints: [String] = [],
        calorieMultiplier: Double = 1.0,
        pfcOverride: PFCRatio? = nil
    ) {
        self.id = id
        self.weekNumber = weekNumber
        self.name = name
        self.nameEn = nameEn.isEmpty ? name : nameEn
        self.description = description
        self.focusPoints = focusPoints
        self.calorieMultiplier = calorieMultiplier
        self.pfcOverride = pfcOverride
    }
}

// MARK: - Sample Meal

struct SampleMeal: Codable, Identifiable {
    let id: String
    let mealType: MealType
    let name: String
    let nameEn: String
    let calories: Int
    let protein: Double
    let fat: Double
    let carbs: Double
    let imageURL: String?

    enum MealType: String, Codable {
        case breakfast = "breakfast"
        case lunch = "lunch"
        case dinner = "dinner"
        case snack = "snack"

        var displayNameJa: String {
            switch self {
            case .breakfast: return "朝食"
            case .lunch: return "昼食"
            case .dinner: return "夕食"
            case .snack: return "間食"
            }
        }

        var displayNameEn: String {
            switch self {
            case .breakfast: return "Breakfast"
            case .lunch: return "Lunch"
            case .dinner: return "Dinner"
            case .snack: return "Snack"
            }
        }
    }
}

// MARK: - Contraindication

struct Contraindication: Codable {
    let condition: String       // e.g., "diabetes_type1"
    let severity: Severity
    let message: String

    enum Severity: String, Codable {
        case warning = "warning"     // 注意が必要
        case prohibited = "prohibited" // 禁忌
    }
}

// MARK: - Recommend Condition

struct RecommendCondition: Codable {
    let biomarker: String      // e.g., "HbA1c", "LDL", "triglycerides"
    let condition: Condition
    let threshold: Double
    let scoreBoost: Int        // このプログラムのスコアをブースト

    enum Condition: String, Codable {
        case above = "above"
        case below = "below"
        case between = "between"
    }
}

// MARK: - Diet Program

struct DietProgram: Codable, Identifiable {
    let id: String
    let nameJa: String
    let nameEn: String
    let category: ProgramCategory
    let description: String
    let descriptionEn: String
    let difficulty: ProgramDifficulty
    let targetGoal: GoalType
    let deficitIntensity: Double  // 0 = maintenance, 0.1 = -10%, 0.2 = -20%
    let basePFC: PFCRatio
    let phases: [ProgramPhase]
    let sampleMeals: [SampleMeal]
    let contraindications: [Contraindication]
    let recommendConditions: [RecommendCondition]
    let tags: [String]
    let features: [String]           // 特徴（箇条書き）
    let expectedResults: [String]    // 期待できる効果
    let imageURL: String?
    var expertQuote: String?         // 栄養チームからの引用コメント

    // MARK: - Layer System (Phase 6)
    let layer: ProgramLayer                  // Base/Timing/Focus/Calibration
    let canStackWithFasting: Bool            // Timing(Fasting)と併用可能か
    let canStackWithFocus: Bool              // Focusプランを重ねてOKか

    /// Asset name for program image (e.g., "program-metabolic-reset")
    var imageAssetName: String {
        "program-\(id)"
    }

    // Custom initializer with default expertQuote and layer properties
    init(
        id: String,
        nameJa: String,
        nameEn: String,
        category: ProgramCategory,
        description: String,
        descriptionEn: String,
        difficulty: ProgramDifficulty,
        targetGoal: GoalType,
        deficitIntensity: Double,
        basePFC: PFCRatio,
        phases: [ProgramPhase],
        sampleMeals: [SampleMeal],
        contraindications: [Contraindication],
        recommendConditions: [RecommendCondition],
        tags: [String],
        features: [String],
        expectedResults: [String],
        imageURL: String?,
        expertQuote: String? = nil,
        layer: ProgramLayer,
        canStackWithFasting: Bool,
        canStackWithFocus: Bool
    ) {
        self.id = id
        self.nameJa = nameJa
        self.nameEn = nameEn
        self.category = category
        self.description = description
        self.descriptionEn = descriptionEn
        self.difficulty = difficulty
        self.targetGoal = targetGoal
        self.deficitIntensity = deficitIntensity
        self.basePFC = basePFC
        self.phases = phases
        self.sampleMeals = sampleMeals
        self.contraindications = contraindications
        self.recommendConditions = recommendConditions
        self.tags = tags
        self.features = features
        self.expectedResults = expectedResults
        self.imageURL = imageURL
        self.expertQuote = expertQuote
        self.layer = layer
        self.canStackWithFasting = canStackWithFasting
        self.canStackWithFocus = canStackWithFocus
    }

    // Computed properties
    var defaultDurations: [Int] {
        [30, 45, 90]  // days
    }

    var estimatedCalorieReduction: Int {
        Int(deficitIntensity * 2000)  // 仮のTDEE 2000kcal基準
    }
}

// MARK: - Enrollment Status

enum EnrollmentStatus: String, Codable {
    case active = "active"
    case paused = "paused"
    case completed = "completed"
    case cancelled = "cancelled"
}

// MARK: - Program Enrollment

struct ProgramEnrollment: Codable, Identifiable {
    let id: String
    let userId: String
    let programId: String
    let duration: Int           // 30, 45, 90 days
    let startDate: String       // ISO8601
    let endDate: String         // ISO8601
    let status: EnrollmentStatus
    let enrolledAt: String      // ISO8601

    // Computed properties for progress tracking
    var startDateParsed: Date? {
        ISO8601DateFormatter().date(from: startDate)
    }

    var endDateParsed: Date? {
        ISO8601DateFormatter().date(from: endDate)
    }

    var currentDay: Int {
        guard let start = startDateParsed else { return 0 }
        let days = Calendar.current.dateComponents([.day], from: start, to: Date()).day ?? 0
        return max(0, min(days + 1, duration))  // Day 1 based
    }

    var currentWeek: Int {
        (currentDay - 1) / 7 + 1
    }

    var progressPercentage: Double {
        Double(currentDay) / Double(duration) * 100
    }

    var isActive: Bool {
        status == .active
    }

    var daysRemaining: Int {
        max(0, duration - currentDay)
    }
}

// MARK: - Enrollment Response

struct EnrollmentResponse: Codable {
    let enrollment: ProgramEnrollment
    let message: String?
}

// MARK: - Roadmap Week (Client-side computed)

struct RoadmapWeek: Identifiable {
    let id: String
    let weekNumber: Int
    let startDate: Date
    let endDate: Date
    let phaseName: String
    let phaseNameEn: String
    let focusPoints: [String]
    let calorieMultiplier: Double
    let pfcOverride: PFCRatio?

    var isCurrentWeek: Bool {
        let now = Date()
        return startDate <= now && now <= endDate
    }

    var isPast: Bool {
        endDate < Date()
    }

    var isFuture: Bool {
        startDate > Date()
    }

    init(
        weekNumber: Int,
        startDate: Date,
        phaseName: String,
        phaseNameEn: String = "",
        focusPoints: [String],
        calorieMultiplier: Double,
        pfcOverride: PFCRatio?
    ) {
        self.id = "week-\(weekNumber)"
        self.weekNumber = weekNumber
        self.startDate = startDate
        self.endDate = Calendar.current.date(byAdding: .day, value: 6, to: startDate) ?? startDate
        self.phaseName = phaseName
        self.phaseNameEn = phaseNameEn.isEmpty ? phaseName : phaseNameEn
        self.focusPoints = focusPoints
        self.calorieMultiplier = calorieMultiplier
        self.pfcOverride = pfcOverride
    }
}
