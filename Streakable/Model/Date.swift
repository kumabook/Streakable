//
//  Date.swift
//  Reminder
//
//  Created by Hiroki Kumamoto on 2023/01/01.
//

import Foundation
import UserNotifications

extension TimeInterval {
    var reminderIntervalString: String? {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.hour, .minute]
        return formatter.string(from: self)
    }
}

extension Date {
    var day: Weekday {
        return Weekday.fromInt(Calendar.current.component(.weekday, from: self))
    }

    var year: Int {
        return Calendar.current.component(.year, from: self)
    }

    var month: Int {
        return Calendar.current.component(.month, from: self)
    }

    var hour: Int {
        return Calendar.current.component(.hour, from: self)
    }

    var minute: Int {
        return Calendar.current.component(.minute, from: self)
    }

    var asContributionTimeString: String {
        return DateFormatter.contribution.string(from: self)
    }

    var asActivityDateString: String {
        return DateFormatter.activity.string(from: self)
    }

    var asDateString: String {
        return DateFormatter.date.string(from: self)
    }

    var asDateSectionString: String {
        return DateFormatter.dateSection.string(from: self)
    }

    var asDayString: String {
        return DateFormatter.day.string(from: self)
    }

    var asMonthString: String {
        return DateFormatter.month.string(from: self)
    }

    var asTimeDateComponents: DateComponents {
        return Calendar.current.dateComponents([.hour, .minute], from: self)
    }

    var asDateComponents: DateComponents {
        return Calendar.current.dateComponents(in: TimeZone.current, from: self)
    }

    var asNotificationTrigger: UNCalendarNotificationTrigger {
        var components = asDateComponents
        components.nanosecond = nil
        components.second = nil
        components.quarter = nil // This line is needed. It seems to be bug of UNCalendarNotificationTrigger
        return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
    }

    func minutesAgo(_ v: Int) -> Date {
        return Calendar.current.date(byAdding: DateComponents(minute: -v), to: self)!
    }

    func minutesAfter(_ v: Int) -> Date {
        return Calendar.current.date(byAdding: DateComponents(minute: v), to: self)!
    }
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    var endOfDay: Date {
        var c = DateComponents()
        c.day = 1
        c.second = -1
        return Calendar.current.date(byAdding: c, to: startOfDay)!
    }
    var tomorrow: Date {
        var c = DateComponents()
        c.day = 1
        return Calendar.current.date(byAdding: c, to: self)!
    }
    func daysLater(_ n: Int) -> Date {
        var c = DateComponents()
        c.day = n
        return Calendar.current.date(byAdding: c, to: self)!
    }
    var yesterday: Date {
        var c = DateComponents()
        c.day = -1
        return Calendar.current.date(byAdding: c, to: self)!
    }
    func daysAgo(_ n: Int) -> Date {
        var c = DateComponents()
        c.day = -n
        return Calendar.current.date(byAdding: c, to: self)!
    }
    var nextWeek: Date {
        var c = DateComponents()
        c.day = 7
        return Calendar.current.date(byAdding: c, to: self)!
    }
    var prevWeek: Date {
        var c = DateComponents()
        c.day = -7
        return Calendar.current.date(byAdding: c, to: self)!
    }
    var nextMonth: Date {
        var c = DateComponents()
        c.month = 1
        return Calendar.current.date(byAdding: c, to: self)!
    }
    var prevMonth: Date {
        var c = DateComponents()
        c.month = -1
        return Calendar.current.date(byAdding: c, to: self)!
    }
    var startOfYear: Date? {
        let year = Calendar.current.component(.year, from: self)
        return Calendar.current.date(from: DateComponents(year: year, month: 1, day: 1))
    }
    func interval(from d: Date) -> Double {
        return timeIntervalSince1970 - d.timeIntervalSince1970
    }
    func interval(to d: Date) -> TimeInterval {
        return d.timeIntervalSince1970 - timeIntervalSince1970
    }
}

extension DateFormatter {
    static let contribution: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    static let activity: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }()
    static let date: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        return formatter
    }()
    static let dateSection: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .none
        formatter.doesRelativeDateFormatting = true
        return formatter
    }()
    static let month: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("M")
        return formatter
    }()
    static let day: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("d")
        return formatter
    }()
}
