//  Copyright © 2015 Mark Carter. All rights reserved.

import Foundation
import CoreData

class DemoDataManager {
    
    var managedObjectContext: NSManagedObjectContext
    var backgroundContext: NSManagedObjectContext
    var timer: NSTimer?

    init( managedObjectContext: NSManagedObjectContext, numberOfItems: Int, numberOfSections: Int) {
        
        self.managedObjectContext = managedObjectContext

        // There are performance implications to using a child context, for simplicity I used one here but you may
        // want to use a non-child background context on a private queue and merge contexts on save if you are doing
        // batch importing of data etc.
        self.backgroundContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
        self.backgroundContext.parentContext = managedObjectContext
        
        createItems( numberOfItems, numberOfSections: numberOfSections )
        
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: #selector(DemoDataManager.modifyData), userInfo: nil, repeats: true)
    }
    
    func createItems( numberOfItems: Int, numberOfSections: Int ) {
        
        managedObjectContext .performBlock {
            let sections = "ABCDEFGHIJKLMNOPQRSTUVWXYZ".characters.map{"\($0) Section"}.randomItems(numberOfSections)

            for i in (0..<numberOfItems) {
                let item = NSEntityDescription.insertNewObjectForEntityForName("Item", inManagedObjectContext: self.managedObjectContext) as! Item
                item.name = "Item \(i)"
                item.ordinal = i
                item.section = sections.randomItem()
            }
        }
    }
    
    @objc func modifyData() {
        
        backgroundContext.performBlock { () -> Void in
            
            let numberOfChanges = Int(arc4random_uniform(5))

            let fetchRequest = NSFetchRequest(entityName: "Item" )
            
            let objects = try! self.backgroundContext.executeFetchRequest(fetchRequest) as! [Item]
            
            for _ in 0..<numberOfChanges {
                
                if let object = objects.randomItem() {
                    
                    let randomChange = NSFetchedResultsChangeType( rawValue: UInt(arc4random_uniform(4)) + 1 )
                    switch randomChange! {
                    case .Delete:
                        object.hidden = true
                    case .Insert:
                        object.hidden = false
                    case .Update:
                        object.name = object.name.flatMap{ return $0.characters.last == "📝" ? String($0.characters.dropLast()) : $0 + "📝" }
                    case .Move:
                        if let swapPositionWithObject = objects.randomItem() {
                            swap(&object.ordinal, &swapPositionWithObject.ordinal)
                            swap(&object.section, &swapPositionWithObject.section)
                        }
                    }
                }
            }
            
            do {
                try self.backgroundContext.save()
            } catch {
                // Should handle save failures appropriately, for this demo there are no
                // consequences for a save failing, as the FRC will never see this update
                print( "Error saving background context \(error)" )
            }
        }
    }
    
}

extension Array {
    
    func randomItem() -> Element? {
        return isEmpty ? nil : self[Int(arc4random_uniform(UInt32(self.count)))]
    }
    
    func randomItems(numberOfItems: Int) -> [Element] {
        var indexes = [Int](self.indices)
        while indexes.count > numberOfItems {
            let randomIndex = Int(arc4random_uniform(UInt32(indexes.count)))
            indexes.removeAtIndex(randomIndex)
        }
        return indexes.map{ self[$0] }
    }
}