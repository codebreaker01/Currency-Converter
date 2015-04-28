//
//  CurrencyRatesUtils.swift
//  CurrencyConverter
//
//  Created by Jaikumar Bhambhwani on 4/27/15.
//  Copyright (c) 2015 Jaikumar Bhambhwani. All rights reserved.
//

import Foundation
import CoreData

extension Currency {
    
    func findOrCreateEntity(entity:String, currencyList:Array<String>, managedObject: ((NSManagedObject) -> Void)? ) {
        
        var sortedIDs = currencyList.sorted { $0.localizedCaseInsensitiveCompare($1) == NSComparisonResult.OrderedAscending }
        var fetchRequest: NSFetchRequest = NSFetchRequest.init()
        fetchRequest.entity = NSEntityDescription.entityForName(entity, inManagedObjectContext: self.managedObjectContext!)
        fetchRequest.predicate = NSPredicate(format: "currencyId IN %@", sortedIDs)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "currencyId", ascending: true)]
        var error: NSError?
        var matchingObjects = self.managedObjectContext?.executeFetchRequest(fetchRequest, error:&error) as? Array<Currency>
        
        var newManagedObjects =  Array<Currency>()
        if matchingObjects != nil {
            for var x = 0, y = 0; x < sortedIDs.count; x++ {
                if let currency = matchingObjects?[y] {
                    if sortedIDs[x] != currency.currencyId {
                        newManagedObjects.append(NSEntityDescription.insertNewObjectForEntityForName("Currency", inManagedObjectContext: DataManager.sharedInstance.managedObjectContext!) as! Currency)
                    } else {
                        y++
                    }
                }
            }
        }
        matchingObjects? += newManagedObjects
    }
}