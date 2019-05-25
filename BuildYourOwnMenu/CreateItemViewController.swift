//
//  CreateItemViewController.swift
//  BuildYourOwnMenu
//
//  Created by Balakumaran Srirangaswamy on 5/23/19.
//  Copyright © 2019 Bala. All rights reserved.
//

import UIKit
import Photos
import AVFoundation

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
    }
    
    @IBAction func editImageButtonPressed(_ sender: UIButton) {
        imagePickerController.allowsEditing = false

        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if let cameraAction = self.createAction(title: "Take Picture", sourceType: .camera) {
            alertController.addAction(cameraAction)
        }
        if let photoLibAction = self.createAction(title: "Photo Library", sourceType: .photoLibrary) {
            alertController.addAction(photoLibAction)
        }
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.popoverPresentationController?.sourceView = sender
            alertController.popoverPresentationController?.sourceRect = sender.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = [.down, .up]
        }
        
        self.present(alertController, animated: true)
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        guard let nameText = nameTextField.text, let pickedImage = itemImageView.image else { return }
        if isMainMenu {
            if isEditMode, let mainIndPath = mainGroupIndexPath {
                PersistenceManager.sharedInstance.updateMainMenuData(indexPath: mainIndPath, name: nameText, imageData: pickedImage.jpegData(compressionQuality: 1))
            } else {
                PersistenceManager.sharedInstance.addMainMenuData(name: nameText, imageData: pickedImage.jpegData(compressionQuality: 1))
            }
        } else {
            guard let mainIndPath = mainGroupIndexPath else { return }
            if isEditMode, let subIndex = subMenuIndex {
                PersistenceManager.sharedInstance.updateSubMenuDataInMainMenu(atIndexPath: mainIndPath, subMenuIndex: subIndex, name: nameText, price: priceTextField.text, imageData: pickedImage.jpegData(compressionQuality: 1))
                
            } else {
                PersistenceManager.sharedInstance.addSubMenuDataInMainMenu(atIndexPath: mainIndPath, name: nameText, price: priceTextField.text, imageData: pickedImage.jpegData(compressionQuality: 1))
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
        let alertAction = UIAlertAction(title: title, style: .default) { [unowned self] (_) in
            self.checkPermission(sourceType: sourceType, completion: { [unowned self] (isAccessGranted) in
                if isAccessGranted {
                    self.imagePickerController.sourceType = sourceType
                    self.present(self.imagePickerController, animated: true)
                }
            })
        }
        return alertAction
    }
    
    func checkPermission(sourceType: UIImagePickerController.SourceType, completion: @escaping (_ isPermissionGranted: Bool) -> Void) {
        switch sourceType {
        case .camera:
            let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
            if cameraAuthorizationStatus == .authorized {
                completion(true)
            } else if cameraAuthorizationStatus == .notDetermined {
                AVCaptureDevice.requestAccess(for: .video) { (isAccessGranted) in
                    if isAccessGranted {
                        print("Camera access granted")
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            } else {
                completion(false)
            }
            break
        case .photoLibrary:
            let photoLibAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
            if photoLibAuthorizationStatus == .authorized {
                completion(true)
            } else if photoLibAuthorizationStatus == .notDetermined {
                PHPhotoLibrary.requestAuthorization { (requestAuthStatus) in
                    if requestAuthStatus == .authorized {
                        print("Photo library access granted")
                        completion(true)
                    } else {
                        completion(false)
                    }
                }
            }
        default:
            print("Source type undefined")
            completion(false)
        }
    }
}
