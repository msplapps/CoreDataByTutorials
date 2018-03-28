//
//  ViewController.swift
//  Babble Tea Finder
//
//  Created by Reddy on 21/03/18.
//  Copyright © 2018 CleanHarbors. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    // MARK: - Properties
    private let filterViewControllerSegueIdentifier = "toFilterViewController"
    fileprivate let venueCellIdentifier = "VenueCell"
    
    var coreDataStack: CoreDataStack!
    var fetchRequest: NSFetchRequest<Venue>!
    var venues: [Venue] = []
    
    var asyncFetchRequest: NSAsynchronousFetchRequest<Venue>!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        guard let model = coreDataStack.managedContext
//                .persistentStoreCoordinator?.managedObjectModel,
//            var fetchRequest2 = model
//                .fetchRequestTemplate(forName: "FetchVenues")
//                as? NSFetchRequest<Venue> else {
//                    return
//        }
     //  self.fetchRequest = fetchRequest2
      //   fetchRequest = Venue.fetchRequest()
        //     fetchAndReload()
        
        doBatchUpdate()

        fetchRequest = Venue.fetchRequest()
        asyncFetchRequest =
            NSAsynchronousFetchRequest<Venue>(
            fetchRequest: fetchRequest) {
                [unowned self] (result: NSAsynchronousFetchResult) in
                guard let venues = result.finalResult else {
                    return
                }
                self.venues = venues
                self.tableView.reloadData()
        }
       
        do {
            try coreDataStack.managedContext.execute(asyncFetchRequest)
            // Returns immediately, cancel here if you want
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
   
        

    
    }

    @IBAction func unwindToVenueListViewController(_ segue: UIStoryboardSegue) {
    }
    
    func doBatchUpdate(){
        let batchUpdate = NSBatchUpdateRequest(entityName: "Venue")
        batchUpdate.propertiesToUpdate =
            [#keyPath(Venue.favorite) : true]
        batchUpdate.affectedStores =
            coreDataStack.managedContext
                .persistentStoreCoordinator?.persistentStores
        batchUpdate.resultType = .updatedObjectsCountResultType
        do {
            let batchResult =
                try coreDataStack.managedContext.execute(batchUpdate)
                    as! NSBatchUpdateResult
            print("Records updated \(batchResult.result!)")
        } catch let error as NSError {
            print("Could not update \(error), \(error.userInfo)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("prepare for segue")
        guard segue.identifier == filterViewControllerSegueIdentifier,
            let navController = segue.destination as? UINavigationController,
            let filterVC = navController.topViewController
                as? FilterViewController else {
                    return
        }
        filterVC.coreDataStack = coreDataStack
        filterVC.delegate = self
    }


}

extension ViewController:UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venues.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: venueCellIdentifier, for: indexPath)
        
        let venue = venues[indexPath.row]
        
        cell.textLabel?.text = venue.name
        cell.detailTextLabel?.text = venue.priceInfo?.priceCategory
        return cell
    }
    
}

// MARK: - Helper methods
extension ViewController {
    func fetchAndReload() {
        do {
            venues =
                try coreDataStack.managedContext.fetch(fetchRequest)
            tableView.reloadData()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }
    }
}

// MARK: - FilterViewControllerDelegate
extension ViewController: FilterViewControllerDelegate {
    
    func filterViewController(filter: FilterViewController,didSelectPredicate predicate: NSPredicate?,sortDescriptor: NSSortDescriptor?) {
        fetchRequest.predicate = nil
        fetchRequest.sortDescriptors = nil
        fetchRequest.predicate = predicate
        if let sr = sortDescriptor {
            fetchRequest.sortDescriptors = [sr]
        }
        fetchAndReload()
    }
    
}

