//
//  MoneyFeedbackTimelineProvider.swift
//  MoneyFeedbackInternal
//
//  Created by mzp on 10/16/25.
//
import OSLog
import SwiftData
import WidgetKit

struct MoneyFeedbackTimelineProvider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), paymentEvent: PaymentEvent(date: Date(), amount: 0))
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), paymentEvent: PaymentEvent(date: Date(), amount: 0))
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let currentDate = Date()
        var latestEvent = PaymentEvent(date: Date(), amount: 0)

        do {
            // Fetch latest payment event
            let modelContext = ModelContext(
                try ModelContainer(for: PaymentEvent.self)
            )
            let descriptor = FetchDescriptor<PaymentEvent>(
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            let events = try modelContext.fetch(descriptor)
            if let first = events.first {
                latestEvent = first
            } else {
                Logger.mfData.warning("No payment events found")
            }
        } catch {
            Logger.mfData.error("Failed to fetch payment events: \(error.localizedDescription)")
        }

        let entry = SimpleEntry(date: currentDate, paymentEvent: latestEvent)
        let timeline = Timeline(entries: [entry], policy: .after(currentDate.addingTimeInterval(3600)))
        completion(timeline)
    }
}
