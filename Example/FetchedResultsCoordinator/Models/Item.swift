import Foundation
import CoreData


class Item: NSManagedObject {

    static var entityName: String { return "Item" }
    
    @NSManaged var hidden: NSNumber?
    @NSManaged var section: String?
    @NSManaged var name: String?
    @NSManaged var ordinal: NSNumber?
}
