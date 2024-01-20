//
//  Recurrence.swift
//  Streakable
//
//  Created by Hiroki Kumamoto on 2024/01/10.
//

import Foundation

enum Recurrence: String, CaseIterable, Identifiable {
    case daily
    case everyOtherDay = "every_other_day"
    case everySecondDay = "every_second_day"
    case weekly
    case monthly

    var id: String { return rawValue }

    var title: String {
        return NSLocalizedString("Recurrence.\(rawValue)", comment: rawValue)
    }
}
