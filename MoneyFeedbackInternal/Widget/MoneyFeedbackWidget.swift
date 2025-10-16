//
//  MoneyFeedbackWidget.swift
//  MoneyFeedbackWidget
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
            if #available(iOS 17.0, *) {
                WidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                WidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

#Preview(as: .systemSmall) {
    MoneyFeedbackWidget()
} timeline: {
    SimpleEntry(date: .now, emoji: "😀")
    SimpleEntry(date: .now, emoji: "🤩")
}
