//
//  File.swift
//  ToDoApp
//
//  Created by Denis Verkhovod on 15.08.2018.
//  Copyright © 2018 Denis Verkhovod. All rights reserved.
//

import Foundation
import RealmSwift
import Realm
import UserNotifications



class Task: Object  {
    
    @objc dynamic var name : String = ""
    @objc dynamic var note : String = ""
    @objc dynamic var priority : Int = 1
    @objc dynamic var date : Date = Date()
    @objc dynamic var image : Data? = nil
    @objc dynamic var shouldRemind : Bool = false
    @objc dynamic var isComplete : Bool = false
    @objc dynamic var isOverdue : Bool = false
    @objc dynamic var id = -1
    
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    static func idFactory() -> Int {
        let taskWithMaxId = RealmData.current.results().max { $0.id < $1.id }
        if let max = taskWithMaxId?.id {
            return max + 1
        } else {
            return 1
        }
    }
    
    func scheduleNotification() {
        //        if shouldRemind && date > Date() {
        print("Notif is set")
        let content = UNMutableNotificationContent()
        content.title = name
        content.body = note
        content.sound = UNNotificationSound.default
        
        let okAction = UNNotificationAction(identifier: "ok", title: "Ok", options: [])
        let completeAction = UNNotificationAction(identifier: "complete", title: "Complete task", options: [])
        let deleteAction = UNNotificationAction(identifier: "delete", title: "Delete task", options: .destructive)
        let category = UNNotificationCategory(identifier: "category", actions: [okAction, completeAction, deleteAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        content.categoryIdentifier = "category"
        
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.month, .day, .hour, .minute], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: "\(id)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        //        }
    }

//    init(name: String, priority: Priority, date: Date?, shouldRemind: Bool?, isOverdue: Bool?) {
//        self.name = name
//        self.priority = priority
//        self.date = date
//        self.shouldRemind = shouldRemind
//        self.isOverdue = isOverdue
//    }
}
