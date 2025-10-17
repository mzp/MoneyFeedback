//
//  MoneyFeedbackWidget.swift
//  MoneyFeedbackInternal
//
//  Created by mzp on 10/15/25.
//

import SwiftUI
import WidgetKit

public struct MoneyFeedbackWidget: Widget {
    let kind: String = "MoneyFeedbackWidget"

    public init() {}

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MoneyFeedbackTimelineProvider()) { entry in
            WidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

#Preview(as: .systemSmall) {
    MoneyFeedbackWidget()
} timeline: {
    SimpleEntry(date: .now, paymentEvent: PaymentEvent(date: .now, amount: 1000))
    SimpleEntry(date: .now, paymentEvent: PaymentEvent(date: .now, amount: 2500))
}
