//
//  AppDelegate.swift
//  Babble Tea Finder
//
//  Created by Reddy on 21/03/18.
//  Copyright © 2018 CleanHarbors. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var  coreDataStack = CoreDataStack(modelName: "Bubble_Tea_Finder")


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        guard let navController = window?.rootViewController as? UINavigationController,
            let viewController = navController.topViewController as? ViewController else {
                return true
        }
        
        viewController.coreDataStack = coreDataStack
        importJSONSeedDataIfNeeded()
        return true
    }

    func applicationWillTerminate(_ application: UIApplication) {

      coreDataStack.saveContext()
    }

    func importJSONSeedDataIfNeeded() {
        let fetchRequest = NSFetchRequest<Venue>(entityName: "Venue")
        let count = try! coreDataStack.managedContext.count(for: fetchRequest)
        
        guard count == 0 else { return }
        
        do {
            let results = try coreDataStack.managedContext.fetch(fetchRequest)
            results.forEach({ coreDataStack.managedContext.delete($0) })
            
            coreDataStack.saveContext()
            importJSONSeedData()
        } catch let error as NSError {
            print("Error fetching: \(error), \(error.userInfo)")
        }
    }
    
    func importJSONSeedData() {
        let jsonURL = Bundle.main.url(forResource: "seed", withExtension: "json")!
        let jsonData = NSData(contentsOf: jsonURL)! as Data
        
        let venueEntity = NSEntityDescription.entity(forEntityName: "Venue", in: coreDataStack.managedContext)!
        let locationEntity = NSEntityDescription.entity(forEntityName: "Location", in: coreDataStack.managedContext)!
        let categoryEntity = NSEntityDescription.entity(forEntityName: "Category", in: coreDataStack.managedContext)!
        let priceEntity = NSEntityDescription.entity(forEntityName: "PriceInfo", in: coreDataStack.managedContext)!
        let statsEntity = NSEntityDescription.entity(forEntityName: "Stats", in: coreDataStack.managedContext)!
        
        let jsonDict = try! JSONSerialization.jsonObject(with: jsonData, options: [.allowFragments]) as! [String: AnyObject]
        let responseDict = jsonDict["response"] as! [String: AnyObject]
        let jsonArray = responseDict["venues"] as! [[String: AnyObject]]
        
        for jsonDictionary in jsonArray {
            let venueName = jsonDictionary["name"] as? String
            let contactDict = jsonDictionary["contact"] as! [String: String]
            
            let venuePhone = contactDict["phone"]
            
            let specialsDict = jsonDictionary["specials"] as! [String: AnyObject]
            let specialCount = specialsDict["count"] as? NSNumber
            
            let locationDict = jsonDictionary["location"] as! [String: AnyObject]
            let priceDict = jsonDictionary["price"] as! [String: AnyObject]
            let statsDict =  jsonDictionary["stats"] as! [String: AnyObject]
            
            let location = Location(entity: locationEntity, insertInto: coreDataStack.managedContext)
            location.address = locationDict["address"] as? String
            location.city = locationDict["city"] as? String
            location.state = locationDict["state"] as? String
            location.zipcode = locationDict["postalCode"] as? String
            let distance = locationDict["distance"] as? NSNumber
            location.distance = distance!.floatValue
            
            let category = Category(entity: categoryEntity, insertInto: coreDataStack.managedContext)
            
            let priceInfo = PriceInfo(entity: priceEntity, insertInto: coreDataStack.managedContext)
            priceInfo.priceCategory = priceDict["currency"] as? String
            
            let stats = Stats(entity: statsEntity, insertInto: coreDataStack.managedContext)
            let checkins = statsDict["checkinsCount"] as? NSNumber
            stats.checkinsCount = checkins!.int32Value
            let tipCount = statsDict["tipCount"] as? NSNumber
            stats.tipCount = tipCount!.int32Value
            
            let venue = Venue(entity: venueEntity, insertInto: coreDataStack.managedContext)
            venue.name = venueName
            venue.phone = venuePhone
            venue.specialCount = specialCount!.int32Value
            venue.location = location
            venue.category = category
            venue.priceInfo = priceInfo
            venue.stats = stats
        }
        
        coreDataStack.saveContext()
    }
    

}

