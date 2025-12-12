//
//  ScrollViewBackgroundClearer.swift
//  AWStest
//
//  UIScrollViewの背景を強制的にクリアするヘルパー
//

import SwiftUI

struct ScrollViewBackgroundClearer: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear

        DispatchQueue.main.async {
            // ScrollViewの親階層を遡ってUIScrollViewを探す
            if let scrollView = view.superview?.superview as? UIScrollView {
                scrollView.backgroundColor = .clear
                // すべてのサブビューの背景もクリア
                scrollView.subviews.forEach { subview in
                    subview.backgroundColor = .clear
                    // UIVisualEffectViewの場合は透明にする
                    if let effectView = subview as? UIVisualEffectView {
                        effectView.effect = nil
                    }
                }
            }
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // 更新時も背景をクリア
        DispatchQueue.main.async {
            if let scrollView = uiView.superview?.superview as? UIScrollView {
                scrollView.backgroundColor = .clear
                scrollView.subviews.forEach { subview in
                    subview.backgroundColor = .clear
                    if let effectView = subview as? UIVisualEffectView {
                        effectView.effect = nil
                    }
                }
            }
        }
    }
}
