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
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        let cameraAction: UIAlertAction = UIAlertAction(title: "Take Picture", style: .default) { action in
            self.launchImagePicker(sender: sender, source: .camera)
        }
        alertController.addAction(cameraAction)
        let photoLibraryAction: UIAlertAction = UIAlertAction(title: "Choose Existing Picture", style: .default) { action in
            self.launchImagePicker(sender: sender, source: .photoLibrary)
        }
        alertController.addAction(photoLibraryAction)
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            alertController.modalPresentationStyle = .popover
            alertController.popoverPresentationController?.sourceView = sender
            alertController.popoverPresentationController?.sourceRect = sender.bounds
        }
        
        self.present(alertController, animated: true, completion: nil)
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
        itemImageView.image = pickedImage.updateOrientation()
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    func launchImagePicker(sender: UIButton, source: UIImagePickerController.SourceType) {
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = false
        imagePickerController.sourceType = source
        if source == .camera {
            imagePickerController.modalPresentationStyle = .fullScreen
        } else {
            imagePickerController.modalPresentationStyle = UIModalPresentationStyle.popover
            if UIDevice.current.userInterfaceIdiom == .pad {
                imagePickerController.popoverPresentationController?.sourceView = sender
                imagePickerController.popoverPresentationController?.sourceRect = sender.bounds
            }
        }
        imagePickerController.display(rootController: self)
    }
}

extension UIImagePickerController {
    func display(rootController: UIViewController) {
        switch sourceType {
        case .camera:
            guard AVCaptureDevice.authorizationStatus(for: .video) != .denied else {
                let alertController = UIAlertController(title: nil, message: "Camera access denied", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                rootController.present(alertController, animated: true, completion: nil)
                return
            }
            
            rootController.present(self, animated: true, completion: {
                if AVCaptureDevice.authorizationStatus(for: .video) == .notDetermined {
                    AVCaptureDevice.requestAccess(for: .video, completionHandler: { (videoGranted: Bool) -> Void in
                        if !videoGranted {
                            self.dismiss(animated: true, completion: nil)
                        }
                    })
                }
            })
        case .photoLibrary:
            guard PHPhotoLibrary.authorizationStatus() != .denied else {
                let alertController = UIAlertController(title: nil, message: "Photo Access denied", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                rootController.present(alertController, animated: true, completion: nil)
                return
            }
            
            rootController.present(self, animated: true, completion: {
                if PHPhotoLibrary.authorizationStatus() == .notDetermined {
                    PHPhotoLibrary.requestAuthorization({ (status) in
                        let granted = status == PHAuthorizationStatus.authorized
                        if !granted {
                            self.dismiss(animated: true, completion: nil)
                        }
                    })
                }
            })
        default:
            print("Bala default")
        }
    }
}

extension UIImage {
    // when saving as png data, rotation is not saved as JPEG rotation flag is absent in png.
    func updateOrientation() -> UIImage {
        if self.imageOrientation == UIImage.Orientation.up {
            return self
        }
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        if let normalizedImage: UIImage = UIGraphicsGetImageFromCurrentImageContext() {
            UIGraphicsEndImageContext()
            return normalizedImage
        } else {
            return self
        }
    }
}
