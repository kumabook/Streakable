//
//  Activity.swift
//  Streakable
//
//  Created by Hiroki Kumamoto on 2023/01/01.
//

import Foundation
import CoreData
import UserNotifications

enum RecurrenceType: String {
    case daily
    case everyOtherDay = "every_other_day"
    case everySecondDay = "every_second_day"
    case weekly
    case monthly
}

extension Activity {
    static var userInfoKey: String {
        return "activityId"
    }
    static func preview(context: NSManagedObjectContext) -> Activity {
        let newItem = Activity(context: context)
        newItem.id = UUID()
        newItem.title = "Preview"
        newItem.remindsAt = Date()
        newItem.recurrence = "daily"
        newItem.snoozeInterval = 0
        newItem.createdAt = Date()
        newItem.updatedAt = Date()
        return newItem
    }
    static func recurrenceString(_ value: String) -> String {
        guard !value.isEmpty else { return NSLocalizedString("None", comment: "None") }
        return NSLocalizedString("Recurrence.\(value)", comment: value)
    }
    var identifier: String {
        return id?.uuidString ?? "unknown"
    }
    var recurrenceType: RecurrenceType? {
        return recurrence.flatMap { RecurrenceType(rawValue: $0) }
    }
    var nextRemindsAt: Date? {
        guard let d = remindsAt else { return nil }
        return calcNextRemindsAt(d)
    }
    var previousRemindsAt: Date? {
        guard let d = remindsAt else { return nil }
        return calcNextRemindsAt(d)
    }
    var snoozeEndDate: Date? {
        return nextRemindsAt ?? remindsAt
    }
    func calcNextRemindsAt(_ date: Date) -> Date {
        guard
            let hour = remindsAt?.hour,
            let minute = remindsAt?.minute,
            let d = Calendar.current.date(bySettingHour: hour, minute: minute, second: 0, of: date)
        else { return date }
        switch RecurrenceType(rawValue: recurrence ?? "daily") {
        case .daily:
            let newDate = d
            if newDate > date {
                return d
            }
            return d.tomorrow
        case .everyOtherDay:
            let newDate = d
            if newDate > date {
                return d
            }
            return d.daysLater(2)
        case .everySecondDay:
            let newDate = d
            if newDate > date {
                return d
            }
            return d.daysLater(3)
        case .weekly:
            for i in 1...6 {
                let d2 = d.daysLater(i)
                if weekDays.contains(d2.day) {
                    return d2
                }
            }
            return d.daysLater(7)
        case .monthly:
            let components = Calendar.current.dateComponents(in: .current, from: d)
            for day in days {
                guard let newDate = Calendar.current.date(from: DateComponents(
                    year: components.year,
                    month: components.month,
                    day: day.date,
                    hour: d.hour,
                    minute: d.minute
                )) else { continue }
                if newDate > date {
                    return newDate
                }
            }
            for day in days {
                guard let newDate = Calendar.current.date(from: DateComponents(
                    year: components.year,
                    month: components.month.map { $0 + 1 },
                    day: day.date,
                    hour: d.hour,
                    minute: d.minute
                )) else { continue }
                if newDate > date {
                    return newDate
                }
            }
            return d.nextMonth
        default:
            return d
        }
    }
    func calcPrevRemindsAt(_ d: Date) -> Date {
        switch RecurrenceType(rawValue: recurrence ?? "daily") {
        case .daily:
            return d.yesterday
        case .everyOtherDay:
            return d.daysAgo(2)
        case .everySecondDay:
            return d.daysAgo(3)
        case .weekly:
            for i in 1...6 {
                let d2 = d.daysAgo(i)
                if weekDays.contains(d2.day) {
                    return d2
                }
            }
            return d.daysAgo(7)
        case .monthly:
            let components = Calendar.current.dateComponents(in: .current, from: d)
            for day in days.reversed() {
                guard let date = Calendar.current.date(from: DateComponents(
                    year: components.year,
                    month: components.month,
                    day: day.date,
                    hour: d.hour,
                    minute: d.minute
                )) else { continue }
                if date < d {
                    return date
                }
            }
            for day in days.reversed() {
                guard let date = Calendar.current.date(from: DateComponents(
                    year: components.year,
                    month: components.month.map { $0 - 1 },
                    day: day.date,
                    hour: d.hour,
                    minute: d.minute
                )) else { continue }
                if date < d {
                    return date
                }
            }
            return d.prevMonth
        default:
            return d
        }
    }

    var weekDays: [Weekday] {
        guard let detail = recurrenceDetail else { return [] }
        let values = detail.split(separator: ",").compactMap { Weekday(rawValue: String($0)) }
        return Weekday.allCases.filter { d in values.contains(where: { $0.id == d.id }) }
    }

    var days: [Day] {
        guard let detail = recurrenceDetail else { return [] }
        let values = detail.split(separator: ",").compactMap { s in Int(s).flatMap { Day(date: $0) }}
        return Day.allCases.filter { d in values.contains(where: { $0.id == d.id }) }
    }

    var reccurenceText: String? {
        guard let r = Recurrence(rawValue: recurrence ?? "") else {
            return nil
        }
        switch r {
        case .weekly:
            return weekDays.map { $0.shortTitle }.joined(separator: ",")
        case .monthly:
            return days.map { $0.shortTitle }.joined(separator: ",")
        default:
            return Self.recurrenceString(r.rawValue)
        }
    }

    func resetReminder(date: Date, context: NSManagedObjectContext) throws {
        remindsAt = calcNextRemindsAt(date)
        try context.save()
    }

    func updateReminderIfNeeded(_ date: Date, context: NSManagedObjectContext) throws {
        guard let d = remindsAt else { return }
        let prev = calcPrevRemindsAt(d).endOfDay
        if prev <= date && date <= d.endOfDay {
            if let n = nextRemindsAt {
                remindsAt = n
                print("[UI] Update reminder at \(n)")
                try context.save()
            }
        }
    }

    func snoozeDate() -> Date? {
        guard let date = remindsAt else { return nil }
        guard let se = snoozeEndDate else { return nil }

        var d = date

        repeat {
            defer {
                d = d.minutesAfter(Int(snoozeInterval))
                if date <= d && d < date.minutesAfter(Int(snoozeInterval))  { d = date }
            }
            let trigger = d.asNotificationTrigger
            guard trigger.nextTriggerDate() != nil else { continue }
            return d
        } while d < se
        return nil
    }

    func toReminderNotificationRequest(at date: Date) -> UNNotificationRequest? {
        let content = UNMutableNotificationContent()
        content.title = ""
        content.subtitle = ""
        content.body = title ?? "Streakable alert"
        content.badge = 1
        content.sound = .default
        content.userInfo[Self.userInfoKey] = id?.uuidString

        return UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: date.asNotificationTrigger
        )
    }
}
