//
//  SelectedCurrencies.swift
//  CurrencyConverter
//
//  Created by Jaikumar Bhambhwani on 5/9/15.
//  Copyright (c) 2015 Jaikumar Bhambhwani. All rights reserved.
//

import UIKit
import CoreData

class SelectedCurrenciesViewController: UIViewController, NSFetchedResultsControllerDelegate {

    // MARK:- Properties
    
    lazy var fetchedResultsController : NSFetchedResultsController = {
        let fetchRC = NSFetchedResultsController(
            fetchRequest: Currency.getSelectedCurrenciesFetchReqest(),
            managedObjectContext: DataManager.sharedInstance.managedObjectContext!,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        fetchRC.delegate = self
        return fetchRC
    } ()
    
    // MARK:- Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}