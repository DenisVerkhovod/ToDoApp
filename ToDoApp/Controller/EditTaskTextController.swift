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
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let text = text {
            textView.text = text
    }
        textView.becomeFirstResponder()
    
    }
    
    @IBAction func donePressed() {
        
        if let text = textView.text {
            completion?(text)
        }
        navigationController?.popViewController(animated: true)
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
