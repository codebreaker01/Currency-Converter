//
//  DictionaryUtils.swift
//  CurrencyConverter
//
//  Created by Jaikumar Bhambhwani on 4/27/15.
//  Copyright (c) 2015 Jaikumar Bhambhwani. All rights reserved.
//

import Foundation

extension Dictionary {
    
    mutating func update(other:Dictionary) {
        for (key,value) in other {
            self.updateValue(value, forKey:key)
        }
    }
    
}