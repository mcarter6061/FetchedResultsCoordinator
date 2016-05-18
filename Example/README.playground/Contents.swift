/*:
 # Tube Arrivals at Kings Cross station
 
 This playground uses a `FetchedResultsCoordinator` to update a table view based on changing arrival times of London Underground trains to Kings Cross station.  
 
 The data is represented by a Arrival model object:
 
        +-----------------+
        | Arrival         |
        |-----------------|
        | id              |
        | timeToStation   |
        | lineName        |
        | platformName    |
        +-----------------+
 
 The data is fetched from the TFL APIs, though in this playground the network code is simulated, replaying previously fetched data stored in a file.
 
 The `PlaygroundViewController` is our demo `UITableViewController` backed by a `NSFetchedResultsController` (FRC) we will instantiate.  The `FetchedResultsCoordinator` will monitor the FRC for data changes and coordinate them with the table view.
 
 The table view's `dataSource` will be a `SimpleTableDataSource` instance, instantiated with the same FRC.  It will respond to the `UITableViewDataSource` protocol methods, which is mostly boilerplate code accessing the FRC. To configure the cells the data source returns our `PlaygroundViewController` will conform to the `TableCellConfigurator` protocol and implement the cell configuration methods.
 
 The fetch request for the FRC will query all Arrivals, sorted by arrival time.  As simulated API responses complete core data will be updated.  Our `FetchedResultsCoordinator` will be notified of the model changes and coordinate the table view to update with the new data.
 */

import XCPlayground
import UIKit
import CoreData
import FetchedResultsCoordinator


//: First we create the Core Data stack.  Generally the model for the context will be created in the Core Data model editor.  In this playground it is created programatically in the playground support files, as currently playgrounds do not support .xcdatamodel files.

let managedObjectContext = makeMainContext()


//: Next we will build a `NSFetchedResultsController` that will be injected into our `PlaygroundViewController` as well as the coordinator and data source instances.  Generally this would be injected by the source view controller's `prepareForSegue` method.  In this demo we will just define a global FRC instance and set it on a property in the `PlaygroundViewController` instance after it is instantiated.

let fetchRequest = NSFetchRequest(entityName: Arrival.entityName)
fetchRequest.sortDescriptors = [NSSortDescriptor( key:"timeToStation", ascending: true), NSSortDescriptor( key:"platformName", ascending: true)]

let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)


//: We will colour the table cells backgrounds with the tube line colours; here are a couple helpers to facilitate that.
let colours = [ "Circle" : [#Color(colorLiteralRed: 0.9960784314, green: 0.7725490196, blue: 0.03529411765, alpha: 1)#], "Hammersmith & City" : [#Color(colorLiteralRed: 0.8039215686, green: 0.5176470587999999, blue: 0.6235294118, alpha: 1)#], "Northern" : [#Color(colorLiteralRed: 0, green: 0, blue: 0, alpha: 1)#], "Victoria" : [#Color(colorLiteralRed: 0.06666666667, green: 0.5568627451, blue: 0.8549019608, alpha: 1)#],  "Piccadilly" : [#Color(colorLiteralRed: 0.02745098039, green: 0, blue: 0.5921568627, alpha: 1)#], "Metropolitan" : [#Color(colorLiteralRed: 0.3764705882, green: 0, blue: 0.2666666667, alpha: 1)#]]

private func colourForLine( name: String? ) -> UIColor {
    return name.flatMap{colours[$0]} ?? [#Color(colorLiteralRed: 0.6000000237999999, green: 0.6000000237999999, blue: 0.6000000237999999, alpha: 1)#]
}

/*:
 ### An Example View Controller

 The `PlaygroundViewController` will be our view controller and own the `FetchedResultsCoordinator` and `SimpleTableDataSource`.  I have chosen to use lazy properties for them, but we could just as easily define a couple optional properties on the view controller and then setup them up in `viewDidLoad`.
 
  * `SimpleTableDataSource` is generic over our `Arrival` model object and `SubtitleCell` our `UITableViewCell` subclass.  We set the cellConfigurator to be `self` as we will conform to the `TableCellConfigurator` protocol in the extension below.
 
  * `FetchedResultsCoordinator` is also generic over `Arrival`.  We pass in the FRC and set our table view as the object to coordinate data changes with.
 
 In `viewDidLoad` we set the table view's `dataSource` to be our `SimpleTableDataSource` instance and load the data for the table by calling `coordinator.loadData()`.  This will call `performFetch` on the FRC and populate and call `reloadData` on the table view once the FRC returns fetched objects.
 */
class PlaygroundViewController: UITableViewController {
    
    var fetchedResultsController: NSFetchedResultsController!
    
    lazy var coodinator: FetchedResultsCoordinator<Arrival> = FetchedResultsCoordinator(coordinatee: self.tableView, fetchedResultsController: self.fetchedResultsController)
    
    lazy var dataSource:FetchedTableDataSource<Arrival,SubtitleCell> = FetchedTableDataSource(cellConfigurator: self, fetchedResultsController: self.fetchedResultsController)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(SubtitleCell.self, forCellReuseIdentifier: "CellReuseIdentifier")
        tableView.separatorStyle = .None

        tableView.dataSource = dataSource
        coodinator.loadData()
    }
    
}

/*:
 ### The `TableCellConfigurator` implementation  
 
In our example we only have one kind of cell, so the `cellReuseIdentifierForManagedObject` method can just return a constant identifier.
 
In `configureCell` we configure the cell with the arrival time, platform names, and tube line colour.
 */

extension PlaygroundViewController: TableCellConfigurator {
    
    enum Constants {
        static let CellIdentifier = "CellReuseIdentifier"
    }
    func cellReuseIdentifierForObject( object: Arrival, atIndexPath indexPath: NSIndexPath ) -> String {
        return Constants.CellIdentifier
    }
    
    func configureCell( cell: SubtitleCell, withObject object: Arrival, atIndexPath indexPath: NSIndexPath ) {
    
        switch object.timeToStation as? Int {
        case nil:
            cell.textLabel?.text = "Missing Data"
        case let secondsToArrival? where secondsToArrival == 0:
            cell.textLabel?.text = "At Platform"
        case let secondsToArrival?:
            let minutes = secondsToArrival / 60
            let seconds = secondsToArrival % 60
            cell.textLabel?.text = String(format: "Arriving in %02d:%02d", minutes, seconds )
        }
        
        if let secondsToArrival = object.timeToStation as? Int {
            if secondsToArrival == 0 {
                
            }
        }
        
        cell.detailTextLabel?.text = object.platformName ?? "Unknown Platform"
        
        cell.backgroundColor = colourForLine( object.lineName )
    }
    
}

/*:
 ### Launch
 
 Finally, we will instantiate the `PlaygroundViewController` and set our FRC on it.  Afer that it just a matter of starting the simulated network requests so the data updates and putting the table view on the screen.  By using the coordinator and data source classes in this component there is very little boilerplate code to get up and running with a table view that can respond to data changes.  See the Example project for more comprehensive example of how to setup tables or collections with a coordinator and data source.
 */
let viewController = PlaygroundViewController()
viewController.fetchedResultsController = frc

fetchArrivals( managedObjectContext: managedObjectContext, demoDataURL: [#FileReference(fileReferenceLiteral: "DemoData.JSON")#] )

//: The table view is displayed in the playground's timeline, open the **Xcode Assistant Editor** to see and interact with the live demo.
viewController.view.frame = CGRectMake(0, 0, 320, 480)
XCPlaygroundPage.currentPage.liveView = viewController.tableView
print( "Open the Timeline view in the Assistant Editor to see the live table view" )
