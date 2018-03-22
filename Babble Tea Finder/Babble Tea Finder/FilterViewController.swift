//
//  FilterViewController.swift
//  Babble Tea Finder
//
//  Created by Reddy on 21/03/18.
//  Copyright © 2018 CleanHarbors. All rights reserved.
//

import UIKit
import CoreData

protocol FilterViewControllerDelegate: class {
    func filterViewController( filter: FilterViewController,didSelectPredicate predicate: NSPredicate?,sortDescriptor: NSSortDescriptor?)
}

class FilterViewController: UITableViewController {
    
    
    // MARK: - Price section
    @IBOutlet weak var cheapVenueCell: UITableViewCell!
    @IBOutlet weak var moderateVenueCell: UITableViewCell!
    @IBOutlet weak var expensiveVenueCell: UITableViewCell!
    
    // MARK: - Most popular section
    @IBOutlet weak var offeringDealCell: UITableViewCell!
    @IBOutlet weak var walkingDistanceCell: UITableViewCell!
    @IBOutlet weak var userTipsCell: UITableViewCell!
    
    // MARK: - Sort section
    @IBOutlet weak var nameAZSortCell: UITableViewCell!
    @IBOutlet weak var nameZASortCell: UITableViewCell!
    @IBOutlet weak var distanceSortCell: UITableViewCell!
    @IBOutlet weak var priceSortCell: UITableViewCell!
    //MARK:- Lablels
    @IBOutlet weak var firstPriceCategoryLabel: UILabel!
    @IBOutlet weak var secondPriceCategoryLabel: UILabel!
    @IBOutlet weak var thirdPriceCategoryLabel: UILabel!
    @IBOutlet weak var numDealsLabel: UILabel!
    
    
    // MARK: - Properties
    var coreDataStack: CoreDataStack!
    
    weak var delegate: FilterViewControllerDelegate?
    var selectedSortDescriptor: NSSortDescriptor?
    var selectedPredicate: NSPredicate?
    
