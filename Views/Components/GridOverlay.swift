//
//  GridOverlay.swift
//  AWStest
//
//  詳細ページ用グリッドオーバーレイ
//

import SwiftUI

struct GridOverlay: View {
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Vertical grid lines
                HStack(spacing: 0) {
                    ForEach(0..<8) { _ in
                        Divider()
                            .background(Color.white.opacity(0.05))
                        Spacer()
                    }
                    Divider()
                        .background(Color.white.opacity(0.05))
                }

                // Horizontal grid lines
                VStack(spacing: 0) {
                    ForEach(0..<12) { _ in
                        Divider()
                            .background(Color.white.opacity(0.05))
                        Spacer()
                    }
                    Divider()
                        .background(Color.white.opacity(0.05))
                }
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}
