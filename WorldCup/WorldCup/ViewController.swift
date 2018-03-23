//
//  ViewController.swift
//  WorldCup
//
//  Created by Reddy on 22/03/18.
//  Copyright © 2018 CleanHarbors. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    
    // MARK: - Properties
    fileprivate let teamCellIdentifier = "teamCellReuseIdentifier"
    var coreDataStack: CoreDataStack!
    var fetchedResultsController: NSFetchedResultsController<Team>!
    
    // MARK: - IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
          addButton.isEnabled = false
  
        let fetchRequest: NSFetchRequest<Team> = Team.fetchRequest()
     //   let sort = NSSortDescriptor(key: #keyPath(Team.teamName),ascending: true)
        let zoneSort = NSSortDescriptor(
            key: #keyPath(Team.qualifyingZone), ascending: true)
        let scoreSort = NSSortDescriptor(
            key: #keyPath(Team.wins), ascending: false)
        let nameSort = NSSortDescriptor(
            key: #keyPath(Team.teamName), ascending: true)
        
        fetchRequest.sortDescriptors = [zoneSort,scoreSort,nameSort]
        
        fetchedResultsController = NSFetchedResultsController(
            fetchRequest: fetchRequest,
            managedObjectContext: coreDataStack.managedContext,
            sectionNameKeyPath: #keyPath(Team.qualifyingZone),
            cacheName: "worldCup")
        
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Fetching error: \(error), \(error.userInfo)")
        }
        
         fetchedResultsController.delegate = self
        
    }
    
    override func motionEnded(_ motion: UIEventSubtype,with event: UIEvent?) {
        if motion == .motionShake {
            addButton.isEnabled = true
        }
    }


}

extension ViewController {
    @IBAction func addTeam(_ sender: AnyObject) {
        let alert = UIAlertController(title: "Secret Team",
                                      message: "Add a new team",
                                      preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Team Name"
        }
        alert.addTextField { textField in
            textField.placeholder = "Qualifying Zone"
        }
        let saveAction = UIAlertAction(title: "Save",style: .default) {[unowned self] action in
            guard let nameTextField = alert.textFields?.first,
                let zoneTextField = alert.textFields?.last else {
                return
            }
    let team = Team(context: self.coreDataStack.managedContext)
        team.teamName = nameTextField.text
        team.qualifyingZone = zoneTextField.text
        team.imageName = "wenderland-flag"
        self.coreDataStack.saveContext()
        }
        alert.addAction(saveAction)
        alert.addAction(UIAlertAction(title: "Cancel",style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
    
        guard let sections = fetchedResultsController.sections else {
            return 0
        }

        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
        guard let sectionInfo = fetchedResultsController.sections?[section] else {
            return 0
        }
        
        return sectionInfo.numberOfObjects
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
   
        let sectionInfo = fetchedResultsController.sections?[section]
        return sectionInfo?.name
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: teamCellIdentifier, for: indexPath) as! TeamCell
        
        configure(cell: cell, for: indexPath)
     
        
        return cell
    }
    
    func configure(cell: UITableViewCell,for indexPath: IndexPath) {
        guard let cell = cell as? TeamCell else {
            return
        }
        let team = fetchedResultsController.object(at: indexPath)
        cell.flagImageView.image = UIImage(named: team.imageName!)
        cell.teamLabel.text = team.teamName
        cell.scoreLabel.text = "Wins: \(team.wins)"
    }
}

extension ViewController:UITableViewDelegate {
    
    func tableView(_ tableView: UITableView,didSelectRowAt indexPath: IndexPath) {
        let team = fetchedResultsController.object(at: indexPath)
        team.wins = team.wins + 1
        coreDataStack.saveContext()
    //    tableView.reloadData()
    }
        
}

// MARK: - NSFetchedResultsControllerDelegate
extension ViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func controller(_ controller:
        NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            let cell = tableView.cellForRow(at: indexPath!) as! TeamCell
            configure(cell: cell, for: indexPath!)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .automatic)
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
         tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    atSectionIndex sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        let indexSet = IndexSet(integer: sectionIndex)
        switch type {
        case .insert:
            tableView.insertSections(indexSet, with: .automatic)
        case .delete:
            tableView.deleteSections(indexSet, with: .automatic)
        default: break
        }
    }

}
