//  Copyright © 2015 Mark Carter. All rights reserved.

import Foundation
import UIKit
import CoreData
import FetchedResultsCoordinator


class ExampleCollectionViewSubviewController: UIViewController, ExampleViewControllersWithFetchedResultController {
    
    @IBOutlet weak var collectionView: UICollectionView!

    var fetchedResultsController: NSFetchedResultsController!
    var frcCoordinator: FetchedResultsCoordinator<Item>?
    var dataSource: SimpleCollectionDataSource<Item>?
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if dataSource == nil {
            dataSource = SimpleCollectionDataSource( fetchedResultsController: self.fetchedResultsController, cellConfigurator: self, supplementaryViewConfigurator: self )
            collectionView.dataSource = dataSource
        }
        
        if frcCoordinator == nil {
            frcCoordinator = FetchedResultsCoordinator( coordinatee: self.collectionView!, fetchedResultsController: self.fetchedResultsController, updateCell: makeUpdateVisibleCell(collectionView) )
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

extension ExampleCollectionViewSubviewController: CollectionCellConfigurator {

    func configureCell(cell: UICollectionViewCell, withManagedObject managedObject: Item) {

        guard let cell = cell as? ExampleCollectionViewCell else { return }
        
        cell.textLabel?.text = managedObject.name
    }
    
    func cellReuseIdentifierForManagedObject(managedObject: Item) -> String {
        return "ECVSCCellReuseIdentifier"
    }
    
}


// MARK: - CollectionViewSupplementaryViewConfigurator methods

extension ExampleCollectionViewSubviewController: CollectionViewSupplementaryViewConfigurator {
    
    func configureView( view: UICollectionReusableView, ofKind: String, atIndexPath: NSIndexPath ) {
        
        guard let view = view as? ExampleCollectionViewHeader else { return }
        
        let sectionName = dataSource?.sectionInfoForSection( atIndexPath.section )?.name
        view.textLabel.text = sectionName
    }

    func reuseIdentifierForSupplementaryViewOfKind( kind: String, atIndexPath: NSIndexPath ) -> String {
        return "ECVSCHeaderReuseIdentifier"
    }
    
}