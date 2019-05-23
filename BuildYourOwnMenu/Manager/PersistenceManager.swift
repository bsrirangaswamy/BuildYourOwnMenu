//
//  PersistenceManager.swift
//  BuildYourOwnMenu
//
//  Created by Balakumaran Srirangaswamy on 5/22/19.
//  Copyright © 2019 Bala. All rights reserved.
//

import UIKit
import CoreData

class PersistenceManager: NSObject {
    
    static let sharedInstance = PersistenceManager()
    
    var managedContext: NSManagedObjectContext? = nil
    
    lazy var fetchedResultsController: NSFetchedResultsController<MenuGroup> = {
        let fetchRequest: NSFetchRequest<MenuGroup> = MenuGroup.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
        fetchRequest.sortDescriptors = [sortDescriptor]
        let fetchRequestContrller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedContext!, sectionNameKeyPath: nil, cacheName: nil)
        do {
            try fetchRequestContrller.performFetch()
            print("Bala fetch successful")
        } catch let error as NSError {
            print("Fetch failed: error = \(error) and description = \(error.userInfo)")
        }
        return fetchRequestContrller
    }()
    
    // MARK :- Add, Update and Delete functions for Main menu group Items
    
    func addMainMenuData(name: String, imageData: Data?) {
        let menuGroupAdd = MenuGroup(context: managedContext!)
        menuGroupAdd.name = name
        menuGroupAdd.imageData = imageData
        do {
            try managedContext!.save()
            print("Bala save successful")
        } catch let error as NSError {
            print("Save failed: error = \(error) and description = \(error.userInfo)")
        }
    }
    
    func updateMainMenuData(indexPath: IndexPath, name: String, imageData: Data?) {
        let menuGroupUpdate = self.fetchedResultsController.object(at: indexPath)
        menuGroupUpdate.name = name
        menuGroupUpdate.imageData = imageData
        do {
            try managedContext?.save()
            print("Bala update saved successful")
        } catch let error as NSError {
            print("Update Save failed: error = \(error) and description = \(error.userInfo)")
        }
    }
    
    func deleteMainMenuData(indexPath: IndexPath) {
        let menuGroupDelete = self.fetchedResultsController.object(at: indexPath)
        self.managedContext?.delete(menuGroupDelete)
        do {
            try managedContext?.save()
            print("Bala update saved successful")
        } catch let error as NSError {
            print("Update Save failed: error = \(error) and description = \(error.userInfo)")
        }
    }

}
