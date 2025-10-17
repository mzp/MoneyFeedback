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
                    savePaymentEvent()
                }

                if latestPaymentEvent != nil {
                    Button("Clear", role: .destructive) {
                        deletePaymentEvent()
                    }
                }
            }
        }
        .onAppear {
            loadLatestPaymentEvent()
        }
    }

    private func loadLatestPaymentEvent() {
        let descriptor = FetchDescriptor<PaymentEvent>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )
        latestPaymentEvent = try? modelContext.fetch(descriptor).first

        if let latest = latestPaymentEvent {
            date = latest.date
            amount = latest.amount.description
            Logger.mfData.log("Loaded latest payment event: \(latest, privacy: .private)")
        }
    }

    private func savePaymentEvent() {
        let paymentAmount = Decimal(string: amount) ?? 0

        if let existing = latestPaymentEvent {
            Logger.mfData.log("Update existing payment event")
            existing.date = date
            existing.amount = paymentAmount
        } else {
            Logger.mfData.log("Create new payment event")
            let newEvent = PaymentEvent(date: date, amount: paymentAmount)
            modelContext.insert(newEvent)
        }

        loadLatestPaymentEvent()
    }

    private func deletePaymentEvent() {
        if let existing = latestPaymentEvent {
            Logger.mfData.log("Delete payment event")
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
