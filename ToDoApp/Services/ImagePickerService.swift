//
//  ImagePicker.swift
//  ToDoApp
//
//  Created by Denis Verkhovod on 1/14/19.
//  Copyright © 2019 Denis Verkhovod. All rights reserved.
//

import Foundation
import UIKit

class ImagePickerService {
    
    func presentAlertController(in viewController: UIViewController) {
        let alertController = UIAlertController(title: "Add image", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Make photo", style: .default) { (action) in
            self.presentImagePickerController(in: viewController, with: .camera)
        }
        let galleryAction = UIAlertAction(title: "Add from gallery", style: .default) { (action) in
            self.presentImagePickerController(in: viewController, with: .photoLibrary)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cameraAction)
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)
        
        viewController.present(alertController, animated: true, completion: nil)
    }
    
    private func presentImagePickerController(in viewController: UIViewController, with source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let picker = UIImagePickerController()
            picker.allowsEditing = true
            picker.sourceType = source
            picker.delegate = viewController as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            
            viewController.present(picker, animated: true, completion: nil)
        }
    }
}
