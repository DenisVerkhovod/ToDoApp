//
//  NewTaskTableViewController.swift
//  ToDoApp
//
//  Created by Denis Verkhovod on 19.08.2018.
//  Copyright © 2018 Denis Verkhovod. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class NewTaskTableViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    var task : Task!
    
    
    @IBOutlet weak var taskName: UITextField! {
        didSet {
            taskName.delegate = self
        }
    }
    @IBOutlet weak var textView: UITextView! {
        didSet {
            textView.delegate = self
            textView.layer.cornerRadius = 5
            textView.text = "Add Note..."
            textView.textColor = UIColor.lightGray
        }
    }
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var prioritySegment: UISegmentedControl!
    @IBOutlet weak var dueDateSwitch: UISwitch!
    @IBOutlet weak var shouldRemindSwitch: UISwitch!
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.setValue(UIColor.white, forKey: "textColor")
        
        task = Task()
        
        taskName.becomeFirstResponder()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(endEditing))
        self.view.addGestureRecognizer(tap)
        
        //        taskName.rightView = overlayButton()
        //        taskName.rightViewMode = UITextFieldViewMode.always
        
    }
    

    @IBAction func doneAction(_ sender: UIBarButtonItem) {
        
        if taskName.text == "" {
            let alertController = UIAlertController(title: "Add task!", message: nil, preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alertController.addAction(action)
            present(alertController, animated: true, completion: nil)
        } else {
            task.name = taskName.text!
            task.note = textView.text!
           
            if addPhotoButton.image(for: .normal) != UIImage(named: "camera") {
                task.image = addPhotoButton.image(for: .normal)!.pngData()
            }
            task.priority = prioritySegment.selectedSegmentIndex 
            
            if dueDateSwitch.isOn {
            task.date = datePicker.date
            }
            task.shouldRemind = shouldRemindSwitch.isOn
            
            let taskWithMaxId = RealmData.current.results().max { $0.id < $1.id }
            if let max = taskWithMaxId?.id {
                print(max)
                task.id = max + 1
            } else {
                task.id = 1
            }
            
            RealmData.current.create(task)
            
            if shouldRemindSwitch.isOn {
                task.scheduleNotification()
            }
            
            
            performSegue(withIdentifier: "unwindToAllTaskSegue", sender: self)
        }
        
    }
    
    @IBAction func addPhotoButtonPressed(_ sender: UIButton) {
    
        let pickerService = ImagePickerService()
        pickerService.presentAlertController(in: self)
        
    }
    
    
    @objc func endEditing() {
    taskName.resignFirstResponder()
        textView.resignFirstResponder()
    }
    
    @IBAction func dueDateSwitchAction(_ sender: UISwitch) {
        guard let cell = view.viewWithTag(1) as? UITableViewCell else { return }
        cell.isHidden = !sender.isOn
    }
    
    //MARK:- imagePickerController Delegates
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        let image = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.editedImage)] as? UIImage
        addPhotoButton.setImage(image, for: .normal)
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK:- TextField Delegates
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //MARK:- TextView Delegates
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Add Note..." {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = "Add Note..."
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func overlayButton() -> UIButton {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "DeleteIcon"), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 28, height: 28)
        return button
    }
 
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
 
    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
