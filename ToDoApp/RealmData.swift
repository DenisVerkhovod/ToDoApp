//
//  RealmData.swift
//  ToDoApp
//
//  Created by Denis Verkhovod on 21.08.2018.
//  Copyright © 2018 Denis Verkhovod. All rights reserved.
//

import Foundation
import RealmSwift
import UserNotifications

class RealmData {
    
    private init() {}
    static let current = RealmData()
    
    var realm = try! Realm()
    
    
    
    func results() -> Results<Task> {
        let tasks : Results<Task> = realm.objects(Task.self)
        return tasks
    }
    
    func resultsNotCompleted() -> Results<Task> {
        let tasks = realm.objects(Task.self).filter("isComplete == %@", false).sorted(byKeyPath: "name", ascending: true)
        return tasks
    }
    
    func resultsSortByPriority() -> Results<Task> {
        let tasks = realm.objects(Task.self).filter("isComplete == %@", false).sorted(byKeyPath: "priority", ascending: false)
        return tasks
    }
    
    func resultsSortByDate() -> Results<Task> {
        let tasks = realm.objects(Task.self).filter("isComplete == %@", false).sorted(byKeyPath: "date", ascending: true)
        return tasks
    }
    
    func resultsCompleted() -> Results<Task> {
        let tasks = realm.objects(Task.self).filter("isComplete == %@", true)
        return tasks
    }
    
    func create(_ object: Object) {
        do {
            try realm.write {
                realm.add(object)
            }
        } catch  {
            
        }
    }
    
    func update(_ object: Object, with dictionary: [String : Any]) {
        do {
            try realm.write {
                object.setValuesForKeys(dictionary)
            }
        } catch  {
            
        }
    }
    
    func delete(_ object: Object) {
        if let task = object as? Task {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [String(task.id)])
        }
        do {
            try realm.write {
                realm.delete(object)
            }
        } catch  {
            
        }
    }

    
    
}
