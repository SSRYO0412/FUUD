//
//  MorningCheckInSheet.swift
//  FUUD
//
//  朝の問診入力シート
//  食事予定と運動予定を入力
//

import SwiftUI

struct MorningCheckInSheet: View {
    @Environment(\.dismiss) var dismiss
    @Binding var morningPlan: MorningPlan

    @State private var breakfast: PlannedMealType?
    @State private var lunch: PlannedMealType?
    @State private var dinner: PlannedMealType?
    @State private var exerciseType: ExerciseType = .none
    @State private var exerciseDuration: Double = 30

    var onSave: (MorningPlan) -> Void

    init(morningPlan: Binding<MorningPlan>, onSave: @escaping (MorningPlan) -> Void) {
        self._morningPlan = morningPlan
        self.onSave = onSave

        // Initialize state from existing plan
        let plan = morningPlan.wrappedValue
        _breakfast = State(initialValue: plan.breakfast)
        _lunch = State(initialValue: plan.lunch)
        _dinner = State(initialValue: plan.dinner)
        _exerciseType = State(initialValue: plan.exercise?.type ?? .none)
        _exerciseDuration = State(initialValue: Double(plan.exercise?.durationMinutes ?? 30))
    }

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: VirgilSpacing.xl) {
                    // Breakfast Section
                    mealSection(
                        title: "朝食",
                        icon: "sunrise.fill",
                        iconColor: .orange,
                        selection: $breakfast
                    )

                    // Lunch Section
                    mealSection(
                        title: "昼食",
                        icon: "sun.max.fill",
                        iconColor: .yellow,
                        selection: $lunch
                    )

                    // Dinner Section
                    mealSection(
                        title: "夕食",
                        icon: "moon.fill",
                        iconColor: .indigo,
                        selection: $dinner
                    )

                    // Exercise Section
                    exerciseSection

                    // Save Button
                    saveButton
                }
                .padding(.horizontal, VirgilSpacing.md)
                .padding(.vertical, VirgilSpacing.lg)
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("今日の予定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }

    // MARK: - Meal Section

    private func mealSection(
        title: String,
        icon: String,
        iconColor: Color,
        selection: Binding<PlannedMealType?>
    ) -> some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.sm) {
            // Header
            HStack(spacing: VirgilSpacing.xs) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(iconColor)

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }

            // Options Grid
            HStack(spacing: VirgilSpacing.sm) {
                ForEach(PlannedMealType.allCases, id: \.self) { type in
                    mealTypeButton(type: type, isSelected: selection.wrappedValue == type) {
                        withAnimation(.easeInOut(duration: 0.15)) {
                            selection.wrappedValue = type
                        }
                    }
                }
            }
        }
        .padding(VirgilSpacing.md)
        .background(Color(.systemBackground))
        .cornerRadius(12)
    }

    private func mealTypeButton(type: PlannedMealType, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: type.icon)
                    .font(.system(size: 20))
                    .foregroundColor(isSelected ? .white : .lifesumDarkGreen)

                Text(type.shortName)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 64)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? Color.lifesumDarkGreen : Color.lifesumDarkGreen.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.clear : Color.lifesumDarkGreen.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }

    // MARK: - Exercise Section

    private var exerciseSection: some View {
        VStack(alignment: .leading, spacing: VirgilSpacing.md) {
            // Header
            HStack(spacing: VirgilSpacing.xs) {
                Image(systemName: "figure.run")
                    .font(.system(size: 16))
                    .foregroundColor(.lifesumLightGreen)

                Text("運動")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
            }

            // Exercise Type Picker
            VStack(alignment: .leading, spacing: VirgilSpacing.xs) {
                Text("種目")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)

                Menu {
                    ForEach(ExerciseType.allCases, id: \.self) { type in
                        Button(action: { exerciseType = type }) {
                            HStack {
                                Image(systemName: type.icon)
                                Text(type.displayName)
                                if exerciseType == type {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Image(systemName: exerciseType.icon)
                            .font(.system(size: 16))
                            .foregroundColor(.lifesumDarkGreen)

                        Text(exerciseType.displayName)
                            .font(.system(size: 16))
                            .foregroundColor(.primary)

                        Spacer()

                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                    .padding(VirgilSpacing.md)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(10)
                }
            }

            // Duration Slider (only show if exercise type is not "none")
            if exerciseType != .none {
                VStack(alignment: .leading, spacing: VirgilSpacing.xs) {
                    HStack {
                        Text("時間")
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)

                        Spacer()

                        Text("\(Int(exerciseDuration))分")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.lifesumDarkGreen)
                    }

                    Slider(value: $exerciseDuration, in: 0...120, step: 5)
                        .tint(.lifesumDarkGreen)

                    HStack {
                        Text("0分")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("60分")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("120分")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(VirgilSpacing.md)
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .animation(.easeInOut(duration: 0.2), value: exerciseType)
    }

    // MARK: - Save Button

    private var saveButton: some View {
        Button(action: savePlan) {
            Text("保存")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(Color.lifesumDarkGreen)
                .cornerRadius(12)
        }
        .padding(.top, VirgilSpacing.sm)
    }

    // MARK: - Actions

    private func savePlan() {
        let plan = MorningPlan(
            breakfast: breakfast,
            lunch: lunch,
            dinner: dinner,
            exercise: exerciseType != .none
                ? ExercisePlan(type: exerciseType, durationMinutes: Int(exerciseDuration))
                : nil,
            recordedAt: Date()
        )

        // Save to UserDefaults
        plan.save()

        // Update binding and notify
        morningPlan = plan
        onSave(plan)

        dismiss()
    }
}

// MARK: - Preview

#Preview {
    MorningCheckInSheet(
        morningPlan: .constant(.empty),
        onSave: { _ in }
    )
}
