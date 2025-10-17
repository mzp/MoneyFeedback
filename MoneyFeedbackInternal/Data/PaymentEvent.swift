//
//  PaymentEvent.swift
//  MoneyFeedbackInternal
//
//  Created by mzp on 10/16/25.
//

import Foundation
import SwiftData

@Model
class PaymentEvent {
    var date: Date
    var amount: Decimal

    init(date: Date, amount: Decimal) {
        self.date = date
        self.amount = amount
    }
}

extension PaymentEvent: CustomStringConvertible, CustomDebugStringConvertible {
    var description: String {
        return "PaymentEvent(date: \(date), amount: \(amount))"
    }

    var debugDescription: String {
        return description
    }
}
