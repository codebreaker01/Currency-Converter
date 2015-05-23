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
    @IBOutlet weak var currencyCode: UILabel!
    @IBOutlet weak var currencyImage: UIImageView!
    @IBOutlet weak var currencyName: UILabel!
    
    @IBOutlet weak var separatorHeightConstraint: NSLayoutConstraint!
    
    var currency: Currency? {
        
        willSet(newCurrencyValue) {
            self.amountLabel.text = newCurrencyValue!.rate
            self.currencyCode.text = newCurrencyValue!.currencyId
            self.currencyImage.image = UIImage(named: "\((newCurrencyValue!.currencyId as NSString).substringToIndex(2).lowercaseString)")
            self.currencyName.text = newCurrencyValue?.currencyName
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.separatorHeightConstraint.constant = 1.0/UIScreen.mainScreen().scale
    }
    
}
