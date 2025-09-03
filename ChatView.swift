//
//  ChatView.swift
//  AWStest
//
//  Created by nao omiya on 2025/08/18.
//

import SwiftUI

struct ChatView: View {
    @State private var message = ""
    @State private var chatHistory: [(role: String, content: String)] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var selectedTopic = "general_health"
    
    let topics = [
        ("general_health", "一般的な健康"),
        ("nutrition", "栄養"),
        ("exercise", "運動"),
        ("lifestyle", "ライフスタイル")
    ]
    
    var body: some View {
        VStack {
            // トピック選択
            Picker("トピック", selection: $selectedTopic) {
                ForEach(topics, id: \.0) { topic in
                    Text(topic.1).tag(topic.0)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            // チャット履歴
            ScrollView {
                VStack(alignment: .leading, spacing: 10) {
                    ForEach(Array(chatHistory.enumerated()), id: \.offset) { index, chat in
                        HStack {
                            if chat.role == "user" {
                                Spacer()
                                Text(chat.content)
                                    .padding()
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(10)
                            } else {
                                Text(chat.content)
                                    .padding()
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(10)
                                Spacer()
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            
            // エラーメッセージ
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding()
            }
            
            // 入力フィールド
            HStack {
                TextField("メッセージを入力", text: $message)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .disabled(isLoading)
                
                Button(action: sendMessage) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "paperplane.fill")
                    }
                }
                .disabled(message.isEmpty || isLoading)
            }
            .padding()
        }
        .navigationTitle("AIチャット")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func sendMessage() {
        let userMessage = message
        message = ""
        errorMessage = nil
        
        // ユーザーメッセージを追加
        chatHistory.append((role: "user", content: userMessage))
        
        isLoading = true
        
        Task {
            do {
                let response = try await ChatService.shared.sendMessage(
                    userMessage,
                    topic: selectedTopic
                )
                
                await MainActor.run {
                    chatHistory.append((role: "assistant", content: response))
                    isLoading = false
                }
            } catch {
                let appError = ErrorManager.shared.convertToAppError(error)
                ErrorManager.shared.logError(appError, context: "ChatView.sendMessage")
                
                await MainActor.run {
                    errorMessage = ErrorManager.shared.userFriendlyMessage(for: appError)
                    isLoading = false
                }
            }
        }
    }
}
