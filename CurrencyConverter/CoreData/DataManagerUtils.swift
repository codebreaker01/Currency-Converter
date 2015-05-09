//
//  DataManagerExt.swift
//  CurrencyConverter
//
//  Created by Jaikumar Bhambhwani on 4/25/15.
//  Copyright (c) 2015 Jaikumar Bhambhwani. All rights reserved.
//

import Foundation

extension DataManager {
    
    // MARK: - Public Utilities
    
    public func aggregateCurrencyListDataSources(currencySymbolSource: Dictionary<String, AnyObject>, availableCurrencySource: Dictionary<String, String>) {
        
        Currency.findOrCreateEntity(availableCurrencySource.keys.array) { (managedObj) -> Void in
            var currency = managedObj as? Currency
            if currency != nil {
                if let currencyName = availableCurrencySource[currency!.currencyId] {
                    currency?.currencyName = currencyName
                }
                if let currencySymbolDict = currencySymbolSource[currency!.currencyId] as? Dictionary<String, String> {
                    if let currencySymbol = currencySymbolDict["currencySymbol"] {
                        currency?.currencySymbol = currencySymbol
                    }
                }
            }
        }
        self.saveContext()
    }
    
    public func manageExchangeRates(base:String, lastUpdated:String, rates:Dictionary<String, String>) {
        
        var baseRate = [ base : "1.0"]
        baseRate.update(rates)
        
        CurrencyRates.deleteAll()
        var cr = CurrencyRates.insertNewObjectInContext(DataManager.sharedInstance.managedObjectContext!)
        cr.currencyRates = baseRate
        if let utcDate = NSDate.toUTCDate(lastUpdated) {
            cr.lastUpdated = utcDate.toLocalTime()
        }
        DataManager.sharedInstance.saveContext()
    }
    
    public func manageHistoricalData(from:String, to:String, rates:Dictionary<String, String>) {
        
        var hr = HistoricalRates.insertNewObjectInContext(DataManager.sharedInstance.managedObjectContext!)
        hr.currencyFrom = from
        hr.currencyTo = to
        hr.rates = rates
    }
    
    public func getBaseCurrency() -> String? {
        
        if let base = NSUserDefaults.standardUserDefaults().valueForKey(kUserDefaultsBaseCurrencyKey) as? String {
            return base
        } else {
            
            if let countryCode = NSLocale.currentLocale().objectForKey(NSLocaleCountryCode) as? String {
                if let country = NSLocale.currentLocale().displayNameForKey(NSLocaleCountryCode, value: countryCode) {
                    if let currencyCode = self.countryToCurrencyCode(country) {
                        return currencyCode;
                    }
                }
            }
        }
        return "USD"
    }
    
    public func setBaseCurrency(base:String!) {
        NSUserDefaults.standardUserDefaults().setValue(base, forKey: kUserDefaultsBaseCurrencyKey)
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    internal func currencySymbolSource() -> Dictionary<String, AnyObject>? {
        
        var error: NSError?
        if let path = NSBundle.mainBundle().pathForResource("ListCurrencySymbol", ofType: "json") {
            if let data = NSData(contentsOfFile: path) {
                let json:AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error:&error)!
                if let dictionaryObj = json as? Dictionary<String, AnyObject> {
                    if let resultsObj = dictionaryObj["results"] as? Dictionary<String, AnyObject> {
                        return resultsObj
                    }
                }
            }
        }
        return nil
    }
    
    // MARK: - Internal Utilities
    
    internal func countryToCurrencyCode(country:String!) -> String? {
        
        var error: NSError?
        if let path = NSBundle.mainBundle().pathForResource("Locale", ofType: "json") {
            if let data = NSData(contentsOfFile: path) {
                let json:AnyObject = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error:&error)!
                if let dictionaryObj = json as? Dictionary<String, AnyObject> {
                    for locale in dictionaryObj.keys {
                        if let currencyDict = dictionaryObj[locale] as? Dictionary<String, String> {
                            if let countryName: String = currencyDict["name"] {
                                if countryName.lowercaseString.rangeOfString(country.lowercaseString) != nil {
                                    return currencyDict["currency"]
                                }
                            }
                        }
                    }
                }
            }
        }
        return nil
    }
}