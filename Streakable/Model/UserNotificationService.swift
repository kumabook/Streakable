//
//  UserNotificationService.swift
//  Streakable
//
//  Created by Hiroki Kumamoto on 2023/11/18.
//

import Foundation
import UIKit
import UserNotifications
import CoreData

open class UserNotificationService: NSObject {
    public private(set) weak var app: UIApplication?
    public private(set) weak var center: UNUserNotificationCenter?
    
    init(app: UIApplication, center: UNUserNotificationCenter) {
        self.app = app
        self.center = center
    }
    
    @discardableResult
    public func start() -> UserNotificationService {
        center?.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.appDidFinishLaunching), name: UIApplication.didFinishLaunchingNotification, object: nil)
        
        return self
    }
    
    public func stop() {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func resetNotifications(activities: [Activity], context: NSManagedObjectContext) async throws {
        let options: UNAuthorizationOptions = [.badge, .sound, .alert]
        let center = UNUserNotificationCenter.current()

        guard try await center.requestAuthorization(options: options) else { return }
        center.removeAllDeliveredNotifications()
        center.removePendingNotificationRequests(withIdentifiers: activities.map { $0.identifier })
        for activity in activities {
            for req in activity.asReminderNotificationRequests {
                try await center.add(req)
            }
        }
    }

    public func addNotification(activity: Activity, context: NSManagedObjectContext) async throws {
        let center = UNUserNotificationCenter.current()
        for req in activity.asReminderNotificationRequests {
            try await center.add(req)
        }
    }

    public func addNotification(at date: Date, activity: Activity, context: NSManagedObjectContext) async throws {
        guard let c = center else { return }
        let options: UNAuthorizationOptions = [.badge, .sound, .alert]
        let granted = try await c.requestAuthorization(options: options)
        guard granted else { return }
        c.removeAllDeliveredNotifications()
        let pendingIdentifiers = await c.pendingNotificationRequests().filter { $0.activityId == activity.id }.map { $0.identifier }
        c.removePendingNotificationRequests(withIdentifiers: pendingIdentifiers)

        if let req = activity.toReminderNotificationRequest(at: date) {
            try await c.add(req)
        }
    }

    public func removeNotification(activity: Activity) async {
        guard let c = center else { return }
        let pendingIdentifiers = await c.pendingNotificationRequests().filter { $0.activityId == activity.id }.map { $0.identifier }
        c.removePendingNotificationRequests(withIdentifiers: pendingIdentifiers)
    }

    public func removePendingNotificationRequests(withIdentifiers identifiers: [String]) {
        guard let c = center else { return }
        c.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
}

extension UserNotificationService: UNUserNotificationCenterDelegate {
    public func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        print("[Notification] willPresent")
        print("[Notification] \(notification.request.identifier)")
        print("[Notification] \(notification.request.content.userInfo)")
        if let activityId = notification.request.activityId {
            do {
                if let task: Activity = try PersistentContainer.shared.findEntity(byId: activityId) {
                    try await addNotification(activity: task, context: PersistentContainer.shared.viewContext)
                } else {
                    print("[Notification] Task isEmpty!")
                }
            } catch {
                print("[Notification] error: \(error)")
            }
        }
        return [.list, .banner, .sound, .badge]
    }

    public func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        print("[Notification] didReceive")
        let req = response.notification.request
        guard let activityId = req.activityId else {
            print("[Notification] activity is empty!")
            return
        }
        do {
            try await Task.sleep(for: .seconds(1.0))
            try await MainActor.run {
                guard let activity: Activity = try PersistentContainer.shared.findEntity(byId: activityId) else { return }
                let reminder = Reminder(
                    id: req.identifier,
                    date: response.notification.date,
                    activity: activity
                )
                NotificationCenter.default.post(name: NSNotification.reminder, object: reminder, userInfo: [Reminder.userInfoKey:reminder])
            }
        } catch {
            
        }
    }

    @objc public func appDidFinishLaunching() {
        app?.applicationIconBadgeNumber = 0
    }

    @objc public func appWillEnterForeground() {
        app?.applicationIconBadgeNumber = 0
    }
}
