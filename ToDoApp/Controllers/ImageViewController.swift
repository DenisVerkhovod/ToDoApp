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
    @IBOutlet weak var scroolViewWidth: NSLayoutConstraint!
    @IBOutlet weak var scroolViewHeight: NSLayoutConstraint!
    @IBOutlet weak var imageView: UIImageView! {
        didSet{
            imageView.image = image
            
            let leftEdgeSwipe = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(leftEdgeSwipe(sender:)))
            leftEdgeSwipe.edges = [.left]
            imageView.addGestureRecognizer(leftEdgeSwipe)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        scrollView.zoomScale = max(self.view.bounds.size.width / image.size.width, self.view.bounds.size.height / image.size.height)
        scroolViewWidth.constant = image.size.width
        scroolViewHeight.constant = image.size.height
    }
    
    @objc func leftEdgeSwipe(sender: UIScreenEdgePanGestureRecognizer) {
        self.navigationController?.popViewController(animated: true)
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
}

//MARK: - Extensions

extension ImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        scroolViewWidth.constant = scrollView.contentSize.width
        scroolViewHeight.constant = scrollView.contentSize.height
    }
}
