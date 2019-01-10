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
   
    @IBOutlet weak var imageView: UIImageView! {
        didSet{
            let leftEdgeSwipe = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(leftEdgeSwipe(sender:)))
            leftEdgeSwipe.edges = [.left]
            imageView.addGestureRecognizer(leftEdgeSwipe)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

    
        imageView.image = image
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @objc func leftEdgeSwipe(sender: UIScreenEdgePanGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
