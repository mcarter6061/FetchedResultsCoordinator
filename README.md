# FetchedResultsCoordinator

## Usage

To run the example project, clone the repo, and run `pod install` from the Example directory first.  There is also a `README.playground` included in the example project showing a simple table view example.

## Installation

FetchedResultsCoordinator is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "FetchedResultsCoordinator"
```

# Documentation

FetchedResultsCoordinator observes section and object changes from a Fetched Results Controller (FRC) and then applies the changes to a table or collection view that is backed by the FRC.  There is a [standard boilerplate implementation](https://developer.apple.com/library/ios/documentation/CoreData/Reference/NSFetchedResultsControllerDelegate_Protocol/) of this code in the Apple documentation for NSFetchedResultsControllerDelegate.  The FetchedResultsCoordinator uses this implementation and wraps it in an easy to integrate interface.

The most common usage is likely in a controller class which owns a `NSFetchedResultsController` and has a table or collection subview.  Instantiate the coordinator like this for a table view:

```swift
    frcCoordinator = FetchedResultsCoordinator<T>( coordinatee: tableView!, fetchedResultsController: fetchedResultsController )
```

or for a collection view:

```swift
    frcCoordinator = FetchedResultsCoordinator<T>( coordinatee: collectionView!, fetchedResultsController: fetchedResultsController )
```

FetchedResultsCoordinator is a generic type, generic over the model object its FRC is fetching.  So for a FRC which is fetching some custom `Animal` model object, a `FetchedResultsCoordinator<Animal>` is a coordinator which monitors the FRC and coordinates updates to a table or collection view.

When you are ready to load the data call `loadData` on the coordinator and it will perform the fetch on the FRC and tell the table or collection view to reload its data.  This is used in place of the FRC `performFetch`, which should not be called directly when using the coordinator.

```swift
    frcCoordinator?.loadData()
```

After calling `loadData` all changes observed by the FRC will be reflected in the table/collection view.

### Reloading vs reconfiguring cells

The initialisation parameter `updateCell` is optional defaulting to `nil`.  Providing a function of which can reconfigure a cell will let the coordinator call your cell configuration code again for an updated object rather than asking the table/collection view to reload that row/cell (which may cause an undesirable animation).  
 
See the sections of this document for the `FetchedTableViewDataSource` and `SimpleCollectionDataSource` for more discussion of the cell configurator protocols, and a helper method to create the function to pass into `updateCell` to avoid the flashing animation.

### Pausing

The coordinator has a paused boolean property, which stops observing FRC changes when set to true.  For instance when bulk loading data there may be performance problems when observing a FRC and trying to apply every update to the view.  It may be a good idea to pause the coordinator during the bulk load and then unpause it once the data is loaded and the managed object context is saved.  

To stop updates you set `coordinator.paused = true`.  The table/collection view will no longer be updated when the FRC's fetched objects are changed.  When you wish to restart observing changes set `paused = false` which will reload the data in the FRC and update the table/collection.

### FRC delegate

To observe the changes the coordinator sets itself to be the delegate of the fetchedResultsController object passed in to its initializer.  This isn't ideal as it isn't obvious that the coordinator is mutating the FRC.  Be aware that if you set the FRC's delegate to another object the coordinator will no longer be notified of data changes and it will not update the table/collection view.  Also when paused it will set the FRC's delegate to nil and when unpaused it will set it back to the coordinator.  You do not need to do anything, other than be aware that the coordinator is modifying the FRC's delegate property. 🙁

### Coordinating other views

The constructor to `FetchedResultsCoordinator` takes any type conforming to the protocol `Coordinatable`.  Default implementations are provided for `UITableView` and `UICollectionView` so you can set either to be the `coordinatee`.  However if you have a custom view which is backed by a `NSFetchedResultsController` and you want to dynamically respond to object changes, it would just be a matter of implementing the `Coordinatable` protocol on your view.  Most of that work would be the `apply` method which gives a batch of changes to be applied to the view.

## Data Sources

There is more boilerplate code to implement `UITableViewDataSource` and `UICollectionViewDataSource` protocols when the table or collection view is backed by a `NSFetchedResultsController`.  This component supplies two simple generic data source objects (`FetchedTableDataSource` and `SimpleCollectionDataSource`) which implement the table/collection view data source protocols, using a passed in FRC to fetch the data.  Again the goal is to wrap up the simple biolerplate code in a easy to integrate interface.

### Table View Data Source

The `FetchedTableDataSource` type is generic across the `NSManagedObject` model object sublcass, and the custom `UITableViewCell` subclass for the table view cells. For example, if there is an `AnimalCell` which is a `UITableViewCell` subclass:

```swift
tableViewDataSource = FetchedTableDataSource<Animal,AnimalCell>( cellConfigurator: self, fetchedResultsController: fetchedResultsController )
tableView.dataSource = tableViewDataSource
```

#### Cell Configuration
To allow custom configuration of the table view cells, a `cellConfigurator` instance is passed in the `FetchedTableDataSource` initializer.  This instance (most likely your table view controller) must conform to the `TableCellConfigurator` protocol:

```swift
public protocol TableCellConfigurator {
    
    associatedtype ObjectType
    associatedtype CellType: UITableViewCell
   
    func configureCell( cell: CellType, withObject object: ObjectType, atIndexPath indexPath: NSIndexPath )
    
