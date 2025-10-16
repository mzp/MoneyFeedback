//
//  MoneyFeedbackTests.swift
//  MoneyFeedbackTests
//
//  Created by mzp on 10/15/25.
//

import Foundation
import Testing

@testable import MoneyFeedbackInternal

struct MoneyFeedbackTests {

    @Test func example() async throws {
        let entry = SimpleEntry(
            date: .now,
            emoji: "🍣"
        )
        #expect(entry.emoji == "🍣")
    }

}
