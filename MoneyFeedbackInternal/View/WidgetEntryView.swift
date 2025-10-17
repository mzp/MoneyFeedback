//
//  WidgetEntryView.swift
//  MoneyFeedbackInternal
//
//  Created by mzp on 10/16/25.
//
import SwiftUI

struct WidgetEntryView: View {
    var entry: MoneyFeedbackTimelineProvider.Entry

    var body: some View {
        VStack {
            Text(entry.paymentEvent.date, format: .dateTime.year().month().day())
                .font(.caption)
            Text(entry.paymentEvent.amount, format: .number)
                .font(.title)
        }
    }
}
