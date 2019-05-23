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
    
    var managedContext: NSManagedObjectContext
    
    lazy var fetchedResultsController: NSFetchedResultsController<MenuGroup> = {
        let fetchRequest: NSFetchRequest<MenuGroup> = MenuGroup.fetchRequest()
        let fetchRequestContrller = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedContext, sectionNameKeyPath: nil, cacheName: nil)
        return fetchRequestContrller
    }()
    
    init(managedContext: NSManagedObjectContext) {
        self.managedContext = managedContext
    }
    
    func saveData(menuGroup: MenuGroup) {
        guard let appDelegateRef = UIApplication.shared.delegate as? AppDelegate else { return }
        let saveManagedContext = appDelegateRef.persistentContainer.viewContext
        do {
            try saveManagedContext.save()
        } catch let error as NSError {
            print("Save failed; error = \(error), description = \(error.userInfo)")
        }
    }

}
