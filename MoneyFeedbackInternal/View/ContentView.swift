//
//  ContentView.swift
//  MoneyFeedbackInternal
//
//  Created by mzp on 10/15/25.
//

import OSLog
import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext

    @State private var date = Date()
    @State private var amount = ""
    @State private var latestPaymentEvent: PaymentEvent?

    var body: some View {
        Form {
            Section("Payment Details") {
                DatePicker("Date", selection: $date, displayedComponents: .date)

                TextField("Amount", text: $amount)
                    .keyboardType(.decimalPad)
            }

            Section {
                Button("Save") {
                    save()
                }

                if latestPaymentEvent != nil {
                    Button("Clear", role: .destructive) {
                        clear()
                    }
                }
            }
        }
        .onAppear {
            fetch()
        }
    }

    private func fetch() {
        do {
            let descriptor = FetchDescriptor<PaymentEvent>(
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )
            let events = try modelContext.fetch(descriptor)
            if let latest = events.first {
                latestPaymentEvent = latest
                date = latest.date
                amount = latest.amount.description
                Logger.mfData.log("\(Self.self).\(#function) Loaded latest payment event: \(latest, privacy: .private)")
            } else {
                Logger.mfData.warning("\(Self.self).\(#function) No payment events found")
            }
        } catch {
            Logger.mfData.error("\(Self.self).\(#function) Failed to fetch payment events: \(error.localizedDescription)")
        }
    }

    private func save() {
        let paymentAmount = Decimal(string: amount) ?? 0

        if let existing = latestPaymentEvent {
            Logger.mfData.log("\(Self.self).\(#function) Update existing payment event")
            existing.date = date
            existing.amount = paymentAmount
        } else {
            Logger.mfData.log("\(Self.self).\(#function) Create new payment event")
            let newEvent = PaymentEvent(date: date, amount: paymentAmount)
            modelContext.insert(newEvent)
        }

        fetch()
    }

    private func clear() {
        if let existing = latestPaymentEvent {
            Logger.mfData.log("\(Self.self).\(#function) Delete payment event")
            modelContext.delete(existing)
            latestPaymentEvent = nil
            date = Date()
            amount = ""
        }
    }
}

#Preview {
    ContentView()
}
