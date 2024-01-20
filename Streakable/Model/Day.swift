//
//  Day.swift
//  Streakable
//
//  Created by Hiroki Kumamoto on 2024/01/10.
//

import Foundation

struct Day: MultiSelectable, Identifiable {
    var id: Int { return date }
    var date: Int

    var title: String {
        let year = Calendar.current.component(.year, from: Date())
        guard let date = Calendar.current.date(from: DateComponents(year: year, month: 1, day: date)) else {
            return "\(date)"
        }
        return date.asDayString
    }

    var shortTitle: String {
        return title
    }

    static var allCases: [Day] = (1...31).map { Day(date: $0) }
}
