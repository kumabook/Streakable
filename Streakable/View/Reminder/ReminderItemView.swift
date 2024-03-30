//
//  ReminderItemView.swift
//  Streakable
//
//  Created by Hiroki Kumamoto on 2023/01/01.
//

import SwiftUI

struct ReminderItemView: View {
    var reminder: Reminder

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "alarm")
                    Text(date.asContributionTimeString)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    if let title = intervalTitle {
                        HStack {
                            Image(systemName: "speaker.zzz").padding([.trailing], -6)
                            Text(title).minimumScaleFactor(0.75).lineLimit(1)
                        }.font(.body).foregroundColor(.red)
                    }
                    Spacer()
                }
                Text(reminder.activity.title ?? "No title")
                    .bold()
                    .foregroundColor(.secondary)
            }
        }
    }

    var date: Date {
        return reminder.date
    }

    var intervalTitle: String? {
        guard
            let interval = reminder.activity.remindsAt?.interval(to: Date()),
            interval > 0,
            let str = interval.reminderIntervalString
        else { return nil }
        return "+\(str)"
    }
}

struct ReminderItemView_Previews: PreviewProvider {
    static var previews: some View {
        ReminderItemView(
            reminder: Reminder(
                id: "0",
                date: Date(),
                activity: Activity.preview(context: PersistentContainer.shared.viewContext)
            )
        )
    }
}
