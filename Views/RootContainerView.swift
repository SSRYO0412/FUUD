//
//  RootContainerView.swift
//  AWStest
//
//  iOS標準TabView - Liquid Glassデザイン
//

import SwiftUI

struct RootContainerView: View {
    @EnvironmentObject var cognitoService: SimpleCognitoService

    var body: some View {
        TabView {
            HomeView()
                .environmentObject(cognitoService)
                .tabItem {
                    Label("HOME", systemImage: "house")
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
