//
//  ViewController.swift
//  Dog Walk
//
//  Created by Reddy on 21/03/18.
//  Copyright © 2018 CleanHarbors. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    
    
    var managedContext:NSManagedObjectContext!
    
    @IBOutlet weak var tableView: UITableView!
    
    var currentDog:Dog?
    
    lazy var dateFormater:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .medium
        return formatter
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Dog Walk"

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        let dogName = "Fido"
        let dogFetch:NSFetchRequest<Dog> = Dog.fetchRequest()
        dogFetch.predicate = NSPredicate(format: "%K == %@", #keyPath(Dog.name),dogName)
        
        do {
            let results = try managedContext.fetch(dogFetch)
            if results.count > 0 {
                currentDog = results.first
            }else {
                currentDog = Dog(context:managedContext)
                currentDog?.name = dogName
                try managedContext.save()
            }
            
        }catch let error as NSError {
            print("Featch error \(error.userInfo)")
        }
        
        
        
        
    }
    
    @IBAction func addWalk(_ sender: Any) {
    
        let walk = Walk(context: managedContext)
        walk.date = Date()
        
     //   currentDog?.addToWalks(walk)
        
        if let dog = currentDog, let walks = dog.walks?.mutableCopy() as? NSMutableOrderedSet {
            walks.add(walk)
            dog.walks = walks
        }
        do {
            try managedContext.save()
        }catch let error as NSError {
            print("Save error:\(error.userInfo)")
        }
    tableView.reloadData()
    
    }
    

}

extension ViewController:UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let walks = currentDog?.walks else {
            return 1
        }
        return walks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        guard let walk = currentDog?.walks?[indexPath.row] as? Walk, let walkDate = walk.date else {
            return cell
        }
        let date = dateFormater.string(from: walkDate)
        cell.textLabel?.text = date
        cell.detailTextLabel?.text = "Morning"
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "List of Walks"
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let walkToRemove = currentDog?.walks?[indexPath.row] as? Walk, editingStyle == .delete else {
            return
        }
        
        managedContext.delete(walkToRemove)
        
        do {
            try managedContext.save()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }catch let error as NSError {
            print("Saving Error:\(error.userInfo)")
        }
    }
}

