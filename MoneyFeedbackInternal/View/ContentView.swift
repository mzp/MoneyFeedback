//
//  ContentView.swift
//  MoneyFeedback
//
//  Created by mzp on 10/15/25.
//

import SwiftUI

public struct ContentView: View {
    public init() {}

    public var body: some View {
        NavigationStack {
            ReminderListView()
        }
    }
}

#Preview {
    ContentView()
}
