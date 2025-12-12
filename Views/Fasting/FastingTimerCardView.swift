//
//  FastingTimerCardView.swift
//  FUUD
//
//  Fasting Timer Card for Home - Lifesum style
//

import SwiftUI

struct FastingTimerCardView: View {
    @StateObject private var viewModel = FastingTimerViewModel.shared
    @State private var showingDetail = false

    private let backgroundColor = Color(hex: "F5F0E8")

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with badge
            HStack {
                Text("FASTING WINDOW")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(Color(hex: "4CD964"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color(hex: "4CD964").opacity(0.15))
                    .cornerRadius(12)

                Spacer()

                Button(action: { showingDetail = true }) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }

            // Plan info
            Text("\(viewModel.selectedPlan.displayName) Fasting interval")
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(.primary)

            // Time range
            if let startTime = viewModel.fastingStartTime,
               let endTime = viewModel.fastingEndTime {
                Text("Fasting from \(viewModel.formatTime(startTime)) - \(viewModel.formatTime(endTime))")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            } else {
                Text("断食を開始してタイマーを始めましょう")
                    .font(.system(size: 13))
                    .foregroundColor(.secondary)
            }

            // Status indicator (if active)
            if viewModel.state.isActive {
                HStack(spacing: 8) {
                    // Mini progress ring
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 3)
                            .frame(width: 24, height: 24)

                        Circle()
                            .trim(from: 0, to: viewModel.progress)
                            .stroke(
                                viewModel.state.isFasting ? Color(hex: "C77DFF") : Color(hex: "4CD964"),
                                style: StrokeStyle(lineWidth: 3, lineCap: .round)
                            )
                            .frame(width: 24, height: 24)
                            .rotationEffect(.degrees(-90))
                    }

                    Text(viewModel.state.isFasting ? "断食中" : "食事時間")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(viewModel.state.isFasting ? Color(hex: "C77DFF") : Color(hex: "4CD964"))

                    Text(viewModel.formattedElapsedTime)
                        .font(.system(size: 12, weight: .bold, design: .monospaced))
                        .foregroundColor(.primary)
                }
                .padding(.top, 4)
            }

            // Go to fasting button
            Button(action: { showingDetail = true }) {
                Text("GO TO FASTING")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Color(hex: "4CD964"))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
        }
        .padding(16)
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
        .fullScreenCover(isPresented: $showingDetail) {
            FastingTimerDetailView()
        }
    }
}

// MARK: - Preview

#if DEBUG
struct FastingTimerCardView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color(hex: "F5F0E8").ignoresSafeArea()
            FastingTimerCardView()
                .padding()
        }
    }
}
#endif
