//
//  ReminderStoreTests.swift
//  MoneyFeedback
//
//  Created by mzp on 10/18/25.
//

import Testing

@testable import MoneyFeedbackInternal

struct ReminderStoreTests {
    @Test func fetchReminders() async throws {
        let store = ReminderStore()
        _ = try await store.requestAccess()
        let reminders = try await store.fetchReminders()
        _ = reminders
    }
}
