//
//  DetailTableViewController.swift
//  ToDoApp
//
//  Created by Denis Verkhovod on 04.09.2018.
//  Copyright © 2018 Denis Verkhovod. All rights reserved.
//

import UIKit

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
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var priorityLabel: UIView! {
        didSet {
            priorityLabel.layer.cornerRadius = priorityLabel.frame.size.height / 2
            
            switch task.priority {
            case .low:
                priorityLabel.backgroundColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1)
            case .normal:
                priorityLabel.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            case .high:
                priorityLabel.backgroundColor = #colorLiteral(red: 0.7450980544, green: 0.1568627506, blue: 0.07450980693, alpha: 1)
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.estimatedRowHeight = 45
        tableView.rowHeight = UITableView.automaticDimension
        
        setDateLabel()
        setImage()
        
    }
    
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
    
    @IBAction func unwindSegue(segue: UIStoryboardSegue) {
        
    }
    
   

   
    func setDateLabel() {
        if let date = task.date {
            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            dateLabel.text = formatter.string(from: date)
        } else {
            dateLabel.text = ""
        }
    }
    
    func setImage() {
        if let image = task.image {
            imageView.image = UIImage(data: image)
        } else {
            imageView.image = UIImage(named: "camera")
        }
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
