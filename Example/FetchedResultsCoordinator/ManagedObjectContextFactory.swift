//  Copyright © 2015 Mark Carter. All rights reserved.

import Foundation
import CoreData

public enum StoreType {
    case SQLite
    case Binary
    case InMemory
    
    private func string() -> String {
        switch self {
        case .SQLite: return NSSQLiteStoreType
        case .Binary: return NSBinaryStoreType
        case .InMemory: return NSInMemoryStoreType
        }
    }
}

public class ManagedObjectContextFactory {
    
    public static func managedObjectContextOfInMemoryStoreTypeWithModel( name: String ) -> NSManagedObjectContext {
        
        return managedObjectContextOfStoreType(.InMemory, withModel: name, storeURL: nil, concurrencyType: .MainQueueConcurrencyType )
    }
    
    public static func managedObjectContextOfStoreType( storeType:StoreType, withModel name:String, storeURL:NSURL?, concurrencyType: NSManagedObjectContextConcurrencyType ) -> NSManagedObjectContext {
       	
        let model = managedObjectModelWithModelName( name )
        let coordinator = persistentStoreCoordinatorWithModel(model, type: storeType, storeURL: storeURL, options: nil)
        return managedObjectContextWithCoordinator(coordinator, concurrencyType: concurrencyType)

    }

    static func managedObjectModelWithModelName( name: String ) -> NSManagedObjectModel {
        
        if let modelURL = modelURLWithModelName(name),
           let model = NSManagedObjectModel(contentsOfURL: modelURL) {
                return model
        }
        
        fatalError( "Unable to find Core Data Model" )
    }

    static func persistentStoreCoordinatorWithModel( model: NSManagedObjectModel, type:StoreType, storeURL: NSURL?, options: [NSObject:AnyObject]? ) -> NSPersistentStoreCoordinator {

        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model )
        
        do {
            try coordinator.addPersistentStoreWithType(type.string(), configuration: nil, URL: storeURL, options: options)
        } catch {
            
            fatalError( "Unresolved error \(error)" )
            
            /* From Apple's CoreDataBooks example source:
            
            Replace this implementation with code to handle the error appropriately.
            
            abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            
            Typical reasons for an error here include:
            * The persistent store is not accessible;
            * The schema for the persistent store is incompatible with current managed object model.
            Check the error message to determine what the actual problem was.
            
            
            If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
            
            If you encounter schema incompatibility errors during development, you can reduce their frequency by:
            * Simply deleting the existing store:
            [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
            
            * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
            [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption, [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];
            
            Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
            
            */

        }
        
        
        return coordinator
    }
    
    static func modelURLWithModelName( name: String ) -> NSURL? {
        let bundle = NSBundle(forClass: self)
        return bundle.URLForResource(name, withExtension: "momd") ?? bundle.URLForResource(name, withExtension: "mom")
    }
    
    static func managedObjectContextWithCoordinator( coordinator: NSPersistentStoreCoordinator, concurrencyType: NSManagedObjectContextConcurrencyType ) -> NSManagedObjectContext {
    
        let managedObjectContext = NSManagedObjectContext(concurrencyType: concurrencyType )
        managedObjectContext.persistentStoreCoordinator = coordinator
        
        return managedObjectContext
    }
    
}
