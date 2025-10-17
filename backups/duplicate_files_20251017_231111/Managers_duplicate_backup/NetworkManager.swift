//
//  NetworkManager.swift
//  AWStest
//
//  統一されたネットワーク通信管理クラス
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    // MARK: - HTTP Methods
    enum HTTPMethod: String {
        case GET = "GET"
        case POST = "POST"
        case PUT = "PUT"
        case DELETE = "DELETE"
    }
    
    // MARK: - Request Configuration
    struct RequestConfig {
        let url: String
        let method: HTTPMethod
        let body: [String: Any]?
        let requiresAuth: Bool
        let requiresAWSSignature: Bool
        let customHeaders: [String: String]?
        
        init(url: String, method: HTTPMethod = .GET, body: [String: Any]? = nil, requiresAuth: Bool = false, requiresAWSSignature: Bool = false, customHeaders: [String: String]? = nil) {
            self.url = url
            self.method = method
            self.body = body
            self.requiresAuth = requiresAuth
            self.requiresAWSSignature = requiresAWSSignature
            self.customHeaders = customHeaders
        }
    }
    
    // MARK: - Main Request Method
    func sendRequest<T: Codable>(
        config: RequestConfig,
        responseType: T.Type
    ) async throws -> T {
        
        guard let url = URL(string: config.url) else {
            throw AppError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = config.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Add custom headers
        config.customHeaders?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        // Add authentication if required
        if config.requiresAuth {
            guard let idToken = await SimpleCognitoService.shared.getIdToken() else {
                throw AppError.unauthorized
            }
            request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        }
        
        // Add request body
        var requestBody: Data?
        if let body = config.body {
            requestBody = try JSONSerialization.data(withJSONObject: body)
            request.httpBody = requestBody
        }
        
        // Add AWS signature if required
        if config.requiresAWSSignature {
            let awsCredentials = ConfigurationManager.shared.awsCredentialsConfig
            let signer = AWSSignatureV4(
                accessKey: awsCredentials.accessKey,
                secretKey: awsCredentials.secretKey,
                region: awsCredentials.region,
                service: "cognito-idp"
            )
            request = signer.signRequest(&request, body: requestBody)
        }
        
        // Execute request
        let (data, response) = try await URLSession.shared.data(for: request)
        
        // Validate response
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.invalidResponse
        }
        
        // Handle HTTP status codes
        switch httpResponse.statusCode {
        case 200...299:
            break
        case 401:
            throw AppError.unauthorized
        case 400:
            throw AppError.badRequest
        default:
            throw AppError.serverError(statusCode: httpResponse.statusCode)
        }
        
        // Decode response
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            throw AppError.decodingError(error)
        }
    }
    
    // MARK: - Convenience Methods
    func sendRawRequest(config: RequestConfig) async throws -> Data {
        guard let url = URL(string: config.url) else {
            throw AppError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = config.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Convert body dictionary to JSON data
        var bodyData: Data = Data()
        if let body = config.body {
            do {
                bodyData = try JSONSerialization.data(withJSONObject: body, options: [])
                request.httpBody = bodyData
            } catch {
                throw AppError.encodingError
            }
        }
        
        if config.requiresAuth {
            // Get credentials from ConfigurationManager
            let awsCredentials = ConfigurationManager.shared.awsCredentialsConfig
            
            let signer = AWSSignatureV4(
                accessKey: awsCredentials.accessKey,
                secretKey: awsCredentials.secretKey,
                region: awsCredentials.region,
                service: "execute-api"
            )
            request = signer.signRequest(&request, body: bodyData)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return data
        case 401:
            throw AppError.unauthorized
        case 400:
            throw AppError.badRequest
        default:
            throw AppError.serverError(statusCode: httpResponse.statusCode)
        }
    }
    
    func sendRequestWithoutResponse(config: RequestConfig) async throws {
        let _: EmptyResponse = try await sendRequest(config: config, responseType: EmptyResponse.self)
    }
    
    func sendRequestWithDictionary(config: RequestConfig) async throws -> [String: Any] {
        guard let url = URL(string: config.url) else {
            throw AppError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = config.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        config.customHeaders?.forEach { key, value in
            request.setValue(value, forHTTPHeaderField: key)
        }
        
        if config.requiresAuth {
            guard let idToken = await SimpleCognitoService.shared.getIdToken() else {
                throw AppError.unauthorized
            }
            request.setValue("Bearer \(idToken)", forHTTPHeaderField: "Authorization")
        }
        
        if let body = config.body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AppError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw AppError.serverError(statusCode: httpResponse.statusCode)
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw AppError.invalidResponse
        }
        
        return json
    }
}

// MARK: - Helper Models
struct EmptyResponse: Codable {}