    lazy var cheapVenuePredicate: NSPredicate = {
        return NSPredicate(format: "%K == %@",
                           #keyPath(Venue.priceInfo.priceCategory), "$")
    }()
    
    lazy var moderateVenuePredicate: NSPredicate = {
        return NSPredicate(format: "%K == %@",
                           #keyPath(Venue.priceInfo.priceCategory), "$$")
    }()
    lazy var expensiveVenuePredicate: NSPredicate = {
        return NSPredicate(format: "%K == %@",
                           #keyPath(Venue.priceInfo.priceCategory), "$$$")
    }()

    lazy var offeringDealPredicate: NSPredicate = {
        return NSPredicate(format: "%K > 0",
                           #keyPath(Venue.specialCount))
    }()
    lazy var walkingDistancePredicate: NSPredicate = {
        return NSPredicate(format: "%K < 500",
                           #keyPath(Venue.location.distance))
    }()
    
    lazy var hasUserTipsPredicate: NSPredicate = {
        return NSPredicate(format: "%K > 0",
                           #keyPath(Venue.stats.tipCount))
    }()
    
    lazy var nameSortDescriptor: NSSortDescriptor = {
        let compareSelector = #selector(NSString.localizedStandardCompare(_:))
        return NSSortDescriptor(key: #keyPath(Venue.name),
                                ascending: true,
                                selector: compareSelector)
    }()
    lazy var distanceSortDescriptor: NSSortDescriptor = {
        return NSSortDescriptor( key: #keyPath(Venue.location.distance),ascending: true)
    }()
    
    lazy var priceSortDescriptor: NSSortDescriptor = {
        return NSSortDescriptor(key: #keyPath(Venue.priceInfo.priceCategory),ascending: true)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        populateCheapVenueCountLabel()
        populateModerateVenueCountLabel()
        populateExpensiveVenueCountLabel()
        populateDealsCountLabel()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func saveButtonTapped(_ sender: Any) {
        delegate?.filterViewController(filter: self, didSelectPredicate: selectedPredicate, sortDescriptor: selectedSortDescriptor)
        dismiss(animated: true)
        
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }
        // Price section
        switch cell {
        case cheapVenueCell:
            selectedPredicate = cheapVenuePredicate
        case moderateVenueCell:
            selectedPredicate = moderateVenuePredicate
        case expensiveVenueCell:
            selectedPredicate = expensiveVenuePredicate
        // Most Popular section
        case offeringDealCell:
            selectedPredicate = offeringDealPredicate
        case walkingDistanceCell:
            selectedPredicate = walkingDistancePredicate
        case userTipsCell:
            selectedPredicate = hasUserTipsPredicate
            
        //Sort By section
        case nameAZSortCell:
            selectedSortDescriptor = nameSortDescriptor
        case nameZASortCell:
            selectedSortDescriptor =
                nameSortDescriptor.reversedSortDescriptor
                as? NSSortDescriptor
        case distanceSortCell:
            selectedSortDescriptor = distanceSortDescriptor
        case priceSortCell:
            selectedSortDescriptor = priceSortDescriptor
            
        default: break
        }
        cell.accessoryType = .checkmark
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}




// MARK: - Helper methods
extension FilterViewController {
    func populateCheapVenueCountLabel() {
        let fetchRequest = NSFetchRequest<NSNumber>(entityName: "Venue")
        fetchRequest.resultType = .countResultType
        fetchRequest.predicate = cheapVenuePredicate
        do {
            let countResult = try coreDataStack.managedContext.fetch(fetchRequest)
            let count = countResult.first!.intValue
            firstPriceCategoryLabel.text =
            "\(count) bubble tea places"
        } catch let error as NSError {
            print("Count not fetch \(error), \(error.userInfo)")
        }
    }
    
    
    func populateModerateVenueCountLabel() {
        let fetchRequest = NSFetchRequest<NSNumber>(entityName: "Venue")
        fetchRequest.resultType = .countResultType
        fetchRequest.predicate = moderateVenuePredicate
        do {
            let countResult =
                try coreDataStack.managedContext.fetch(fetchRequest)
            let count = countResult.first!.intValue
            secondPriceCategoryLabel.text = "\(count) bubble tea places"
        } catch let error as NSError {
            print("Count not fetch \(error), \(error.userInfo)")
        }
    }
    
    func populateExpensiveVenueCountLabel() {
        
        let fetchRequest: NSFetchRequest<Venue> = Venue.fetchRequest()
        fetchRequest.predicate = expensiveVenuePredicate
        do {
            let count =
                try coreDataStack.managedContext.count(for: fetchRequest)
            thirdPriceCategoryLabel.text = "\(count) bubble tea places"
        } catch let error as NSError {
            print("Count not fetch \(error), \(error.userInfo)")
        }
    }
    
    func populateDealsCountLabel() {
      
        let fetchRequest = NSFetchRequest<NSDictionary>(entityName: "Venue")
        fetchRequest.resultType = .dictionaryResultType
    
        let sumExpressionDesc = NSExpressionDescription()
        sumExpressionDesc.name = "sumDeals"
     
        let specialCountExp =
            NSExpression(forKeyPath: #keyPath(Venue.specialCount))
        sumExpressionDesc.expression =
            NSExpression(forFunction: "sum:",
                         arguments: [specialCountExp])
        sumExpressionDesc.expressionResultType =
            .integer32AttributeType
       
        fetchRequest.propertiesToFetch = [sumExpressionDesc]
        
        do {
            let results = try coreDataStack.managedContext.fetch(fetchRequest)
            let resultDict = results.first!
            print(resultDict)
            let numDeals = resultDict["sumDeals"]!
            print(numDeals)
            self.numDealsLabel.text = "\(numDeals) total deals"
        } catch let error as NSError {
            print("Count not fetch \(error), \(error.userInfo)")
        }
    }
    
}
