//
//  HealthProfileService.swift
//  AWStest
//
//  健康プロファイルAPIとの通信を管理するサービス
//

import Foundation

class HealthProfileService {
    static let shared = HealthProfileService()
    
    // API Gateway のエンドポイント（TUUNapp-Health-Profile-API）
    private var endpoint: String {
        ConfigurationManager.shared.apiEndpoints.healthProfile
    }
    
    private init() {}
    
    // MARK: - プロファイル作成
    func createProfile(sections: HealthProfileSections, consent: HealthProfile.ConsentInfo) async throws {
        guard let userEmail = SimpleCognitoService.shared.currentUserEmail else {
            throw AppError.userNotFound
        }
        
        let request = HealthProfileCreateRequest(
            userId: userEmail,
            action: "create",
            sections: sections,
            consent: consent
        )
        
        let body = try request.toDictionary()
        let requestConfig = NetworkManager.RequestConfig(
            url: endpoint,
            method: .POST,
            body: body,
            requiresAuth: true
        )
        
        try await NetworkManager.shared.sendRequestWithoutResponse(config: requestConfig)
    }
    
    // MARK: - プロファイル取得
    func getProfile() async throws -> HealthProfile? {
        guard let userEmail = SimpleCognitoService.shared.currentUserEmail else {
            throw AppError.userNotFound
        }
        
        let requestConfig = NetworkManager.RequestConfig(
            url: endpoint,
            method: .POST,
            body: [
                "userId": userEmail,
                "action": "get"
            ],
            requiresAuth: true
        )
        
        let response = try await NetworkManager.shared.sendRequestWithDictionary(config: requestConfig)
        
        // レスポンスからプロファイルを取得
        if let profileData = response["profile"] as? [String: Any],
           let sectionsData = profileData["sections"] as? [String: Any] {
            
            // sectionsを個別に処理
            var sections = HealthProfileSections()
            
            // Physical section
            if let physicalData = sectionsData["physical"] as? [String: Any] {
                let jsonData = try JSONSerialization.data(withJSONObject: physicalData)
                sections.physical = try JSONDecoder().decode(PhysicalSection.self, from: jsonData)
            }
            
            // Lifestyle section
            if let lifestyleData = sectionsData["lifestyle"] as? [String: Any] {
                let jsonData = try JSONSerialization.data(withJSONObject: lifestyleData)
                sections.lifestyle = try JSONDecoder().decode(LifestyleSection.self, from: jsonData)
            }
            
            // Health status section
            if let healthStatusData = sectionsData["healthStatus"] as? [String: Any] {
                let jsonData = try JSONSerialization.data(withJSONObject: healthStatusData)
                sections.healthStatus = try JSONDecoder().decode(HealthStatusSection.self, from: jsonData)
            }
            
            // Goals section
            if let goalsData = sectionsData["goals"] as? [String: Any] {
                let jsonData = try JSONSerialization.data(withJSONObject: goalsData)
                sections.goals = try JSONDecoder().decode(GoalsSection.self, from: jsonData)
            }
            
            // Consent
            let consentData = profileData["consent"] as? [String: Any] ?? [:]
            let consent = HealthProfile.ConsentInfo(
                dataUsage: consentData["dataUsage"] as? Bool ?? true,
                marketing: consentData["marketing"] as? Bool ?? false
            )
            
            let profile = HealthProfile(
                userId: profileData["userId"] as? String ?? userEmail,
                sections: sections,
                consent: consent
            )
            
            return profile
        }
        
        return nil
    }
    
    // MARK: - プロファイル部分更新
    func patchProfile(patches: [String: Any]) async throws {
        guard let userEmail = SimpleCognitoService.shared.currentUserEmail else {
            throw AppError.userNotFound
        }
        
        let request = HealthProfilePatchRequest(
            userId: userEmail,
            patches: patches
        )
        
        let requestConfig = NetworkManager.RequestConfig(
            url: endpoint,
            method: .POST,
            body: request.toDictionary(),
            requiresAuth: true
        )
        
        try await NetworkManager.shared.sendRequestWithoutResponse(config: requestConfig)
    }
    
    // NOTE: sendRequest method is now handled by NetworkManager
}

// NOTE: HealthProfileError is now handled by the unified AppError system
