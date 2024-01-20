//
//  Day.swift
//  Streakable
//
//  Created by Hiroki Kumamoto on 2023/06/08.
//

import Foundation

enum Weekday: String, MultiSelectable, CaseIterable {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday

    var id: String {
        return rawValue
    }
    
    var title: String {
        return NSLocalizedString("Weekday.\(rawValue)", comment: rawValue)
    }
    
    var shortTitle: String {
        return NSLocalizedString("WeekdayShort.\(rawValue)", comment: rawValue)
    }

    static var values: [Weekday] {
        return allCases.sorted { d1, d2 in d1.index < d2.index }
    }

    static func fromInt(_ n: Int) -> Weekday {
        switch n {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        case 7: return .saturday
        default: return .sunday
        }
    }

    var weekday: Int {
        switch self {
        case .monday: 2
        case .tuesday: 3
        case .wednesday: 4
        case .thursday: 5
        case .friday: 6
        case .saturday: 7
        case .sunday: 1
        }
    }

    var index: Int {
        switch self {
        case .monday: 0
        case .tuesday: 1
        case .wednesday: 2
        case .thursday: 3
        case .friday: 4
        case .saturday: 5
        case .sunday: 6
        }
    }

    static var calendar: Calendar = {
        var calendar = Calendar.current
        if let weekday = Weekday.values.first?.weekday {
            calendar.firstWeekday = weekday
        }
        return calendar
    }()
}
