import Foundation
import CoreData
import XCPlayground

var managedObjectContext: NSManagedObjectContext!

// Going to fetch data from disk rather than real API calls
public func fetchArrivals(managedObjectContext context: NSManagedObjectContext, demoDataURL: NSURL ) {
    
    managedObjectContext = context
    
    guard let data = NSData(contentsOfURL: demoDataURL),
        let jsonResponses = (try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)) as? NSArray
        else { fatalError("Failed to load demo data") }

    // Start replay, will simulate fetch every 5 seconds until data is exhausted
    replayResponse(0,responses: jsonResponses)
}

func replayResponse( index: Int, responses: NSArray ) {

    guard let nextArrivals = responses[index] as? NSArray else { fatalError("Replay of response failed") }
    
    let podos = parseArrivals( nextArrivals )

    managedObjectContext.performBlock {
        updateContext( podos )
        print( "Managed Object Context inserts \(managedObjectContext.insertedObjects.count) updates \(managedObjectContext.updatedObjects.count) deletes \(managedObjectContext.deletedObjects.count)")
        try! managedObjectContext.save()
    }

    if index + 1 < responses.count {
        let time = dispatch_time(DISPATCH_TIME_NOW, Int64(5 * NSEC_PER_SEC))
        dispatch_after(time, dispatch_get_main_queue()) {
            replayResponse( index + 1, responses: responses)
        }
    } else {
        print("Demo Finished, execute playground again to replay the 'live' data")
        XCPlaygroundPage.currentPage.finishExecution()
    }
}


struct ArrivalPODO {
    var id: String
    var lineName: String
    var platformName: String
    var timeToStation: Int
}

func parseArrivals( jsonArray: NSArray ) -> [ArrivalPODO] {
    
    var podos: [ArrivalPODO] = []
    
    for arrivalDict in jsonArray {
        guard let id = arrivalDict["id"] as? String,
            let lineName = arrivalDict["lineName"] as? String,
            let platformName = arrivalDict["platformName"] as? String,
            let timeToStation = arrivalDict["timeToStation"] as? Int else { continue }
        
        let podo = ArrivalPODO( id: id, lineName: lineName, platformName: platformName, timeToStation: timeToStation )
        podos.append( podo )
    }
    return podos
}

var existingArrivals:Set<Arrival> = []

func updateContext( podos: [ArrivalPODO] ) {
    
    var updatedArrivals:Set<Arrival> = []
    
    for podo in podos {
        var arrival: Arrival!
        if let existingArrival = existingArrivals.filter({$0.id == podo.id}).first {
            arrival = existingArrival
        } else {
            let entity = NSEntityDescription.entityForName(Arrival.entityName, inManagedObjectContext: managedObjectContext )
            arrival = Arrival(entity: entity!, insertIntoManagedObjectContext: managedObjectContext)
        }
        arrival.id = podo.id
        arrival.lineName = podo.lineName
        arrival.platformName = podo.platformName
        arrival.timeToStation = podo.timeToStation
        updatedArrivals.insert(arrival)
    }
    
    existingArrivals.subtract(updatedArrivals).forEach{
        managedObjectContext.deleteObject($0)
    }
    
    existingArrivals = updatedArrivals
}

