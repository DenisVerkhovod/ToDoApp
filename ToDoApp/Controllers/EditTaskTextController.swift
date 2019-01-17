//
//  EditTaskTextController.swift
//  ToDoApp
//
//  Created by Denis Verkhovod on 10/9/18.
//  Copyright © 2018 Denis Verkhovod. All rights reserved.
//

import UIKit

class EditTaskTextController: UIViewController {
    
    var text: String!
    
    var completion: ((String) -> ())?
    
    @IBOutlet weak var textView: UITextView! {
        didSet {
            if let text = text {
                textView.text = text
            }
        }
    }
    
    //MARK: - View's lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textView.becomeFirstResponder()
    }
    
    @IBAction func donePressed() {
        if let text = textView.text {
            completion?(text)
        }
        navigationController?.popViewController(animated: true)
    }
}
