//
//  CreateItemViewController.swift
//  BuildYourOwnMenu
//
//  Created by Balakumaran Srirangaswamy on 5/23/19.
//  Copyright © 2019 Bala. All rights reserved.
//

import UIKit

class CreateItemViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var editImageButton: UIButton!
    @IBOutlet weak var itemImageView: UIImageView!
    @IBOutlet weak var priceStackView: UIStackView!
    
    var isMainMenu: Bool = false
    var isEditMode: Bool = false
    
    var imagePickerController = UIImagePickerController()
    
    var imageDataReceived: Data?
    var nameReceived: String?
    var priceReceived: String?
    var indexPath: IndexPath?
    
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
        if isEditMode, let indPath = indexPath {
            PersistenceManager.sharedInstance.updateMainMenuData(indexPath: indPath, name: nameText, imageData: pickedImage.pngData())
        } else {
            PersistenceManager.sharedInstance.addMainMenuData(name: nameText, imageData: pickedImage.pngData())
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
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
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
}
