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
    
    var tap = UITapGestureRecognizer()
    
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
    
    //MARK: - View's lifecycle methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        addNewTaskButton()
        addNewTaskView()
        
        filterMode = FilterMode.descending
        
        setObserveRealm()
        setTitleButton()
        
        tap = UITapGestureRecognizer(target: self, action: #selector(cancelEditing))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    //MARK: - Set Realm Notifications
    
    func setObserveRealm() {
        notificationToken = results.observe { [weak self] (changes: RealmCollectionChange) in
            guard let tableView = self?.tableView else { return }
            switch changes {
            case .initial:
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                tableView.beginUpdates()
                tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0)}),
                                     with: .automatic)
                tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                                     with: .automatic)
                tableView.endUpdates()
            case .error(let error):
                fatalError("\(error)")
            }
        }
    }
    
    //MARK: -  NewTask button and newTask textField
    
    private func addNewTaskButton () {
        newTaskButton = UIButton()
        newTaskButton.setImage(UIImage(named: "plusButton"), for: .normal)
        tableView.addSubview(newTaskButton)
        newTaskButton.addTarget(self, action: #selector(addButtonPressed(sender:)), for: .touchUpInside)
        
        newTaskButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            newTaskButton.heightAnchor.constraint(equalToConstant: Constant.newTaskButtonHeight),
            newTaskButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            newTaskButton.bottomAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.bottomAnchor, constant: -Constant.newTaskButtonOffset)
            ])
    }
    
    @objc private func addButtonPressed(sender: UIButton) {
        newTaskButton.alpha = 0
        newTaskTextField.becomeFirstResponder()
    }
    
    private func addNewTaskView() {
        
        newTaskView = UIView(frame: CGRect(x: 0, y: self.view.frame.maxY + newTaskViewHeight, width: view.bounds.size.width, height: newTaskViewHeight))
        newTaskView.backgroundColor = UIColor.clear
        newTaskView.layer.cornerRadius = Constant.cornerRadius
        newTaskView.clipsToBounds = true
        self.navigationController?.view.addSubview(newTaskView)
        
        let imageView = UIImageView(image: UIImage(named: "plusButton"))
        let size: CGFloat = newTaskViewHeight - 10
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
        newTaskTextField.backgroundColor = .white
        newTaskTextField.borderStyle = .roundedRect
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
    
    // MARK: - Alert controller for navigation's bar title
    
    private func setTitleButton() {
        let button = UIButton(type: UIButton.ButtonType.system)
        button.setAttributedTitle(navBarAttributed(title: "Tasks ∨"), for: .normal)
        button.addTarget(self, action: #selector(titleButtonPressed(sender:)), for: .touchUpInside)
        self.navigationItem.titleView = button
    }
    
    @objc private func titleButtonPressed(sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let azSort = UIAlertAction(title: "A - Z", style: .default) { _ in
            self.filterMode = .descending
            self.setObserveRealm()
        }
        let prioritySort = UIAlertAction(title: "Priority", style: .default) { _ in
            self.filterMode = .priority
            self.setObserveRealm()
        }
        let dateSort = UIAlertAction(title: "Date", style: .default) { _ in
            self.filterMode = .date
            self.setObserveRealm()
        }
        let completeSort = UIAlertAction(title: "Completed", style: .default) { _ in
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
        
        alertController.setValue(alertControllerAttributed(title: "Sort by:"), forKey: "attributedTitle")
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func navBarAttributed(title: String) -> NSMutableAttributedString {
        let attributes: [NSAttributedString.Key: Any] = [.font: UIFont(name: "LaoSangamMN", size: 10)!, .foregroundColor: UIColor.gray]
        let attributedString = NSMutableAttributedString(string: title)
        attributedString.addAttributes(attributes, range: NSRange(location: 6, length: 1))
        return attributedString
    }
    
    private func alertControllerAttributed(title: String) -> NSAttributedString {
        let font = UIFont(name: "LaoSangamMN", size: 18.0)!
        let attributes: [NSAttributedString.Key : Any] = [.font: font, .foregroundColor: UIColor.gray]
        return NSAttributedString(string: title, attributes: attributes)
        
    }
    
    @objc private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        
        let keyboardFrame = keyboardSize.cgRectValue
        newTaskView.frame.origin.y = keyboardFrame.origin.y - newTaskViewHeight
        
    }
    
    @objc private func keyboardWillHide(notification: Notification) {
        newTaskView.frame.origin.y = self.view.frame.maxY
        newTaskButton.alpha = 1
    }
    
    @objc private func cancelEditing() {
        newTaskTextField.resignFirstResponder()
    }
    
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TaskCell
        let task = results[indexPath.row]
        cell.taskNameLabel.text = task.name
        cell.taskNoteLabel.text = task.note
        cell.priorityLabel.backgroundColor = {
            switch task.priority {
            case 0:
                return UIColor.green
            case 2:
                return UIColor.red
            default:
                return UIColor.yellow
            }
        }()
        let date = task.date 
        cell.dateLabel.text = dateFormatter(date: date)
        cell.outOfDateLabel.isHidden = Date() > date ? false : true
        cell.remindMeImageView.image = task.shouldRemind ? UIImage(named: "ringBell") : UIImage(named: "muteBell")
        if let image = task.image {
            cell.taskImageView.image = UIImage(data: image)
        }
        
        return cell
    }
    
    private func dateFormatter(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        let formatDate = formatter.string(from: date)
        return formatDate == formatter.string(from: Date()) ? "Today" : formatDate
    }
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard filterMode != FilterMode.complete else { return nil}
        let completeAction = UIContextualAction(style: .normal, title: "Complete") { (_, _, completionHandler) in
            RealmData.current.update(self.results[indexPath.row], with: ["isComplete" : true])
            completionHandler(true)
        }
        completeAction.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        
        return UISwipeActionsConfiguration(actions: [completeAction])
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
            RealmData.current.delete(self.results[indexPath.row])
            completionHandler(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailControllerSegue" {
            let destinationVC = segue.destination as! DetailTableViewController
            if let indexPath = tableView.indexPathForSelectedRow {
                destinationVC.task = results[indexPath.row]
            }
        }
    }
}


//MARK: - Extensions

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

extension AllTasksTableViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard gestureRecognizer == tap else { return true }
        if newTaskTextField.isFirstResponder {
            return true
        } else {
            return false
        }
    }
}
