//
//  AllTasksTableViewController.swift
//  ToDoApp
//
//  Created by Denis Verkhovod on 15.08.2018.
//  Copyright © 2018 Denis Verkhovod. All rights reserved.
//

import UIKit
import RealmSwift

enum FilterMode {
    case descending
    case priority
    case date
    case complete
    
}

class AllTasksTableViewController: UITableViewController {
    
    var filterMode : FilterMode!
    var notificationToken: NotificationToken?
    var newTaskButton: UIButton!
    var newTaskView: UIView!
    var newTaskTextField: UITextField! {
        didSet {
            newTaskTextField.delegate = self
        }
    }
    
    var newTaskViewHeight: CGFloat = 40
    var newTaskViewOffset: CGFloat {
        return newTaskViewHeight + 40
    }

    var results : Results<Task> {
        get {
            switch filterMode {
            case .descending?:
                return RealmData.current.resultsNotCompleted()
            case .priority?:
                return RealmData.current.resultsSortByPriority()
            case .date?:
                return RealmData.current.resultsSortByDate()
            case .complete?:
                return RealmData.current.resultsCompleted()
            default:
                break
            }
            return RealmData.current.resultsNotCompleted()
        }
    }

  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        tableView.estimatedRowHeight = 80
        addNewTaskButton()
        addNewTaskView()
        
        filterMode = FilterMode.descending
        
        setObserveRealm()
        setTitleButton()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        notificationToken?.invalidate()
        print("INVALIDATE TOKEN")
    }
    
    
    @IBAction func close(segue: UIStoryboardSegue) {
        
    }
    
    
    
    // Set Realm Notifications
        func setObserveRealm() {
            notificationToken = results.observe { [weak self] (changes: RealmCollectionChange) in
                guard let tableView = self?.tableView else { return }
                switch changes {
                case .initial:
                    // Results are now populated and can be accessed without blocking the UI
                    tableView.reloadData()
                case .update(_, let deletions, let insertions, let modifications):
                    // Query results have changed, so apply them to the UITableView
                    tableView.beginUpdates()
                    tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                         with: .automatic)
                    tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                         with: .automatic)
                    tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                         with: .automatic)
                    tableView.endUpdates()
                case .error(let error):
                    // An error occurred while opening the Realm file on the background worker thread
                    fatalError("\(error)")
                }
        }
        }
    
    //MARK: -  New Task Button
    
    func addNewTaskButton () {
        newTaskButton = UIButton()
        
        newTaskButton.setImage(UIImage(named: "plusButton"), for: .normal)
        tableView.addSubview(newTaskButton)
        newTaskButton.addTarget(self, action: #selector(addButtonPressed(sender:)), for: .touchUpInside)

        newTaskButton.translatesAutoresizingMaskIntoConstraints = false
        newTaskButton.heightAnchor.constraint(equalToConstant: Constant.newTaskButtonHeight).isActive = true
        
        NSLayoutConstraint.activate([
            newTaskButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            newTaskButton.bottomAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.bottomAnchor, constant: -Constant.newTaskButtonOffset)
            ])
    }
    
    @objc func addButtonPressed(sender: UIButton) {
        
//        performSegue(withIdentifier: "NewTaskTableViewController", sender: self)
//        newTaskAnimator()
        newTaskButton.alpha = 0
        newTaskTextField.becomeFirstResponder()

    }
    
    func addNewTaskView() {
        
        newTaskView = UIView(frame: CGRect(x: 0, y: self.view.frame.maxY + newTaskViewHeight, width: view.bounds.size.width, height: newTaskViewHeight))
        newTaskView.backgroundColor = UIColor.white
        newTaskView.layer.cornerRadius = Constant.cornerRadius
        newTaskView.clipsToBounds = true
        self.navigationController?.view.addSubview(newTaskView)
        
//        newTaskView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            newTaskView.heightAnchor.constraint(equalToConstant: newTaskViewHeight),
//            newTaskView.widthAnchor.constraint(equalToConstant: self.tableView.bounds.width),
//            newTaskView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
////            newTaskView.bottomAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.bottomAnchor, constant: 0)
//            ])
        
        let imageView = UIImageView(image: UIImage(named: "plusButton"))
        let size: CGFloat = newTaskViewHeight - 10
//        imageView.frame.size = CGSize(width: size, height: size)
        imageView.contentMode = .scaleToFill
        
        newTaskView.addSubview(imageView)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.widthAnchor.constraint(equalToConstant: size),
            imageView.topAnchor.constraint(equalTo: newTaskView.topAnchor, constant: Constant.newTaskTextFieldOffset),
            imageView.leadingAnchor.constraint(equalTo: newTaskView.leadingAnchor, constant: Constant.newTaskTextFieldOffset),
            imageView.bottomAnchor.constraint(equalTo: newTaskView.bottomAnchor, constant: -Constant.newTaskTextFieldOffset)
            ])
        
        newTaskTextField = UITextField()
        newTaskTextField.backgroundColor = .green
        newTaskTextField.placeholder = "Add Task..."
        newTaskView.addSubview(newTaskTextField)
        
        newTaskTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            newTaskTextField.bottomAnchor.constraint(equalTo: newTaskView.bottomAnchor, constant: -Constant.newTaskTextFieldOffset),
            newTaskTextField.topAnchor.constraint(equalTo: newTaskView.topAnchor, constant: Constant.newTaskTextFieldOffset),
            newTaskTextField.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: Constant.newTaskTextFieldOffset),
            newTaskTextField.trailingAnchor.constraint(equalTo: newTaskView.trailingAnchor, constant: -Constant.newTaskTextFieldOffset)
            ])
    }
    
