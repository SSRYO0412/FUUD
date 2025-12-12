//
//  CopyHelper.swift
//  AWStest
//
//  クリップボードコピーヘルパー
//

import SwiftUI
import UIKit

/// クリップボードコピーとフィードバック管理
struct CopyHelper {

    /// テキストをクリップボードにコピーし、ハプティックフィードバックとトースト表示をトリガー
    /// [DUMMY] デバッグログ付き、本番環境では削除予定
    static func copyToClipboard(_ text: String, showToast: Binding<Bool>) {
        // クリップボードにコピー
        UIPasteboard.general.string = text

        // ハプティックフィードバック（軽量）
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        // トースト表示トリガー
        DispatchQueue.main.async {
            showToast.wrappedValue = true
        }

        // [DUMMY] デバッグログ（開発中のみ）
        #if DEBUG
        print("📋 [CopyHelper] Copied to clipboard:")
        print(text.prefix(200)) // 最初の200文字のみ表示
        if text.count > 200 {
            print("... (\(text.count) total characters)")
        }
        #endif
    }

    /// テキストをクリップボードにコピー（トースト表示なし）
    /// [DUMMY] シンプルなコピー専用、通知不要な場合に使用
    static func copyToClipboardSilent(_ text: String) {
        UIPasteboard.general.string = text

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()

        #if DEBUG
        print("📋 [CopyHelper] Silent copy: \(text.count) characters")
        #endif
    }
}
