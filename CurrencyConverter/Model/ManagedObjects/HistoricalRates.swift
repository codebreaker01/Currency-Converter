//
//  HistoricalRates.swift
//  CurrencyConverter
//
//  Created by Jaikumar Bhambhwani on 5/9/15.
//  Copyright (c) 2015 Jaikumar Bhambhwani. All rights reserved.
//

import Foundation
import CoreData

class HistoricalRates: NSManagedObject {

    @NSManaged var currencyFrom: String
    @NSManaged var currencyTo: String
    @NSManaged var rates: AnyObject

}
