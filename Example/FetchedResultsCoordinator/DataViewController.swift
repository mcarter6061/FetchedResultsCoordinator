//  Copyright © 2015 Mark Carter. All rights reserved.

import UIKit
import CoreData

@objc protocol ExampleViewControllersWithFetchedResultController {
    var fetchedResultsController: NSFetchedResultsController! {get set}
}


class DataViewController: UIViewController {

    var managedObjectContext: NSManagedObjectContext?
    var dataManager: DemoDataManager?
    var childTabBarController: UITabBarController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBOutlet weak var itemCountSlider: UISlider!
    @IBOutlet weak var itemCountLabel: UILabel!
    @IBOutlet weak var sectionCountSlider: UISlider!
    @IBOutlet weak var sectionCountLabel: UILabel!
    
    var sectionCount:Int { return Int( sectionCountSlider.value ) }
    var itemCount:Int { return Int( itemCountSlider.value ) }
    
    @IBAction func sectionCountSliderChanged(sender: UISlider) {
        sectionCountLabel.text = "across \(sectionCount) section\(sectionCount > 1 ? "s":"")"
    }
    
    @IBAction func itemCountSliderChanged(sender: UISlider) {
        itemCountLabel.text = "\(itemCount) items"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    @IBAction func unwindToDemoViewController(sender: UIStoryboardSegue) {
        childTabBarController = nil
    }

    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        managedObjectContext = ManagedObjectContextFactory.managedObjectContextOfInMemoryStoreTypeWithModel("Example")

        guard let managedObjectContext = managedObjectContext else {
            fatalError("Core Data stack not setup")
        }

        // Creates the data and then modifies it
        dataManager = DemoDataManager( managedObjectContext: managedObjectContext, numberOfItems: itemCount, numberOfSections: sectionCount )

        // Set fetch results controller on all the ExampleViewControllersWithFetchedResultController ( search vc heirarchy )
        setupChildControllers(segue.destinationViewController, managedObjectContext: managedObjectContext)
        childTabBarController = segue.destinationViewController as? UITabBarController
    }
        
    func fetchedResultsController( managedObjectContext: NSManagedObjectContext ) -> NSFetchedResultsController {
        
        let sectionKeyPath:String? = (sectionCountSlider.value > 1) ? "section" : nil
        
        return NSFetchedResultsController(fetchRequest: fetchRequest(managedObjectContext), managedObjectContext: managedObjectContext, sectionNameKeyPath: sectionKeyPath, cacheName: nil)
    }
    
    
    func fetchRequest( managedObjectContext: NSManagedObjectContext ) -> NSFetchRequest {
        
        guard let fetchRequest = managedObjectContext.persistentStoreCoordinator?.managedObjectModel.fetchRequestFromTemplateWithName( "VisibleItems", substitutionVariables: [:]) else {
            fatalError()
        }
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "section", ascending: true),NSSortDescriptor(key: "ordinal", ascending: true)]
        
        return fetchRequest
    }
    
    func setupChildControllers( viewController: UIViewController, managedObjectContext: NSManagedObjectContext) {
        
        if let viewController = viewController as? ExampleViewControllersWithFetchedResultController {
            viewController.fetchedResultsController = fetchedResultsController( managedObjectContext )
        } else {
            viewController.childViewControllers.forEach{setupChildControllers($0, managedObjectContext: managedObjectContext)}
        }
    }
}


// Keyboard shortcuts for switching between tabs

extension DataViewController {
    
    override var keyCommands: [UIKeyCommand] {
        if #available(iOS 9.0, *) {
            return [UIKeyCommand(input: "1", modifierFlags: UIKeyModifierFlags(), action: #selector(DataViewController.switchTab1), discoverabilityTitle: "Table VC"),
                UIKeyCommand(input: "2", modifierFlags: UIKeyModifierFlags(), action: #selector(DataViewController.switchTab2), discoverabilityTitle: "Table View"),
                UIKeyCommand(input: "3", modifierFlags: UIKeyModifierFlags(), action: #selector(DataViewController.switchTab3), discoverabilityTitle: "Collection VC"),
                UIKeyCommand(input: "4", modifierFlags: UIKeyModifierFlags(), action: #selector(DataViewController.switchTab4), discoverabilityTitle: "Collection View")]
        } else {
            return []
        }
    }
    
    func switchTab1() {
        childTabBarController?.selectedIndex = 0
    }
    
    func switchTab2() {
        childTabBarController?.selectedIndex = 1
    }
    
    func switchTab3() {
        childTabBarController?.selectedIndex = 2
    }
    
    func switchTab4() {
        childTabBarController?.selectedIndex = 3
    }
}