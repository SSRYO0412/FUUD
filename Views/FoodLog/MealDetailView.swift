//
//  MealDetailView.swift
//  FUUD
//
//  Lifesum風食事詳細画面
//

import SwiftUI

struct MealDetailView: View {
    @Binding var meal: ParsedMeal
    @Environment(\.dismiss) private var dismiss

    @State private var servings: Int = 1
    @State private var selectedMealType: MealType
    @State private var selectedFoodItem: FoodItem?
    @State private var showingFoodDetail = false

    private let backgroundColor = Color(hex: "F5F0E8")

    init(meal: Binding<ParsedMeal>) {
        self._meal = meal
        self._selectedMealType = State(initialValue: meal.wrappedValue.mealType)
    }

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header info
                    headerSection

                    // PFC Circles
                    PFCCirclesView(
                        carbsPercentage: meal.carbsPercentage,
                        proteinPercentage: meal.proteinPercentage,
                        fatPercentage: meal.fatPercentage,
                        carbsGrams: meal.totalCarbs,
                        proteinGrams: meal.totalProtein,
                        fatGrams: meal.totalFat
                    )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)

                    // Meal content header
                    Text("食材内容（\(servings)人前）")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                        .padding(.top, 16)
                        .padding(.bottom, 8)

                    // Food items list
                    foodItemsList

                    Spacer(minLength: 100)
                }
            }

            // Track button
            VStack {
                Spacer()
                trackButton
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.primary)
                }
            }

            ToolbarItem(placement: .principal) {
                Text(truncatedTitle)
                    .font(.system(size: 16, weight: .semibold))
                    .lineLimit(1)
            }

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
            }
        }
        .sheet(isPresented: $showingFoodDetail) {
            if let item = selectedFoodItem {
                NavigationView {
                    FoodItemDetailView(foodItem: .constant(item))
                }
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Date
            Text(meal.formattedDate)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.secondary)

            // Servings and meal type
            HStack(spacing: 16) {
                // Servings picker
                Menu {
                    ForEach(1...10, id: \.self) { count in
                        Button(action: { servings = count }) {
                            HStack {
                                Text("\(count)")
                                if servings == count {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text("\(servings)")
                            .font(.system(size: 15, weight: .medium))
                        Text("人前")
                            .font(.system(size: 15, weight: .regular))
                            .foregroundColor(.secondary)
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                }

                // Meal type picker
                Menu {
                    ForEach(MealType.allCases, id: \.self) { type in
                        Button(action: { selectedMealType = type }) {
                            HStack {
                                Text(type.displayName)
                                if selectedMealType == type {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text(selectedMealType.displayName)
                            .font(.system(size: 15, weight: .medium))
                        Image(systemName: "chevron.down")
                            .font(.system(size: 10))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                }
            }

            // Total calories
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.orange)
                Text("\(meal.totalCalories * servings) kcal")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
            }
        }
        .padding(16)
    }

    // MARK: - Food Items List

    private var foodItemsList: some View {
        VStack(spacing: 0) {
            ForEach(meal.items) { item in
                Button(action: {
                    selectedFoodItem = item
                    showingFoodDetail = true
                }) {
                    FoodItemRow(item: item)
                }
                .buttonStyle(PlainButtonStyle())

                Divider()
                    .padding(.leading, 16)
            }
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Track Button

    private var trackButton: some View {
        Button(action: {
            // Track meal
            dismiss()
        }) {
            Text("記録する")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(hex: "4CD964"))
                .cornerRadius(12)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
        .background(
            LinearGradient(
                colors: [backgroundColor.opacity(0), backgroundColor],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 80)
            .allowsHitTesting(false)
        )
    }

    // MARK: - Helpers

    private var truncatedTitle: String {
        let fullTitle = "\(meal.name)（\(meal.description.prefix(20))..."
        return fullTitle.count > 30 ? String(fullTitle.prefix(30)) + "..." : fullTitle
    }
}

// MARK: - Food Item Row

struct FoodItemRow: View {
    let item: FoodItem

    private let carbsColor = Color(hex: "FFCB05")
    private let proteinColor = Color(hex: "9C27B0")
    private let fatColor = Color(hex: "FF6B6B")
    private let fiberColor = Color(hex: "8BC34A")

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Name
            Text(item.name)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.primary)

            // Amount
            Text("\(Int(item.amount)) \(item.unit)")
                .font(.system(size: 13, weight: .regular))
                .foregroundColor(.secondary)

            // Nutrition info
            HStack(spacing: 12) {
                // Calories
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.orange)
                    Text("\(item.calories) kcal")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }

                // PFC dots
                PFCDotsView(
                    carbs: item.carbs,
                    protein: item.protein,
                    fat: item.fat,
                    fiber: item.fiber
                )
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - Preview

#if DEBUG
struct MealDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleMeal = ParsedMeal(
            name: "和定食セット",
            description: "牛肉炒め、わかめスープ、冷奴、アボカドときゅうりのサラダ",
            mealType: .dinner,
            items: [
                FoodItem(name: "牛肉（スライス、炒め）", amount: 120, unit: "g", calories: 300, carbs: 0, protein: 31.2, fat: 20.4),
                FoodItem(name: "わかめスープ", amount: 1, unit: "杯", calories: 30, carbs: 3, protein: 2, fat: 1),
                FoodItem(name: "冷奴", amount: 150, unit: "g", calories: 84, carbs: 2.3, protein: 7.8, fat: 4.9)
            ]
        )

        NavigationView {
            MealDetailView(meal: .constant(sampleMeal))
        }
    }
}
#endif
