//
//  CreateItemViewController.swift
//  BuildYourOwnMenu
//
//  Created by Balakumaran Srirangaswamy on 5/23/19.
//  Copyright © 2019 Bala. All rights reserved.
//

import UIKit
import Photos

class CreateItemViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var editImageButton: UIButton!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var priceStackView: UIStackView!
    
    var isMainMenu: Bool = false
    var isEditMode: Bool = false
    
    var mainGroupIndexPath: IndexPath?
    var subMenuIndex: Int?
    
    var nameReceived: String?
    var priceReceived: String?
    var imageDataReceived: Data?
    
    private var imagePickerController = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextField.delegate = self
        priceTextField.delegate = self
        imagePickerController.delegate = self
        
        if isMainMenu {
            self.priceStackView.isHidden = true
        }
        
        if isEditMode {
            self.nameTextField.text = nameReceived ?? ""
            self.priceTextField.text = priceReceived ?? ""
            if let imageDataRecd = imageDataReceived {
                self.itemImageView.image = UIImage(data: imageDataRecd)
            }
        }
        self.view.bringSubviewToFront(editImageButton)
        print("Bala is edit button interaction enabled = \(editImageButton.isUserInteractionEnabled)")
    }
    
    @IBAction func editImageButtonPressed(_ sender: UIButton) {
        checkPermission()
        imagePickerController.allowsEditing = false

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let alertAction = self.createAction(title: "Take Picture", sourceType: .camera){
            alertController.addAction(alertAction)
        }
        if let alertAction = self.createAction(title: "Photo Library", sourceType: .photoLibrary) {
            alertController.addAction(alertAction)
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = self.view
            alertController.popoverPresentationController?.sourceRect = self.view.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }
        
        self.present(alertController, animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        guard let nameText = nameTextField.text, let pickedImage = itemImageView.image else { return }
        if isMainMenu {
            if isEditMode, let mainIndPath = mainGroupIndexPath {
                PersistenceManager.sharedInstance.updateMainMenuData(indexPath: mainIndPath, name: nameText, imageData: pickedImage.pngData())
            } else {
                PersistenceManager.sharedInstance.addMainMenuData(name: nameText, imageData: pickedImage.pngData())
            }
        } else {
            guard let mainIndPath = mainGroupIndexPath else { return }
            if isEditMode, let subIndex = subMenuIndex {
                PersistenceManager.sharedInstance.updateSubMenuDataInMainMenu(atIndexPath: mainIndPath, subMenuIndex: subIndex, name: nameText, price: priceTextField.text, imageData: pickedImage.pngData())
                
            } else {
                PersistenceManager.sharedInstance.addSubMenuDataInMainMenu(atIndexPath: mainIndPath, name: nameText, price: priceTextField.text, imageData: pickedImage.pngData())
            }
            
        }
        self.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func cancelButtonPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }

}

extension CreateItemViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension CreateItemViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let pickedImage = info[.originalImage] as? UIImage else {
            return
        }
        itemImageView.image = pickedImage
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    func createAction(title: String, sourceType: UIImagePickerController.SourceType) -> UIAlertAction? {
        guard UIImagePickerController.isSourceTypeAvailable(sourceType) else {
            return nil
        }
        let alertAction = UIAlertAction(title: title, style: .default) { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.imagePickerController.sourceType = sourceType
            strongSelf.present(strongSelf.imagePickerController, animated: true)
        }
        return alertAction
    }
    
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    print("success")
                }
            })
            print("It is not determined until now")
        case .restricted:
            print("User do not have access to photo album.")
        case .denied:
            print("User has denied the permission.")
        default:
            print("User has not granted permission")
        }
    }
}
