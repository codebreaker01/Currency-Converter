//
//  CurrencyRatesUtils.swift
//  CurrencyConverter
//
//  Created by Jaikumar Bhambhwani on 4/27/15.
//  Copyright (c) 2015 Jaikumar Bhambhwani. All rights reserved.
//

import Foundation
import CoreData

let kCurrencyRatesEntityName = "CurrencyRates"

extension CurrencyRates {
    
    class func deleteAll() {
        
        var fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName(kCurrencyRatesEntityName, inManagedObjectContext: DataManager.sharedInstance.managedObjectContext!)
        fetchRequest.includesPropertyValues = false
        var error: NSError?
        var objs = DataManager.sharedInstance.managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) as! Array<NSManagedObject>
        
        for managedObject in objs {
            DataManager.sharedInstance.managedObjectContext?.deleteObject(managedObject)
        }
        DataManager.sharedInstance.saveContext()
    }
    
    class func getAll() -> Dictionary<String, String>? {
        
        var fetchRequest = NSFetchRequest()
        fetchRequest.entity = NSEntityDescription.entityForName(kCurrencyRatesEntityName, inManagedObjectContext: DataManager.sharedInstance.managedObjectContext!)
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "lastUpdated", ascending: true)]
        var error: NSError?
        var objs = DataManager.sharedInstance.managedObjectContext?.executeFetchRequest(fetchRequest, error: &error) as? Array<CurrencyRates>
        return objs?.first?.currencyRates as? Dictionary<String, String>
    }
    
    class func insertNewObjectInContext(context:NSManagedObjectContext) -> CurrencyRates {
        let entity = NSEntityDescription.entityForName(kCurrencyRatesEntityName, inManagedObjectContext: context)
        return NSManagedObject(entity: entity!, insertIntoManagedObjectContext: context) as! CurrencyRates
    }
    
}