import Foundation
import CoreData

@objc(CollectionCellConfigurator) public protocol CollectionCellConfiguratorObjC {
    
    func configureCell( cell: UICollectionViewCell, withManagedObject managedObject: NSManagedObject )
    func cellReuseIdentifierForManagedObject( managedObject: NSManagedObject ) -> String
}


@objc(SimpleCollectionDataSource) public class SimpleCollectionDataSourceObjC: NSObject, UICollectionViewDataSource {

    public var fetchedResultsController: NSFetchedResultsController { return dataSource.fetchedResultsController }

    private var dataSource: SimpleCollectionDataSource<NSManagedObject,UICollectionViewCell>
    
    public init( fetchedResultsController: NSFetchedResultsController, cellConfigurator: CollectionCellConfiguratorObjC, supplementaryViewConfigurator: CollectionViewSupplementaryViewConfigurator? ) {
        let cellConfigurator = _CollectionCellConfiguratorObjC(cellConfigurator: cellConfigurator)
        dataSource = SimpleCollectionDataSource(fetchedResultsController: fetchedResultsController, cellConfigurator: cellConfigurator, supplementaryViewConfigurator: supplementaryViewConfigurator)
    }
    
    public func sectionInfoForSection( sectionIndex: Int ) -> NSFetchedResultsSectionInfo? {
        return dataSource.sectionInfoForSection(sectionIndex)
    }
    
    // MARK: - UICollectionViewDataSource methods
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.collectionView(collectionView, numberOfItemsInSection: section)
    }
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return dataSource.numberOfSectionsInCollectionView(collectionView)
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        return dataSource.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
    }
    
    // do not expose collectionView:viewForSupplementaryElementOfKind:atIndexPath: if no supplementaryViewConfigurator was passed in
    public override func respondsToSelector(aSelector: Selector) -> Bool {
        
        if aSelector == NSSelectorFromString("collectionView:viewForSupplementaryElementOfKind:atIndexPath:") {
            return dataSource.supplementaryViewConfigurator != nil
        }
        
        return super.respondsToSelector(aSelector)
    }
    
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        return dataSource.collectionView(collectionView, viewForSupplementaryElementOfKind: kind, atIndexPath: indexPath)
    }
    

}

private class _CollectionCellConfiguratorObjC: CollectionCellConfigurator {
    
    let cellConfigurator: CollectionCellConfiguratorObjC
    
    init( cellConfigurator: CollectionCellConfiguratorObjC ) {
        self.cellConfigurator = cellConfigurator
    }
    
    func configureCell( cell: UICollectionViewCell, withManagedObject managedObject: NSManagedObject ) {
        self.cellConfigurator.configureCell(cell, withManagedObject: managedObject)
    }
    func cellReuseIdentifierForManagedObject( managedObject: NSManagedObject ) -> String {
        return self.cellConfigurator.cellReuseIdentifierForManagedObject(managedObject)
    }

}