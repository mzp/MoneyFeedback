//
//  MoneyFeedbackScene.swift
//  MoneyFeedbackInternal
//
//  Created by mzp on 10/16/25.
//

import SwiftData
import SwiftUI

public struct MoneyFeedbackScene: Scene {
    public init() {
    }

    public var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(for: [
                    PaymentEvent.self
                ])
        }
    }
}
