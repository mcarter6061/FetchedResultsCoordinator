import Foundation
import CoreData


// Model object
public class Arrival: NSManagedObject {
    public static let entityName = "Arrival"
    @NSManaged public var id: String?
    @NSManaged public var lineName: String?
    @NSManaged public var platformName: String?
    @NSManaged public var timeToStation: NSNumber?
}


public func makeMainContext() -> NSManagedObjectContext {
    
    let model = makeModel()
    
    let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel:model)
    
    do {
        try persistentStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
    }
    catch {
        fatalError("error creating psc: \(error)")
    }
    
    let managedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.MainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
    
    return managedObjectContext
}


// This would normally be done through the Core Data Model Editor, but in a playground it was easiest to create the model programmatically

func makeModel() -> NSManagedObjectModel {
    let model = NSManagedObjectModel()
    
    let arrivalEntity = NSEntityDescription()
    arrivalEntity.name = "Arrival"
    arrivalEntity.managedObjectClassName = "README_Sources.Arrival"  // Note: prefixed with Playground Sources module
    
    let idNameAttribute = NSAttributeDescription()
    idNameAttribute.name = "id"
    idNameAttribute.attributeType = NSAttributeType.StringAttributeType
    idNameAttribute.optional = false
    idNameAttribute.indexed = false
    
    let lineNameAttribute = NSAttributeDescription()
    lineNameAttribute.name = "lineName"
    lineNameAttribute.attributeType = NSAttributeType.StringAttributeType
    lineNameAttribute.optional = false
    lineNameAttribute.indexed = false
    
    let platformNameAttribute = NSAttributeDescription()
    platformNameAttribute.name = "platformName"
    platformNameAttribute.attributeType = NSAttributeType.StringAttributeType
    platformNameAttribute.optional = false
    platformNameAttribute.indexed = false
    
    let timeToStationAttribute = NSAttributeDescription()
    timeToStationAttribute.name = "timeToStation"
    timeToStationAttribute.attributeType = NSAttributeType.Integer64AttributeType
    timeToStationAttribute.optional = false
    timeToStationAttribute.indexed = false
    
    
    arrivalEntity.properties = [idNameAttribute,lineNameAttribute,platformNameAttribute,timeToStationAttribute]
    
    model.entities = [arrivalEntity]
    
    return model
}
