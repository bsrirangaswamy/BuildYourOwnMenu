//
//  SubMenuItemViewController.swift
//  BuildYourOwnMenu
//
//  Created by Balakumaran Srirangaswamy on 5/23/19.
//  Copyright © 2019 Bala. All rights reserved.
//

import UIKit
import CoreData

class SubMenuItemViewController: UIViewController {

    @IBOutlet weak var subMenuItemTableView: UITableView!
    var mainGroupIndexPath: IndexPath = IndexPath(row: 0, section: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PersistenceManager.sharedInstance.fetchedResultsController.delegate = self
        self.title = PersistenceManager.sharedInstance.fetchedResultsController.object(at: mainGroupIndexPath).name
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        print("Bala add button tapped")
        let createItemController = CreateItemViewController()
        createItemController.mainGroupIndexPath = mainGroupIndexPath
        self.present(createItemController, animated: true, completion: nil)
    }

    @IBAction func doneButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension SubMenuItemViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PersistenceManager.sharedInstance.fetchedResultsController.object(at: mainGroupIndexPath).subMenuItem?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "mainMenuCell", for: indexPath) as? MainMenuTableViewCell,  let subItem = PersistenceManager.sharedInstance.fetchedResultsController.object(at: mainGroupIndexPath).subMenuItem?[indexPath.row] as? SubMenuItem else { return MainMenuTableViewCell() }
        cell.setupCell(name: subItem.itemName, price: subItem.itemPrice, imageData: subItem.itemImageData)
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexpath) in
            PersistenceManager.sharedInstance.deleteSubMenuDataInMainMenu(atIndexPath: self.mainGroupIndexPath, subMenuIndex: indexPath.row)
        }
        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexpath) in
            self.editSubMenuInMainMenu(atIndexPath: self.mainGroupIndexPath, subMenuIndex: indexPath.row)
        }
        return [deleteAction, editAction]
    }
    
    func editSubMenuInMainMenu(atIndexPath: IndexPath, subMenuIndex: Int) {
        let createItemController = CreateItemViewController()
        let subMenuGroupEdit = PersistenceManager.sharedInstance.fetchedResultsController.object(at: atIndexPath).subMenuItem?[subMenuIndex] as? SubMenuItem
        createItemController.isEditMode = true
        createItemController.mainGroupIndexPath = atIndexPath
        createItemController.subMenuIndex = subMenuIndex
        createItemController.nameReceived = subMenuGroupEdit?.itemName
        createItemController.priceReceived = subMenuGroupEdit?.itemPrice
        createItemController.imageDataReceived = subMenuGroupEdit?.itemImageData
        self.present(createItemController, animated: true, completion: nil)
    }
    
}

extension SubMenuItemViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        subMenuItemTableView.reloadData()
    }
}
