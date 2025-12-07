//
//  MFASetupView.swift
//  TUUN
//
//  MFAセットアップUI（QRコード表示、TOTPコード入力）
//

import SwiftUI
import CoreImage.CIFilterBuiltins

struct MFASetupView: View {
    @ObservedObject var cognitoService = SimpleCognitoService.shared
    @State private var totpCode = ""
    @State private var isVerifying = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // ヘッダー
                    headerSection

                    // QRコード表示
                    if let secretCode = cognitoService.mfaSecretCode {
                        qrCodeSection(secretCode: secretCode)
                    }

                    // 手動入力用シークレット
                    if let secretCode = cognitoService.mfaSecretCode {
                        manualEntrySection(secretCode: secretCode)
                    }

                    // TOTPコード入力
                    totpInputSection

                    // 確認ボタン
                    verifyButton

                    // メッセージ表示
                    if !cognitoService.message.isEmpty {
                        messageSection
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("二段階認証の設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        cognitoService.resetMFAState()
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - View Components

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.shield")
                .font(.system(size: 60))
                .foregroundColor(.blue)

            Text("認証アプリの設定")
                .font(.title2)
                .fontWeight(.bold)

            Text("Google Authenticator、Microsoft Authenticatorなどの認証アプリでQRコードをスキャンしてください。")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical)
    }

    private func qrCodeSection(secretCode: String) -> some View {
        VStack(spacing: 12) {
            if let qrImage = generateQRCode(from: secretCode) {
                Image(uiImage: qrImage)
                    .interpolation(.none)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(12)
                    .shadow(radius: 4)
            } else {
                Text("QRコードの生成に失敗しました")
                    .foregroundColor(.red)
            }
        }
    }

    private func manualEntrySection(secretCode: String) -> some View {
        VStack(spacing: 8) {
            Text("手動で入力する場合")
                .font(.caption)
                .foregroundColor(.secondary)

            HStack {
                Text(formatSecretCode(secretCode))
                    .font(.system(.body, design: .monospaced))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)

                Button(action: {
                    UIPasteboard.general.string = secretCode
                }) {
                    Image(systemName: "doc.on.doc")
                        .foregroundColor(.blue)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6).opacity(0.5))
        .cornerRadius(12)
    }

    private var totpInputSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("認証コード")
                .font(.subheadline)
                .foregroundColor(.secondary)

            TextField("6桁のコードを入力", text: $totpCode)
                .keyboardType(.numberPad)
                .textContentType(.oneTimeCode)
                .font(.system(.title2, design: .monospaced))
                .multilineTextAlignment(.center)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .onChange(of: totpCode) { newValue in
                    // 6桁に制限
                    if newValue.count > 6 {
                        totpCode = String(newValue.prefix(6))
                    }
                    // 数字のみに制限
                    let filtered = newValue.filter { $0.isNumber }
                    if filtered != newValue {
                        totpCode = filtered
                    }
                }
        }
    }

    private var verifyButton: some View {
        Button(action: {
            Task {
                isVerifying = true
                await cognitoService.verifyMFASetup(totpCode: totpCode)
                isVerifying = false

                // 成功したら自動で閉じる
                if cognitoService.isSignedIn {
                    dismiss()
                }
            }
        }) {
            HStack {
                if isVerifying {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("設定を完了する")
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(totpCode.count == 6 ? Color.blue : Color.gray)
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(totpCode.count != 6 || isVerifying)
    }

    private var messageSection: some View {
        Text(cognitoService.message)
            .font(.subheadline)
            .foregroundColor(cognitoService.message.contains("失敗") || cognitoService.message.contains("エラー") ? .red : .green)
            .multilineTextAlignment(.center)
            .padding()
    }

    // MARK: - Helper Methods

    /// QRコード生成
    private func generateQRCode(from secretCode: String) -> UIImage? {
        let userEmail = cognitoService.currentUserEmail ?? cognitoService.pendingUsername ?? "user"
        let issuer = "TUUN"
        let otpauthURL = "otpauth://totp/\(issuer):\(userEmail)?secret=\(secretCode)&issuer=\(issuer)"

        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(otpauthURL.utf8)
        filter.correctionLevel = "M"

        guard let outputImage = filter.outputImage else { return nil }

        // スケールアップ
        let scale = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = outputImage.transformed(by: scale)

        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else { return nil }

        return UIImage(cgImage: cgImage)
    }

    /// シークレットコードをフォーマット（4文字ごとにスペース）
    private func formatSecretCode(_ code: String) -> String {
        var formatted = ""
        for (index, char) in code.enumerated() {
            if index > 0 && index % 4 == 0 {
                formatted += " "
            }
            formatted += String(char)
        }
        return formatted
    }
}

#Preview {
    MFASetupView()
}
