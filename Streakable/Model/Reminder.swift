//
//  Reminder.swift
//  Streakable
//
//  Created by Hiroki Kumamoto on 2023/11/23.
//

import Foundation

struct Reminder: Identifiable {
    var id: String
    var date: Date
    var activity: Activity

    var sectionKey: Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
        return Calendar.current.date(from: components) ?? date
    }

    static var todaySectionKey: Date {
        let components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        return Calendar.current.date(from: components) ?? Date()
    }

    static var userInfoKey: String {
        return "reminder"
    }
}
