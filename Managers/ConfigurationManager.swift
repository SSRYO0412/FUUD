//
//  ConfigurationManager.swift
//  AWStest
//
//  アプリケーション設定管理クラス
//

import Foundation

class ConfigurationManager {
    static let shared = ConfigurationManager()
    
    private init() {}
    
    // MARK: - Environment
    enum Environment {
        case development
        case staging
        case production
        
        static var current: Environment {
            #if DEBUG
            return .development
            #else
            return .production
            #endif
        }
    }
    
    // MARK: - API Endpoints
    struct APIEndpoints {
        let createUser: String
        let chat: String
        let healthProfile: String
        let intelligence: String  // TUUNING Intelligence API
        let bloodData: String     // 血液データAPI
        let geneData: String      // 遺伝子データAPI

        // FUUD API エンドポイント
        let fuudBase: String       // FUUD API ベースURL
        let fuudTdee: String       // TDEE計算API
        let fuudFoods: String      // 食品検索API
        let fuudMealLog: String    // 食事記録API
        let fuudWeightLog: String  // 体重記録API

        // FUUD API ベースURL定数
        private static let fuudBaseUrl = "https://5l5ol9ehia.execute-api.ap-northeast-1.amazonaws.com"

        static var current: APIEndpoints {
            switch Environment.current {
            case .development:
                return APIEndpoints(
                    createUser: "https://02fc5gnwoi.execute-api.ap-northeast-1.amazonaws.com/dev/users",
                    chat: "https://api.tuun-api.com/chat",  // Cloudflare経由（base path mappingで/prodにルーティング）
                    healthProfile: "https://70ubpe7e14.execute-api.ap-northeast-1.amazonaws.com/prod/profile",
                    intelligence: "",  // TODO: Phase 3でエンドポイント設定
                    bloodData: "https://7rk2qibxm6.execute-api.ap-northeast-1.amazonaws.com/prod",
                    geneData: "https://kxuyul35l4.execute-api.ap-northeast-1.amazonaws.com/prod",
                    fuudBase: fuudBaseUrl,
                    fuudTdee: "\(fuudBaseUrl)/api/v1/tdee",
                    fuudFoods: "\(fuudBaseUrl)/api/v1/foods",
                    fuudMealLog: "\(fuudBaseUrl)/api/v1/logs/meal",
                    fuudWeightLog: "\(fuudBaseUrl)/api/v1/logs/weight"
                )
            case .staging:
                return APIEndpoints(
                    createUser: "https://02fc5gnwoi.execute-api.ap-northeast-1.amazonaws.com/staging/users",
                    chat: "https://api.tuun-api.com/chat",  // Cloudflare経由（base path mappingで/prodにルーティング）
                    healthProfile: "https://70ubpe7e14.execute-api.ap-northeast-1.amazonaws.com/staging/profile",
                    intelligence: "",  // TODO: Phase 3でエンドポイント設定
                    bloodData: "https://7rk2qibxm6.execute-api.ap-northeast-1.amazonaws.com/prod",
                    geneData: "https://kxuyul35l4.execute-api.ap-northeast-1.amazonaws.com/prod",
                    fuudBase: fuudBaseUrl,
                    fuudTdee: "\(fuudBaseUrl)/api/v1/tdee",
                    fuudFoods: "\(fuudBaseUrl)/api/v1/foods",
                    fuudMealLog: "\(fuudBaseUrl)/api/v1/logs/meal",
                    fuudWeightLog: "\(fuudBaseUrl)/api/v1/logs/weight"
                )
            case .production:
                return APIEndpoints(
                    createUser: "https://02fc5gnwoi.execute-api.ap-northeast-1.amazonaws.com/prod/users",
                    chat: "https://api.tuun-api.com/chat",  // Cloudflare経由（base path mappingで/prodにルーティング）
                    healthProfile: "https://70ubpe7e14.execute-api.ap-northeast-1.amazonaws.com/prod/profile",
                    intelligence: "",  // TODO: Phase 3でエンドポイント設定
                    bloodData: "https://7rk2qibxm6.execute-api.ap-northeast-1.amazonaws.com/prod",
                    geneData: "https://kxuyul35l4.execute-api.ap-northeast-1.amazonaws.com/prod",
                    fuudBase: fuudBaseUrl,
                    fuudTdee: "\(fuudBaseUrl)/api/v1/tdee",
                    fuudFoods: "\(fuudBaseUrl)/api/v1/foods",
                    fuudMealLog: "\(fuudBaseUrl)/api/v1/logs/meal",
                    fuudWeightLog: "\(fuudBaseUrl)/api/v1/logs/weight"
                )
            }
        }
    }
    
    // MARK: - Cognito Configuration
    struct CognitoConfig {
        let userPoolId: String
        let clientId: String
        let region: String
        
        static var current: CognitoConfig {
            return CognitoConfig(
                userPoolId: "ap-northeast-1_cwAKljjzb",
                clientId: "3uhtrfkr51ggh4gi5s597klinf",
                region: "ap-northeast-1"
            )
        }
    }
    
    // MARK: - AWS Credentials Configuration
    struct AWSCredentialsConfig {
        let accessKey: String
        let secretKey: String
        let region: String
        
        static var current: AWSCredentialsConfig {
            // 実際の本番環境では環境変数から取得するか、より安全な方法を使用
            return AWSCredentialsConfig(
                accessKey: ProcessInfo.processInfo.environment["AWS_ACCESS_KEY_ID"] ?? "AKIAIOSFODNN7EXAMPLE", // [DUMMY] AWSアクセスキーの例示値
                secretKey: ProcessInfo.processInfo.environment["AWS_SECRET_ACCESS_KEY"] ?? "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY", // [DUMMY] AWSシークレットキーの例示値
                region: "ap-northeast-1"
            )
        }
    }
    
    // MARK: - App Configuration
    struct AppConfig {
        let maxRetryAttempts: Int
        let requestTimeout: TimeInterval
        let enableLogging: Bool
        
        static var current: AppConfig {
            switch Environment.current {
            case .development:
                return AppConfig(
                    maxRetryAttempts: 3,
                    requestTimeout: 30.0,
                    enableLogging: true
                )
            case .staging, .production:
                return AppConfig(
                    maxRetryAttempts: 2,
                    requestTimeout: 15.0,
                    enableLogging: false
                )
            }
        }
    }
    
    // MARK: - Convenience Properties
    var apiEndpoints: APIEndpoints { APIEndpoints.current }
    var cognitoConfig: CognitoConfig { CognitoConfig.current }
    var awsCredentialsConfig: AWSCredentialsConfig { AWSCredentialsConfig.current }
    var appConfig: AppConfig { AppConfig.current }
    var environment: Environment { Environment.current }
}
