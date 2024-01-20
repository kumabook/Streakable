//
//  Streak.swift
//  Streakable
//
//  Created by Hiroki Kumamoto on 2024/01/04.
//

import Foundation
import CloudKit

struct Streak {
    var contribution: Int = 0
    var score: Int64 = 0
    var current: Int = 0
    var longest: Int = 0
    var prevDueDate: Date? = nil
    var dueDate: Date? = nil

    mutating func append(_ score: Int64, _ date: Date, _ activity: Activity) {
        self.contribution += 1
        self.score += score
        guard
            let due = dueDate,
            let prev = prevDueDate
        else {
            prevDueDate = date.endOfDay
            dueDate = activity.calcNextRemindsAt(date).endOfDay
            current = 1
            longest = 1
            return
        }
        if prev <= date && date <= due {
            current += 1
            longest = max(current, longest)
            prevDueDate = due
            dueDate = activity.calcNextRemindsAt(due).endOfDay
        } else {
            current = 1
            prevDueDate = date.endOfDay
            dueDate = activity.calcNextRemindsAt(date).endOfDay
        }
    }
}
