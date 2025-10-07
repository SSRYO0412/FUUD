//
//  ContentUnavailableViewCompat.swift
//  AWStest
//
//  iOS 15互換用ContentUnavailableView代替
//

import SwiftUI

struct ContentUnavailableViewCompat<Actions: View>: View {
    let systemImage: String
    let title: String
    let description: String
    let actions: () -> Actions

    init(
        _ title: String,
        systemImage: String,
        description: String,
        @ViewBuilder actions: @escaping () -> Actions = { EmptyView() as! Actions }
    ) {
        self.systemImage = systemImage
        self.title = title
        self.description = description
        self.actions = actions
    }

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: systemImage)
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text(title)
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.primary)

                Text(description)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            actions()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// シンプル版（actionsなし）
extension ContentUnavailableViewCompat where Actions == EmptyView {
    init(
        _ title: String,
        systemImage: String,
        description: String
    ) {
        self.systemImage = systemImage
        self.title = title
        self.description = description
        self.actions = { EmptyView() }
    }
}
