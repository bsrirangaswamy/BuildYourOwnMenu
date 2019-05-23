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
        cell.mainItemLabel.text = menuGroupFetched.name
        if let imgData = menuGroupFetched.imageData {
            cell.mainItemImageView.image = UIImage(data: imgData)
        }
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
    
    func editMainMenu(atIndexPath: IndexPath) {
        let createItemController = CreateItemViewController()
        let menuGroupEdit = PersistenceManager.sharedInstance.fetchedResultsController.object(at: atIndexPath)
        createItemController.isMainMenu = true
        createItemController.isEditMode = true
        createItemController.imageDataReceived = menuGroupEdit.imageData
        createItemController.nameReceived = menuGroupEdit.name
        createItemController.indexPath = atIndexPath
        self.present(createItemController, animated: true, completion: nil)
    }
}

extension ViewController: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        mainGroupTableView.reloadData()
    }
}

