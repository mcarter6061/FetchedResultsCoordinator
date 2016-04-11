import Foundation
import CoreData


public func fetchData( managedObjectContext context: NSManagedObjectContext ) {
    
    managedObjectContext = context
//    let url = NSBundle.mainBundle().URLForResource("sampleData", withExtension: "json")
    let url = NSURL( string:"https://api.tfl.gov.uk/StopPoint/940GZZLUKSX/Arrivals?app_id=&app_key=" )

    let sessionTask = NSURLSession.sharedSession().dataTaskWithURL(url!, completionHandler: responseHandler)
    sessionTask.resume()
    
    let time = dispatch_time(DISPATCH_TIME_NOW, Int64(10 * NSEC_PER_SEC))
    dispatch_after(time, dispatch_get_main_queue()) {
        fetchData(managedObjectContext: managedObjectContext)
    }
}

var managedObjectContext: NSManagedObjectContext!

func responseHandler(data:NSData?, response:NSURLResponse?,error:NSError?) {

    guard error == nil,
        let data = data  else {
            print("Failed to fetch data")
            return
    }
    
    do {
        let podos = try parseData( data )
        
        managedObjectContext.performBlock {
            updateContext( podos )
            print( "Managed Object Context inserts \(managedObjectContext.insertedObjects.count) updates \(managedObjectContext.updatedObjects.count) deletes \(managedObjectContext.deletedObjects.count)")
            try! managedObjectContext.save()
        }

    } catch {
        print( "Error fetching data \(error)" )
    }
    
}


struct ArrivalPODO {
    var id: String
    var lineName: String
    var platformName: String
    var expectedArrival: NSDate
}

var dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    return formatter
}()

func parseData( data: NSData ) throws -> [ArrivalPODO] {
    
    var jsonArray: NSArray?
    
    jsonArray = (try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)) as? NSArray

    guard let jsonArrayValue = jsonArray else { return[] }
    
    var podos: [ArrivalPODO] = []
    
    for arrivalDict in jsonArrayValue {
        guard let id = arrivalDict["id"] as? String,
            let lineName = arrivalDict["lineName"] as? String,
            let platformName = arrivalDict["platformName"] as? String,
            let dateString = arrivalDict["expectedArrival"] as? String,
            let expectedArrival = dateFormatter.dateFromString( dateString ) else { continue }
        
        let podo = ArrivalPODO( id: id, lineName: lineName, platformName: platformName, expectedArrival: expectedArrival )
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
        arrival.expectedArrival = podo.expectedArrival
        updatedArrivals.insert(arrival)
    }
    
    existingArrivals.subtract(updatedArrivals).forEach{
        managedObjectContext.deleteObject($0)
    }
    
    existingArrivals = updatedArrivals
}

