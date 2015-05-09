//
//  CurrencyRatesUtils.swift
//  CurrencyConverter
//
//  Created by Jaikumar Bhambhwani on 4/27/15.
//  Copyright (c) 2015 Jaikumar Bhambhwani. All rights reserved.
//

import Foundation
import CoreData

let kCurrencyEntityName = "Currency"

extension Currency {
    
    class func findOrCreateEntity(currencyList:Array<String>, managedObject: ((NSManagedObject) -> Void)? ) {
        
        var sortedIDs = currencyList.sorted { $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
        var fetchRequest: NSFetchRequest = NSFetchRequest.init()
        fetchRequest.entity = NSEntityDescription.entityForName(kCurrencyEntityName, inManagedObjectContext: DataManager.sharedInstance.managedObjectContext!)
        fetchRequest.predicate = NSPredicate(format: "currencyId IN %@", sortedIDs)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "currencyId", ascending: true)]
        var error: NSError?
        var matchingObjects = DataManager.sharedInstance.managedObjectContext?.executeFetchRequest(fetchRequest, error:&error) as? Array<Currency>
        
        if matchingObjects != nil && matchingObjects?.count > 0 {
            for var x = 0, y = 0; x < sortedIDs.count; x++ {
                if let currencyFromDb = matchingObjects?[y] {
                    if sortedIDs[x] != currencyFromDb.currencyId {
                        var currency = Currency.insertNewObjectInContext(DataManager.sharedInstance.managedObjectContext!)
                        currency.currencyId = sortedIDs[x]
                        managedObject?(currency)
                    } else {
                        managedObject?(currencyFromDb)
                        y++
                    }
                }
            }
        } else {
            for currencyId in sortedIDs {
                var currency = Currency.insertNewObjectInContext(DataManager.sharedInstance.managedObjectContext!)
                currency.currencyId = currencyId
                managedObject?(currency)
            }
        }
    }
    
    class func addCurrency(currency:Currency) {
        currency.selected = true
        DataManager.sharedInstance.saveContext()
    }
    
    class func getSelectedCurrencies() -> Array<Currency>? {
        
        var fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName(kCurrencyEntityName, inManagedObjectContext: DataManager.sharedInstance.managedObjectContext!)
        fetchRequest.predicate = NSPredicate(format: "(selected == 1)")
        
        var error: NSError?;
        var results = DataManager.sharedInstance.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? Array<Currency>
        return results
    }
    
    class func insertNewObjectInContext(context:NSManagedObjectContext) -> Currency {
        let entity = NSEntityDescription.entityForName(kCurrencyEntityName, inManagedObjectContext: context)
        return NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context) as! Currency
    }
    
}