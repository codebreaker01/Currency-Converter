//
//  CurrencyCollectionViewCell.swift
//  CurrencyConverter
//
//  Created by Jaikumar Bhambhwani on 5/9/15.
//  Copyright (c) 2015 Jaikumar Bhambhwani. All rights reserved.
//

import UIKit

let kCurrencyCollectionViewCellIdentifier = "CurrencyCollectionViewCellIdentifier"

class CurrencyCollectionViewCell: UICollectionViewCell {

    // MARK: - UI Properties
    
    @IBOutlet weak var amountLabel: UILabel!
    @IBOutlet weak var currencyName: UILabel!
    @IBOutlet weak var currencyImage: UIImageView!
    
    var currency: Currency? {
        
        willSet(newCurrencyValue) {
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
