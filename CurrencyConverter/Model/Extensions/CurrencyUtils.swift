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
let defaultCurrencies = ["USD", "EURO", "GBP", "CAD", "AUD", "INR", "CNY"]

extension Currency {

    
    // MARK: - Find/Edit/Create Utils
    
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
    
    class func updateWithCurrencyRates(currencyRates:Dictionary<String, String>) {
        
        var sortedIDs = currencyRates.keys.array.sorted { $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
        var fetchRequest: NSFetchRequest = NSFetchRequest.init()
        fetchRequest.entity = NSEntityDescription.entityForName(kCurrencyEntityName, inManagedObjectContext: DataManager.sharedInstance.managedObjectContext!)
        fetchRequest.predicate = NSPredicate(format: "currencyId IN %@", sortedIDs)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "currencyId", ascending: true)]
        var error: NSError?
        var matchingObjects = DataManager.sharedInstance.managedObjectContext?.executeFetchRequest(fetchRequest, error:&error) as? Array<Currency>
        
        if matchingObjects != nil && matchingObjects?.count > 0 {
            for var x = 0, y = 0; x < sortedIDs.count; x++ {
                if let currencyFromDb = matchingObjects?[y] {
                    if sortedIDs[x] == currencyFromDb.currencyId {
                        if let rate = currencyRates[sortedIDs[x]] {
                            currencyFromDb.rate = rate
                            currencyFromDb.rateDouble = (rate as NSString).doubleValue
                            if currencyFromDb.rateDouble.doubleValue > 0 {
                                currencyFromDb.inverseRate = 1/currencyFromDb.rateDouble.doubleValue
                            } else {
                                currencyFromDb.inverseRate = 0
                            }
                        }
                        y++
                    }
                }
            }
        }
    }
    
    class func addSelectedCurrency(currency:Currency) {
        currency.selected = true
        DataManager.sharedInstance.saveContext()
    }
    
    class func removeSelectedCurrency(currency:Currency) {
        currency.selected = false
        DataManager.sharedInstance.saveContext()
    }
    
    class func setBaseCurrency(currency:Currency) {
        getBaseCurrency()?.isBase = false
        currency.isBase = true
        DataManager.sharedInstance.saveContext()
    }
    
    class func getBaseCurrency() -> Currency? {
        
        var fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName(kCurrencyEntityName, inManagedObjectContext: DataManager.sharedInstance.managedObjectContext!)
        fetchRequest.predicate = NSPredicate(format: "(isBase == 1)")
        
        var error: NSError?
        var results = DataManager.sharedInstance.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? Array<Currency>
        
        if let base = results?.first {
            return base
        } else {
            var base = getCurrency(DataManager.sharedInstance.getBaseCurrencyFromLocale())
            base?.isBase = true
            return base
        }
    }
    
    class func getCurrency(currencyName:String) -> Currency? {
        
        var fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName(kCurrencyEntityName, inManagedObjectContext: DataManager.sharedInstance.managedObjectContext!)
        fetchRequest.predicate = NSPredicate(format: "(currencyId == %@)", currencyName)
        
        var error: NSError?
        var results = DataManager.sharedInstance.managedObjectContext!.executeFetchRequest(fetchRequest, error: &error) as? Array<Currency>
        return results?.first
    }
    
    class func setDefaultCurrencies() {
        
        for currencyName in defaultCurrencies {
            var currency = getCurrency(currencyName)
            currency?.selected = true
        }
        _ = getBaseCurrency()
        DataManager.sharedInstance.saveContext()
    }
    
    class func getSelectedCurrenciesFetchReqest() -> NSFetchRequest {
        
        var fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName(kCurrencyEntityName, inManagedObjectContext: DataManager.sharedInstance.managedObjectContext!)
        fetchRequest.predicate = NSPredicate(format: "(selected == 1)")
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "currencyName", ascending: true), NSSortDescriptor(key: "isBase", ascending: false)]

        return fetchRequest
    }
    
    class func insertNewObjectInContext(context:NSManagedObjectContext) -> Currency {
        let entity = NSEntityDescription.entityForName(kCurrencyEntityName, inManagedObjectContext: context)
        return NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context) as! Currency
    }
    
}