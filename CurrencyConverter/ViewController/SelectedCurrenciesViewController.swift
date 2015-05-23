//
//  SelectedCurrencies.swift
//  CurrencyConverter
//
//  Created by Jaikumar Bhambhwani on 5/9/15.
//  Copyright (c) 2015 Jaikumar Bhambhwani. All rights reserved.
//

import UIKit
import CoreData

class SelectedCurrenciesViewController: BaseViewController, NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    // MARK:- View Properties
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK:- Data handling Properties
    
    var shouldReloadCollectionView = false;
    var blockOperation: NSBlockOperation!;
    
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
        
        self.collectionView.registerNib(UINib(nibName: "CurrencyCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: kCurrencyCollectionViewCellIdentifier)
        
        WebServiceClient.sharedInstance.buildCurrencyList() {
            
            WebServiceClient.sharedInstance.getCurrencyRates() {
                
                var error : NSError?
                self.fetchedResultsController.performFetch(&error)
                if let n = (self.fetchedResultsController.sections?.first as? NSFetchedResultsSectionInfo)?.numberOfObjects {
                    if n == 0 {
                        Currency.setDefaultCurrencies()
                        self.fetchedResultsController.performFetch(&error)
                    }
                }
                self.collectionView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // MARK: - UICollectionViewDataSouce
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        let info = self.fetchedResultsController.sections?[section] as? NSFetchedResultsSectionInfo
        if let n = (self.fetchedResultsController.sections?.first as? NSFetchedResultsSectionInfo)?.numberOfObjects {
            return n
        } else {
            return 0
        }
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
       
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier(kCurrencyCollectionViewCellIdentifier, forIndexPath: indexPath) as! UICollectionViewCell
        configureCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    func configureCell(cell:UICollectionViewCell, atIndexPath:NSIndexPath) {
        
        if let currency = self.fetchedResultsController.objectAtIndexPath(atIndexPath) as? Currency {
            var currencyCell = cell as? CurrencyCollectionViewCell
            currencyCell?.currency = currency
        }
        
    }
    
    // MARK: - UICollectionViewDelegate, UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: self.view.bounds.size.width, height: 90)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return 0
    }
    
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        
        let collectionView = self.collectionView
        switch type {
            case .Insert:
                self.blockOperation.addExecutionBlock({
                    collectionView.insertSections( NSIndexSet(index: sectionIndex) )
                })
            case .Delete:
                self.blockOperation.addExecutionBlock({
                    collectionView.deleteSections( NSIndexSet(index: sectionIndex) )
                })
            case .Update:
                self.blockOperation.addExecutionBlock({
                    collectionView.reloadSections( NSIndexSet(index: sectionIndex ) )
                })
            default:()
        }
    }
    
    func controller(controller: NSFetchedResultsController,
        didChangeObject anObject: AnyObject,
        atIndexPath indexPath: NSIndexPath?,
        forChangeType type: NSFetchedResultsChangeType,
        newIndexPath: NSIndexPath?) {
            
        let collectionView = self.collectionView
        switch type {
            
        case .Insert:
            if collectionView.numberOfSections() > 0 {
                
                if collectionView.numberOfItemsInSection( newIndexPath!.section ) == 0 {
                    self.shouldReloadCollectionView = true
                } else {
                    self.blockOperation.addExecutionBlock({
                        collectionView.insertItemsAtIndexPaths([newIndexPath!])
                    })
                }
                
            } else {
                self.shouldReloadCollectionView = true
            }
            
        case .Delete:
            if collectionView.numberOfItemsInSection(indexPath!.section) == 1 {
                self.shouldReloadCollectionView = true
            } else {
                self.blockOperation.addExecutionBlock({
                    collectionView.deleteItemsAtIndexPaths([indexPath!])
                })
            }
            
        case .Update:
            self.blockOperation.addExecutionBlock({
                collectionView.reloadItemsAtIndexPaths([indexPath!])
            })
            
        case .Move:
            self.blockOperation.addExecutionBlock({
                collectionView.moveItemAtIndexPath(indexPath!, toIndexPath: newIndexPath!)
            })
        default:()
        }
    }
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        self.shouldReloadCollectionView = false
        self.blockOperation = NSBlockOperation()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        // Checks if we should reload the collection view to fix a bug @ http://openradar.appspot.com/12954582
        if self.shouldReloadCollectionView {
            self.collectionView.reloadData()
        } else {
            self.collectionView.performBatchUpdates({
                self.blockOperation.start()
                }, completion: nil )
        }
    }
    
}