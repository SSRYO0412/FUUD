//
//  FastingTimer.swift
//  FUUD
//
//  Fasting Timer Model - Lifesum style
//

import Foundation

// MARK: - Fasting Plan

enum FastingPlan: String, CaseIterable, Codable {
    case ratio12_12 = "12:12"
    case ratio14_10 = "14:10"
    case ratio16_8 = "16:8"
    case ratio18_6 = "18:6"
    case ratio20_4 = "20:4"

    var fastingHours: Int {
        switch self {
        case .ratio12_12: return 12
        case .ratio14_10: return 14
        case .ratio16_8: return 16
        case .ratio18_6: return 18
        case .ratio20_4: return 20
        }
    }

    var eatingHours: Int {
        return 24 - fastingHours
    }

    var displayName: String {
        return rawValue
    }
}

// MARK: - Fasting State

enum FastingState: Codable, Equatable {
    case idle
    case fasting(startDate: Date)
    case eating(startDate: Date, fastEndDate: Date)

    var isFasting: Bool {
        if case .fasting = self { return true }
        return false
    }

    var isEating: Bool {
        if case .eating = self { return true }
        return false
    }

    var isActive: Bool {
        return isFasting || isEating
    }
}

// MARK: - Fasting Session

struct FastingSession: Codable, Identifiable {
    let id: UUID
    let plan: FastingPlan
    let startDate: Date
    var endDate: Date?
    var actualFastEndDate: Date?

    init(plan: FastingPlan, startDate: Date = Date()) {
        self.id = UUID()
        self.plan = plan
        self.startDate = startDate
    }

    var plannedFastEndDate: Date {
        return Calendar.current.date(byAdding: .hour, value: plan.fastingHours, to: startDate) ?? startDate
    }

    var plannedEatingEndDate: Date {
        return Calendar.current.date(byAdding: .hour, value: 24, to: startDate) ?? startDate
    }

    var fastingDuration: TimeInterval {
        let endDate = actualFastEndDate ?? Date()
        return endDate.timeIntervalSince(startDate)
    }

    var isCompleted: Bool {
        return endDate != nil
    }
}

// MARK: - Ketosis Phase

enum KetosisPhase {
    case notStarted
    case earlyFasting      // 0-12h
    case fatBurning        // 12-18h
    case ketosis           // 18-24h
    case deepKetosis       // 24h+

    var displayName: String {
        switch self {
        case .notStarted: return "開始前"
        case .earlyFasting: return "断食初期"
        case .fatBurning: return "脂肪燃焼"
        case .ketosis: return "ケトーシス"
        case .deepKetosis: return "深いケトーシス"
        }
    }

    var description: String {
        switch self {
        case .notStarted: return ""
        case .earlyFasting: return "血糖値が安定し始めています"
        case .fatBurning: return "脂肪燃焼モードに移行中"
        case .ketosis: return "ケトン体が生成されています"
        case .deepKetosis: return "オートファジーが活性化"
        }
    }

    static func phase(for hours: Double) -> KetosisPhase {
        switch hours {
        case ..<0: return .notStarted
        case 0..<12: return .earlyFasting
        case 12..<18: return .fatBurning
        case 18..<24: return .ketosis
        default: return .deepKetosis
        }
    }
}
