//
//  LocalNotificationService.swift
//  ToDoApp
//
//  Created by Denis Verkhovod on 1/16/19.
//  Copyright © 2019 Denis Verkhovod. All rights reserved.
//

import Foundation
import UserNotifications

class LocalNotificationService {
    
    func scheduleNotification(for task: Task) {
        let content = UNMutableNotificationContent()
        content.title = task.name
        content.body = task.note
        content.sound = UNNotificationSound.default
        
        let okAction = UNNotificationAction(identifier: "ok", title: "Ok", options: [])
        let completeAction = UNNotificationAction(identifier: "complete", title: "Complete task", options: [])
        let deleteAction = UNNotificationAction(identifier: "delete", title: "Delete task", options: .destructive)
        let category = UNNotificationCategory(identifier: "category", actions: [okAction, completeAction, deleteAction], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        content.categoryIdentifier = "category"
        
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.month, .day, .hour, .minute], from: task.date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(identifier: "\(task.id)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
    }
    
    func removeNotification(for task: Task) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(task.id)"])
    }
    
}
