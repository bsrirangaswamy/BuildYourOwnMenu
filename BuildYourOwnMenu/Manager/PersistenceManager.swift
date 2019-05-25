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
        menuGroupAdd.lastUpdated = Date()
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
        menuGroupUpdate.lastUpdated = Date()
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
    
    // MARK :- Add, Update and Delete functions for sub menu group Items
    
    func addSubMenuDataInMainMenu(atIndexPath: IndexPath, name: String, price: String?, imageData: Data?) {
        let menuGroupUpdate = self.fetchedResultsController.object(at: atIndexPath)
        let subMenuAdd = SubMenuItem(context: managedContext!)
        subMenuAdd.itemName = name
        subMenuAdd.itemPrice = price
        subMenuAdd.itemImageData = imageData
        menuGroupUpdate.lastUpdated = Date()
        menuGroupUpdate.addToSubMenuItem(subMenuAdd)
        do {
            try managedContext!.save()
            print("Bala save successful")
        } catch let error as NSError {
            print("Save failed: error = \(error) and description = \(error.userInfo)")
        }
    }
    
    func updateSubMenuDataInMainMenu(atIndexPath: IndexPath, subMenuIndex: Int, name: String, price: String?, imageData: Data?) {
        let menuGroupUpdate = self.fetchedResultsController.object(at: atIndexPath)
        guard let subMenuUpdate = menuGroupUpdate.subMenuItem?[subMenuIndex] as? SubMenuItem else {
            return
        }
        subMenuUpdate.itemName = name
        subMenuUpdate.itemPrice = price
        subMenuUpdate.itemImageData = imageData
        menuGroupUpdate.lastUpdated = Date()
        do {
            try managedContext!.save()
            print("Bala Update save successful")
        } catch let error as NSError {
            print("Update Save failed: error = \(error) and description = \(error.userInfo)")
        }
    }
    
    func deleteSubMenuDataInMainMenu(atIndexPath: IndexPath, subMenuIndex: Int) {
        let menuGroupUpdate = self.fetchedResultsController.object(at: atIndexPath)
        menuGroupUpdate.removeFromSubMenuItem(at: subMenuIndex)
        do {
            try managedContext!.save()
            print("Bala delet save successful")
        } catch let error as NSError {
            print("Delete Save failed: error = \(error) and description = \(error.userInfo)")
        }
    }
    
    func preLoadData() {
        let menuGroup1 = createMenuGroup(name: "Waffles", imageName: "waffles")
        menuGroup1.addToSubMenuItem(createSubItem(name: "Chocolate Waffle", imageName: "chocolateWaffle", price: "7.99$"))
        menuGroup1.addToSubMenuItem(createSubItem(name: "Banana Waffle", imageName: "bananaWaffle", price: "8.99$"))
        menuGroup1.addToSubMenuItem(createSubItem(name: "vegan Waffle", imageName: "veganWaffle", price: "9.99$"))
        
        let menuGroup2 = createMenuGroup(name: "Pancakes", imageName: "pancakes")
        menuGroup2.addToSubMenuItem(createSubItem(name: "Sprinkes Pancakes", imageName: "sprinklesPancake", price: "6.99$"))
        menuGroup2.addToSubMenuItem(createSubItem(name: "Banana Pancakes", imageName: "bananaPancake", price: "7.99$"))
        menuGroup2.addToSubMenuItem(createSubItem(name: "Japanese Pancakes", imageName: "japanesePancake", price: "8.99$"))
        
        let menuGroup3 = createMenuGroup(name: "Bagels", imageName: "bagels")
        menuGroup3.addToSubMenuItem(createSubItem(name: "Garlic Bagel", imageName: "garlicBagel", price: "5.99$"))
        menuGroup3.addToSubMenuItem(createSubItem(name: "Blueberry Bagel", imageName: "blueberryBagel", price: "6.99$"))
        menuGroup3.addToSubMenuItem(createSubItem(name: "Everything Bagel", imageName: "everythingBagel", price: "7.99$"))
        do {
            try managedContext!.save()
            print("Bala save successful")
        } catch let error as NSError {
            print("Save failed: error = \(error) and description = \(error.userInfo)")
        }
    }
    
    private func createMenuGroup(name: String?, imageName: String) -> MenuGroup {
        let menuGroupCreated = MenuGroup(context: managedContext!)
        menuGroupCreated.name = name
        menuGroupCreated.imageData = UIImage(named: imageName)?.jpegData(compressionQuality: 1)
        menuGroupCreated.lastUpdated = Date()
        return menuGroupCreated
    }
    
    private func createSubItem(name: String?, imageName: String, price: String?) -> SubMenuItem {
        let subMenuItemCreated = SubMenuItem(context: managedContext!)
        subMenuItemCreated.itemName = name
        subMenuItemCreated.itemPrice = price
        subMenuItemCreated.itemImageData = UIImage(named: imageName)?.jpegData(compressionQuality: 1)
        return subMenuItemCreated
    }
}
