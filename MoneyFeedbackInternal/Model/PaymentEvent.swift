//
//  PaymentEvent.swift
//  MoneyFeedback
//
//  Created by mzp on 10/18/25.
//
import Foundation

struct PaymentEvent: Sendable {
    var id: String
    var title: String
    var amount: String
    var date: Date

    init(id: String, title: String, amount: String, date: Date) {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
    }
}
