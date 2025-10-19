//
//  ReminderListView.swift
//  MoneyFeedbackInternal
//
//  Created by mzp on 10/18/25.
//

import EventKit
import SwiftUI

public struct ReminderListView: View {
    @State private var reminders: [EKReminder] = []
    @State private var isAuthorized = false
    @State private var errorMessage: String?
    private let store = ReminderStore()

    public init() {}

    public var body: some View {
        List {
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else if reminders.isEmpty {
                Text("No reminders")
                    .foregroundColor(.secondary)
            } else {
                ForEach(reminders, id: \.calendarItemIdentifier) { reminder in
                    VStack(alignment: .leading) {
                        Text(reminder.title ?? "")
                            .font(.headline)
                        if let notes = reminder.notes {
                            Text(notes)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Reminders")
        .task {
            await loadReminders()
        }
        .refreshable {
            await loadReminders()
        }
    }

    private func loadReminders() async {
        do {
            isAuthorized = try await store.requestAccess()
            if isAuthorized {
                reminders = try await store.fetchReminders()
                errorMessage = nil
            } else {
                errorMessage = "Access denied"
            }
        } catch {
            errorMessage = "Error: \(error.localizedDescription)"
        }
    }
}

#Preview {
    NavigationStack {
        ReminderListView()
    }
}
