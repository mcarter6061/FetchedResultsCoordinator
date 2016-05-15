import CoreData
import UIKit

@objc(TableCellConfigurator) public protocol TableCellConfiguratorObjC {
    
    func configureCell(cell: UITableViewCell, withObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath)
    
    func cellReuseIdentifierForObject(object: NSManagedObject, atIndexPath indexPath: NSIndexPath) -> String
}

@objc(FetchedTableDataSource) public class FetchedTableDataSourceObjC: NSObject {
    
    private var dataSource: FetchedTableDataSource<NSManagedObject,UITableViewCell>!
    
    public var systemHeaders:Bool {
        get { return dataSource.systemHeaders }
        set { dataSource.systemHeaders = newValue }
    }
    
    public var tableIndex: Bool {
        get { return dataSource.tableIndex }
        set { dataSource.tableIndex = newValue }
    }
    
    public var defaultSectionTitle: String? {
        get { return dataSource.defaultSectionTitle }
        set { dataSource.defaultSectionTitle = newValue }
    }
    
    public init(cellConfigurator: TableCellConfiguratorObjC, fetchedResultsController: NSFetchedResultsController) {
        let configurator = _TableCellConfiguratorObjC( cellConfigurator: cellConfigurator )
        self.dataSource = FetchedTableDataSource(cellConfigurator: configurator, fetchedResultsController: fetchedResultsController)
    }
    
    @objc public func sectionInfoForSection( sectionIndex: Int ) -> NSFetchedResultsSectionInfo? {
        return dataSource.sectionInfoForSection(sectionIndex)
    }

    @objc public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return dataSource.numberOfSectionsInTableView(tableView)
    }
    
    @objc public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.tableView(tableView, numberOfRowsInSection: section)
    }
    
    @objc public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return dataSource.tableView(tableView, cellForRowAtIndexPath: indexPath)
    }
    
    @objc public func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return dataSource.tableView(tableView, titleForHeaderInSection: section)
    }
    
    @objc public func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return dataSource.sectionIndexTitlesForTableView(tableView)
    }
    
    @objc public func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return dataSource.tableView(tableView, sectionForSectionIndexTitle: title, atIndex: index)
    }
    
}

private class _TableCellConfiguratorObjC: TableCellConfigurator {
    // Implements swift generic protocol by proxying to passed in ObjC version, this is needed to pass into our FetchedTableDataSource initializer.
    
    let configurator: TableCellConfiguratorObjC
    
    init( cellConfigurator: TableCellConfiguratorObjC ) {
        self.configurator = cellConfigurator
    }
    
    func configureCell(cell: UITableViewCell, withObject object: NSManagedObject, atIndexPath indexPath: NSIndexPath) {
        configurator.configureCell(cell, withObject: object, atIndexPath: indexPath)
    }
    
    func cellReuseIdentifierForObject(object: NSManagedObject, atIndexPath indexPath: NSIndexPath) -> String {
        return configurator.cellReuseIdentifierForObject(object, atIndexPath: indexPath)
    }
}

