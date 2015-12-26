//  Copyright © 2015 Mark Carter. All rights reserved.

import Foundation
import CoreData
import UIKit


@objc public protocol CollectionCellConfigurator {
    
    func configureCell( cell: UICollectionViewCell, withManagedObject managedObject: NSManagedObject )
    func cellReuseIdentifierForManagedObject( managedObject: NSManagedObject ) -> String
}

@objc public protocol CollectionViewSupplementaryViewConfigurator {
    
    func configureView( view: UICollectionReusableView, ofKind: String, atIndexPath: NSIndexPath )
    func reuseIdentifierForSupplementaryViewOfKind( kind: String, atIndexPath: NSIndexPath ) -> String
}



public class SimpleCollectionDataSource: NSObject, UICollectionViewDataSource {
    
    public var fetchedResultsController: NSFetchedResultsController
    
    var cellConfigurator: CollectionCellConfigurator
    var supplementaryViewConfigurator: CollectionViewSupplementaryViewConfigurator?
    
    public init( fetchedResultsController: NSFetchedResultsController, cellConfigurator: CollectionCellConfigurator, supplementaryViewConfigurator: CollectionViewSupplementaryViewConfigurator? ) {
        
        self.fetchedResultsController = fetchedResultsController
        self.cellConfigurator = cellConfigurator
        self.supplementaryViewConfigurator = supplementaryViewConfigurator
    }
    
    public func sectionInfoForSection( sectionIndex: Int ) -> NSFetchedResultsSectionInfo? {
        
        if let sectionInfo = self.fetchedResultsController.sections?[sectionIndex] {
            return sectionInfo
        }
        
        return nil
    }
    
    
    // MARK: - UICollectionViewDataSource methods
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if let sectionInfo = sectionInfoForSection(section) {
            return sectionInfo.numberOfObjects
        }
        
        return 0
    }
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        if let sections = self.fetchedResultsController.sections {
            return sections.count
        }
        
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let object = fetchedResultsController.objectAtIndexPath(indexPath) as! NSManagedObject
        
        let reuseIdentifier = cellConfigurator.cellReuseIdentifierForManagedObject(object)
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(reuseIdentifier, forIndexPath: indexPath)
        
        cellConfigurator.configureCell(cell, withManagedObject: object)
        
        return cell
    }
    
    // do not expose collectionView:viewForSupplementaryElementOfKind:atIndexPath: if no supplementaryViewConfigurator was passed in
    public override func respondsToSelector(aSelector: Selector) -> Bool {
        
        if aSelector == NSSelectorFromString("collectionView:viewForSupplementaryElementOfKind:atIndexPath:") {
            return supplementaryViewConfigurator != nil
        }
        
        return super.respondsToSelector(aSelector)
    }
    
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        guard let supplementaryViewConfigurator = self.supplementaryViewConfigurator else {
            fatalError("Should not be able to call collectionView:viewForSupplementaryElementOfKind:atIndexPath without a supplementaryViewConfiugrator set")
        }
        
        let reuseIdentifier = supplementaryViewConfigurator.reuseIdentifierForSupplementaryViewOfKind(kind, atIndexPath: indexPath)
        
        let supplementaryView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: reuseIdentifier, forIndexPath: indexPath)
        
        supplementaryViewConfigurator.configureView(supplementaryView, ofKind: kind, atIndexPath: indexPath)
        
        return supplementaryView
    }
    
}

