//
//  FloatingChatButton.swift
//  AWStest
//
//  フローティングチャットボタン - HTML版準拠
//

import SwiftUI

struct FloatingChatButton: View {
    @State private var isPressed = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                // 黒い円形背景
                Circle()
                    .fill(Color.black)
                    .frame(width: 56, height: 56)
                    .shadow(
                        color: Color.black.opacity(0.2),
                        radius: isPressed ? 16 : 12,
                        x: 0,
                        y: isPressed ? 12 : 8
                    )

                // メッセージアイコン
                Image(systemName: "message.fill")
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(.white)
            }
            .scaleEffect(isPressed ? 1.1 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0.1, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

struct FloatingChatButtonModifier: ViewModifier {
    @State private var showChat = false

    func body(content: Content) -> some View {
        ZStack {
            content

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    FloatingChatButton {
                        showChat = true
                    }
                    .padding(.trailing, 20)
                    .padding(.bottom, 10) // TabViewの少し上
                }
            }
        }
        .sheet(isPresented: $showChat) {
            NavigationView {
                ChatView()
            }
        }
    }
}

extension View {
    /// HTML版準拠のフローティングチャットボタンを追加
    func floatingChatButton() -> some View {
        self.modifier(FloatingChatButtonModifier())
    }
}
