# FetchedResultsCoordinator

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

FetchedResultsCoordinator is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "FetchedResultsCoordinator"
```

# Documentation

FetchedResultsCoordinator is an object which observes section/object changes in a Fetched Results Controller (FRC) and then applies the changes to a table or collection view that is backed by the FRC.  There is [standard boilerplate implementations](https://developer.apple.com/library/ios/documentation/CoreData/Reference/NSFetchedResultsControllerDelegate_Protocol/) of this code in the Apple documentation for NSFetchedResultsControllerDelegate.  The FetchedResultsCoordinator uses this implementation and wraps it in an easy to integrate interface.

The most common usage is likely in a controller class which owns a FetchedResultsController and has a table or collection subview.  Instantiate the coordinator like this:

```swift
    frcCoordinator = FetchedResultsCoordinator( tableView: self.tableView!, fetchedResultsController: self.fetchedResultsController, cellConfigurator: self )
```

or for a collection view:

```swift
    frcCoordinator = FetchedResultsCoordinator( collectionView: self.collectionView!, fetchedResultsController: self.fetchedResultsController, cellConfigurator: self )
```

When you are ready to load the data call `loadData()` on the coordinator and it will perform the fetch on the FRC and tell the table or collection view to reload its data.  This is used in place of the FRC `performFetch()`, which should not be called directly when using the coordinator.

```swift
    frcCoordinator?.loadData()
```

After this all changes observed by the FRC will be refelected in the table/collection view.

### reloading vs reconfiguring cells

The initialization parameter `cellConfigurator` is optional.  Providing one will let the coordinator call your cell configuration code again for an updated object rather than asking the table/collection view to reload that row/cell (which may cause an undesirable animation for that row/cell).  See the sections of this document for the SimpleTableViewDataSource and SimpleCollectionDataSource for more discussion of the cell configurator protocols.

### Pausing

The coordinator has a paused boolean property, which can be set should you wish to temporarily stop observing data changes.  For instance when bulk loading data there may be performance problems if you are observing a FRC and trying to apply every update to the view.  It may be a good idea to pause the coordinator during the bulk load and then unpause it once the data is loaded and the managed object context is saved.  

To stop updates you set `paused = true` on the coordinator.  The table/collection view will no longer be updated when the FRC's fetched objects are changed.  When you wish to restart observing changes set `paused = false` which will reload the data in the FRC and update the table/collection.  After that the view will be kept up to date with managed object changes.

### FRC delegate

To observe the changes the coordinator sets itself to be the delegate of the fetchedResultsController object passed in at instantiation.  This is slightly yucky as it isn't obvious that it is mutating the FRC.  Be aware that if you set the FRC's delegate to another object the coordinator will no longer be notified of data changes and it will not update the view.  Also when paused it will set the FRC's delegate to nil and when unpaused it will set it back to the coordinator.  You do not need to do anything, other than be aware that the coordinator is modifying the FRC's delegate property.

## Data Sources

There is more boilerplate code to implement `UITableViewDataSource/UICollectionViewDataSource` protocols when the view is backed by a `NSFetchedResultsController`.  This component supplies two basic data source objects which query the FRC in the implementation of the data source protocols.  Again the goal is to wrap up the simple biolerplate code in a easy to integrate interface.

### Table View Data Source

```swift
    tableViewDataSource = SimpleTableDataSource( configurator: self, fetchedResultsController: fetchedResultsController )
```

the configurator object ( most likely your table view controller ) must conform to `TableCellConfigurator` protocol.

```swift
public protocol TableCellConfigurator {
   
    func configureCell( cell: UITableViewCell, withObject: NSManagedObject )
    
    func cellReuseIdentifierForObject( object: NSManagedObject ) -> String
}
```

Those two methods and instantiating a SimpleTableDataSource is enough to get a table view up and running.

`cellReuseIdentifierForObject( object: NSManagedObject )` can just return a hard coded identifier if you only have one type of cell for your table.  This must be the cell's reuse identifier in your xib / storyboard.  If you have multiple types of cells the object for the cell is an argument to help determine which cell identifier to return.  

The coordinator will use the identifier returned to dequeue cells, and it will call the cell configurator `configureCell( cell: UITableViewCell, withObject: NSManagedObject )` to give you a chance to update the cell with the data from the object for that row.

The data source also supports table view system headers and table view indexes based on FRC section indexes.

```swift
tableViewDataSource?.systemHeaders = true
tableViewDataSource?.tableIndex = true
```

See the Example project `ExampleTableViewController` class for an example of how to use a `SimpleTableDataSource` in a `UITableViewController` subclass.  See the `ExampleTableViewSubviewController` class for an example of how to use a `SimpleTableDataSource` in a `UIViewController` subclass that has a `UITableView` subview.

### Collection View Data Source

TODO:

## Author

Mark Carter, mark@deeperdigital.co.uk

## License

FetchedResultsCoordinator is available under the MIT license. See the LICENSE file for more info.
