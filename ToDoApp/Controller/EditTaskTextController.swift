//
//  EditTaskTextController.swift
//  ToDoApp
//
//  Created by Denis Verkhovod on 10/9/18.
//  Copyright © 2018 Denis Verkhovod. All rights reserved.
//

import UIKit

class EditTaskTextController: UIViewController {
    
    var nameText: String!
    var noteText: String!
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let text = nameText {
            textView.text = text
        } else if let text = noteText {
            textView.text = text
        }
       
        
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
