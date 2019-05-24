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
        // Do any additional setup after loading the view.
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "mainMenuCell", for: indexPath) as! MainMenuTableViewCell
        let menuGroupFetched = PersistenceManager.sharedInstance.fetchedResultsController.object(at: indexPath)
        cell.itemLabel.text = menuGroupFetched.name
        if let imgData = menuGroupFetched.imageData {
            DispatchQueue.global(qos: .background).async {
                let image = UIImage(data: imgData)
                DispatchQueue.main.async {
                    cell.itemImageView.image = image
                }
            }
        }
        cell.itemPriceLabel.isHidden = true
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
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        mainGroupTableView.reloadData()
    }
}


extension ViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showSubItemsVC", let navController = segue.destination as? UINavigationController, let subMenuItemVC = navController.topViewController as? SubMenuItemViewController {
            subMenuItemVC.mainGroupIndexPath = mainGroupTableView.indexPathForSelectedRow
        }
    }
}

