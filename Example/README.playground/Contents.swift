/*:
 # Tube Arrivals at Kings Cross station
 
 This playground uses a `FetchedResultsCoordinator` to update a table view based on changing arrival times of London Underground trains to Kings Cross station.  
 
 The data is represented by a Arrival model object:
 
        +-----------------+
        | Arrival         |
        |-----------------|
        | id              |
        | expectedArrival |
        | lineName        |
        | platformName    |
        +-----------------+
 
 The data is fetched from the TFL apis, though in this playground the network code is simulated, playing back previously fetched data stored in a file ( because the API requires a key ).
 
 The `PlaygroundViewController`
 */

import XCPlayground
import UIKit
import CoreData
import FetchedResultsCoordinator


//: Create the Core Data stack.  Generally the model for the context will be created in the Core Data model editor.  In this playground it is created programatically in the playground support files, as currently playgrounds do not support .xcdatamodel files.

let managedObjectContext = makeMainContext()


//: Create a Fetched Results controller that will be injected into our example view controller
let fetchRequest = NSFetchRequest(entityName: Arrival.entityName)
fetchRequest.sortDescriptors = [NSSortDescriptor( key:"expectedArrival", ascending: true)]

let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)


//: Configure some global colours for the tube lines
let colours = [ "Circle" : [#Color(colorLiteralRed: 0.9960784314, green: 0.7725490196, blue: 0.03529411765, alpha: 1)#], "Hammersmith & City" : [#Color(colorLiteralRed: 0.8039215686, green: 0.5176470587999999, blue: 0.6235294118, alpha: 1)#], "Northern" : [#Color(colorLiteralRed: 0, green: 0, blue: 0, alpha: 1)#], "Victoria" : [#Color(colorLiteralRed: 0.06666666667, green: 0.5568627451, blue: 0.8549019608, alpha: 1)#],  "Piccadilly" : [#Color(colorLiteralRed: 0.02745098039, green: 0, blue: 0.5921568627, alpha: 1)#], "Metropolitan" : [#Color(colorLiteralRed: 0.3764705882, green: 0, blue: 0.2666666667, alpha: 1)#]]

private func colourForLine( name: String? ) -> UIColor {
    return name.flatMap{colours[$0]} ?? [#Color(colorLiteralRed: 0.6000000237999999, green: 0.6000000237999999, blue: 0.6000000237999999, alpha: 1)#]
}

//: ## `PlaygroundViewController`

class PlaygroundViewController: UITableViewController {
    
    var fetchedResultsController: NSFetchedResultsController!
    
    lazy var coodinator: FetchedResultsCoordinator<Arrival> = FetchedResultsCoordinator(coordinatee: self.tableView, fetchedResultsController: self.fetchedResultsController)
    
    lazy var dataSource:SimpleTableDataSource<Arrival,UITableViewCell> = SimpleTableDataSource(cellConfigurator: self, fetchedResultsController: self.fetchedResultsController)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(SubtitleCell.self, forCellReuseIdentifier: "CellReuseIdentifier")
        tableView.separatorStyle = .None

        tableView.dataSource = dataSource
        coodinator.loadData()
    }
    
}

//: The `TableCellConfigurator` implementation.  In our example we only have one kind of cell, so the `cellReuseIdentifierForManagedObject` method can just return a constant identifier.

extension PlaygroundViewController: TableCellConfigurator {
    
    enum Constants {
        static let CellIdentifier = "CellReuseIdentifier"
    }
    
    func cellReuseIdentifierForManagedObject(managedObject: Arrival) -> String {
        return Constants.CellIdentifier
    }
    
    func configureCell(cell: UITableViewCell, withManagedObject managedObject: Arrival) {
        
        if let secondsToArrival = managedObject.expectedArrival?.timeIntervalSinceNow {
            let minutes = Int(Double.abs( secondsToArrival ) / 60.0)
            let seconds = Int(Double.abs( secondsToArrival ) % 60.0)
            cell.textLabel?.text = String(format: "Arriving in %02d:%02d", minutes, seconds )
        }
        
        cell.detailTextLabel?.text = managedObject.platformName ?? "Unknown Platform"
        
        cell.backgroundColor = colourForLine( managedObject.lineName )
    }
    
}

let viewController = PlaygroundViewController()
viewController.fetchedResultsController = frc

viewController.view.frame = CGRectMake(0, 0, 320, 480)
XCPlaygroundPage.currentPage.liveView = viewController.tableView

fetchData( managedObjectContext: managedObjectContext )

print( "Open the Timeline view in the Assistant Editor to see the live table view" )
