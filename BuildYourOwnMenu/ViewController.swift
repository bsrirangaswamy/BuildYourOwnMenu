//
//  ViewController.swift
//  BuildYourOwnMenu
//
//  Created by Balakumaran Srirangaswamy on 5/22/19.
//  Copyright © 2019 Bala. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var mainGroupTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Main Menu"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PersistenceManager.sharedInstance.fetchedResultsController.delegate = self
    }

    @IBAction func addMainMenuItem(_ sender: UIBarButtonItem) {
        let createItemController = CreateItemViewController()
        createItemController.isMainMenu = true
        self.present(createItemController, animated: true, completion: nil)
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0
        rowCount = PersistenceManager.sharedInstance.fetchedResultsController.sections?[section].numberOfObjects ?? 0
        return rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "mainMenuCell", for: indexPath) as?  MainMenuTableViewCell else { return MainMenuTableViewCell() }
        let menuGroupFetched = PersistenceManager.sharedInstance.fetchedResultsController.object(at: indexPath)
        cell.setupCell(name: menuGroupFetched.name, price: nil, imageData: menuGroupFetched.imageData)
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexpath) in
            PersistenceManager.sharedInstance.deleteMainMenuData(indexPath: indexPath)
        }
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexpath) in
            self.editMainMenu(atIndexPath: indexPath)
        }
        return [deleteAction, editAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func editMainMenu(atIndexPath: IndexPath) {
        let createItemController = CreateItemViewController()
        let menuGroupEdit = PersistenceManager.sharedInstance.fetchedResultsController.object(at: atIndexPath)
        createItemController.isMainMenu = true
        createItemController.isEditMode = true
        createItemController.mainGroupIndexPath = atIndexPath
        createItemController.imageDataReceived = menuGroupEdit.imageData
        createItemController.nameReceived = menuGroupEdit.name
        self.present(createItemController, animated: true, completion: nil)
    }
}

extension ViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        mainGroupTableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if let newIndPath = newIndexPath {
                mainGroupTableView.insertRows(at: [newIndPath], with: .automatic)
            }
            break
        case .delete:
            if let indPath = indexPath {
                mainGroupTableView.deleteRows(at: [indPath], with: .automatic)
            }
            break
        case .update:
            if let indPath = indexPath {
                mainGroupTableView.reloadRows(at: [indPath], with: .automatic)
            }
            break
        default:
            print("Bala action not supported")
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        mainGroupTableView.endUpdates()
    }
}


extension ViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSubItemsVC", let navController = segue.destination as? UINavigationController, let subMenuItemVC = navController.topViewController as? SubMenuItemViewController {
            subMenuItemVC.mainGroupIndexPath = mainGroupTableView.indexPathForSelectedRow ?? IndexPath(row: 0, section: 0)
        }
    }
}

