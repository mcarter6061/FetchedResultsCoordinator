//: [Previous](@previous)

import XCPlayground
import UIKit
import CoreData
import FetchedResultsCoordinator

let managedObjectContext = makeMainContext()


//: Create a Fetched Results controller that will be injected into our example view controller
let fetchRequest = NSFetchRequest(entityName: Arrival.entityName)
fetchRequest.sortDescriptors = [NSSortDescriptor( key:"expectedArrival", ascending: true)]

let frc = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)


class PlaygroundViewController: UITableViewController {
    
    var fetchedResultsController: NSFetchedResultsController!
    
    lazy var coodinator: FetchedResultsCoordinator<Arrival> = FetchedResultsCoordinator(coordinatee: self, fetchedResultsController: self.fetchedResultsController, updateCell: self.makeUpdateVisibleCell(self.tableView))
    
    lazy var dataSource:SimpleTableDataSource<Arrival> = SimpleTableDataSource<Arrival>(cellConfigurator: self, fetchedResultsController: self.fetchedResultsController)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(SubtitleCell.self, forCellReuseIdentifier: "CellReuseIdentifier")
        tableView.separatorStyle = .None

        tableView.dataSource = dataSource
        coodinator.loadData()
    }
    
}

let colors = [ "Circle" : [#Color(colorLiteralRed: 0.9960784314, green: 0.7725490196, blue: 0.03529411765, alpha: 1)#], "Hammersmith & City" : [#Color(colorLiteralRed: 0.8039215686, green: 0.5176470587999999, blue: 0.6235294118, alpha: 1)#], "Northern" : [#Color(colorLiteralRed: 0, green: 0, blue: 0, alpha: 1)#], "Victoria" : [#Color(colorLiteralRed: 0.06666666667, green: 0.5568627451, blue: 0.8549019608, alpha: 1)#],  "Piccadilly" : [#Color(colorLiteralRed: 0.02745098039, green: 0, blue: 0.5921568627, alpha: 1)#], "Metropolitan" : [#Color(colorLiteralRed: 0.3764705882, green: 0, blue: 0.2666666667, alpha: 1)#]]

extension PlaygroundViewController: TableCellConfigurator {
    
    func cellReuseIdentifierForManagedObject(managedObject: Arrival) -> String {
        return "CellReuseIdentifier"
    }
    
    func configureCell(cell: UITableViewCell, withManagedObject managedObject: Arrival) {
        
        if let secondsToArrival = managedObject.expectedArrival?.timeIntervalSinceNow {
            let minutes = Int(Double.abs( secondsToArrival ) / 60.0)
            let seconds = Int(Double.abs( secondsToArrival ) % 60.0)
            cell.textLabel?.text = String(format: "Arriving in %02d:%02d", minutes, seconds )
        }
        
        cell.detailTextLabel?.text = managedObject.platformName ?? "Unknown Platform"
        
        let lineColor = managedObject.lineName.flatMap{colors[$0]} ?? [#Color(colorLiteralRed: 0.4588235294, green: 0.2352941176, blue: 0.1098039216, alpha: 1)#]
        cell.backgroundColor = lineColor
    }
}

let viewController = PlaygroundViewController()
viewController.fetchedResultsController = frc

viewController.view.frame = CGRectMake(0, 0, 320, 480)
XCPlaygroundPage.currentPage.liveView = viewController.tableView

fetchData( managedObjectContext: managedObjectContext )
