//
//  ContentView.swift
//  AWStest
//
//  Created by nao omiya on 2025/07/24.
//

import SwiftUI

struct ContentView: View {
    // Cognitoサービスのインスタンス（アプリ全体で共有）
    @StateObject private var cognitoService = SimpleCognitoService.shared
    @State private var isInitializing = true
    
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
                MainTabView()
                    .environmentObject(cognitoService)
            } else {
                AuthenticationView()
                    .environmentObject(cognitoService)
            }
        }
        .task {
            // 少し待ってから初期化完了とする（トークン読み込みを確実にするため）
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
