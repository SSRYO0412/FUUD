//
//  ProgramRoadmapDetailView.swift
//  FUUD
//
//  Lifesum-style Program Roadmap Detail View
//  コース開始前のロードマップ詳細画面
//  通常版 / pro版（血液検査ベース）対応
//

import SwiftUI

struct ProgramRoadmapDetailView: View {
    let program: DietProgram
    let selectedDuration: Int
    let mode: ProgramMode
    let onStart: (ProgramEnrollment) -> Void

    @Environment(\.presentationMode) var presentationMode
    @StateObject private var programService = DietProgramService.shared
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showReplaceConfirmation = false

    private var courseFocus: CourseFocus {
        HighProteinRoadmap.getFocus(duration: selectedDuration)
    }

    private var roadmapPhases: [RoadmapPhase] {
        HighProteinRoadmap.getPhases(duration: selectedDuration)
    }

    var body: some View {
        ZStack {
            // Full-screen dark green background
            Color.lifesumDarkGreen
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: VirgilSpacing.xl) {
                    // Header Section
                    headerSection

                    // PFC Pie Chart Section
                    pfcChartSection

                    // Divider
                    sectionDivider(title: "DOS AND DON'TS")

                    // DOS and DON'TS Section
                    dosAndDontsSection

                    // Divider
                    sectionDivider(title: "WEEKLY ROADMAP")

                    // Weekly Roadmap Section (Expandable)
                    weeklyRoadmapSection

                    // Bottom spacing for button
                    Color.clear.frame(height: 80)
                }
                .padding(.horizontal, VirgilSpacing.lg)
                .padding(.top, VirgilSpacing.xl)
            }

            // Fixed Start Button at bottom
            VStack {
                Spacer()
                startButtonSection
            }
        }
        .navigationBarHidden(true)
        .alert("エラー", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
        .confirmationDialog(
            "プログラムの変更",
            isPresented: $showReplaceConfirmation,
            titleVisibility: .visible
        ) {
            Button("新しいプログラムを開始", role: .destructive) {
                Task {
                    await replaceProgram()
                }
            }
            Button("キャンセル", role: .cancel) {}
        } message: {
            Text("現在のプログラムを終了して、新しいプログラムを開始しますか？")
        }
        .task {
            await programService.fetchEnrolledProgram()
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: VirgilSpacing.md) {
            // Back button row
            HStack {
                Button {
                    presentationMode.wrappedValue.dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))
                }
                Spacer()

                // Mode badge
                Text(mode.displayName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(mode == .pro ? .orange : .white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(mode == .pro ? Color.orange.opacity(0.2) : Color.white.opacity(0.2))
                    )
            }

            // Program name (small)
            Text(program.nameJa.uppercased())
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.7))
                .tracking(2)

            // Course duration
            Text("\(selectedDuration)日コース")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))

            // Main title "Your focus"
            Text("Your focus")
                .font(.system(size: 36, weight: .regular, design: .serif))
                .foregroundColor(.white)
                .padding(.top, VirgilSpacing.sm)

            // Course concept
            Text(courseFocus.concept)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
                .multilineTextAlignment(.center)
                .padding(.horizontal, VirgilSpacing.lg)
        }
    }

    // MARK: - PFC Chart Section

    private var pfcChartSection: some View {
        HStack(spacing: VirgilSpacing.xl) {
            // Pie Chart
            RoadmapPFCPieChart(pfc: courseFocus.pfc)
                .frame(width: 140, height: 140)

            // Legend
            VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
                pfcLegendItem(label: "Protein", percentage: Int(courseFocus.pfc.protein), color: Color(hex: "4ECDC4"))
                pfcLegendItem(label: "Fat", percentage: Int(courseFocus.pfc.fat), color: Color(hex: "FFE66D"))
                pfcLegendItem(label: "Carbs", percentage: Int(courseFocus.pfc.carbs), color: Color(hex: "95E1D3"))
            }
        }
        .padding(.vertical, VirgilSpacing.md)
    }

    private func pfcLegendItem(label: String, percentage: Int, color: Color) -> some View {
        HStack(spacing: VirgilSpacing.sm) {
            Circle()
                .fill(color)
                .frame(width: 12, height: 12)

            Text(label)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))

            Text("\(percentage)%")
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)
        }
    }

    // MARK: - Section Divider

    private func sectionDivider(title: String) -> some View {
        HStack {
            Rectangle()
                .fill(Color.white.opacity(0.3))
                .frame(height: 1)

            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.6))
                .tracking(1)

            Rectangle()
                .fill(Color.white.opacity(0.3))
                .frame(height: 1)
        }
    }

    // MARK: - DOS and DON'TS Section

    private var dosAndDontsSection: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            // DO items
            ForEach(courseFocus.dos, id: \.self) { item in
                HStack(alignment: .top, spacing: VirgilSpacing.sm) {
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: "4ECDC4"))
                        .frame(width: 20)

                    Text(item)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }

            // DON'T items
            ForEach(courseFocus.donts, id: \.self) { item in
                HStack(alignment: .top, spacing: VirgilSpacing.sm) {
                    Image(systemName: "xmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: "FF6B6B"))
                        .frame(width: 20)

                    Text(item)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.9))
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
    }

    // MARK: - Weekly Roadmap Section

    private var weeklyRoadmapSection: some View {
        VStack(spacing: VirgilSpacing.md) {
            ForEach(roadmapPhases) { phase in
                RoadmapWeekCard(phase: phase, showProNotes: mode == .pro)
            }
        }
    }

    // MARK: - Start Button Section

    private var startButtonSection: some View {
        VStack {
            Button {
                Task {
                    if programService.isEnrolled {
                        showReplaceConfirmation = true
                    } else {
                        await startProgram()
                    }
                }
            } label: {
                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .lifesumDarkGreen))
                    } else {
                        Text("このコースで始める")
                            .font(.system(size: 16, weight: .bold))
                    }
                }
                .foregroundColor(.lifesumDarkGreen)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.white)
                .cornerRadius(28)
            }
            .disabled(isLoading)
            .padding(.horizontal, VirgilSpacing.lg)
            .padding(.bottom, VirgilSpacing.xl)
        }
        .background(
            LinearGradient(
                colors: [Color.lifesumDarkGreen.opacity(0), Color.lifesumDarkGreen],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 100)
            .allowsHitTesting(false)
        )
    }

    // MARK: - Helper Functions

    private func startProgram() async {
        isLoading = true

        let success = await programService.enrollProgram(
            program.id,
            duration: selectedDuration,
            startDate: Date()
        )

        isLoading = false

        if success, let enrollment = programService.enrolledProgram {
            NotificationCenter.default.post(name: .programEnrollmentChanged, object: nil)
            presentationMode.wrappedValue.dismiss()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                onStart(enrollment)
            }
        } else {
            errorMessage = programService.errorMessage ?? "プログラムの開始に失敗しました"
            showError = true
        }
    }

    private func replaceProgram() async {
        isLoading = true

        let cancelled = await programService.cancelEnrollment()

        if cancelled {
            await startProgram()
        } else {
            isLoading = false
            errorMessage = programService.errorMessage ?? "プログラムの終了に失敗しました"
            showError = true
        }
    }
}

