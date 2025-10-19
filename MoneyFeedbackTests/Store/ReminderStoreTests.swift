//
//  ReminderStoreTests.swift
//  MoneyFeedback
//
//  Created by mzp on 10/18/25.
//

import Testing

@testable import MoneyFeedbackInternal

struct ReminderStoreTests {
    var store = ReminderStore()

    @Test func requestAccessReturnsAuthorizationStatus() async throws {
        let isAuthorized = try await store.requestAccess()
        _ = isAuthorized
    }

    @Test func fetchRemindersReturnsArray() async throws {
        _ = try await store.requestAccess()
        let reminders = try await store.fetchReminders()
        _ = reminders
    }
}
