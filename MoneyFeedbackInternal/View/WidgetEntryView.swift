//
//  MoneyFeedbackWidgetEntryView.swift
//  MoneyFeedback
//
//  Created by mzp on 10/16/25.
//
import SwiftUI

struct WidgetEntryView: View {
    var entry: MoneyFeedbackTimelineProvider.Entry

    var body: some View {
        VStack {
            Text("Time:")
            Text(entry.date, style: .time)

            Text("Emoji:")
            Text(entry.emoji)
        }
    }
}
