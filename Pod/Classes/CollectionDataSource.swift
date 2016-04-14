//  Copyright © 2015 Mark Carter. All rights reserved.

import Foundation
import CoreData
import UIKit


public protocol CollectionCellConfigurator {
    
    associatedtype ManagedObjectType: NSManagedObject
    
    func configureCell( cell: UICollectionViewCell, withManagedObject managedObject: ManagedObjectType )
    func cellReuseIdentifierForManagedObject( managedObject: ManagedObjectType ) -> String
}

@objc public protocol CollectionViewSupplementaryViewConfigurator {
    
    func configureView( view: UICollectionReusableView, ofKind: String, atIndexPath: NSIndexPath )
    func reuseIdentifierForSupplementaryViewOfKind( kind: String, atIndexPath: NSIndexPath ) -> String
}



public class SimpleCollectionDataSource<ManagedObjectType:NSManagedObject>: NSObject, UICollectionViewDataSource {
    
    public var fetchedResultsController: NSFetchedResultsController
    
    private var cellConfigurator: AnyCollectionCellConfigurator<ManagedObjectType>
    internal var supplementaryViewConfigurator: CollectionViewSupplementaryViewConfigurator?
    
    public init<U:CollectionCellConfigurator where U.ManagedObjectType == ManagedObjectType>( fetchedResultsController: NSFetchedResultsController, cellConfigurator: U, supplementaryViewConfigurator: CollectionViewSupplementaryViewConfigurator? ) {
        
        self.fetchedResultsController = fetchedResultsController
        self.cellConfigurator = AnyCollectionCellConfigurator(cellConfigurator)
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
        
        guard let object = fetchedResultsController.objectAtIndexPath(indexPath) as? ManagedObjectType else {
            fatalError("Incorrect object type")
        }
        
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

extension CollectionCellConfigurator {
    
    // Helper method to create the UpdateCell function passed into a FetchedResultsCoordinator
    // The function fetches the visible cell at indexPath and if it exists configures it again
    // This is used to avoid the animation "flash" when you call tableView.reloadRowsAtIndexPaths
    public func makeUpdateVisibleCell( collectionView: UICollectionView ) -> ( NSIndexPath, ManagedObjectType ) -> Void {
        return { indexPath, object in
            guard let cell = collectionView.cellForItemAtIndexPath( indexPath ) else { return }
            self.configureCell(cell, withManagedObject: object )
        }
    }

}

// Type erased wrapper for CollectionCellConfigurator protocol
private class AnyCollectionCellConfigurator<ManagedObjectType:NSManagedObject>: CollectionCellConfigurator {
    
    let _configureCell: (cell:UICollectionViewCell,withManagedObject:ManagedObjectType)->()
    let _cellReuseIdentifierForManagedObject: (managedObject: ManagedObjectType) -> String
    
    init<U:CollectionCellConfigurator where U.ManagedObjectType == ManagedObjectType>( _ configurator: U ) {
        _cellReuseIdentifierForManagedObject = configurator.cellReuseIdentifierForManagedObject
        _configureCell = configurator.configureCell
    }
    
    func configureCell(cell: UICollectionViewCell, withManagedObject managedObject: ManagedObjectType) {
        _configureCell(cell: cell, withManagedObject: managedObject)
    }
    
    func cellReuseIdentifierForManagedObject(managedObject: ManagedObjectType) -> String {
        return _cellReuseIdentifierForManagedObject(managedObject: managedObject)
    }
    
}


