//
//  ReminderListView.swift
//  Streakable
//
//  Created by Hiroki Kumamoto on 2022/12/31.
//

import SwiftUI

struct ReminderListView: View {
    @EnvironmentObject private var appDelegate: AppDelegate
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Activity.priority, ascending: false)],
        animation: .default)
    private var activities: FetchedResults<Activity>
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Contribution.date, ascending: false)],
        predicate: NSCompoundPredicate(andPredicateWithSubpredicates: [
            NSPredicate(format: "date >= %@", Date().startOfDay as CVarArg),
            NSPredicate(format: "date <= %@", Date().endOfDay as CVarArg)
        ]),
        animation: .default)
    private var todayContributions: FetchedResults<Contribution>
    @State private var actionItem: Reminder? = nil
    @State var items: [Reminder] = []
    @State private var sections: [Date] = []
    @State private var itemsBySection: [Date?: [Reminder]] = [:]
    @State private var confirmingReset: Bool = false

    var body: some View {
        List {
            if items.isEmpty {
                Text("Reminder.EmptyMessage")
            } else {
                ForEach(sections, id: \.self) { d in
                    Section {
                        if (itemsBySection[d] ?? []).isEmpty {
                            if todayContributions.count > 0 {
                                Text("Reminder.CompleteMessage")
                            } else {
                                Text("Reminder.EmptyTodayMessage")
                            }
                        } else {
                            ForEach(itemsBySection[d] ?? []) { item in
                                DisclosureIndicatorRow() {
                                    actionItem = item
                                } label: {
                                    ReminderItemView(reminder: item)
                                }
                            }
                        }
                    } header: {
                        Text(d.asDateSectionString)
                            .font(.title2)
                    }
                }
            }
        }.sheet(item: $actionItem, onDismiss: {
            Task {
                await refresh()
            }
        }, content: {
            ContributionEditView(activity: $0.activity, activities: Array(activities), action: .create($0))
        }).toolbar {
            ToolbarItem {
                Button(action: { confirmingReset = true }) {
                    Label("Reminder.Reset", systemImage: "arrow.2.squarepath")
                }
            }
        }.confirmationDialog("Reminder.Reset.ConfirmTitle", isPresented: $confirmingReset, titleVisibility: .hidden) {
            Button("Reminder.Reset.ConfirmButton", role: .destructive) {
                Task {
                    await reset()
                }
            }
            Button("Cancel", role: .cancel, action: {})
        } message: {
            Text("Reminder.Reset.ConfirmMessage")
        }.task {
            await refresh()
        }.refreshable {
            await refresh()
        }.onReceive(NotificationCenter.default.publisher(for: NSNotification.reminder)) {
            actionItem = $0.reminder
        }
        .navigationTitle("Reminder")
    }

    func reset() async {
        do {
            for activity in activities {
                if todayContributions.filter({ $0.activityId == activity.id }).isEmpty {
                    try activity.resetReminder(date: Date().startOfDay, context: viewContext)
                }
            }
            try await appDelegate.notification?.resetNotifications(activities: Array(activities), context: viewContext)
            await refresh()
        } catch {
            print("[UI][Error] \(error)")
        }
    }
    
    func refresh() async {
        do {
            guard let center = self.appDelegate.notification?.center else { return }
            let notifications = await center.pendingNotificationRequests()
            try await appDelegate.notification?.resetNotifications(
                activities: activities.filter { activity in
                    if
                        let n = notifications.first(where: { $0.activityId == activity.id }),
                        let t = n.trigger as? UNCalendarNotificationTrigger
                    {
                        return t.nextTriggerDate() == nil
                    }
                    return true
                },
                context: viewContext
            )
            items = await center.pendingNotificationRequests().compactMap {
                guard
                    let t = $0.trigger as? UNCalendarNotificationTrigger,
                    let d = t.nextTriggerDate(),
                    let activityId = $0.activityId,
                    let activity: Activity = activities.first(where: { a in a.id == activityId })
                else {
                    return nil
                }
                return Reminder(
                    id: $0.identifier,
                    date: d,
                    activity: activity
                )
            }
            sections = items.map { $0.sectionKey }
            sections.append(Reminder.todaySectionKey)
            sections = sections.unique.sorted()
            itemsBySection = Dictionary(grouping: items, by: { $0.sectionKey })
        } catch {
            print("[UI][Error] \(error)")
        }
    }
}


struct ReminderListView_Previews: PreviewProvider {
    static var previews: some View {
        ReminderListView()
            .environment(\.managedObjectContext, PersistentContainer.shared.viewContext)
    }
}

