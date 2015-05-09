//
//  HistoricalDatesUtils.swift
//  CurrencyConverter
//
//  Created by Jaikumar Bhambhwani on 5/9/15.
//  Copyright (c) 2015 Jaikumar Bhambhwani. All rights reserved.
//

import Foundation
import CoreData

let kHistoricalRatesEntityName = "HistoricalRates"

extension HistoricalRates {
    
    class func fetchHistoricalRateFromdb(from:String, to:String) -> HistoricalRates? {
    
        var fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName(kHistoricalRatesEntityName, inManagedObjectContext: DataManager.sharedInstance.managedObjectContext!)
        fetchRequest.predicate = NSPredicate(format: "(currencyFrom == %@) AND (currencyTo == %@)", from, to)
        
        var error: NSError?;
        var results = DataManager.sharedInstance.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? Array<HistoricalRates>
        
        if results != nil && results?.count > 0 {
            return results?.first
        } else {
            return nil
        }
    }
    
    class func insertNewObjectInContext(context:NSManagedObjectContext) -> HistoricalRates {
        let entity = NSEntityDescription.entityForName(kHistoricalRatesEntityName, inManagedObjectContext: context)
        return NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context) as! HistoricalRates
    }
    
}