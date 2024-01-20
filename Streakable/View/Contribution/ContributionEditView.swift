//
//  ContributionEditView.swift
//  Streakable
//
//  Created by Hiroki Kumamoto on 2024/01/04.
//

import SwiftUI

struct ContributionEditView: View {
    enum Action {
        case create(Reminder)
        case update(Contribution)
    }
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var appDelegate: AppDelegate

    @State private var activity: Activity
    @State private var score: Int64 = 5
    @State private var note: String = ""
    @State private var date: Date = Date()
    var activities: [Activity] = []

    var action: Action

    init(activity: Activity, activities: [Activity], action: Action) {
        self.action = action
        self.activities = activities
        _activity = State(initialValue: activity)
        switch action {
        case .create:
            _date = State(initialValue:Date())
        case .update(let contribution):
            _note = State(initialValue: contribution.note ?? "")
            _date = State(initialValue: contribution.date ?? Date())
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: .zero) {
                List {
                    Section {
                        Picker("Activity", selection: $activity) {
                            ForEach(activities, id: \.self) {
                                Text($0.title ?? "No title").tag($0)
                            }
                        }
                    }
                    Section {
                        Picker("Score", selection: $score) {
                            ForEach(1...10, id: \.self) {
                                Text("\($0)").tag(Int64($0))
                            }
                        }
                    }
                    Section {
                        DatePicker("Date", selection: $date)
                    }
                    Section {
                        PlaceHolderTextEditor(text: $note, placeholder: "Note")
                            .font(.callout)
                    }
                }
                switch action {
                case .create(let reminder):
                    VStack {
                        Button(action: {
                            Task {
                                await createContribution(reminder)
                                dismiss()
                            }
                        }) {
                            Text("Contribution.Create")
                                .padding()
                                .frame(maxWidth: .infinity)
                        }.foregroundColor(Color.white)
                            .background(Color.accentColor)
                            .cornerRadius(12, antialiased: true)

                        if Calendar.current.isDateInToday(reminder.date) {
                            Button(action: {
                                Task {
                                    await remindLater(reminder)
                                    dismiss()
                                }
                            }) {
                                Text(String(format: String.localized("Contribution.RemindLater"), activity.snoozeInterval))
                                    .padding()
                                    .frame(maxWidth: .infinity)
                            }.foregroundColor(Color.accentColor)
                                .background(Color.accentColor.opacity(0.15))
                                .cornerRadius(12, antialiased: true)
                        }

                        Button(action: {
                            Task {
                                await skip(reminder)
                                dismiss()
                            }
                        }) {
                            Text("Contribution.Skip")
                                .padding()
                                .frame(maxWidth: .infinity)
                        }.foregroundColor(Color.accentColor)
                            .background(Color(.tertiarySystemFill))
                            .cornerRadius(12, antialiased: true)
                    }.font(.title3).padding()
                case .update(let contribution):
                    VStack {
                        Button(action: {
                            Task {
                                await updateContribution(contribution)
                                dismiss()
                            }
                        }) {
                            Text("Update")
                                .padding()
                                .font(.title3)
                                .frame(maxWidth: .infinity)
                        }.foregroundColor(Color.white)
                            .background(Color.accentColor)
                            .opacity(1.0)
                            .cornerRadius(12, antialiased: true)
                    }.padding()
                }
            }.toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                    }
                }
            }
        }
    }

    @discardableResult
    private func createContribution(_ reminder: Reminder) async -> Contribution? {
        let newItem = Contribution(context: viewContext)
        newItem.score = score
        newItem.date = date
        newItem.note = note
        newItem.createdAt = Date()
        newItem.updatedAt = Date()
        newItem.activityId = activity.id
        newItem.activity = activity
        
        do {
            try viewContext.save()
            if Calendar.current.isDateInToday(reminder.date) {
                appDelegate.notification?.removePendingNotificationRequests(withIdentifiers: [reminder.id])
                try activity.updateReminderIfNeeded(reminder.date, context: viewContext)
                try await appDelegate.notification?.addNotification(activity: activity, context: viewContext)
            }
            return newItem
        } catch {
            print("[UI][Error] \(error)")
            return nil
        }
    }

    func updateContribution(_ contribution: Contribution) async {
        do {
            contribution.date = date
            contribution.note = note
            try viewContext.save()
        } catch {
            print("[UI][Error] \(error)")
        }
    }

    func remindLater(_ reminder: Reminder) async {
        do {
            appDelegate.notification?.removePendingNotificationRequests(withIdentifiers: [reminder.id])
            let d = Date().minutesAfter(Int(activity.snoozeInterval))
            try await appDelegate.notification?.addNotification(at: d, activity: activity, context: viewContext)
        } catch {
            print("[UI][Error] \(error)")
        }
    }

    func skip(_ reminder: Reminder) async {
        do {
            appDelegate.notification?.removePendingNotificationRequests(withIdentifiers: [reminder.id])
            try activity.updateReminderIfNeeded(reminder.date, context: viewContext)
            try await appDelegate.notification?.addNotification(activity: activity, context: viewContext)
        } catch {
            print("[UI][Error] \(error)")
        }
    }

    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    ContributionEditView(
        activity: Activity(context: PersistentContainer.shared.viewContext),
        activities: [],
        action: .update(Contribution(context: PersistentContainer.shared.viewContext))
    )
}
