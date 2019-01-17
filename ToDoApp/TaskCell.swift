//
//  TaskCell.swift
//  ToDoApp
//
//  Created by Denis Verkhovod on 15.08.2018.
//  Copyright © 2018 Denis Verkhovod. All rights reserved.
//

import UIKit

class TaskCell: UITableViewCell {
    
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var taskNameLabel: UILabel!
    @IBOutlet weak var taskNoteLabel: UILabel!
    @IBOutlet weak var outOfDateLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var remindMeImageView: UIImageView!
    @IBOutlet weak var taskImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
