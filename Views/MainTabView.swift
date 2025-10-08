//
//  MainTabView.swift
//  AWStest
//
//  メインタブビュー
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var cognitoService: SimpleCognitoService
    
    var body: some View {
        TabView {
            HomeView()
                .environmentObject(cognitoService)
                .tabItem {
                    Label("ホーム", systemImage: "house")
                }

            GeneDataView()
                .tabItem {
                    Label("遺伝子", systemImage: "dna")
                }

            BloodTestView()
                .tabItem {
                    Label("血液検査", systemImage: "heart.text.square")
                }

            ChatView()
                .environmentObject(cognitoService)
                .tabItem {
                    Label("相談", systemImage: "message")
                }

            SettingsView()
                .environmentObject(cognitoService)
                .tabItem {
                    Label("設定", systemImage: "gearshape")
                }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
}

#if DEBUG
struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .environmentObject(SimpleCognitoService.shared)
    }
}
#endif
