//
//  ProgramDetailView.swift
//  FUUD
//
//  Lifesum-style program detail view
//

import SwiftUI

struct ProgramDetailView: View {
    let program: DietProgram
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var programService = DietProgramService.shared
    @State private var showingDurationSheet = false
    @State private var showingProgressView = false

    var body: some View {
        ZStack(alignment: .top) {
            // Background
            Color(.systemBackground).ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // Spacer for header
                    Color.clear.frame(height: 200)

                    // Content
                    VStack(alignment: .leading, spacing: VirgilSpacing.xl) {
                        // Description
                        descriptionSection

                        // HERE'S WHAT YOU GET
                        heresWhatYouGetSection

                        // Recipes Section
                        recipesSection

                        // Expert Quote
                        expertQuoteSection

                        // Expected Results
                        expectedResultsSection

                        // Program Flow
                        programFlowSection

                        // Contraindications
                        if !program.contraindications.isEmpty {
                            contraindicationsSection
                        }
                    }
                    .padding(.horizontal, VirgilSpacing.md)
                    .padding(.bottom, VirgilSpacing.xl4)
                }
            }

            // Fixed Header
            headerSection
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingDurationSheet) {
            DurationSelectionSheet(program: program) { enrollment in
                showingProgressView = true
            }
        }
        .background(
            NavigationLink(
                destination: ProgramProgressView(program: program),
                isActive: $showingProgressView
            ) {
                EmptyView()
            }
        )
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 0) {
            // Header Background
            ZStack(alignment: .bottom) {
                // Background with program image
                ZStack {
                    Image(program.imageAssetName)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .clipped()

                    // Dark overlay
                    Color.lifesumDarkGreen.opacity(0.85)
                }
                .frame(height: 200)

                // Content
                VStack(spacing: VirgilSpacing.md) {
                    // Navigation Bar
                    HStack {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "chevron.left")
                                Text("戻る")
                            }
                            .foregroundColor(.white)
                        }

                        Spacer()

                        // Category Badge
                        Text(program.category.displayNameEn.uppercased())
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.horizontal, VirgilSpacing.md)
                    .padding(.top, 50)

                    Spacer()

                    // Program Name
                    Text(program.nameJa)
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, VirgilSpacing.md)

                    // START PLAN Button
                    Button {
                        showingDurationSheet = true
                    } label: {
                        Text("START PLAN")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.lifesumDarkGreen)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color.white)
                            .cornerRadius(25)
                            .padding(.horizontal, VirgilSpacing.lg)
                    }
                    .padding(.bottom, VirgilSpacing.md)
                }
            }
            .clipShape(RoundedCorner(radius: 24, corners: [.bottomLeft, .bottomRight]))
        }
        .ignoresSafeArea(edges: .top)
    }

    // MARK: - Description Section

    private var descriptionSection: some View {
        Text(program.description)
            .font(.body)
            .foregroundColor(.secondary)
            .lineSpacing(4)
    }

    // MARK: - HERE'S WHAT YOU GET Section

    private var heresWhatYouGetSection: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            Text("HERE'S WHAT YOU GET")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.secondary)

            VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
                ForEach(program.features, id: \.self) { feature in
                    HStack(alignment: .top, spacing: VirgilSpacing.sm) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.lifesumDarkGreen)
                            .frame(width: 20)

                        Text(feature)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }

    // MARK: - Recipes Section

    private var recipesSection: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            Text("Recipes")
                .font(.system(size: 20, weight: .bold, design: .serif))
                .foregroundColor(.primary)

            // Large Recipe Image
            ZStack(alignment: .bottomLeading) {
                Image(program.imageAssetName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipped()
                    .cornerRadius(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.lifesumCream)
                    )

                // Recipe Info Overlay
                if let firstMeal = program.sampleMeals.first {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(firstMeal.name)
                            .font(.headline)
                            .foregroundColor(.white)
                        Text("\(firstMeal.calories) kcal")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(VirgilSpacing.md)
                    .background(
                        LinearGradient(
                            colors: [.black.opacity(0.6), .clear],
                            startPoint: .bottom,
                            endPoint: .top
                        )
                    )
                    .cornerRadius(16, corners: [.bottomLeft, .bottomRight])
                }
            }

            // Sample Meals List
            VStack(spacing: VirgilSpacing.sm) {
                ForEach(program.sampleMeals) { meal in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(meal.mealType.displayNameJa)
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text(meal.name)
                                .font(.subheadline)
                                .fontWeight(.medium)
                        }

                        Spacer()

                        Text("\(meal.calories) kcal")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(VirgilSpacing.sm)
                    .background(Color.lifesumCream)
                    .cornerRadius(8)
                }
            }
        }
    }

    // MARK: - Expert Quote Section

    private var expertQuoteSection: some View {
        let quote = program.expertQuote ?? defaultQuote

        return VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            HStack(alignment: .top, spacing: VirgilSpacing.sm) {
                Text("\u{201C}")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.lifesumDarkGreen)
                    .offset(y: -10)

                Text(quote)
                    .font(.body)
                    .italic()
                    .foregroundColor(.primary)
                    .lineSpacing(4)
            }

            Text("── FUUD 栄養チーム")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding(VirgilSpacing.md)
        .background(Color.lifesumCream)
        .cornerRadius(12)
    }

    private var defaultQuote: String {
        switch program.category {
        case .biohacking:
            return "科学的アプローチで、あなたの体を最適化します。"
        case .balanced:
            return "バランスの良い食事は、長期的な健康の基盤です。"
        case .fasting:
            return "断食は体をリセットし、細胞を若返らせる古来の知恵です。"
        case .highProtein:
            return "タンパク質は筋肉だけでなく、すべての体の組織を作る大切な栄養素です。"
        case .lowCarb:
            return "糖質をコントロールすることで、体は効率的に脂肪を燃やすようになります。"
        }
    }

    // MARK: - Expected Results Section

    private var expectedResultsSection: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            HStack(spacing: VirgilSpacing.sm) {
                Image(systemName: "sparkles")
                    .foregroundColor(.lifesumDarkGreen)
                Text("期待できる効果")
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: VirgilSpacing.xs) {
                ForEach(program.expectedResults, id: \.self) { result in
                    HStack(alignment: .top, spacing: VirgilSpacing.sm) {
                        Text("•")
                            .foregroundColor(.lifesumDarkGreen)
                        Text(result)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }

    // MARK: - Program Flow Section

    private var programFlowSection: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            HStack(spacing: VirgilSpacing.sm) {
                Image(systemName: "calendar")
                    .foregroundColor(.lifesumDarkGreen)
                Text("プログラムの流れ")
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
                ForEach(program.phases) { phase in
                    HStack(alignment: .top, spacing: VirgilSpacing.sm) {
                        // Week indicator
                        Text("Week \(phase.weekNumber)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.lifesumDarkGreen)
                            .cornerRadius(4)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(phase.name)
                                .font(.subheadline)
                                .fontWeight(.medium)

                            if !phase.description.isEmpty {
                                Text(phase.description)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Contraindications Section

    private var contraindicationsSection: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            HStack(spacing: VirgilSpacing.sm) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                Text("注意事項")
                    .font(.headline)
            }

            VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
                ForEach(program.contraindications.indices, id: \.self) { index in
                    let contra = program.contraindications[index]
                    HStack(alignment: .top, spacing: VirgilSpacing.sm) {
                        Image(systemName: contra.severity == .prohibited ? "xmark.circle.fill" : "exclamationmark.circle.fill")
                            .foregroundColor(contra.severity == .prohibited ? .red : .orange)
                            .font(.subheadline)

                        Text(contra.message)
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding(VirgilSpacing.sm)
            .background(Color.orange.opacity(0.1))
            .cornerRadius(8)
        }
    }
}

// MARK: - Corner Radius Extension

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        ProgramDetailView(program: DietProgramCatalog.programs[0])
    }
}