//    func newTaskAnimator() {
//
//
//        UIViewPropertyAnimator.runningPropertyAnimator(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
//           self.newTaskView.frame.origin.y -= self.newTaskViewOffset
//        }, completion: nil)
//
//    }
    
    
    // MARK: - Alert controller to navigation's bar title
    
    func setTitleButton() {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.setAttributedTitle(attributedNav(title: "Tasks ∨"), for: .normal)
        button.addTarget(self, action: #selector(titleButtonPressed(sender:)), for: .touchUpInside)
        self.navigationItem.titleView = button
    }
    
    @objc func titleButtonPressed(sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let azSort = UIAlertAction(title: "A - Z", style: .default) { action in
            self.filterMode = .descending
            self.setObserveRealm()
        }
        let prioritySort = UIAlertAction(title: "Priority", style: .default) { action in
            self.filterMode = .priority
            self.setObserveRealm()
        }
        let dateSort = UIAlertAction(title: "Date", style: .default) { action in
            self.filterMode = .date
            self.setObserveRealm()
        }
        let completeSort = UIAlertAction(title: "Completed", style: .default) { action in
            self.filterMode = .complete
            self.setObserveRealm()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        
        alertController.addAction(azSort)
        alertController.addAction(prioritySort)
        alertController.addAction(dateSort)
        alertController.addAction(completeSort)
        alertController.addAction(cancel)
        
        if let alertView = alertController.view {
            let translatedHeight = alertView.frame.size.height * (1 - Constant.alertControllerScale)
            alertView.transform = CGAffineTransform.identity.scaledBy(x: Constant.alertControllerScale, y: Constant.alertControllerScale).translatedBy(x: 0, y: translatedHeight / 4)
        }
        
            alertController.setValue(attributedAlert(title: "Sort by:"), forKey: "attributedTitle")
        
        present(alertController, animated: true, completion: nil)
    }
    
    func attributedNav(title: String) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "LaoSangamMN", size: 10)!, .foregroundColor: UIColor.gray]
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttributes(attributes, range: NSRange(location: 6, length: 1))
        return attributedString
    }
    
    func attributedAlert(title: String) -> NSAttributedString {
            let font = UIFont(name: "LaoSangamMN", size: 18.0)!
            let attributes: [NSAttributedString.Key : Any] = [.font: font, .foregroundColor: UIColor.gray]
            return NSAttributedString(string: title, attributes: attributes)
     
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardFrame = keyboardSize.cgRectValue
        newTaskView.frame.origin.y = keyboardFrame.origin.y - newTaskViewHeight

    }
    
    @objc func keyboardWillHide(notification: Notification) {
        newTaskView.frame.origin.y = self.view.frame.maxY
        newTaskButton.alpha = 1
    }
    
    
    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return results.count
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TaskCell
        let task = results[indexPath.row]
        cell.taskNameLabel.text = task.name
        cell.taskNoteLabel.text = task.note
        cell.priorityLabel.backgroundColor = {
            switch task.priority {
            case .high:
                return #colorLiteral(red: 1, green: 0.1491314173, blue: 0, alpha: 1)
            case .normal:
                return #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
            case .low:
                return #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
            }
        }()
        if let date = task.date {
            cell.dateLabel.text = dateFormatter(date: date)
            
            cell.priorityLabel.isHidden = Date() > date ? false : true
        }
        
        cell.remindMeImageView.image = task.shouldRemind ? UIImage(named: "rengBell") : UIImage(named: "noiseBell")
        if let image = task.image {
            cell.taskImageView.image = UIImage(data: image)
        }
        
        return cell
    }
    
   
    
    func dateFormatter(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        let formatDate = formatter.string(from: date)
        return formatDate == formatter.string(from: Date()) ? "Today" : formatDate
        
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard filterMode != FilterMode.complete else { return nil}
        let completeAction = UIContextualAction(style: .normal, title: "Complete") { (action, sourceView, completionHandler) in
            RealmData.current.update(self.results[indexPath.row], with: ["isComplete" : true])
            completionHandler(true)
        }
        completeAction.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [completeAction])
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, sourceView, completionHandler) in
            RealmData.current.delete(self.results[indexPath.row])
            completionHandler(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
     // MARK: - Navigation
     
     
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case "detailControllerSegue":
            let destinationVC = segue.destination as! DetailTableViewController
            if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.task = results[indexPath.row]
            }
        default:
            break
        }
    }
    
}

extension AllTasksTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text, !text.isEmpty {
            let task = Task()
            task.name = text
            task.id = Task.idFactory()
            RealmData.current.create(task)
            textField.text = ""
        }
        textField.resignFirstResponder()
        return true
    }
}
