//
//  TaxReturn.swift
//  MoneyFeedbackInternal
//
//  Created by mzp on 10/16/25.
//

import Foundation
import SwiftData

@Model
class TaxReturn {
    var year: Int
    var federalTax: Decimal
    var stateTax: Decimal

    init(year: Int, federalTax: Decimal, stateTax: Decimal) {
        self.year = year
        self.federalTax = federalTax
        self.stateTax = stateTax
    }
}
