//
//  SettingsView.swift
//  AWStest
//
//  設定画面
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var cognitoService: SimpleCognitoService
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                // アカウント情報
                Section("アカウント") {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundStyle(.blue.gradient)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text("ユーザーアカウント")
                                .font(.body)
                            if let userEmail = cognitoService.currentUserEmail {
                                Text(userEmail)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                    .padding(.vertical, 2)
                }
                
                // データ管理
                Section("データ管理") {
                    Label("遺伝子データをエクスポート", systemImage: "square.and.arrow.up")
                    Label("血液検査データをエクスポート", systemImage: "doc.text")
                    Label("データ同期", systemImage: "arrow.triangle.2.circlepath")
                }
                
                // プライバシーとセキュリティ
                Section("プライバシーとセキュリティ") {
                    Label("プライバシーポリシー", systemImage: "hand.raised")
                    Label("利用規約", systemImage: "doc.text")
                    Label("データの取り扱いについて", systemImage: "lock")
                }
                
                // サポート
                Section("サポート") {
                    Label("ヘルプ", systemImage: "questionmark.circle")
                    Label("お問い合わせ", systemImage: "envelope")
                    Label("フィードバックを送信", systemImage: "heart")
                }
                
                // アプリ情報
                Section("アプリ情報") {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }
                    
                    HStack {
                        Text("ビルド")
                        Spacer()
                        Text("1")
                            .foregroundStyle(.secondary)
                    }
                }
                
                // ログアウト
                Section {
                    Button("ログアウト") {
                        showingLogoutAlert = true
                    }
                    .foregroundStyle(.red)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle("設定")
            .navigationBarTitleDisplayMode(.large)
            .alert("ログアウト", isPresented: $showingLogoutAlert) {
                Button("キャンセル", role: .cancel) { }
                Button("ログアウト", role: .destructive) {
                    Task {
                        await cognitoService.signOut()
                    }
                }
            } message: {
                Text("アカウントからログアウトしますか？")
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(SimpleCognitoService.shared)
}