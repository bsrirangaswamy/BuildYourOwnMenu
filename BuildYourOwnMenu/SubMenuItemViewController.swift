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
    var mainGroupIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        PersistenceManager.sharedInstance.fetchedResultsController.delegate = self
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        print("Bala add button tapped")
        let createItemController = CreateItemViewController()
        if let mainIndPath = mainGroupIndexPath {
            createItemController.indexPath = mainIndPath
        }
        self.present(createItemController, animated: true, completion: nil)
    }

    @IBAction func doneButtonPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
}

extension SubMenuItemViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var rowCount = 0
        if let mainIndPath = mainGroupIndexPath {
            rowCount = PersistenceManager.sharedInstance.fetchedResultsController.object(at: mainIndPath).subMenuItem?.count ?? 0
        }
        return rowCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainMenuCell", for: indexPath) as! MainMenuTableViewCell
        if let mainIndPath = mainGroupIndexPath, let subItem = PersistenceManager.sharedInstance.fetchedResultsController.object(at: mainIndPath).subMenuItem?[indexPath.row] as? SubMenuItem {
            cell.itemLabel.text = subItem.itemName
            cell.itemPriceLabel.text = subItem.itemPrice
            if let imgData = subItem.itemImageData {
                DispatchQueue.global(qos: .background).async {
                    let image = UIImage(data: imgData)
                    DispatchQueue.main.async {
                        cell.itemImageView.image = image
                    }
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexpath) in
            if let mainIndPath = self.mainGroupIndexPath {
                PersistenceManager.sharedInstance.deleteSubMenuDataInMainMenu(atIndexPath: mainIndPath, subMenuIndex: indexPath.row)
            }
        }
//        let editAction = UITableViewRowAction(style: .normal, title: "Edit") { (action, indexpath) in
//            self.editMainMenu(atIndexPath: indexPath)
//        }
        return [deleteAction]
    }
    
    
}

extension SubMenuItemViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        subMenuItemTableView.reloadData()
    }
}
