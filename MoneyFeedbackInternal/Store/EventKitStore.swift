//
//  EventKitStore.swift
//  MoneyFeedbackInternal
//
//  Created by mzp on 10/18/25.
//

import EventKit
import Foundation

extension PaymentEvent : Identifiable {
    var combinedTitle: String {
        "\(title) - \(amount)"
    }

    static func parse(from reminderTitle: String) -> (title: String, amount: String)? {
        let components = reminderTitle.split(separator: " - ", maxSplits: 1)
        guard components.count == 2 else { return nil }
        return (String(components[0]), String(components[1]))
    }

    init?(from reminder: EKReminder) {
        guard let reminderTitle = reminder.title,
              let (title, amount) = PaymentEvent.parse(from: reminderTitle),
              let dueDateComponents = reminder.dueDateComponents,
              let date = Calendar.current.date(from: dueDateComponents) else {
            return nil
        }
        self.id = reminder.calendarItemIdentifier
        self.title = title
        self.amount = amount
        self.date = date
    }

    func toEKReminder(in eventStore: EKEventStore) -> EKReminder {
        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = combinedTitle
        reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        reminder.calendar = eventStore.defaultCalendarForNewReminders()
        return reminder
    }

    func update(reminder: EKReminder) {
        reminder.title = combinedTitle
        reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
    }
}

class EventKitStore {
    private let eventStore = EKEventStore()

    init() {}

    func requestAccess() async throws -> Bool {
        try await eventStore.requestFullAccessToReminders()
    }

    func fetch() async throws -> [PaymentEvent] {
        let calendars = eventStore.calendars(for: .reminder)

        let predicate = eventStore.predicateForIncompleteReminders(
            withDueDateStarting: .distantPast,
            ending: .distantFuture,
            calendars: calendars
        )

        return try await withCheckedThrowingContinuation { continuation in
            eventStore.fetchReminders(matching: predicate) { reminders in
                if let reminders = reminders {
                    let paymentEvents = reminders.compactMap { PaymentEvent(from: $0) }
                    continuation.resume(returning: paymentEvents)
                } else {
                    continuation.resume(throwing: PaymentEventStoreError.fetchFailed)
                }
            }
        }
    }

    func create(paymentEvent: PaymentEvent) async throws {
        let reminder = paymentEvent.toEKReminder(in: eventStore)
        try eventStore.save(reminder, commit: true)
    }

    func update(paymentEvent: PaymentEvent) async throws {
        guard let reminder = eventStore.calendarItem(withIdentifier: paymentEvent.id) as? EKReminder else {
            throw PaymentEventStoreError.eventNotFound
        }

        paymentEvent.update(reminder: reminder)
        try eventStore.save(reminder, commit: true)
    }

    func complete(paymentEvent: PaymentEvent) async throws {
        guard let reminder = eventStore.calendarItem(withIdentifier: paymentEvent.id) as? EKReminder else {
            throw PaymentEventStoreError.eventNotFound
        }

        reminder.isCompleted = true
        try eventStore.save(reminder, commit: true)
    }

    func delete(paymentEvent: PaymentEvent) async throws {
        guard let reminder = eventStore.calendarItem(withIdentifier: paymentEvent.id) as? EKReminder else {
            throw PaymentEventStoreError.eventNotFound
        }

        try eventStore.remove(reminder, commit: true)
    }
}

extension DateComponents {
    var date: Date? {
        Calendar.current.date(from: self)
    }
}

enum PaymentEventStoreError: Error {
    case notAuthorized
    case fetchFailed
    case eventNotFound
}