    func cellReuseIdentifierForObject( object: ObjectType, atIndexPath indexPath: NSIndexPath ) -> String
}
```

There are two *associated types* which will be supplied by the `TableCellConfigurator` implementation, which will be the same types specified in the *generic argument list* for the `FetchedTableDataSource` instance.  ie. For a FRC fetching `Animal` objects, the type conforming to `TableCellConfigurator` would implement something like:

```swift
func configureCell( cell: AnimalCell, withObject object: Animal, atIndexPath indexPath: NSIndexPath ) { 
    // cell configuration
    cell.animalName = managedObject.name
    ... 
}

func cellReuseIdentifierForManagedObject( object: Animal, atIndexPath indexPath: NSIndexPath ) -> String { 
    return "AnimalCellReuseIdentifier"
}
```

The `FetchedTableDataSource` will use the identifier string returned from `cellReuseIdentifierForManagedObject` to dequeue cells, and it will call the `configureCell` to give you a chance to configure the cell with the data from the model object for that row.

Implementing those two methods and hooking up a `FetchedTableDataSource` instance to the table view's `dataSource` property is enough to get a table view up and running. Be aware that the `dataSource` property on `UITableView` is weak, which means you will need to hold another strong reference to the instance elsewhere.

`cellReuseIdentifierForManagedObject` can just return a hardcoded identifier if the table only has one prototype cell.  This must be the cell's reuse identifier in your xib / storyboard.  If the table has multiple prototype cells the method should return the reuse identifier that applies to the row for the given associated model object.  In this case the `CellType` will have to be `UITableViewCell` and downcast to the cell subclass appropriately in the `configureCell` implementation.

If you are using a system `UITableViewCell` instead of a custom subclass ( ie a Basic, Right Detail, Left Detail, or Subtitle style cell), just use `UITableViewCell` as the `CellType` in `configureCell` and in the `FetchedTableDataSource` generic argument list.

#### Section headers and section index
The data source also supports `UITableView` system headers and section indexes based on FRC section indexes.

```swift
    public var systemHeaders: Bool = false
    public var tableIndex: Bool = false
    public var defaultSectionTitle: String?
```

When `systemHeaders` is set the section name from the FRC will be set as the title of each section header.  When `tableIndex` is set the table view will display the section index, using the capitalized first letter of each section name in the FRC. See the subclassing notes of the NSFetchedResultsController documentation for a discussion on how to customize the section indexs.  When `defaultSectionTitle` is set this will be used for the table view's section header.

See the Example project `ExampleTableViewController` class for an example of how to use a `FetchedTableDataSource` in a `UITableViewController` subclass.  See the `ExampleTableViewSubviewController` class for an example of how to use a `FetchedTableDataSource` in a `UIViewController` subclass that has a `UITableView` subview.

### Collection View Data Source

The `SimpleCollectionDataSource` follows the same conventions as the `FetchedTableDataSource`.  It is also generic across the model object and cell subclass.

```swift
dataSource = SimpleCollectionDataSource<Animal,AnimalCell>( fetchedResultsController: fetchedResultsController, cellConfigurator: self, supplementaryViewConfigurator: self )
collectionView.dataSource = dataSource
```

The collection data source has two configurators, one for cells and one for supplementary views.  

```swift
public protocol CollectionCellConfigurator {
    
    associatedtype ManagedObjectType: NSManagedObject
    associatedtype CellType: UICollectionViewCell
    
    func configureCell( cell: CellType, withManagedObject managedObject: ManagedObjectType )
    func cellReuseIdentifierForManagedObject( managedObject: ManagedObjectType ) -> String
}

@objc public protocol CollectionViewSupplementaryViewConfigurator {
    
    func configureView( view: UICollectionReusableView, ofKind: String, atIndexPath: NSIndexPath )
    func reuseIdentifierForSupplementaryViewOfKind( kind: String, atIndexPath: NSIndexPath ) -> String
}
```

The cell configurator is just like the table view cell configurator.  The `cellReuseIdentifierForManagedObject` method can return a hardcoded identifier or different values if the collection has multiple prototype cells.  The `configureCell` method gives you the opportunity to set properties on the cell for its object.

The supplementary view configurator also works the same way, `configureView` is provided a dequeued view based on the reuse identifier returned by `reuseIdentifierForSupplementaryViewOfKind`.

`CollectionCellConfigurator` is generic over the model object, just as `TableCellConfigurator` was.  In your implementation substitute in the view's model object type as the `ManagedObjectType` type. 

### Update Cell

Both `TableCellConfigurator` and `CollectionCellConfigurator` provide an default implementation of a `makeUpdateVisibleCell` method.  This method has a return type of `(NSIndexPath, ManagedObjectType) -> Void`.  Passing the result of that method into the `updateCell` parameter of the `FetchedResultsCoordinator` will give the coordinator a function to call to reconfigure a cell rather than calling the table/collection view reload methods which animate in an undesirable way.  

```swift
    let updateCell = makeUpdateVisibleCell(tableView)
    frcCoordinator = FetchedResultsCoordinator<Animal>( coordinatee: tableView, fetchedResultsController: fetchedResultsController, updateCell: updateCell )
```

## Objective-C usage

There are versions of `FetchedResultsCoordinator`, `FetchedTableDataSource` and `SimpleCollectionDataSource` which have been specialized to model objects of type `NSManagedObject` and cells of type `UITableViewCell`/`UICollectionViewCell`. The specialized versions are exposed to Objective-C using those same names, so all three classes can be used in Objective-C code, just without the advantage of knowing the model object subclass and the cell view subclass in method arguments.

## Author

Mark Carter, mark@deeperdigital.co.uk

## License

FetchedResultsCoordinator is available under the MIT license. See the LICENSE file for more info.
