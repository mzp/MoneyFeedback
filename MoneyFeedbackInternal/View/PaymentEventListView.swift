//
//  PaymentEventListView.swift
//  MoneyFeedbackInternal
//
//  Created by mzp on 10/18/25.
//

import EventKit
import SwiftUI
import OSLog


public struct PaymentEventListView: View {
    @State private var events: [PaymentEvent] = []
    @State private var isAuthorized = false
    @State private var errorMessage: String?
    @State private var showingAddSheet = false
    @State private var editingEvent: PaymentEvent?
    private let store = EventKitStore()

    public init() {}

    public var body: some View {
        List {
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            } else if events.isEmpty {
                Text("No payment events")
                    .foregroundColor(.secondary)
            } else {
                ForEach(events, id: \.id) { event in
                    VStack(alignment: .leading) {
                        Text(event.title)
                            .font(.headline)
                        HStack {
                            Text(event.amount)
                                .font(.subheadline)
                                .foregroundColor(.blue)
                            Text(event.date, style: .date)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editingEvent = event
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            Task {
                                await complete(paymentEvent: event)
                            }
                        } label: {
                            Label("Complete", systemImage: "checkmark.circle")
                        }
                        .tint(.green)
                    }
                    .swipeActions(edge: .trailing) {
                        Button(role: .destructive) {
                            Task {
                                await delete(paymentEvent: event)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
        }
        .navigationTitle("Payment Events")
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
            await load()
        }
        .refreshable {
            await load()
        }
        .sheet(isPresented: $showingAddSheet) {
            PaymentEventEditView(store: store) {
                await load()
            }
        }
        .sheet(item: $editingEvent) { event in
            PaymentEventEditView(store: store, paymentEvent: event) {
                await load()
            }
        }
    }

    private func load() async {
        do {
            isAuthorized = try await store.requestAccess()
            if isAuthorized {
                events = try await store.fetch()
                errorMessage = nil
            } else {
                Logger.mfEventKit.error("\(Self.self).\(#function) Access denied for payment events")
                errorMessage = "Access denied"
            }
        } catch {
            Logger.mfEventKit.error("\(Self.self).\(#function) Failed to load payment events: \(error.localizedDescription)")
            errorMessage = "Error: \(error.localizedDescription)"
        }
    }

    private func complete(paymentEvent: PaymentEvent) async {
        do {
            try await store.complete(paymentEvent: paymentEvent)
            await load()
        } catch {
            Logger.mfEventKit.error("\(Self.self).\(#function) Failed to complete payment event: \(error.localizedDescription)")
            errorMessage = "Failed to complete: \(error.localizedDescription)"
        }
    }

    private func delete(paymentEvent: PaymentEvent) async {
        do {
            try await store.delete(paymentEvent: paymentEvent)
            await load()
        } catch {
            Logger.mfEventKit.error("\(Self.self).\(#function) Failed to delete payment event: \(error.localizedDescription)")
            errorMessage = "Failed to delete: \(error.localizedDescription)"
        }
    }
}

struct PaymentEventEditView: View {
    let store: EventKitStore
    let paymentEvent: PaymentEvent?
    let onSave: () async -> Void

    @State private var title: String
    @State private var amount: String
    @State private var dueDate: Date
    @Environment(\.dismiss) private var dismiss

    init(store: EventKitStore, paymentEvent: PaymentEvent? = nil, onSave: @escaping () async -> Void) {
        self.store = store
        self.paymentEvent = paymentEvent
        self.onSave = onSave

        _title = State(initialValue: paymentEvent?.title ?? "")
        _amount = State(initialValue: paymentEvent?.amount ?? "")
        _dueDate = State(initialValue: paymentEvent?.date ?? Date())
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Title", text: $title)
                    TextField("Amount", text: $amount)
                }

                Section {
                    DatePicker("Due Date", selection: $dueDate, displayedComponents: [.date])
                }
            }
            .navigationTitle(paymentEvent == nil ? "New Payment" : "Edit Payment")
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
                    .disabled(title.isEmpty || amount.isEmpty)
                }
            }
        }
    }

    private func save() async {
        do {
            if let oldEvent = paymentEvent {
                let newEvent = PaymentEvent(id: oldEvent.id, title: title, amount: amount, date: dueDate)
                try await store.update(paymentEvent: newEvent)
            } else {
                let newEvent = PaymentEvent(id: UUID().uuidString, title: title, amount: amount, date: dueDate)
                try await store.create(paymentEvent: newEvent)
            }

            await onSave()
            dismiss()
        } catch {
            Logger.mfEventKit.error("\(Self.self).\(#function) Failed to save payment event: \(error.localizedDescription)")
        }
    }
}

#Preview {
    NavigationStack {
        PaymentEventListView()
    }
}
