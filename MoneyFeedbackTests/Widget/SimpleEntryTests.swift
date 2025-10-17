//
//  SimpleEntryTests.swift
//  SimpleEntryTests
//
//  Created by mzp on 10/15/25.
//

import Foundation
import Testing

@testable import MoneyFeedbackInternal

struct SimpleEntryTests {

    @Test func example() async throws {
        let paymentEvent = PaymentEvent(date: .now, amount: 1000)
        let entry = SimpleEntry(
            date: .now,
            paymentEvent: paymentEvent
        )
        #expect(entry.paymentEvent.amount == 1000)
    }

}
