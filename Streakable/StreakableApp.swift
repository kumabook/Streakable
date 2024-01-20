//
//  StreakableApp.swift
//  Streakable
//
//  Created by Hiroki Kumamoto on 2022/12/30.
//

import SwiftUI
import UIKit

@main
struct StreakableApp: App {
    @UIApplicationDelegateAdaptor (AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, PersistentContainer.shared.viewContext)
                .environmentObject(appDelegate)
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, ObservableObject {
    @Published var notification: UserNotificationService?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        application.registerForRemoteNotifications()
        notification = UserNotificationService(app: application, center: UNUserNotificationCenter.current())
        notification?.start()
        return true
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    }
}
