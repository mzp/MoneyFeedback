//
//  ReminderStore.swift
//  MoneyFeedbackInternal
//
//  Created by mzp on 10/18/25.
//

import EventKit
import Foundation

public class ReminderStore {
    private let eventStore = EKEventStore()

    public init() {}

    public func requestAccess() async throws -> Bool {
        try await eventStore.requestFullAccessToReminders()
    }

    public func fetchReminders() async throws -> [EKReminder] {
        let calendars = eventStore.calendars(for: .reminder)
        let predicate = eventStore.predicateForReminders(in: calendars)

        return try await withCheckedThrowingContinuation { continuation in
            eventStore.fetchReminders(matching: predicate) { reminders in
                if let reminders = reminders {
                    continuation.resume(returning: reminders)
                } else {
                    continuation.resume(throwing: ReminderStoreError.fetchFailed)
                }
            }
        }
    }
}

public enum ReminderStoreError: Error {
    case notAuthorized
    case fetchFailed
}
