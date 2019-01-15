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

    @objc func leftEdgeSwipe(sender: UIScreenEdgePanGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
}

extension ImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        print(scrollView.contentSize)
    }
    
    }
