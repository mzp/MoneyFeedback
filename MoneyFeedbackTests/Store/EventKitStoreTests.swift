//
//  EventKitStoreTests.swift
//  MoneyFeedback
//
//  Created by mzp on 10/18/25.
//

import Testing
import Foundation

@testable import MoneyFeedbackInternal

struct EventKitStoreTests {
    @Test func fetch() async throws {
        let store = EventKitStore()
        _ = try await store.requestAccess()
        let events = try await store.fetch()
        _ = events
    }

    @Test func createAndFetch() async throws {
        let store = EventKitStore()
        _ = try await store.requestAccess()

        let testEvent = PaymentEvent(
            id: UUID().uuidString,
            title: "Test Payment",
            amount: "¥1000",
            date: Date()
        )

        try await store.create(paymentEvent: testEvent)

        let events = try await store.fetch()
        #expect(events.contains(where: { $0.title == "Test Payment" && $0.amount == "¥1000" }))
    }

    @Test func update() async throws {
        let store = EventKitStore()
        _ = try await store.requestAccess()

        // Create a payment event
        let originalEvent = PaymentEvent(
            id: UUID().uuidString,
            title: "Original Payment",
            amount: "¥2000",
            date: Date()
        )
        try await store.create(paymentEvent: originalEvent)

        // Fetch to get the actual ID from EventKit
        let fetchedEvents = try await store.fetch()
        guard let createdEvent = fetchedEvents.first(where: { $0.title == "Original Payment" }) else {
            Issue.record("Failed to find created event")
            return
        }

        // Update the event
        let updatedEvent = PaymentEvent(
            id: createdEvent.id,
            title: "Updated Payment",
            amount: "¥3000",
            date: Date()
        )
        try await store.update(paymentEvent: updatedEvent)

        // Verify update
        let eventsAfterUpdate = try await store.fetch()
        #expect(eventsAfterUpdate.contains(where: { $0.title == "Updated Payment" && $0.amount == "¥3000" }))
        #expect(!eventsAfterUpdate.contains(where: { $0.title == "Original Payment" }))
    }

    @Test func complete() async throws {
        let store = EventKitStore()
        _ = try await store.requestAccess()

        // Create a payment event
        let testEvent = PaymentEvent(
            id: UUID().uuidString,
            title: "Complete Test",
            amount: "¥4000",
            date: Date()
        )
        try await store.create(paymentEvent: testEvent)

        // Fetch to get the actual ID
        let fetchedEvents = try await store.fetch()
        guard let createdEvent = fetchedEvents.first(where: { $0.title == "Complete Test" }) else {
            Issue.record("Failed to find created event")
            return
        }

        // Complete the event
        try await store.complete(paymentEvent: createdEvent)

        // Verify it's no longer in incomplete events
        let eventsAfterComplete = try await store.fetch()
        #expect(!eventsAfterComplete.contains(where: { $0.title == "Complete Test" }))
    }

    @Test func delete() async throws {
        let store = EventKitStore()
        _ = try await store.requestAccess()

        // Create a payment event
        let testEvent = PaymentEvent(
            id: UUID().uuidString,
            title: "Delete Test",
            amount: "¥5000",
            date: Date()
        )
        try await store.create(paymentEvent: testEvent)

        // Fetch to get the actual ID
        let fetchedEvents = try await store.fetch()
        guard let createdEvent = fetchedEvents.first(where: { $0.title == "Delete Test" }) else {
            Issue.record("Failed to find created event")
            return
        }

        // Delete the event
        try await store.delete(paymentEvent: createdEvent)

        // Verify it's deleted
        let eventsAfterDelete = try await store.fetch()
        #expect(!eventsAfterDelete.contains(where: { $0.title == "Delete Test" }))
    }
}
