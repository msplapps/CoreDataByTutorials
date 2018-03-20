//
//  ViewController.swift
//  HitList
//
//  Created by Reddy on 19/03/18.
//  Copyright © 2018 CleanHarbors. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
  //  var names:[String] = []
    var people:[NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "The list"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
         
        guard let appdelegate = UIApplication.shared.delegate as? AppDelegate else {return}
        
        let managedContext = appdelegate.persistentContainer.viewContext
        
        let featchRequest = NSFetchRequest<NSManagedObject>(entityName: "Person")

        do{
            people = try managedContext.fetch(featchRequest)
        } catch let error as NSError {
            print("Unable to read:\(error), \(error.localizedDescription)")
            
        }
        
        
    }

    @IBAction func addName(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Add Name", message: "enter name", preferredStyle: .alert)
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned self](action) in
        
            guard let textField = alert.textFields?.first, let nameToSave = textField.text else {
                return
            }
           
           // self.names.append(name!)
            self.save(name: nameToSave)
            self.tableView.reloadData()
            
        }
        
        let cancelAction = UIAlertAction(title: "cancel", style: .cancel, handler: nil)
        
        alert.addTextField( )
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    func save(name:String){
        
        guard  let appdelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appdelegate.persistentContainer.viewContext
        
        let entity = NSEntityDescription.entity(forEntityName: "Person", in: managedContext)
        let person = NSManagedObject(entity: entity!, insertInto: managedContext)
        
        person.setValue(name, forKey: "name")
        do{
            try managedContext.save()
            people.append(person)
        } catch let error as NSError{
            print("Cound not save \(error): \(error.localizedDescription)")
        }
        
        
    }
    


}


// MARK:- TableView Data source

extension ViewController:UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return people.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
      //  let name = names[indexPath.row]
        let perosn = people[indexPath.row]
        
        let name = perosn.value(forKey: "name")
        cell.textLabel?.text = name as? String
        return cell
    }
    
    
}
