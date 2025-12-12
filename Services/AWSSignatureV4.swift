//
//  AWSSignatureV4.swift
//  AWStest
//
//  AWS Signature Version 4 署名実装
//

import Foundation
import CryptoKit

class AWSSignatureV4 {
    private let accessKey: String
    private let secretKey: String
    private let region: String
    private let service: String
    
    init(accessKey: String, secretKey: String, region: String, service: String) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.region = region
        self.service = service
    }
    
    func signRequest(_ request: inout URLRequest, body: Data?) -> URLRequest {
        let now = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss'Z'"
        dateFormatter.timeZone = TimeZone(identifier: "UTC")
        let amzDate = dateFormatter.string(from: now)
        
        dateFormatter.dateFormat = "yyyyMMdd"
        let dateStamp = dateFormatter.string(from: now)
        
        // ヘッダーを追加
        request.setValue(amzDate, forHTTPHeaderField: "X-Amz-Date")
        request.setValue("AWS4-HMAC-SHA256", forHTTPHeaderField: "Authorization")
        
        // ホストヘッダーを追加
        if let host = request.url?.host {
            request.setValue(host, forHTTPHeaderField: "Host")
        }
        
        // ボディのハッシュを計算
        let bodyHash = SHA256.hash(data: body ?? Data())
        let bodyHashString = bodyHash.compactMap { String(format: "%02x", $0) }.joined()
        request.setValue(bodyHashString, forHTTPHeaderField: "X-Amz-Content-Sha256")
        
        // カノニカルリクエストを作成
        let canonicalRequest = createCanonicalRequest(request: request, bodyHash: bodyHashString)
        
        // 署名文字列を作成
        let credentialScope = "\(dateStamp)/\(region)/\(service)/aws4_request"
        let algorithm = "AWS4-HMAC-SHA256"
        let canonicalRequestHash = SHA256.hash(data: Data(canonicalRequest.utf8))
        let canonicalRequestHashString = canonicalRequestHash.compactMap { String(format: "%02x", $0) }.joined()
        
        let stringToSign = "\(algorithm)\n\(amzDate)\n\(credentialScope)\n\(canonicalRequestHashString)"
        
        // 署名を計算
        let signature = calculateSignature(stringToSign: stringToSign, dateStamp: dateStamp)
        
        // 認証ヘッダーを作成
        let authorizationHeader = "\(algorithm) Credential=\(accessKey)/\(credentialScope), SignedHeaders=\(getSignedHeaders(request)), Signature=\(signature)"
        request.setValue(authorizationHeader, forHTTPHeaderField: "Authorization")
        
        return request
    }
    
    private func createCanonicalRequest(request: URLRequest, bodyHash: String) -> String {
        let method = request.httpMethod ?? "GET"
        let uri = request.url?.path ?? "/"
        let query = request.url?.query ?? ""
        
        // ヘッダーをソート
        let headers = request.allHTTPHeaderFields?.sorted { $0.key.lowercased() < $1.key.lowercased() } ?? []
        let canonicalHeaders = headers.map { "\($0.key.lowercased()):\($0.value)" }.joined(separator: "\n") + "\n"
        let signedHeaders = getSignedHeaders(request)
        
        return "\(method)\n\(uri)\n\(query)\n\(canonicalHeaders)\n\(signedHeaders)\n\(bodyHash)"
    }
    
    private func getSignedHeaders(_ request: URLRequest) -> String {
        let headers = request.allHTTPHeaderFields?.keys.map { $0.lowercased() }.sorted() ?? []
        return headers.joined(separator: ";")
    }
    
    private func calculateSignature(stringToSign: String, dateStamp: String) -> String {
        let kDate = hmacSHA256(key: "AWS4\(secretKey)", data: dateStamp)
        let kRegion = hmacSHA256(key: kDate, data: region)
        let kService = hmacSHA256(key: kRegion, data: service)
        let kSigning = hmacSHA256(key: kService, data: "aws4_request")
        let signature = hmacSHA256(key: kSigning, data: stringToSign)
        
        return signature.map { String(format: "%02x", $0) }.joined()
    }
    
    private func hmacSHA256(key: String, data: String) -> Data {
        return hmacSHA256(key: Data(key.utf8), data: data)
    }
    
    private func hmacSHA256(key: Data, data: String) -> Data {
        let hmac = HMAC<SHA256>.authenticationCode(for: Data(data.utf8), using: SymmetricKey(data: key))
        return Data(hmac)
    }
}