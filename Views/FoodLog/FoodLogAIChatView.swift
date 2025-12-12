//
//  FoodLogAIChatView.swift
//  FUUD
//
//  Lifesum風AIチャット食品登録画面
//

import SwiftUI

struct FoodLogAIChatView: View {
    @StateObject private var viewModel = FoodLogViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var showingMealDetail = false
    @State private var selectedMeal: ParsedMeal?
    @FocusState private var isInputFocused: Bool

    private let backgroundColor = Color(hex: "F5F0E8")

    var body: some View {
        NavigationView {
            ZStack {
                backgroundColor.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Chat messages
                    chatMessagesView

                    // Suggestions (when idle or completed)
                    if viewModel.state == .idle || viewModel.state == .completed {
                        suggestionsView
                    }

                    // Done tracking button
                    if viewModel.state == .completed {
                        doneTrackingButton
                    }

                    // Input bar
                    inputBarView
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
                    mealTypePicker
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.reset() }) {
                        Image(systemName: "trash")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .sheet(isPresented: $showingMealDetail) {
                if let meal = selectedMeal {
                    NavigationView {
                        MealDetailView(meal: .constant(meal))
                    }
                }
            }
        }
    }

    // MARK: - Meal Type Picker

    private var mealTypePicker: some View {
        Menu {
            ForEach(MealType.allCases, id: \.self) { type in
                Button(action: { viewModel.selectedMealType = type }) {
                    HStack {
                        Text(type.displayName)
                        if viewModel.selectedMealType == type {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Text(viewModel.selectedMealType.displayName)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
                Image(systemName: "chevron.down")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            .cornerRadius(20)
        }
    }

    // MARK: - Chat Messages View

    private var chatMessagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 16) {
                    // Date header
                    Text(formattedDate)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .padding(.top, 8)

                    ForEach(viewModel.messages) { message in
                        ChatMessageBubble(message: message) { meal in
                            selectedMeal = meal
                            showingMealDetail = true
                        }
                        .id(message.id)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .onChange(of: viewModel.messages.count) { _ in
                if let lastMessage = viewModel.messages.last {
                    withAnimation {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
        }
    }

    // MARK: - Suggestions View

    private var suggestionsView: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("よく記録される\(viewModel.selectedMealType.displayName)")
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
                .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(viewModel.mealSuggestions, id: \.self) { suggestion in
                        SuggestionChip(text: suggestion) {
                            viewModel.selectSuggestion(suggestion)
                        }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 12)
        .background(backgroundColor)
    }

    // MARK: - Done Tracking Button

    private var doneTrackingButton: some View {
        Button(action: {
            viewModel.trackMeal()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                dismiss()
            }
        }) {
            Text("記録を完了")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(hex: "4CD964"))
                .cornerRadius(12)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Input Bar View

    private var inputBarView: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(spacing: 12) {
                // Camera button
                Button(action: {}) {
                    Image(systemName: "camera")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                }

                // Add button
                Button(action: {}) {
                    Image(systemName: "plus.circle")
                        .font(.system(size: 18))
                        .foregroundColor(.secondary)
                }

                Spacer()

                // Text input
                HStack {
                    TextField("変更したいことはありますか？", text: $viewModel.currentInput)
                        .font(.system(size: 15))
                        .focused($isInputFocused)

                    // Mic button
                    Button(action: {}) {
                        Image(systemName: "mic")
                            .font(.system(size: 16))
                            .foregroundColor(.secondary)
                    }

                    // Send button
                    Button(action: { viewModel.sendMessage() }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(
                                viewModel.currentInput.isEmpty
                                    ? Color.gray.opacity(0.3)
                                    : Color(hex: "4CD964")
                            )
                    }
                    .disabled(viewModel.currentInput.isEmpty)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                .cornerRadius(24)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(backgroundColor)
        }
    }

    // MARK: - Helpers

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateFormat = "M月d日（E）"
        return "今日, \(formatter.string(from: Date()))"
    }
}

// MARK: - Preview

#if DEBUG
struct FoodLogAIChatView_Previews: PreviewProvider {
    static var previews: some View {
        FoodLogAIChatView()
    }
}
#endif