// MARK: - Roadmap PFC Pie Chart

struct RoadmapPFCPieChart: View {
    let pfc: PFCRatio

    private var slices: [(startAngle: Double, endAngle: Double, color: Color)] {
        let protein = pfc.protein / 100
        let fat = pfc.fat / 100
        let carbs = pfc.carbs / 100

        var currentAngle = -90.0  // Start from top
        var result: [(Double, Double, Color)] = []

        // Protein
        let proteinEnd = currentAngle + protein * 360
        result.append((currentAngle, proteinEnd, Color(hex: "4ECDC4")))
        currentAngle = proteinEnd

        // Fat
        let fatEnd = currentAngle + fat * 360
        result.append((currentAngle, fatEnd, Color(hex: "FFE66D")))
        currentAngle = fatEnd

        // Carbs
        let carbsEnd = currentAngle + carbs * 360
        result.append((currentAngle, carbsEnd, Color(hex: "95E1D3")))

        return result
    }

    var body: some View {
        ZStack {
            // Pie slices
            ForEach(0..<slices.count, id: \.self) { index in
                PieSlice(
                    startAngle: Angle(degrees: slices[index].startAngle),
                    endAngle: Angle(degrees: slices[index].endAngle)
                )
                .fill(slices[index].color)
            }

            // Center circle (donut hole)
            Circle()
                .fill(Color.lifesumDarkGreen)
                .padding(25)

            // Center text
            VStack(spacing: 2) {
                Text("P:\(Int(pfc.protein))")
                    .font(.system(size: 11, weight: .bold))
                Text("F:\(Int(pfc.fat))")
                    .font(.system(size: 11, weight: .bold))
                Text("C:\(Int(pfc.carbs))")
                    .font(.system(size: 11, weight: .bold))
            }
            .foregroundColor(.white)
        }
    }
}

// MARK: - Pie Slice Shape

struct PieSlice: Shape {
    var startAngle: Angle
    var endAngle: Angle

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2

        path.move(to: center)
        path.addArc(
            center: center,
            radius: radius,
            startAngle: startAngle,
            endAngle: endAngle,
            clockwise: false
        )
        path.closeSubpath()

        return path
    }
}

// MARK: - Roadmap Week Card

struct RoadmapWeekCard: View {
    let phase: RoadmapPhase
    let showProNotes: Bool

    init(phase: RoadmapPhase, showProNotes: Bool = false) {
        self.phase = phase
        self.showProNotes = showProNotes
    }

    var body: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            // Week header
            HStack {
                Text("Week \(phase.weekNumber)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.2))
                    .cornerRadius(4)

                Text(phase.dayRange)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }

            // Phase title
            Text(phase.title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.white)

            // Subtitle (週テーマ)
            Text(phase.subtitle)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))

            // User benefit (メリット)
            HStack(alignment: .top, spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.system(size: 10))
                    .foregroundColor(Color(hex: "FFE66D"))

                Text(phase.userBenefit)
                    .font(.caption)
                    .foregroundColor(Color(hex: "FFE66D"))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(.top, 2)

            // Focus points
            VStack(alignment: .leading, spacing: 4) {
                ForEach(phase.focusPoints, id: \.self) { point in
                    HStack(alignment: .top, spacing: 6) {
                        Circle()
                            .fill(Color.white.opacity(0.5))
                            .frame(width: 4, height: 4)
                            .padding(.top, 6)

                        Text(point)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
            }

            // Pro Notes (血液検査ベースの微調整 - pro版のみ表示)
            if showProNotes && !phase.proNotes.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Text("🩸")
                            .font(.caption)
                        Text("血液検査ベースの微調整")
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                    .padding(.top, 4)

                    ForEach(phase.proNotes, id: \.self) { note in
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 8))
                                .foregroundColor(.orange.opacity(0.8))
                                .padding(.top, 4)

                            Text(note)
                                .font(.caption2)
                                .foregroundColor(.orange.opacity(0.9))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                }
                .padding(VirgilSpacing.sm)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(8)
            }
        }
        .padding(VirgilSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        ProgramRoadmapDetailView(
            program: DietProgramCatalog.programs[0],
            selectedDuration: 45,
            mode: .pro
        ) { _ in }
    }
}
