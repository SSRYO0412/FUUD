//
//  FoodItemDetailView.swift
//  FUUD
//
//  Lifesum風食材詳細画面
//

import SwiftUI

struct FoodItemDetailView: View {
    @Binding var foodItem: FoodItem
    @Environment(\.dismiss) private var dismiss

    @State private var amount: Double
    @State private var selectedUnit: String
    @State private var showingUnitPicker = false

    private let backgroundColor = Color(hex: "F5F0E8")

    init(foodItem: Binding<FoodItem>) {
        self._foodItem = foodItem
        self._amount = State(initialValue: foodItem.wrappedValue.amount)
        self._selectedUnit = State(initialValue: foodItem.wrappedValue.unit)
    }

    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    // Header
                    headerSection

                    // PFC Circles
                    PFCCirclesView(
                        carbsPercentage: foodItem.carbsPercentage,
                        proteinPercentage: foodItem.proteinPercentage,
                        fatPercentage: foodItem.fatPercentage,
                        carbsGrams: scaledNutrient(foodItem.carbs),
                        proteinGrams: scaledNutrient(foodItem.protein),
                        fatGrams: scaledNutrient(foodItem.fat)
                    )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)

                    // Food Rating
                    foodRatingSection

                    // Nutritional Information
                    nutritionalInfoSection

                    Spacer(minLength: 100)
                }
            }

            // Update button
            VStack {
                Spacer()
                updateButton
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

            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "trash")
                        .font(.system(size: 16))
                        .foregroundColor(.secondary)
                }
            }
        }
        .sheet(isPresented: $showingUnitPicker) {
            unitPickerSheet
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Food name
            Text(foodItem.name)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)

            // Amount and unit pickers
            HStack(spacing: 12) {
                // Amount picker
                Menu {
                    ForEach(amountOptions, id: \.self) { value in
                        Button(action: { amount = value }) {
                            HStack {
                                Text("\(Int(value))")
                                if amount == value {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack(spacing: 8) {
                        Text("\(Int(amount))")
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

                // Unit picker
                Button(action: { showingUnitPicker = true }) {
                    HStack(spacing: 8) {
                        Text(unitDisplayName)
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

            // Calories
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.orange)
                Text("\(scaledCalories) kcal")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.primary)
            }
        }
        .padding(16)
    }

    // MARK: - Food Rating Section

    private var foodRatingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("食品評価")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)

                Spacer()

                Button(action: {}) {
                    Image(systemName: "info.circle")
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                }
            }

            VStack(spacing: 12) {
                // Rating header with emoji
                HStack {
                    Text(ratingEmoji)
                        .font(.system(size: 24))
                    Text("\(scaledCalories) kcal")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                }

                // Pros and Cons
                HStack(alignment: .top, spacing: 24) {
                    // Pros
                    VStack(alignment: .leading, spacing: 6) {
                        if foodItem.isProteinRich {
                            ratingItem(positive: true, text: "タンパク質豊富")
                        }
                        if foodItem.isLowCarb {
                            ratingItem(positive: true, text: "低糖質")
                        }
                        if foodItem.isLowSugar {
                            ratingItem(positive: true, text: "低糖類")
                        }
                        if foodItem.isLowSodium {
                            ratingItem(positive: true, text: "低ナトリウム")
                        }
                    }

                    // Cons
                    VStack(alignment: .leading, spacing: 6) {
                        if foodItem.isCalorieDense {
                            ratingItem(positive: false, text: "カロリー高め")
                        }
                        if foodItem.isHighSaturatedFat {
                            ratingItem(positive: false, text: "飽和脂肪高め")
                        }
                        if foodItem.isProcessed {
                            ratingItem(positive: false, text: "加工食品")
                        }
                    }
                }
            }
            .padding(16)
            .background(Color(.systemBackground))
            .cornerRadius(12)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    private func ratingItem(positive: Bool, text: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: positive ? "checkmark" : "xmark")
                .font(.system(size: 10, weight: .bold))
                .foregroundColor(positive ? Color(hex: "4CD964") : Color(hex: "FF6B6B"))
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
    }

    // MARK: - Nutritional Information Section

    private var nutritionalInfoSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("栄養成分表")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
                .padding(.horizontal, 16)

            VStack(spacing: 0) {
                nutritionRow(label: "カロリー", value: "\(scaledCalories) kcal", icon: "flame.fill", iconColor: .orange)
                Divider().padding(.leading, 16)
                nutritionRow(label: "糖質", value: String(format: "%.1f g", scaledNutrient(foodItem.carbs)))
                Divider().padding(.leading, 16)
                nutritionRow(label: "タンパク質", value: String(format: "%.1f g", scaledNutrient(foodItem.protein)))
                Divider().padding(.leading, 16)
                nutritionRow(label: "脂質", value: String(format: "%.1f g", scaledNutrient(foodItem.fat)))
                Divider().padding(.leading, 16)
                nutritionRow(label: "食物繊維", value: String(format: "%.1f g", scaledNutrient(foodItem.fiber)))
                Divider().padding(.leading, 16)
                nutritionRow(label: "糖類", value: String(format: "%.1f g", scaledNutrient(foodItem.sugar)))
                Divider().padding(.leading, 16)
                nutritionRow(label: "ナトリウム", value: String(format: "%.0f mg", scaledNutrient(foodItem.sodium)))
            }
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .padding(.horizontal, 16)
        }
        .padding(.vertical, 8)
    }

    private func nutritionRow(label: String, value: String, icon: String? = nil, iconColor: Color = .secondary) -> some View {
        HStack {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(iconColor)
            }
            Text(label)
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.primary)

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }

    // MARK: - Unit Picker Sheet

    @ViewBuilder
    private var unitPickerSheet: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("単位を選択")
                    .font(.system(size: 16, weight: .semibold))

                Spacer()

                Button(action: { showingUnitPicker = false }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.secondary)
                }
            }
            .padding()

            Divider()

            // Unit options
            List {
                ForEach(FoodUnit.allCases, id: \.self) { unit in
                    Button(action: {
                        selectedUnit = unit.rawValue
                        showingUnitPicker = false
                    }) {
                        HStack {
                            Text(unit.displayName)
                                .foregroundColor(.primary)

                            Spacer()

                            if selectedUnit == unit.rawValue {
                                Image(systemName: "checkmark")
                                    .foregroundColor(Color(hex: "4CD964"))
                            }
                        }
                    }
                }
            }
            .listStyle(PlainListStyle())
        }
        .modifier(PresentationDetentsModifier())
    }

    // MARK: - Update Button

    private var updateButton: some View {
        Button(action: {
            // Update food item
            dismiss()
        }) {
            Text("更新する")
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

    // MARK: - Computed Properties

    private var amountOptions: [Double] {
        let baseOptions: [Double] = [10, 20, 30, 50, 75, 100, 120, 150, 200, 250, 300, 400, 500]
        if !baseOptions.contains(foodItem.amount) {
            return (baseOptions + [foodItem.amount]).sorted()
        }
        return baseOptions
    }

    private var unitDisplayName: String {
        FoodUnit(rawValue: selectedUnit)?.displayName ?? selectedUnit
    }

    private var scaledCalories: Int {
        foodItem.caloriesFor(amount: amount)
    }

    private func scaledNutrient(_ value: Double) -> Double {
        guard foodItem.amount > 0 else { return 0 }
        return value * amount / foodItem.amount
    }

    private var ratingEmoji: String {
        let pros = [foodItem.isProteinRich, foodItem.isLowCarb, foodItem.isLowSugar, foodItem.isLowSodium].filter { $0 }.count
        let cons = [foodItem.isCalorieDense, foodItem.isHighSaturatedFat, foodItem.isProcessed].filter { $0 }.count

        if pros > cons + 1 { return "😊" }
        if cons > pros + 1 { return "😐" }
        return "🙂"
    }
}

// MARK: - iOS 16+ Presentation Detents Modifier

struct PresentationDetentsModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content.presentationDetents([.medium])
        } else {
            content
        }
    }
}

// MARK: - Preview

#if DEBUG
struct FoodItemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleItem = FoodItem(
            name: "牛肉（スライス、炒め）",
            amount: 120,
            unit: "g",
            calories: 300,
            carbs: 0,
            protein: 31.2,
            fat: 20.4,
            fiber: 0,
            sugar: 0,
            sodium: 65,
            isProcessed: false
        )

        NavigationView {
            FoodItemDetailView(foodItem: .constant(sampleItem))
        }
    }
}
#endif
