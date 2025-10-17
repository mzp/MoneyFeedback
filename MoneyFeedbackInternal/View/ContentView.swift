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

    let year: Int

    @State private var federalTax = ""
    @State private var stateTax = ""
    @State private var taxReturns: [TaxReturn] = []

    init(year: Int = 2024) {
        self.year = year
    }

    var existingTaxReturn: TaxReturn? {
        taxReturns.first
    }

    var body: some View {
        Form {
            Section("Tax Amount (\(year, format: .number.grouping(.never)))") {
                TextField("Federal Tax", text: $federalTax)
                    .keyboardType(.decimalPad)

                TextField("State Tax", text: $stateTax)
                    .keyboardType(.decimalPad)
            }

            Section {
                Button("Save") {
                    saveTaxReturn()
                }
            }
        }
        .onAppear {
            loadTaxReturns()
            loadExistingData()
        }
    }

    private func loadTaxReturns() {
        let descriptor = FetchDescriptor<TaxReturn>(
            predicate: #Predicate { $0.year == year }
        )
        taxReturns = (try? modelContext.fetch(descriptor)) ?? []
        Logger.mfData.log("Tax returns loaded: \(taxReturns, privacy: .private)")
    }

    private func loadExistingData() {
        if let existing = existingTaxReturn {
            federalTax = existing.federalTax.description
            stateTax = existing.stateTax.description
            Logger.mfData.log("Update form from \(existing, privacy: .private)")
        }
    }

    private func saveTaxReturn() {
        let federal = Decimal(string: federalTax) ?? 0
        let state = Decimal(string: stateTax) ?? 0

        if let existing = existingTaxReturn {
            Logger.mfData.log("Update existing record")
            existing.federalTax = federal
            existing.stateTax = state
        } else {
            Logger.mfData.log("Create new record")
            let newTaxReturn = TaxReturn(year: year, federalTax: federal, stateTax: state)
            modelContext.insert(newTaxReturn)
        }
        loadTaxReturns()
    }
}

#Preview {
    ContentView()
}
