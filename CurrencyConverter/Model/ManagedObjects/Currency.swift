//
//  Currency.swift
//  CurrencyConverter
//
//  Created by Jaikumar Bhambhwani on 5/9/15.
//  Copyright (c) 2015 Jaikumar Bhambhwani. All rights reserved.
//

import Foundation
import CoreData

class Currency: NSManagedObject {

    @NSManaged var countryName: String
    @NSManaged var currencyId: String
    @NSManaged var currencyName: String
    @NSManaged var currencySymbol: String
    @NSManaged var isBase: NSNumber
    @NSManaged var selected: NSNumber
    @NSManaged var rate: String
    @NSManaged var rateDouble: NSNumber
    @NSManaged var inverseRate: NSNumber

}
