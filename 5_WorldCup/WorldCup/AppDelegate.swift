//
//  AppDelegate.swift
//  WorldCup
//
//  Created by Reddy on 22/03/18.
//  Copyright © 2018 CleanHarbors. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    lazy var  coreDataStack = CoreDataStack(modelName: "WorldCup")

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        importJSONSeedDataIfNeeded()
        
        guard let navController = window?.rootViewController as? UINavigationController,
            let viewController = navController.topViewController as? ViewController else {
                return true
        }
        
        viewController.coreDataStack = coreDataStack
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }



    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        coreDataStack.saveContext()
    }

   

}

// MARK: - Helper methods
extension AppDelegate {
    func importJSONSeedDataIfNeeded() {
        
        let fetchRequest: NSFetchRequest<Team> = Team.fetchRequest()
        let count = try? coreDataStack.managedContext.count(for: fetchRequest)
        
        guard let teamCount = count,
            teamCount == 0 else {
                return
        }
        
        importJSONSeedData()
    }
    
    func importJSONSeedData() {
        
        let jsonURL = Bundle.main.url(forResource: "seed", withExtension: "json")!
        let jsonData = NSData(contentsOf: jsonURL) as! Data
        
        do {
            let jsonArray = try JSONSerialization.jsonObject(with: jsonData, options: [.allowFragments]) as! [AnyObject]
            let entity = NSEntityDescription.entity(forEntityName: "Team", in: coreDataStack.managedContext)!
            
            for jsonDictionary in jsonArray {
                let teamName = jsonDictionary["teamName"] as! String
                let zone = jsonDictionary["qualifyingZone"] as! String
                let imageName = jsonDictionary["imageName"] as! String
                let wins = jsonDictionary["wins"] as! NSNumber
                
                let team = Team(entity: entity, insertInto: coreDataStack.managedContext)
                team.teamName = teamName
                team.imageName = imageName
                team.qualifyingZone = zone
                team.wins = wins.int32Value
            }
            
            coreDataStack.saveContext()
            print("Imported \(jsonArray.count) teams")
            
        } catch let error as NSError {
            print("Error importing teams: \(error)")
        }
    }
}
