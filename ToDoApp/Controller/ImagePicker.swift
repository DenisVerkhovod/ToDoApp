//
//  ImagePicker.swift
//  ToDoApp
//
//  Created by Denis Verkhovod on 1/14/19.
//  Copyright © 2019 Denis Verkhovod. All rights reserved.
//

import Foundation
import UIKit

class ImagePicker {
    
    func alertController() -> UIAlertController {
        let alertController = UIAlertController(title: "Add image", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Make photo", style: .default) { (action) in
            self.imgPickerController(source: .camera)
        }
        
        let galleryAction = UIAlertAction(title: "Add from gallery", style: .default) { (action) in
            self.imgPickerController(source: .photoLibrary)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cameraAction)
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)
        return alertController
    }
    
    func imgPickerController(source: UIImagePickerController.SourceType) -> UIImagePickerController {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let picker = UIImagePickerController()
            picker.allowsEditing = true
            picker.sourceType = source
            
            return picker
        }
    
    return UIImagePickerController()
    
}
}
