//
//  MicrobiomeSection.swift
//  AWStest
//
//  腸内細菌セクションコンポーネント
//

import SwiftUI

// MARK: - Data Model

struct MicrobiomeItem {
    let name: String
    let description: String
    let impact: String
    let color: Color
}

// MARK: - Microbiome Section

struct MicrobiomeSection: View {
    let bacteria: [MicrobiomeItem]  // [DUMMY] 腸内細菌データ、API連携後に実データ使用

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            HStack {
                Text("🦠")
                    .font(.system(size: 16))
                Text("RELATED MICROBIOME")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.virgilTextSecondary)
            }

            VStack(spacing: VirgilSpacing.sm) {
                ForEach(bacteria.indices, id: \.self) { index in
                    MicrobiomeCard(item: bacteria[index])
                }
            }
        }
        .padding(VirgilSpacing.md)
        .liquidGlassCard()
    }
}

// MARK: - Microbiome Card

private struct MicrobiomeCard: View {
    let item: MicrobiomeItem

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.xs) {
            HStack {
                Text(item.name)
                    .font(.system(size: 11, weight: .semibold))
                    .italic()
                    .foregroundColor(.virgilTextPrimary)

                Spacer()

                Text(item.impact)
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(item.color)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(item.color.opacity(0.1))
                    .cornerRadius(4)
            }

            Text(item.description)
                .font(.system(size: 9, weight: .regular))
                .foregroundColor(.virgilTextSecondary)
        }
        .padding(VirgilSpacing.sm)
        .background(Color.black.opacity(0.02))
        .cornerRadius(8)
    }
}

// MARK: - Preview

#if DEBUG
struct MicrobiomeSection_Previews: PreviewProvider {
    static var previews: some View {
        MicrobiomeSection(bacteria: [
            // [DUMMY] プレビュー用データ
            MicrobiomeItem(
                name: "Faecalibacterium",
                description: "酪酸産生菌・腸内環境を改善",
                impact: "優秀",
                color: Color(hex: "00C853")
            ),
            MicrobiomeItem(
                name: "Bifidobacterium",
                description: "プロバイオティクス・免疫機能向上",
                impact: "良好",
                color: Color(hex: "FFCB05")
            )
        ])
        .padding()
        .background(Color.white)
    }
}
#endif
