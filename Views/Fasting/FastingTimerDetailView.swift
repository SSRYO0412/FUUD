//
//  FastingTimerDetailView.swift
//  FUUD
//
//  Fasting Timer Detail View - Lifesum style
//

import SwiftUI

struct FastingTimerDetailView: View {
    @StateObject private var viewModel = FastingTimerViewModel.shared
    @Environment(\.dismiss) private var dismiss

    @State private var showingEndFastSheet = false
    @State private var showingPlanPicker = false
    @State private var selectedEndDate = Date()

    private let backgroundColor = Color(hex: "F5F0E8")

    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Main content
                    ScrollView {
                        VStack(spacing: 24) {
                            // Fasting card
                            fastingCard
                                .padding(.horizontal, 16)
                                .padding(.top, 16)
                        }
                    }

                    // Bottom buttons
                    bottomButtons
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                            .frame(width: 36, height: 36)
                            .background(Color(.systemBackground))
                            .clipShape(Circle())
                    }
                }

                ToolbarItem(placement: .principal) {
                    Text("Fasting")
                        .font(.system(size: 17, weight: .semibold))
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "info.circle")
                            .font(.system(size: 16))
                            .foregroundColor(.primary)
                            .frame(width: 36, height: 36)
                            .background(Color(.systemBackground))
                            .clipShape(Circle())
                    }
                }
            }
            .sheet(isPresented: $showingEndFastSheet) {
                endFastSheet
            }
            .sheet(isPresented: $showingPlanPicker) {
                planPickerSheet
            }
        }
    }

    // MARK: - Fasting Card

    private var fastingCard: some View {
        VStack(spacing: 20) {
            // Plan selector
            Button(action: { showingPlanPicker = true }) {
                HStack(spacing: 6) {
                    Image(systemName: "pencil")
                        .font(.system(size: 12))
                    Text(viewModel.selectedPlan.displayName)
                        .font(.system(size: 14, weight: .medium))
                }
                .foregroundColor(.primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                .cornerRadius(20)
                .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            }

            // Status message
            VStack(spacing: 8) {
                Text(viewModel.state.isFasting ? "You're in your fasting window" :
                     viewModel.state.isEating ? "You're in your eating window" :
                     "Ready to start fasting")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)

                // Ketosis indicator (only during fasting)
                if viewModel.state.isFasting && viewModel.ketosisPhase != .notStarted {
                    HStack(spacing: 4) {
                        Image(systemName: "bolt.fill")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "C77DFF"))
                        Text(viewModel.ketosisPhase.displayName)
                            .font(.system(size: 13))
                            .foregroundColor(.secondary)
                    }
                }

                // Eating window message
                if viewModel.state.isEating {
                    Text("Eat colorful meals to get all your nutrients")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                }
            }

            // Progress ring
            progressRing

            // Time info
            if viewModel.state.isActive {
                timeInfoSection
            }
        }
        .padding(24)
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 2)
    }

    // MARK: - Progress Ring

    private var progressRing: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(Color.gray.opacity(0.15), lineWidth: 16)
                .frame(width: 220, height: 220)

            // Progress arc
            Circle()
                .trim(from: 0, to: viewModel.progress)
                .stroke(
                    progressGradient,
                    style: StrokeStyle(lineWidth: 16, lineCap: .round)
                )
                .frame(width: 220, height: 220)
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 0.5), value: viewModel.progress)

            // Progress dot at end
            if viewModel.state.isActive {
                Circle()
                    .fill(progressColor)
                    .frame(width: 16, height: 16)
                    .offset(y: -110)
                    .rotationEffect(.degrees(360 * viewModel.progress))
            }

            // Center content
            VStack(spacing: 4) {
                Text(viewModel.state.isFasting ? "Fasting for" :
                     viewModel.state.isEating ? "Eating for" : "")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)

                Text(viewModel.formattedElapsedTime)
                    .font(.system(size: 40, weight: .semibold, design: .default))
                    .foregroundColor(.primary)

                if viewModel.state.isActive {
                    Button(action: {
                        if viewModel.state.isFasting {
                            selectedEndDate = Date()
                            showingEndFastSheet = true
                        }
                    }) {
                        Text(viewModel.state.isFasting ? "Done" : "\(viewModel.formattedRemainingTime) left")
                            .font(.system(size: 13))
                            .foregroundColor(viewModel.state.isFasting ? Color(hex: "C77DFF") : .secondary)
                    }
                    .disabled(!viewModel.state.isFasting)
                }
            }
        }
        .padding(.vertical, 16)
    }

    private var progressGradient: LinearGradient {
        if viewModel.state.isFasting {
            return LinearGradient(
                colors: [Color(hex: "C77DFF"), Color(hex: "E040FB")],
                startPoint: .leading,
                endPoint: .trailing
            )
        } else {
            return LinearGradient(
                colors: [Color(hex: "4CD964"), Color(hex: "34C759")],
                startPoint: .leading,
                endPoint: .trailing
            )
        }
    }

    private var progressColor: Color {
        viewModel.state.isFasting ? Color(hex: "C77DFF") : Color(hex: "4CD964")
    }

    // MARK: - Time Info Section

    private var timeInfoSection: some View {
        HStack(spacing: 40) {
            // Start of fast
            VStack(alignment: .leading, spacing: 4) {
                Text("Start of fast:")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.primary)

                if let startTime = viewModel.fastingStartTime {
                    Text(viewModel.formatShortDate(startTime))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }

                Button(action: {}) {
                    HStack(spacing: 4) {
                        Image(systemName: "pencil")
                            .font(.system(size: 10))
                        Text("Edit")
                            .font(.system(size: 11))
                    }
                    .foregroundColor(.secondary)
                }
            }

            Spacer()

            // End of fast
            VStack(alignment: .trailing, spacing: 4) {
                Text("End of fast:")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.primary)

                if let endTime = viewModel.fastingEndTime {
                    Text(viewModel.formatShortDate(endTime))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Bottom Buttons

    private var bottomButtons: some View {
        VStack(spacing: 12) {
            // Main action button
            Button(action: {
                if viewModel.state.isFasting {
                    selectedEndDate = Date()
                    showingEndFastSheet = true
                } else if viewModel.state.isEating {
                    viewModel.startNextFast()
                } else {
                    viewModel.startFasting()
                }
            }) {
                HStack(spacing: 8) {
                    if viewModel.state.isFasting {
                        Image(systemName: "stop.fill")
                            .font(.system(size: 14))
                    } else {
                        Image(systemName: "play.fill")
                            .font(.system(size: 14))
                    }

                    Text(viewModel.state.isFasting ? "END FAST" : "START FASTING")
                        .font(.system(size: 16, weight: .semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(viewModel.state.isFasting ? Color(hex: "C77DFF") : Color(hex: "4CD964"))
                .cornerRadius(12)
            }
            .padding(.horizontal, 16)

            // Cancel button
            if viewModel.state.isActive {
                Button(action: { viewModel.cancelFasting() }) {
                    Text("CANCEL FASTING")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 8)
            }
        }
        .padding(.vertical, 16)
        .background(backgroundColor)
    }

    // MARK: - End Fast Sheet

    private var endFastSheet: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("When did you end your fast?")
                    .font(.system(size: 17, weight: .semibold))

                Spacer()

                Button(action: { showingEndFastSheet = false }) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.secondary)
                }
            }
            .padding()

            Divider()

            // Date picker
            DatePicker(
                "",
                selection: $selectedEndDate,
                in: (viewModel.fastingStartTime ?? Date())...Date(),
                displayedComponents: [.date, .hourAndMinute]
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .padding()

            Spacer()

            // End fast button
            Button(action: {
                viewModel.endFasting(at: selectedEndDate)
                showingEndFastSheet = false
            }) {
                Text("END FAST")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color(hex: "4CD964"))
                    .cornerRadius(12)
            }
            .padding()
        }
    }

    // MARK: - Plan Picker Sheet

    private var planPickerSheet: some View {
        NavigationView {
            List {
                ForEach(FastingPlan.allCases, id: \.self) { plan in
                    Button(action: {
                        viewModel.changePlan(to: plan)
                        showingPlanPicker = false
                    }) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(plan.displayName)
                                    .font(.system(size: 17, weight: .medium))
                                    .foregroundColor(.primary)

                                Text("\(plan.fastingHours)時間断食 / \(plan.eatingHours)時間食事")
                                    .font(.system(size: 13))
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if viewModel.selectedPlan == plan {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color(hex: "4CD964"))
                            }
                        }
                    }
                }
            }
            .navigationTitle("プランを選択")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        showingPlanPicker = false
                    }
                }
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct FastingTimerDetailView_Previews: PreviewProvider {
    static var previews: some View {
        FastingTimerDetailView()
    }
}
#endif
