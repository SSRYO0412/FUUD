//
//  HomeView.swift
//  AWStest
//
//  ホーム画面
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var cognitoService: SimpleCognitoService
    
    var body: some View {
        NavigationStack {
            List {
                // ユーザー情報セクション
                Section {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.blue.gradient)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("ようこそ")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            if let userEmail = cognitoService.currentUserEmail {
                                Text(userEmail)
                                    .font(.headline)
                                    .fontWeight(.medium)
                            }
                        }
                        
                        Spacer()
                        
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                    .padding(.vertical, 8)
                }
                
                // 機能セクション
                Section("健康データ") {
                    NavigationLink(destination: GeneDataView()) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("遺伝子解析結果")
                                    .font(.body)
                                Text("遺伝的リスクと推奨事項を確認")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "dna")
                                .foregroundStyle(.purple.gradient)
                        }
                    }
                    
                    NavigationLink(destination: BloodTestView()) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("血液検査結果")
                                    .font(.body)
                                Text("最新の血液検査データを確認")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "heart.text.square.fill")
                                .foregroundStyle(.red.gradient)
                        }
                    }
                }
                
                Section("サービス") {
                    NavigationLink(destination: ChatView().environmentObject(cognitoService)) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("AIチャット相談")
                                    .font(.body)
                                Text("健康に関する質問をAIに相談")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "message.fill")
                                .foregroundStyle(.green.gradient)
                        }
                    }
                    
                    NavigationLink(destination: OnboardingView()) {
                        Label {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("健康プロファイル")
                                    .font(.body)
                                Text("個人の健康情報を設定・管理")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        } icon: {
                            Image(systemName: "person.text.rectangle.fill")
                                .foregroundStyle(.orange.gradient)
                        }
                    }
                }
                
                // 最近の活動セクション（将来の拡張用）
                Section("最近の活動") {
                    HStack {
                        Image(systemName: "clock")
                            .foregroundStyle(.secondary)
                        Text("最新のデータ分析はありません")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("ホーム")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(SimpleCognitoService.shared)
}