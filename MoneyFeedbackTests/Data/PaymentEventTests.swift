//
//  PaymentEventTests.swift
//  MoneyFeedbackTests
//
//  Created by mzp on 10/16/25.
//

import Foundation
import SwiftData
import Testing

@testable import MoneyFeedbackInternal

struct PaymentEventTests {

    @Test @MainActor func persistent() throws {
        let container = try ModelContainer(
            for: PaymentEvent.self,
            configurations: .init(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext

        let date = Date()
        let paymentEvent = PaymentEvent(date: date, amount: 15_000.50)
        context.insert(paymentEvent)

        let results = try context.fetch(FetchDescriptor<PaymentEvent>())
        #expect(results.first?.date == paymentEvent.date)
        #expect(results.first?.amount == paymentEvent.amount)
    }

}
