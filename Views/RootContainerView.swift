//
//  RootContainerView.swift
//  AWStest
//
//  iOS標準TabView - Liquid Glassデザイン + 中央+ボタン
//

import SwiftUI

struct RootContainerView: View {
    @EnvironmentObject var cognitoService: SimpleCognitoService
    @State private var showingFoodLogSheet = false

    var body: some View {
        ZStack {
            TabView {
                HomeView()
                    .environmentObject(cognitoService)
                    .tabItem {
                        Label("HOME", systemImage: "house")
                    }

                NavigationView {
                    ProgramCatalogView()
                }
                .navigationViewStyle(.stack)
                .tabItem {
                    Label("PROGRAM", systemImage: "list.bullet.clipboard")
                }

                // Placeholder for center button
                Color.clear
                    .tabItem {
                        Label("", systemImage: "")
                    }

                DataView()
                    .tabItem {
                        Label("DATA", systemImage: "chart.bar")
                    }

                ProfileView()
                    .environmentObject(cognitoService)
                    .tabItem {
                        Label("PROFILE", systemImage: "person")
                    }
            }

            // Floating center + button
            VStack {
                Spacer()
                centerPlusButton
                    .offset(y: -20)
            }
        }
        .fullScreenCover(isPresented: $showingFoodLogSheet) {
            FoodLogAIChatView()
        }
    }

    // MARK: - Center Plus Button

    private var centerPlusButton: some View {
        Button(action: {
            showingFoodLogSheet = true
        }) {
            ZStack {
                Circle()
                    .fill(Color(hex: "4CD964"))
                    .frame(width: 56, height: 56)
                    .shadow(color: Color(hex: "4CD964").opacity(0.4), radius: 8, x: 0, y: 4)

                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
        }
    }
}

// MARK: - Preview

#if DEBUG
struct RootContainerView_Previews: PreviewProvider {
    static var previews: some View {
        RootContainerView()
            .environmentObject(SimpleCognitoService.shared)
    }
}
#endif
