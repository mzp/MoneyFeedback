//
//  TaxReturnTests.swift
//  MoneyFeedbackTests
//
//  Created by mzp on 10/16/25.
//

import Foundation
import SwiftData
import Testing

@testable import MoneyFeedbackInternal

struct TaxReturnTests {

    @Test @MainActor func persistent() throws {
        let container = try ModelContainer(
            for: TaxReturn.self,
            configurations: .init(isStoredInMemoryOnly: true)
        )
        let context = container.mainContext

        let taxReturn = TaxReturn(year: 2025, federalTax: 10_000, stateTax: 5_000.0)
        context.insert(taxReturn)

        let results = try context.fetch(
            FetchDescriptor<TaxReturn>(
                predicate: #Predicate { $0.year == 2025 }
            ))
        #expect(results.first?.federalTax == taxReturn.federalTax)
        #expect(results.first?.stateTax == taxReturn.stateTax)
    }

}
