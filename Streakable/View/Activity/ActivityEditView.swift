//
//  ActivityEditView.swift
//  Streakable
//
//  Created by Hiroki Kumamoto on 2022/12/31.
//

import SwiftUI

struct ActivityEditView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var appDelegate: AppDelegate
    @State private var confirmingDelete: Bool = false

    private var activity: Activity? = nil
    private var priority: Double = 0
    @State private var title: String = ""
    @State private var note: String = ""
    @State private var remindsAt: Date = Date(timeIntervalSinceNow: 60 * 60 * 1)
    @State private var recurrence: Recurrence = .daily
    @State private var weekdays: [Weekday] = []
    @State private var days: [Day] = []
    @State private var snoozeInterval: Int64 = 60

    init(priority: Double) {
        self.priority = priority
    }

    init(activity: Activity) {
        self.activity = activity
        self.priority = activity.priority
        _title = State(initialValue: activity.title ?? "")
        _note = State(initialValue: activity.note ?? "")
        _remindsAt = State(initialValue: activity.remindsAt ?? Date())
        _recurrence = State(initialValue: Recurrence(rawValue: activity.recurrence ?? "") ?? .daily)
        _snoozeInterval = State(initialValue: activity.snoozeInterval)

        switch recurrence {
        case .weekly:
            _weekdays = State(initialValue: activity.weekDays)
        case .monthly:
            _days = State(initialValue: activity.days)
        default:
            break
        }
    }

    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField("Title", text: $title)
                        .textFieldStyle(.plain)
                    PlaceHolderTextEditor(text: $note, placeholder: "Note")
                        .font(.callout)
                }
                Section {
                    Picker(
                        selection: $recurrence,
                        label: HStack {
                            Image(systemName: "repeat")
                            Text("Recurrence")
                        },
                        content: {
                            ForEach(Recurrence.allCases,  id: \.self) {
                                Text($0.title).tag($0)
                            }
                        }
                    )
                    switch recurrence {
                    case .weekly:
                        MultiSelector(
                            label: HStack {
                                Image(systemName: "calendar")
                                Text("Weekdays")
                            },
                            options: Weekday.allCases,
                            selected: $weekdays
                        )
                    case .monthly:
                        MultiSelector(
                            label: HStack {
                                Image(systemName: "calendar")
                                Text("Days")
                            },
                            options: Day.allCases,
                            selected: $days
                        )
                    default:
                        EmptyView()
                    }
                }
                Section {
                    DatePicker(selection: $remindsAt, displayedComponents: [.hourAndMinute]) {
                        HStack {
                            Image(systemName: "alarm")
                            Text("RemindsAt")
                        }
                    }
                }
                Section {
                    Picker(
                        selection: $snoozeInterval,
                        label: HStack {
                            Image(systemName: "speaker.zzz")
                            Text("SnoozeInterval")
                        },
                        content: {
                            ForEach(minutesChoices(), id: \.self) {
                                if $0 == 0 {
                                    Text("None")
                                } else {
                                    Text(String(format: NSLocalizedString("Every %d minutes", comment: ""), $0))
                                }
                            }
                        }
                    )
                }
            }.toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: { 
                        Task {
                            if let activity = activity {
                                await updateActivity(activity)
                            } else {
                                await createActivity()
                            }
                            dismiss()
                        }
                    }) {
                        if activity != nil {
                            Text("Update")
                        } else {
                            Text("Create")
                        }
                    }
                }
                if activity != nil {
                    ToolbarItem(placement: .bottomBar) {
                        Button(action: {
                            confirmingDelete = true
                        }) {
                            Text("Delete").foregroundColor(Color.red)
                        }
                    }
                }
            }.confirmationDialog("Activity.Delete.ConfirmTitle", isPresented: $confirmingDelete, titleVisibility: .hidden) {
                Button("Activity.Delete.ConfirmButton", role: .destructive) {
                    guard let activity = activity else { return }
                    Task { 
                        await deleteActivity(activity)
                        dismiss()
                    }
                }
                Button("Cancel", role: .cancel, action: {})
            } message: {
                Text("Activity.Delete.ConfirmMessage")
            }
        }
    }

    var recurrenceDetail: String? {
        switch recurrence {
        case .weekly:
            return weekdays.map { $0.rawValue }.joined(separator: ",")
        case .monthly:
            return days.map { String($0.date) }.joined(separator: ",")
        default:
            return nil
        }
    }

    private func createActivity() async {
        let newItem = Activity(context: viewContext)
        newItem.id = UUID()
        newItem.title = title
        newItem.note = note
        newItem.recurrence = recurrence.rawValue
        newItem.recurrenceDetail = recurrenceDetail
        newItem.snoozeInterval = snoozeInterval
        newItem.createdAt = Date()
        newItem.updatedAt = Date()
        do {
            try viewContext.save()
            try await appDelegate.notification?.addNotification(activity: newItem, context: viewContext)
        } catch {
            print("[UI][Error] \(error)")
        }
    }
    
    private func updateActivity(_ activity: Activity) async {
        activity.title = title
        activity.note = note
        activity.priority = priority
        activity.snoozeInterval = snoozeInterval
        activity.updatedAt = Date()

        if activity.recurrence != recurrence.rawValue || activity.recurrenceDetail != recurrenceDetail {
            activity.recurrence = recurrence.rawValue
            activity.recurrenceDetail = recurrenceDetail
            activity.remindsAt = remindsAt.yesterday
            activity.remindsAt = activity.calcNextRemindsAt(Date())
        } else {
            activity.remindsAt = remindsAt
        }
        do {
            try viewContext.save()
            try await appDelegate.notification?.addNotification(activity: activity, context: viewContext)
        } catch {
            print("[UI][Error] \(error)")
        }
    }

    private func deleteActivity(_ activity: Activity) async {
        do {
            viewContext.delete(activity)
            try viewContext.save()
            await appDelegate.notification?.removeNotification(activity: activity)
        } catch {
            print("[UI][Error] \(error)")
        }
    }

    private func dismiss() {
        presentationMode.wrappedValue.dismiss()
    }
}

private func minutesChoices() -> [Int64] {
    return [
        0, 5, 10, 15, 20, 25, 30, 40, 50, 60, 90, 120, 180
    ]
}

struct ActivityEditView_Previews: PreviewProvider {
    static var previews: some View {
        ActivityEditView(priority: 0)
    }
}

extension String: Identifiable {
    public var id: String {
        return self
    }
}
