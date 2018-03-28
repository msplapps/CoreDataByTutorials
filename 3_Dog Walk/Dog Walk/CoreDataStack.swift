//
//  CoreDataStack.swift
//  Dog Walk
//
//  Created by Reddy on 21/03/18.
//  Copyright © 2018 CleanHarbors. All rights reserved.
//

import Foundation
import CoreData

class CoreDataStack {
    
   private let modelName:String
    
    init(modelName:String) {
        self.modelName = modelName
    }
    
   private lazy var storeContainer:NSPersistentContainer = {
        let container = NSPersistentContainer(name: self.modelName)
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
        if let error = error as NSError?{
            print("Unresolved error \(error.userInfo)")
        }
    })
    return container
  }()
    
    lazy var managedContext:NSManagedObjectContext = {
        return self.storeContainer.viewContext
    }()
    
    func saveContext() {
        
        guard managedContext.hasChanges else {
            return
        }
        do{
            try managedContext.save()
        }catch let error as NSError {
            print("Unresolved error \(error.userInfo)")
        }
    }
    
}
