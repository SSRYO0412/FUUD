//
//  ExpandableCardOverlay.swift
//  AWStest
//
//  カード拡大オーバーレイアニメーション（Apple Music風）
//

import SwiftUI

struct ExpandableCardOverlay: View {
    let detail: HealthMetricDetail
    @Binding var isExpanded: Bool
    var namespace: Namespace.ID?

    @State private var dragOffset: CGFloat = 0
    @State private var opacity: Double = 0

    var body: some View {
        ZStack {
            // 背景ぼかしオーバーレイ
            if isExpanded {
                Color.clear
                    .contentShape(Rectangle())
                    .ignoresSafeArea()
                    .onTapGesture {
                        closeCard()
                    }
                    .transition(.opacity)
            }

            // 詳細カード
            if isExpanded {
                GeometryReader { geometry in
                    ZStack(alignment: .top) {
                        HealthMetricDetailCard(detail: detail, onClose: closeCard)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .offset(y: dragOffset)
                            .simultaneousGesture(
                                DragGesture()
                                    .onChanged { value in
                                        // 下方向のドラッグのみ許可
                                        if value.translation.height > 0 {
                                            dragOffset = value.translation.height
                                            // ドラッグ量に応じて透明度を変更
                                            opacity = max(0.0, 1.0 - Double(dragOffset / 200))
                                        }
                                    }
                                    .onEnded { value in
                                        // 閾値を超えたら閉じる
                                        if value.translation.height > 300 {
                                            closeCard()
                                        } else {
                                            // 閾値未満なら元の位置に戻す
                                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                                dragOffset = 0
                                                opacity = 1
                                            }
                                        }
                                    }
                            )
                    }
                    .padding(.top, geometry.safeAreaInsets.top * 0.5)
                    // 上部フェードオーバーレイ
                    .overlay(alignment: .top) {
                        LinearGradient(
                            colors: [
                                Color(.secondarySystemBackground),
                                Color(.secondarySystemBackground).opacity(0)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .frame(height: 60)
                        .blur(radius: 8)
                        .allowsHitTesting(false)
                    }
                }
                .ignoresSafeArea()
                .transition(.asymmetric(
                    insertion: .scale(scale: 0.9).combined(with: .opacity),
                    removal: .scale(scale: 0.9).combined(with: .opacity)
                ))
                .zIndex(1)
            }
        }
        .onChange(of: isExpanded) { newValue in
            if newValue {
                withAnimation(.easeInOut(duration: 0.2)) {
                    opacity = 1
                }
            }
        }
    }

    private func closeCard() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
            isExpanded = false
            dragOffset = 0
            opacity = 0
        }
    }
}

// MARK: - ViewModifier for Easy Integration

struct ExpandableCardModifier: ViewModifier {
    let detail: HealthMetricDetail?
    @Binding var isExpanded: Bool
    var namespace: Namespace.ID?

    func body(content: Content) -> some View {
        ZStack {
            content
                .blur(radius: isExpanded ? 8 : 0)
                .animation(.easeInOut(duration: 0.3), value: isExpanded)

            if let detail = detail {
                ExpandableCardOverlay(detail: detail, isExpanded: $isExpanded, namespace: namespace)
            }
        }
    }
}

extension View {
    func expandableCard(detail: HealthMetricDetail?, isExpanded: Binding<Bool>, namespace: Namespace.ID? = nil) -> some View {
        modifier(ExpandableCardModifier(detail: detail, isExpanded: isExpanded, namespace: namespace))
    }
}

// MARK: - Preview

#if DEBUG
struct ExpandableCardOverlay_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var isExpanded = false
        @Namespace private var animation

        var body: some View {
            ZStack {
                Color.gray.opacity(0.3)
                    .ignoresSafeArea()

                VStack {
                    Button("Expand Card") {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            isExpanded.toggle()
                        }
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
            }
            .expandableCard(
                detail: .metabolicSample,
                isExpanded: $isExpanded,
                namespace: animation
            )
        }
    }

    static var previews: some View {
        PreviewWrapper()
            .preferredColorScheme(.dark)
    }
}
#endif
