//
//  WebServiceClient.swift
//  CurrencyConverter
//
//  Created by Jaikumar Bhambhwani on 4/25/15.
//  Copyright (c) 2015 Jaikumar Bhambhwani. All rights reserved.
//

import Foundation
import Alamofire

public class WebServiceClient  {
    
    // MARK: - Singleton Instance
    
    static let sharedInstance = WebServiceClient()
    
    // MARK: - Web Services
    
    public func buildCurrencyList(completion:(() -> Void)?) {
        
        if let currencySymbolSource = DataManager.sharedInstance.currencySymbolSource() {
            
            // Get available Currency List
            Alamofire.request(.GET, kURLForCurrencies)
                .responseJSON { (_, _, availableCurrencyJSON, _) in
                    
                    if let availableCurrency = availableCurrencyJSON as? Dictionary<String, String> {
                        
                        DataManager.sharedInstance.aggregateCurrencyListDataSources(currencySymbolSource, availableCurrencySource: availableCurrency)
                        completion?()
                    }
            }
        }
    }
    
    public func getCurrencyRates(completion:(() -> Void)?) {
        
        let params = [
            "base" : "USD",
            "apiKey" : kJSONRatesAPIKey
        ]
        
        Alamofire.request(.GET, kURLForExchangeRate, parameters: params)
            .responseJSON { (_, _, results, _) in
                
                if let json = results as? Dictionary<String, AnyObject> {
                    
                    if let rates = json["rates"] as? Dictionary<String, String> {
                        
                        DataManager.sharedInstance.manageExchangeRates(json["base"] as! String, lastUpdated: json["utctime"] as! String, rates:rates)
                        DataManager.sharedInstance.aggregateCurrencyWithCurrencyRates()
                        completion?()
                    }
                }
        }
    }
    
    public func getHistoricalRates(from:NSString!, to:NSString!, start:NSDate!, end:NSDate!, completion:(() -> Void)?) {
        
        let params = [
            "from"      : from,
            "to"        : to,
            "dateStart" : start,
            "dateEnd"   : end,
            "apiKey"    : kJSONRatesAPIKey
        ]
        
        Alamofire.request(.GET, kURLForHistoricalData, parameters: params)
            .responseJSON { (_, _, results, _) in
                
                if let json = results as? Dictionary<String, AnyObject> {
                    
                    if let rates = json["rates"] as? Dictionary<String, String> {
                        
                        DataManager.sharedInstance.manageHistoricalData(json["from"] as! String, to:json["to"] as! String, rates:rates)
                        completion?()
                    }
                }
        }
    }
    
}