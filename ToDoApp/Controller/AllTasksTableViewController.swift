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
    var addNewTaskButton: UIButton!
    var newTaskView: UIView!
    var newTaskTextField: UITextField!
    
    var newTaskViewHeight: CGFloat = 40
    var newTaskViewOffset: CGFloat {
        return newTaskViewHeight + 10
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
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        addNewTaskView()
        addPlusButton()
        
        
        filterMode = FilterMode.descending
        
        setObserveRealm()
        setTitleButton()
        
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
    
    func addPlusButton () {
        addNewTaskButton = UIButton()
        
        addNewTaskButton.setImage(UIImage(named: "plusButton"), for: .normal)
        tableView.addSubview(addNewTaskButton)
        addNewTaskButton.addTarget(self, action: #selector(addButtonPressed(sender:)), for: .touchUpInside)

        addNewTaskButton.translatesAutoresizingMaskIntoConstraints = false
        addNewTaskButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        NSLayoutConstraint.activate([
            addNewTaskButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            addNewTaskButton.bottomAnchor.constraint(equalTo: newTaskView.topAnchor, constant: -20)
            ])
    }
    
    @objc func addButtonPressed(sender: UIButton) {
        
        performSegue(withIdentifier: "NewTaskTableViewController", sender: self)

    }
    
    func addNewTaskView() {
        
        newTaskView = UIView()
        newTaskView.backgroundColor = UIColor.white
        newTaskView.layer.cornerRadius = 5.0
        newTaskView.clipsToBounds = true
        tableView.addSubview(newTaskView)
        
        newTaskView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            newTaskView.heightAnchor.constraint(equalToConstant: newTaskViewHeight),
            newTaskView.widthAnchor.constraint(equalToConstant: self.tableView.bounds.width - 30),
            newTaskView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            newTaskView.topAnchor.constraint(equalTo: tableView.safeAreaLayoutGuide.bottomAnchor, constant: -newTaskViewOffset)
            ])
       
        newTaskTextField = UITextField()
        newTaskTextField.backgroundColor = .green
        newTaskView.addSubview(newTaskTextField)
        
        newTaskTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            newTaskTextField.bottomAnchor.constraint(equalTo: newTaskView.bottomAnchor, constant: -5),
            newTaskTextField.topAnchor.constraint(equalTo: newTaskView.topAnchor, constant: 5),
            newTaskTextField.leadingAnchor.constraint(equalTo: newTaskView.leadingAnchor, constant: 5),
            newTaskTextField.trailingAnchor.constraint(equalTo: newTaskView.trailingAnchor, constant: -5)
            ])
    }
    
    func newTaskAnimator() {
        
        
        
    }
    
    
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
    
    
    // MARK: - Table view data source
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return results.count
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TaskCell
        let task = results[indexPath.row]
        cell.taskNameLabel.text = task.name
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
