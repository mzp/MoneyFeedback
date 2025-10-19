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
    @State private var showingAddSheet = false
    @State private var editingReminder: EKReminder?
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
                        if let dueDateComponents = reminder.dueDateComponents,
                           let date = Calendar.current.date(from: dueDateComponents) {
                            Text(date, style: .date)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editingReminder = reminder
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            Task {
                                await completeReminder(reminder)
                            }
                        } label: {
                            Label("Complete", systemImage: "checkmark.circle")
                        }
                        .tint(.green)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            Task {
                                await deleteReminder(reminder)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("Reminders")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .task {
            await loadReminders()
        }
        .refreshable {
            await loadReminders()
        }
        .sheet(isPresented: $showingAddSheet) {
            ReminderEditView(store: store) {
                await loadReminders()
            }
        }
        .sheet(item: $editingReminder) { reminder in
            ReminderEditView(store: store, reminder: reminder) {
                await loadReminders()
            }
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

    private func completeReminder(_ reminder: EKReminder) async {
        do {
            try await store.updateReminder(reminder, isCompleted: true)
            await loadReminders()
        } catch {
            errorMessage = "Failed to complete: \(error.localizedDescription)"
        }
    }

    private func deleteReminder(_ reminder: EKReminder) async {
        do {
            try await store.deleteReminder(reminder)
            await loadReminders()
        } catch {
            errorMessage = "Failed to delete: \(error.localizedDescription)"
        }
    }
}

extension EKReminder: Identifiable {
    public var id: String {
        calendarItemIdentifier
    }
}

struct ReminderEditView: View {
    let store: ReminderStore
    let reminder: EKReminder?
    let onSave: () async -> Void

    @State private var title: String
    @State private var notes: String
    @State private var dueDate: Date
    @State private var hasDueDate: Bool
    @Environment(\.dismiss) private var dismiss

    init(store: ReminderStore, reminder: EKReminder? = nil, onSave: @escaping () async -> Void) {
        self.store = store
        self.reminder = reminder
        self.onSave = onSave

        _title = State(initialValue: reminder?.title ?? "")
        _notes = State(initialValue: reminder?.notes ?? "")

        if let dueDateComponents = reminder?.dueDateComponents,
           let date = Calendar.current.date(from: dueDateComponents) {
            _dueDate = State(initialValue: date)
            _hasDueDate = State(initialValue: true)
        } else {
            _dueDate = State(initialValue: Date())
            _hasDueDate = State(initialValue: false)
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }

                Section {
                    Toggle("Due Date", isOn: $hasDueDate)
                    if hasDueDate {
                        DatePicker("Date", selection: $dueDate, displayedComponents: [.date])
                    }
                }
            }
            .navigationTitle(reminder == nil ? "New Reminder" : "Edit Reminder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await save()
                        }
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }

    private func save() async {
        do {
            let dueDateComponents = hasDueDate ? Calendar.current.dateComponents([.year, .month, .day], from: dueDate) : nil

            if let reminder = reminder {
                try await store.updateReminder(
                    reminder,
                    title: title,
                    notes: notes.isEmpty ? nil : notes,
                    dueDate: dueDateComponents
                )
            } else {
                _ = try await store.createReminder(
                    title: title,
                    notes: notes.isEmpty ? nil : notes,
                    dueDate: dueDateComponents
                )
            }

            await onSave()
            dismiss()
        } catch {
            // Handle error
        }
    }
}

#Preview {
    NavigationStack {
        ReminderListView()
    }
}
