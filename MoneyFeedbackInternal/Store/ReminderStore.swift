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

        let predicate = eventStore.predicateForIncompleteReminders(
            withDueDateStarting: nil,
            ending: nil,
            calendars: calendars
        )

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

    public func createReminder(
        title: String,
        notes: String? = nil,
        dueDate: DateComponents? = nil,
        calendar: EKCalendar? = nil
    ) async throws -> EKReminder {
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = title
        reminder.notes = notes
        reminder.dueDateComponents = dueDate
        reminder.calendar = calendar ?? eventStore.defaultCalendarForNewReminders()

        try eventStore.save(reminder, commit: true)
        return reminder
    }

    public func updateReminder(
        _ reminder: EKReminder,
        title: String? = nil,
        notes: String? = nil,
        dueDate: DateComponents? = nil,
        isCompleted: Bool? = nil
    ) async throws {
        if let title = title {
            reminder.title = title
        }
        if let notes = notes {
            reminder.notes = notes
        }
        if let dueDate = dueDate {
            reminder.dueDateComponents = dueDate
        }
        if let isCompleted = isCompleted {
            reminder.isCompleted = isCompleted
        }

        try eventStore.save(reminder, commit: true)
    }

    public func deleteReminder(_ reminder: EKReminder) async throws {
        try eventStore.remove(reminder, commit: true)
    }
}

public enum ReminderStoreError: Error {
    case notAuthorized
    case fetchFailed
}
