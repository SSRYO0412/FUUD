//
//  HorizontalBarView.swift
//  AWStest
//
//  横バービジュアル（回復スピード用）
//

import SwiftUI

struct HorizontalBarView: View {
    let progress: Double // 0.0 ~ 1.0
    let colors: [Color]

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 背景バー
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 12)

                // プログレスバー（グラデーション）
                RoundedRectangle(cornerRadius: 8)
                    .fill(
                        LinearGradient(
                            colors: colors,
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress, height: 12)
            }
        }
        .frame(height: 12)
    }
}

#if DEBUG
struct HorizontalBarView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            HorizontalBarView(
                progress: 0.71,
                colors: [Color(hex: "F4E04D"), Color(hex: "9FD356"), Color(hex: "4FC0D0")]
            )
            .frame(width: 200)

            HorizontalBarView(
                progress: 0.43,
                colors: [Color(hex: "F4E04D"), Color(hex: "9FD356")]
            )
            .frame(width: 200)
        }
        .padding()
        .background(Color.black)
    }
}
#endif
