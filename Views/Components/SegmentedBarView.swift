//
//  SegmentedBarView.swift
//  AWStest
//
//  セグメントバービジュアル（代謝力用）
//

import SwiftUI

struct SegmentedBarView: View {
    let progress: Double // 0.0 ~ 1.0
    let segmentCount: Int // セグメント数
    let activeColor: Color
    let inactiveColor: Color

    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 4) {
                ForEach(0..<segmentCount, id: \.self) { index in
                    let segmentProgress = Double(index + 1) / Double(segmentCount)
                    let isActive = progress >= segmentProgress

                    RoundedRectangle(cornerRadius: 4)
                        .fill(isActive ? activeColor : inactiveColor)
                        .frame(height: 12)
                }
            }
        }
        .frame(height: 12)
    }
}

#if DEBUG
struct SegmentedBarView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            SegmentedBarView(
                progress: 0.35,
                segmentCount: 3,
                activeColor: Color(hex: "5E7CE2"),
                inactiveColor: Color.gray.opacity(0.3)
            )
            .frame(width: 200)

            SegmentedBarView(
                progress: 0.8,
                segmentCount: 5,
                activeColor: Color(hex: "00C853"),
                inactiveColor: Color.gray.opacity(0.3)
            )
            .frame(width: 200)
        }
        .padding()
        .background(Color.black)
    }
}
#endif
