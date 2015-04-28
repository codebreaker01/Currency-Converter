//
//  CurrencyRates.swift
//  CurrencyConverter
//
//  Created by Jaikumar Bhambhwani on 4/27/15.
//  Copyright (c) 2015 Jaikumar Bhambhwani. All rights reserved.
//

import Foundation
import CoreData

class CurrencyRates: NSManagedObject {

    @NSManaged var currencyRates: AnyObject
    @NSManaged var lastUpdated: NSDate

}
