//
//  UNNotificationRequest.swift
//  Streakable
//
//  Created by Hiroki Kumamoto on 2024/01/02.
//

import Foundation
import UserNotifications

extension UNNotificationRequest {
    var activityId: UUID? {
        guard let id = content.userInfo[Activity.userInfoKey] as? String else { return nil }
        return UUID(uuidString: id)
    }
}

extension NSNotification {
    static let reminder = NSNotification.Name("reminder")
}

extension Notification {
    var reminder: Reminder? {
        return userInfo?[Reminder.userInfoKey] as? Reminder
    }
}
