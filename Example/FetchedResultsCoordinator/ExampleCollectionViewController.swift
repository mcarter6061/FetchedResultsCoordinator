//  Copyright © 2015 Mark Carter. All rights reserved.

import Foundation
import UIKit
import CoreData
import FetchedResultsCoordinator

class ExampleCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var textLabel: UILabel!
}

class ExampleCollectionViewHeader: UICollectionReusableView {
    @IBOutlet weak var textLabel: UILabel!
}

class ExampleCollectionViewController: UICollectionViewController, ExampleViewControllersWithFetchedResultController {
 
    var fetchedResultsController: NSFetchedResultsController!
    var frcCoordinator: FetchedResultsCoordinator<Item>?
    var dataSource: SimpleCollectionDataSource<Item>?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if dataSource == nil {
            dataSource = SimpleCollectionDataSource( fetchedResultsController: fetchedResultsController, cellConfigurator: self, supplementaryViewConfigurator: self )
            collectionView!.dataSource = dataSource
        }
        
        if frcCoordinator == nil {
            frcCoordinator = FetchedResultsCoordinator( coordinatee: collectionView!, fetchedResultsController: fetchedResultsController, updateCell: makeUpdateVisibleCell(collectionView!) )
            frcCoordinator?.loadData()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tappedPause(sender: UIBarButtonItem) {
        guard let frcCoordinator = frcCoordinator else { return }
        
        frcCoordinator.paused = !frcCoordinator.paused
        sender.title = frcCoordinator.paused ? "Unpause" : "Pause"
    }
}


// MARK: - CollectionCellConfigurator methods

extension ExampleCollectionViewController: CollectionCellConfigurator {
    
    func configureCell(cell: UICollectionViewCell, withManagedObject managedObject: Item) {
        
        guard let cell = cell as? ExampleCollectionViewCell else { return }
        
        cell.textLabel?.text = managedObject.name
    }
    
    func cellReuseIdentifierForManagedObject(managedObject: Item) -> String {
        return "ECVCCellReuseIdentifier"
    }
}


// MARK: - CollectionViewSupplementaryViewConfigurator methods

extension ExampleCollectionViewController: CollectionViewSupplementaryViewConfigurator {
    
    func reuseIdentifierForSupplementaryViewOfKind( kind: String, atIndexPath: NSIndexPath ) -> String {
        return "ECVCHeaderReuseIdentifier"
    }
    
    func configureView( view: UICollectionReusableView, ofKind: String, atIndexPath: NSIndexPath ) {
        
        guard let view = view as? ExampleCollectionViewHeader else { return }

        let sectionName = dataSource?.sectionInfoForSection( atIndexPath.section )?.name
        view.textLabel.text = sectionName
    }

}