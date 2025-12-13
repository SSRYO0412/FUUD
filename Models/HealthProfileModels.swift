//
//  HealthProfileModels.swift
//  AWStest
//
//  健康プロファイルのデータモデル定義
//

import Foundation

// MARK: - 健康プロファイルのメインモデル
struct HealthProfile: Codable {
    let userId: String
    var sections: HealthProfileSections
    var consent: ConsentInfo
    
    struct ConsentInfo: Codable {
        let dataUsage: Bool
        let marketing: Bool
    }
}

// MARK: - セクション構造
struct HealthProfileSections: Codable {
    var physical: PhysicalSection?
    var lifestyle: LifestyleSection?
    var healthStatus: HealthStatusSection?
    var goals: GoalsSection?
    var preferences: PreferencesSection?
}

// MARK: - 身体情報セクション
struct PhysicalSection: Codable {
    var height: Double?     // cm
    var weight: Double?     // kg
    var bmi: Double?        // 自動計算される
    var bodyFatPercentage: Double?
}

// MARK: - ライフスタイルセクション
struct LifestyleSection: Codable {
    var smoking: SmokingInfo?
    var alcohol: AlcoholInfo?
    var exercise: ExerciseInfo?
    var sleep: SleepInfo?
    var diet: DietInfo?
    
    struct SmokingInfo: Codable {
        var status: SmokingStatus
        var quitDate: String?
        
        enum SmokingStatus: String, Codable, CaseIterable {
            case never = "never"
            case former = "former"
            case current = "current"
            
            var displayName: String {
                switch self {
                case .never: return "吸わない"
                case .former: return "以前吸っていた"
                case .current: return "吸っている"
                }
            }
        }
    }
    
    struct AlcoholInfo: Codable {
        var frequency: AlcoholFrequency
        var amount: String?
        
        enum AlcoholFrequency: String, Codable, CaseIterable {
            case never = "never"
            case occasional = "occasional"
            case weekly = "weekly"
            case daily = "daily"
            
            var displayName: String {
                switch self {
                case .never: return "飲まない"
                case .occasional: return "たまに"
                case .weekly: return "週に数回"
                case .daily: return "毎日"
                }
            }
        }
    }
    
    struct ExerciseInfo: Codable {
        var frequency: String
        var types: [String]?
        var duration: Int?  // 分
    }
    
    struct SleepInfo: Codable {
        var averageHours: Double
        var quality: SleepQuality?
        
        enum SleepQuality: String, Codable, CaseIterable {
            case poor = "poor"
            case fair = "fair"
            case good = "good"
            case excellent = "excellent"
            
            var displayName: String {
                switch self {
                case .poor: return "悪い"
                case .fair: return "普通"
                case .good: return "良い"
                case .excellent: return "とても良い"
                }
            }
        }
    }
    
    struct DietInfo: Codable {
        var style: String?
        var concerns: [String]?
    }
}

// MARK: - 健康状態セクション
struct HealthStatusSection: Codable {
    var currentIssues: [String]?
    var allergies: [String]?
    var hasMedications: Bool?
}

// MARK: - 目標セクション
struct GoalsSection: Codable {
    var primary: String
    var secondary: [String]?
    var targetWeight: Double?
    var timeframe: String?
}

// MARK: - 設定セクション
struct PreferencesSection: Codable {
    var communicationStyle: String?
    var reminderFrequency: String?
    var interests: [String]?
}

// HealthProfileModels.swift の該当部分を以下に置き換え

// MARK: - API リクエスト（シンプル版）
// 複雑なCodable実装は不要なので、シンプルな構造に変更
struct HealthProfileCreateRequest {
    let userId: String
    let action: String
    let sections: HealthProfileSections
    let consent: HealthProfile.ConsentInfo
    
    func toDictionary() throws -> [String: Any] {
        let encoder = JSONEncoder()
        let data = try encoder.encode(sections)
        guard let sectionsDict = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw AppError.encodingError
        }
        
        let requestBody: [String: Any] = [
            "userId": userId,
            "action": action,
            "sections": [
                "physical": sectionsDict["physical"] as? [String: Any] ?? [:],
                "lifestyle": sectionsDict["lifestyle"] as? [String: Any] ?? [:],
                "health_status": sectionsDict["healthStatus"] as? [String: Any] ?? [:],
                "goals": sectionsDict["goals"] as? [String: Any] ?? [:],
                "preferences": sectionsDict["preferences"] as? [String: Any] ?? [:]
            ] as [String: Any],
            "consent": [
                "dataUsage": consent.dataUsage,
                "marketing": consent.marketing
            ] as [String: Any]
        ]
        
        // デバッグ用: POSTデータをログ出力
        if let debugData = try? JSONSerialization.data(withJSONObject: requestBody),
           let debugString = String(data: debugData, encoding: .utf8) {
            print("📤 HealthProfile POST Data: \(debugString)")
        }
        
        return requestBody
    }
}

struct HealthProfilePatchRequest {
    let userId: String
    let action: String = "patch"
    let patches: [String: Any]
    
    func toDictionary() -> [String: Any] {
        return [
            "userId": userId,
            "action": action,
            "patches": patches
        ]
    }
}
