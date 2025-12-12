//
//  QuestionMessage.swift
//  AWStest
//
//  選択式質問のデータモデル
//

import Foundation

/// 選択式質問の選択肢
struct QuestionOption: Identifiable {
    let id = UUID()
    let emoji: String
    let text: String
}

/// 選択式質問のメッセージ
struct QuestionMessage {
    let question: String
    let options: [QuestionOption]
}
