//
//  File.swift
//  Streakable
//
//  Created by Hiroki Kumamoto on 2024/01/05.
//

import Foundation

struct ContribCalendarRow: Hashable {
    var day: Weekday
    var cells: [ContribCalendarCell]
}

struct ContribCalendarHeader: Hashable {
    var title: String
    var length: Int
}

struct ContribCalendarCell: Hashable {
    var cellType: ContribCalendarCellType
    var score: Int64 = 0
    var date: Date

    mutating func add(_ score: Int64) {
        self.score += score
        self.score = min(10, self.score)
    }
}

enum ContribCalendarCellType: Hashable {
    case blank
    case level
    case today
}

struct ContribCalendar {

    var year: Int
    var rows: [ContribCalendarRow]

    init(date: Date) {
        year = date.year
        rows = []
        
        for day in Weekday.values {
            rows.append(ContribCalendarRow(day: day, cells: []))
        }
        for weekOfYear in 1...53 {
            var components = DateComponents()
            components.year = year
            components.weekOfYear = weekOfYear
            components.yearForWeekOfYear = year
            for (i, day) in Weekday.values.enumerated() {
                components.weekday = day.weekday
                guard let d = Weekday.calendar.date(from: components) else { break }
                if d.year == year {
                    if Calendar.current.isDateInToday(d) {
                        rows[i].cells.append(ContribCalendarCell(cellType: .today, date: d))
                    } else {
                        rows[i].cells.append(ContribCalendarCell(cellType: .level, date: d))
                    }
                } else {
                    rows[i].cells.append(ContribCalendarCell(cellType: .blank, date: d))
                }
            }
        }
    }

    mutating func append(_ score: Int64, _ date: Date, _ activity: Activity) {
        guard date.year == year else { return }
        let weekOfYear = Weekday.calendar.component(.weekOfYear, from: date)
        rows[date.day.index].cells[weekOfYear - 1].add(score)
    }

    var today: ContribCalendarCell? {
        let date = Date()
        guard date.year == year else { return nil }
        let weekOfYear = Weekday.calendar.component(.weekOfYear, from: date)
        return rows[date.day.index].cells[weekOfYear - 1]
    }

    var headers: [ContribCalendarHeader] {
        var months: [String] = []
        for weekOfYear in 1...53 {
            var components = DateComponents()
            components.year = year
            components.weekOfYear = weekOfYear
            components.yearForWeekOfYear = year
            components.weekday = Weekday.values.last?.weekday
            guard let d = Weekday.calendar.date(from: components) else { break }
            
            months.append(d.asMonthString)
        }
        return months.unique.map { m in
            ContribCalendarHeader(title: m, length: months.filter { $0 == m }.count )
        }
    }
}
