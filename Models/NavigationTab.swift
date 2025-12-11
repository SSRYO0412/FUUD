//
//  NavigationTab.swift
//  AWStest
//
//  カスタムボトムナビゲーションのタブ定義 - HTML版完全一致
//

import SwiftUI

enum NavigationTab: String, CaseIterable, Identifiable {
    case home
    case program
    case data
    case profile

    var id: String { self.rawValue }

    // MARK: - Display Properties

    var title: String {
        switch self {
        case .home:
            return "HOME"
        case .program:
            return "PROGRAM"
        case .data:
            return "DATA"
        case .profile:
            return "PROFILE"
        }
    }

    var icon: String {
        switch self {
        case .home:
            return "house.fill"
        case .program:
            return "list.bullet.clipboard.fill"
        case .data:
            return "chart.bar.fill"
        case .profile:
            return "person.fill"
        }
    }

    var inactiveIcon: String {
        switch self {
        case .home:
            return "house"
        case .program:
            return "list.bullet.clipboard"
        case .data:
            return "chart.bar"
        case .profile:
            return "person"
        }
    }

    // MARK: - Color

    var accentColor: Color {
        switch self {
        case .home:
            return Color.black
        case .program:
            return Color.black
        case .data:
            return Color.black
        case .profile:
            return Color.black
        }
    }
}
