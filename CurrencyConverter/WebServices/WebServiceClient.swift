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
        Alamofire.request(.GET, kURLForCurrencyList)
            .responseJSON { (_, _, JSON, _) in
                
        }
    }
}