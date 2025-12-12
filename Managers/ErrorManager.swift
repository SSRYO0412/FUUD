//
//  ErrorManager.swift
//  AWStest
//
//  統一されたエラー管理クラス
//

import Foundation

// MARK: - Unified App Error
enum AppError: LocalizedError, Equatable {
    case unauthorized
    case userNotFound
    case invalidURL
    case invalidResponse
    case badRequest
    case serverError(statusCode: Int)
    case decodingError(Error)
    case encodingError
    case networkUnavailable
    case timeout
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .unauthorized:
            return "認証が必要です。ログインしてください。"
        case .userNotFound:
            return "ユーザー情報が見つかりません。"
        case .invalidURL:
            return "URLが無効です。"
        case .invalidResponse:
            return "サーバーからの応答が無効です。"
        case .badRequest:
            return "リクエストが無効です。"
        case .serverError(let statusCode):
            return "サーバーエラーが発生しました。(コード: \(statusCode))"
        case .decodingError:
            return "データの解析に失敗しました。"
        case .encodingError:
            return "データの変換に失敗しました。"
        case .networkUnavailable:
            return "ネットワークに接続できません。"
        case .timeout:
            return "リクエストがタイムアウトしました。"
        case .unknown:
            return "予期しないエラーが発生しました。"
        }
    }
    
    var isRecoverable: Bool {
        switch self {
        case .networkUnavailable, .timeout, .serverError:
            return true
        case .unauthorized:
            return true // Can retry after re-authentication
        default:
            return false
        }
    }
    
    static func == (lhs: AppError, rhs: AppError) -> Bool {
        switch (lhs, rhs) {
        case (.unauthorized, .unauthorized),
             (.userNotFound, .userNotFound),
             (.invalidURL, .invalidURL),
             (.invalidResponse, .invalidResponse),
             (.badRequest, .badRequest),
             (.encodingError, .encodingError),
             (.networkUnavailable, .networkUnavailable),
             (.timeout, .timeout):
            return true
        case (.serverError(let lhsCode), .serverError(let rhsCode)):
            return lhsCode == rhsCode
        case (.decodingError, .decodingError),
             (.unknown, .unknown):
            return true // Simplified comparison for Error types
        default:
            return false
        }
    }
}

// MARK: - Error Manager
class ErrorManager {
    static let shared = ErrorManager()
    
    private init() {}
    
    // MARK: - Error Conversion
    func convertToAppError(_ error: Error) -> AppError {
        if let appError = error as? AppError {
            return appError
        }
        
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost:
                return .networkUnavailable
            case .timedOut:
                return .timeout
            case .badURL:
                return .invalidURL
            case .badServerResponse:
                return .invalidResponse
            default:
                return .unknown(urlError)
            }
        }
        
        if error is DecodingError {
            return .decodingError(error)
        }
        
        if error is EncodingError {
            return .encodingError
        }
        
        return .unknown(error)
    }
    
    // MARK: - Error Logging
    func logError(_ error: AppError, context: String = "") {
        guard ConfigurationManager.shared.appConfig.enableLogging else { return }
        
        let timestamp = DateFormatter.iso8601.string(from: Date())
        let logMessage = "[\(timestamp)] ERROR in \(context): \(error.localizedDescription)"
        
        print(logMessage)
        
        // In production, you might want to send this to a crash reporting service
        // like Crashlytics or Sentry
    }
    
    // MARK: - User-Friendly Messages
    func userFriendlyMessage(for error: AppError) -> String {
        switch error {
        case .networkUnavailable:
            return "インターネット接続を確認してください。"
        case .timeout:
            return "処理に時間がかかっています。もう一度お試しください。"
        case .serverError(let code) where code >= 500:
            return "サーバーでエラーが発生しています。しばらく待ってからお試しください。"
        default:
            return error.localizedDescription
        }
    }
}

// MARK: - Extensions
extension DateFormatter {
    static let iso8601: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        return formatter
    }()
}