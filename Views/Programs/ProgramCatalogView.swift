//
//  ProgramCatalogView.swift
//  FUUD
//
//  Lifesum-style program catalog with category sections
//

import SwiftUI

struct ProgramCatalogView: View {
    @StateObject private var programService = DietProgramService.shared
    @StateObject private var traitsViewModel = YourTraitsViewModel()
    @StateObject private var recommender = ProgramRecommender.shared
    @State private var selectedProgram: DietProgram?
    @State private var showingDetail = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Dark Green Header
                headerSection

                // Your Traits + おすすめプログラム カルーセル
                YourTraitsCarouselSection(
                    traitsViewModel: traitsViewModel,
                    recommender: recommender,
                    onProgramTap: { program in
                        selectedProgram = program
                        showingDetail = true
                    }
                )
                .padding(.top, VirgilSpacing.lg)

                // Category Sections
                VStack(spacing: VirgilSpacing.xl) {
                    // BIOHACKING
                    categorySection(
                        title: "BIOHACKING",
                        programs: programsByCategory(.biohacking)
                    )

                    // BALANCED
                    categorySection(
                        title: "BALANCED",
                        programs: programsByCategory(.balanced)
                    )

                    // FASTING
                    categorySection(
                        title: "FASTING",
                        programs: programsByCategory(.fasting)
                    )

                    // HIGH PROTEIN
                    categorySection(
                        title: "HIGH PROTEIN",
                        programs: programsByCategory(.highProtein)
                    )

                    // KETO / LOW CARB
                    categorySection(
                        title: "KETO / LOW CARB",
                        programs: programsByCategory(.lowCarb)
                    )
                }
                .padding(.top, VirgilSpacing.lg)
                .padding(.bottom, VirgilSpacing.xl4)
            }
        }
        .background(Color(.systemBackground))
        .navigationBarHidden(true)
        .task {
            // 並列でデータ読み込み
            async let traitsTask: () = traitsViewModel.loadAllTraits()
            async let recommendTask: () = recommender.calculateRecommendations()
            _ = await (traitsTask, recommendTask)
        }
        .background(
            Group {
                if let program = selectedProgram {
                    NavigationLink(
                        destination: ProgramDetailView(program: program),
                        isActive: $showingDetail
                    ) {
                        EmptyView()
                    }
                }
            }
        )
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: VirgilSpacing.md) {
            // Safe area spacer
            Color.clear.frame(height: 44)

            VStack(spacing: VirgilSpacing.sm) {
                Text("Find your plan")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundColor(.white)

                Text("あなたに合ったプログラムを見つけよう")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding(.bottom, VirgilSpacing.lg)
        }
        .frame(maxWidth: .infinity)
        .background(
            Color.lifesumDarkGreen
                .clipShape(RoundedCorner(radius: 24, corners: [.bottomLeft, .bottomRight]))
        )
        .ignoresSafeArea(edges: .top)
    }

    // MARK: - Category Section

    private func categorySection(title: String, programs: [DietProgram]) -> some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            // Section Title
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.secondary)
                .padding(.horizontal, VirgilSpacing.md)

            // Horizontal Scroll
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: VirgilSpacing.md) {
                    ForEach(programs) { program in
                        LifesumProgramCard(
                            program: program,
                            isCurrent: programService.enrolledProgram?.programId == program.id,
                            isNew: isNewProgram(program)
                        ) {
                            selectedProgram = program
                            showingDetail = true
                        }
                        .frame(width: 195) // 150 * 1.3 = 195
                    }
                }
                .padding(.horizontal, VirgilSpacing.md)
            }
        }
    }

    // MARK: - Helper Functions

    private func programsByCategory(_ category: ProgramCategory) -> [DietProgram] {
        DietProgramCatalog.programs.filter { $0.category == category }
    }

    private func isNewProgram(_ program: DietProgram) -> Bool {
        // Programs with "NEW" tag or specific IDs can be marked as new
        program.tags.contains("NEW") || program.tags.contains("new")
    }
}

// MARK: - Lifesum Style Program Card

struct LifesumProgramCard: View {
    let program: DietProgram
    let isCurrent: Bool
    let isNew: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 0) {
                // Image Section
                ZStack(alignment: .topLeading) {
                    // Program Image (placeholder for now)
                    Image(program.imageAssetName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 130) // 100 * 1.3 = 130
                        .clipped()
                        .background(
                            // Fallback gradient if image not found
                            LinearGradient(
                                colors: [categoryColor(program.category).opacity(0.3), categoryColor(program.category).opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    // NEW Badge
                    if isNew {
                        Text("NEW")
                            .font(.system(size: 12, weight: .bold)) // 10 * 1.3 ≈ 12
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.lifesumLightGreen)
                            .cornerRadius(5)
                            .padding(10)
                    }
                }

                // Content Section
                VStack(alignment: .leading, spacing: 6) {
                    // Category Label
                    Text(categoryLabel(program.category))
                        .font(.system(size: 11, weight: .semibold)) // 9 * 1.3 ≈ 11
                        .foregroundColor(categoryColor(program.category))

                    // Program Name
                    Text(program.nameJa)
                        .font(.system(size: 16, weight: .semibold)) // 14 * 1.3 ≈ 16
                        .foregroundColor(.primary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)

                    // CURRENT Label
                    if isCurrent {
                        Text("CURRENT PLAN")
                            .font(.system(size: 11, weight: .bold)) // 10 * 1.3 ≈ 11
                            .foregroundColor(.lifesumDarkGreen)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.lifesumDarkGreen.opacity(0.1))
                            .cornerRadius(4)
                            .padding(.top, 4)
                    }
                }
                .padding(VirgilSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .background(Color.lifesumCream)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }

    private func categoryLabel(_ category: ProgramCategory) -> String {
        switch category {
        case .biohacking: return "BIOHACKING"
        case .balanced: return "BALANCED"
        case .fasting: return "FASTING"
        case .highProtein: return "HIGH PROTEIN"
        case .lowCarb: return "KETO"
        }
    }

    private func categoryColor(_ category: ProgramCategory) -> Color {
        switch category {
        case .biohacking: return .purple
        case .balanced: return .lifesumDarkGreen
        case .fasting: return .orange
        case .highProtein: return .blue
        case .lowCarb: return .teal
        }
    }
}

// MARK: - Rounded Corner Helper

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        ProgramCatalogView()
    }
}
