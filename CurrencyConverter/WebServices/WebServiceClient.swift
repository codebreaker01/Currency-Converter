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
    
    public func buildCurrencyList() {
        
        // Get Currency List with Symbols
        Alamofire.request(.GET, kURLForCurrencySymbols)
            .responseJSON { (_, _, symbolCurrencyJSON, _) in
                
                if let symbolCurrency = symbolCurrencyJSON as? Dictionary<String, AnyObject> {
                    
                    if let symbolCurrencyResults = symbolCurrency["results"] as? Dictionary<String, AnyObject> {
                        
                    // Get available Currency List
                    Alamofire.request(.GET, kURLForCurrencies)
                        .responseJSON { (_, _, availableCurrencyJSON, _) in
                            
                            if let availableCurrency = availableCurrencyJSON as? Dictionary<String, AnyObject> {
                                
                                DataManager.sharedInstance.aggregateCurrencyListDataSources(symbolCurrencyResults, availableCurrencySource: availableCurrency)
                                
                            }
                    }
                }
            }
        }
    }
    
    public func getCurrencyRates() {
        
        let params = [
            "base" : "USD",
            "apiKey" : kJSONRatesAPIKey
        ]
        
        Alamofire.request(.GET, kURLForExchangeRate, parameters: params)
            .responseJSON { (_, _, results, _) in
                
                if let json = results as? Dictionary<String, AnyObject> {
                    
                    if let rates = json["rates"] as? Array<String> {
                        
                        DataManager.sharedInstance.manageExchangeRates(json["base"] as! String, rates: rates)
                        
                    }
                }
        }
    }
}