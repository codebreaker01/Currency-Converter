//
//  Currency.swift
//  CurrencyConverter
//
//  Created by Jaikumar Bhambhwani on 4/26/15.
//  Copyright (c) 2015 Jaikumar Bhambhwani. All rights reserved.
//

import Foundation
import CoreData

class Currency: NSManagedObject {

    @NSManaged var countryName: String
    @NSManaged var currencyId: String
    @NSManaged var currencyName: String
    @NSManaged var currencySymbol: String

}
