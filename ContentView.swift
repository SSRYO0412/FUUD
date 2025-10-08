//
//  ContentView.swift
//  AWStest
//
//  Created by nao omiya on 2025/07/24.
//

import SwiftUI

struct ContentView: View {
    // Cognitoサービスのインスタンス（アプリ全体で共有）
    @StateObject private var cognitoService: SimpleCognitoService
    init(service: SimpleCognitoService = .shared) {
        _cognitoService = StateObject(wrappedValue: service)
    }
    @State private var isInitializing: Bool = {
        // Previewsでは初期化フラグを即falseにしてスプラッシュを回避
        if ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil {
            return false
        }
        return true
    }()
    
    private var isPreview: Bool {
        // Xcode Previews では環境変数が "1" 固定とは限らないため、存在チェックに変更
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
    }
    
    // UI制御用の状態変数
    @State private var email = ""
    @State private var password = ""
    @State private var confirmationCode = ""
    @State private var showConfirmation = false
    
    var body: some View {
        Group {
            if isInitializing {
                // 初期化中のスプラッシュ画面
                VStack {
                    ProgressView()
                        .controlSize(.large)
                    Text("初期化中...")
                        .padding(.top)
                }
            } else if cognitoService.isSignedIn {
                RootContainerView()
                    .environmentObject(cognitoService)
            } else {
                AuthenticationView()
                    .environmentObject(cognitoService)
            }
        }
        // Previews で .task がキャンセルされても確実に抜けるための冗長化
        .onAppear {
            if isPreview { isInitializing = false }
        }
        .task {
            // プレビュー環境では即時に初期化完了へ
            if isPreview {
                isInitializing = false
                return
            }
            // 実行時は少し待ってから初期化完了とする（トークン読み込みの猶予）
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5秒
            isInitializing = false
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
