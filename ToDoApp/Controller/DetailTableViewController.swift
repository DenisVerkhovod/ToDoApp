//
//  DetailTableViewController.swift
//  ToDoApp
//
//  Created by Denis Verkhovod on 04.09.2018.
//  Copyright © 2018 Denis Verkhovod. All rights reserved.
//

import UIKit
import AVFoundation

class DetailTableViewController: UITableViewController {
    
    var task : Task!
    
    @IBOutlet weak var nameLabel: UILabel! {
        didSet {
           nameLabel.text = task.name
        }
    }
    @IBOutlet weak var nameView: UIView! {
        didSet {
            nameView.layer.cornerRadius = Constant.cornerRadius
        }
    }
    @IBOutlet weak var noteLabel: UILabel! {
        didSet {
            noteLabel.text = task.note
        }
    }
    @IBOutlet weak var noteView: UIView! {
        didSet {
            noteView.layer.cornerRadius = Constant.cornerRadius
        }
    }

    @IBOutlet weak var pickerView: AreaTapPickerView! {
        didSet {
            pickerView.dataSource = self
            pickerView.delegate = self
            pickerView.layer.cornerRadius = Constant.cornerRadius
            pickerView.selectRow(task.priority, inComponent: 0, animated: false)
        }
    }
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var priorityLabel: UIView! {
        didSet {
            priorityLabel.layer.cornerRadius = priorityLabel.frame.size.height / 2
            
            switch task.priority {
            case 0:
                priorityLabel.backgroundColor = UIColor.green
            case 2:
                priorityLabel.backgroundColor = UIColor.red
            default:
                priorityLabel.backgroundColor = UIColor.yellow
            }
        }
    }
    @IBOutlet weak var noteCell: UITableViewCell!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var dateView: UIView! {
        didSet {
            dateView.layer.cornerRadius = Constant.cornerRadius
        }
    }
    @IBOutlet weak var remindView: UIView! {
        didSet {
            remindView.layer.cornerRadius = Constant.cornerRadius
        }
    }
    
    @IBOutlet weak var remindImageView: UIImageView! {
        didSet {
            if task.shouldRemind {
                remindImageView.image = UIImage(named: "ringBell")
            } else {
                remindImageView.image = UIImage(named: "noiseBell")
            }
        }
    }
    @IBOutlet weak var datePickerCell: UITableViewCell!
    @IBOutlet weak var datePickerView: UIView! {
        didSet {
            datePickerView.layer.cornerRadius = Constant.cornerRadius
        }
    }
    @IBOutlet weak var datePicker: UIDatePicker!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = UITableView.automaticDimension
        
        setDateLabel()
        setImage()
        
    }
    
    @IBAction func datePickerChanged(_ sender: UIDatePicker) {
        
        let date = sender.date
        RealmData.current.update(self.task, with: ["date":date])
        setDateLabel()
        
        
    }
    //MARK: - Gesture actions
    
    @IBAction func backPanFromEdge(_ sender: UIScreenEdgePanGestureRecognizer) {
        
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func imageViewTapped(_ sender: UITapGestureRecognizer) {
        
        performSegue(withIdentifier: "imageSegue", sender: self)
        
    }
    
    @IBAction func nameOrNoteTapped(_ sender: UITapGestureRecognizer) {
        if let initialView = sender.view {
            if initialView.tag == 1 {
                performSegue(withIdentifier: "nameTextSegue", sender: self)
            } else if initialView.tag == 2 {
                performSegue(withIdentifier: "noteTextSegue", sender: self)
            }
        }
        
    }
    
    @IBAction func dateViewTapped(_ sender: UITapGestureRecognizer) {
        guard let dateCell = view.viewWithTag(3) as? UITableViewCell else { return }
        datePicker.date = task.date
        dateCell.isHidden.toggle()
        tableView.reloadData()
    }
    @IBAction func remindMeViewTapped(_ sender: UITapGestureRecognizer) {
        let notification = LocalNotificationService()
        
        if task.shouldRemind {
            RealmData.current.update(self.task, with: ["shouldRemind" : false])
            notification.removeNotification(for: task)
            remindImageView.image = UIImage(named: "noiseBell")
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        } else {
            RealmData.current.update(self.task, with: ["shouldRemind" : true])
            notification.scheduleNotification(for: task)
            remindImageView.image = UIImage(named: "ringBell")
            AudioServicesPlaySystemSound(1054)
        }
        
    }
    
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {
        
    }

    func setDateLabel() {
        let date = task.date
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        dateLabel.text = formatter.string(from: date)
      
    }
    
    func setImage() {
        if let image = task.image {
            imageView.image = UIImage(data: image)
        } else {
            imageView.image = UIImage(named: "camera")
        }
    }
    
    // MARK: - TableView delegate's methods
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 1:
            return 100
        case 3:
            return datePickerCell.isHidden ? 0 : 200
        default:
            return 45
        }
}
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "imageSegue":
                if let destinationVC = segue.destination as? ImageViewController {
                    if let image = task.image {
                        destinationVC.image = UIImage(data: image)
                    } else {
                        let imagePicker = ImagePickerService()
                        imagePicker.presentAlertController(in: self)
                    }
                    destinationVC.deleteImage = { [unowned self] in
                        RealmData.current.update(self.task, with: ["image": nil])
                        self.imageView.image = UIImage(named: "camera")
                        
                    }
                }
            case "nameTextSegue":
                if let destinationVC = segue.destination as? EditTaskTextController {
                    destinationVC.text = task.name
                    destinationVC.completion = { [unowned self] text in
                        RealmData.current.update(self.task, with: ["name": text])
                        self.nameLabel.text = text
                    }
                }
            case "noteTextSegue":
                if let destinationVC = segue.destination as? EditTaskTextController {
                    destinationVC.text = task.note
                    destinationVC.completion = { [unowned self] text in
                        RealmData.current.update(self.task, with: ["note": text])
                        self.noteLabel.text = text
                    }
                }
            default:
                break
            }
        }
    }
}

extension DetailTableViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else { return }
       
        RealmData.current.update(self.task, with: ["image": image.pngData()!])
        imageView.image = image
        dismiss(animated: true, completion: nil)
    }
}

extension DetailTableViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        let pickview = UIView(frame: CGRect(x: 0, y: 0, width: pickerView.frame.size.width - 2, height: pickerView.frame.size.height - 2))
        pickview.layer.cornerRadius = pickview.frame.size.width / 2
        switch row {
        case 0:
            pickview.backgroundColor = .green
        case 1:
            pickview.backgroundColor = .yellow
        case 2:
            pickview.backgroundColor = .red
        default:
            break
        }
        
        return pickview
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return pickerView.frame.size.height
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        RealmData.current.update(self.task, with: ["priority" : row])
        
    }
    
}
