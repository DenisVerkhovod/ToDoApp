//
//  ImageViewController.swift
//  ToDoApp
//
//  Created by Denis Verkhovod on 10/3/18.
//  Copyright © 2018 Denis Verkhovod. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {
    
    var image: UIImage!
    var deleteImage: (() -> ())?
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.delegate = self
        }
    }

   @IBOutlet weak var imageView: UIImageView! {
        didSet{
            imageView.image = image
            let leftEdgeSwipe = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(leftEdgeSwipe(sender:)))
            leftEdgeSwipe.edges = [.left]
            imageView.addGestureRecognizer(leftEdgeSwipe)
        }
    }
    @IBAction func deleteImageAction(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Delete image?", message: nil, preferredStyle: UIAlertController.Style.alert)
        let deleteAction = UIAlertAction(title: "Yes", style: .destructive) { (action) in
            self.deleteImage?()
            self.navigationController?.popViewController(animated: true)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.default, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        
    }
    
    @objc func leftEdgeSwipe(sender: UIScreenEdgePanGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}

extension ImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
}
