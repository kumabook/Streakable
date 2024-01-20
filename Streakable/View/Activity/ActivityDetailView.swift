//
//  ActivityDetailView.swift
//  Streakable
//
//  Created by Hiroki Kumamoto on 2024/01/05.
//

import SwiftUI

struct ActivityDetailView: View {
    @State private var editing: Bool = false
    var activity: Activity
    var streak: Streak
    var calendar: ContribCalendar

    var body: some View {
        List {
            Section("RemindsAt") {
                HStack {
                    Image(systemName: "alarm").font(.callout)
                    if let date = activity.remindsAt?.asActivityDateString {
                        Text(date)
                            .font(.body)
                            .lineLimit(1)
                    }
                    if let s = activity.reccurenceText {
                        Text(s)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(Color(.white))
                            .cornerRadius(12)
                            .lineLimit(1)
                            .padding(EdgeInsets(top: 4, leading: 8, bottom: 4, trailing: 8))
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.red)
                            )
                    }
                }
                if activity.snoozeInterval > 0 {
                    HStack {
                        Image(systemName: "speaker.zzz").font(.callout)
                        Text(String(format: NSLocalizedString("Every %d minutes", comment: ""), activity.snoozeInterval))
                    }
                }
            }
            if let note = activity.note {
                Section("Note") {
                    Text(note)
                }
            }
            Section() {
                NavigationLink {
                    ContributionListView(activity: activity)
                } label: {
                    HStack {
                        Text("Contributions")
                        Spacer()
                        Text("\(streak.contribution)")
                    }
                }
                HStack {
                    Text("Scores")
                    Spacer()
                    Text("\(streak.score)")
                    Spacer().frame(width: 18)
                }
                HStack {
                    Text("CurrentStreak")
                    Spacer()
                    Text("\(streak.current)")
                    Spacer().frame(width: 18)
                }
                HStack {
                    Text("LongestStreak")
                    Spacer()
                    Text("\(streak.longest)")
                    Spacer().frame(width: 18)
                }
                ContributionCalendarView(value: calendar)
            }
        }.toolbar {
            ToolbarItem {
                Button(action: { editing = true }) {
                    Label("Edit", systemImage: "square.and.pencil")
                }
            }
        }.sheet(isPresented: $editing, content: {
            ActivityEditView(activity: activity)
        }).navigationTitle(activity.title ?? "Activity")
    }
}

#Preview {
    ActivityDetailView(
        activity: Activity(context: PersistentContainer.shared.viewContext),
        streak: Streak(),
        calendar: ContribCalendar(date: Date())
    )
}
